//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_data.sv
// Description: L1 Cache for data
// Version:     0.1
//================================================
`include "cache_def.svh"
`include "data_array_wrapper.sv"
`include "tag_array_wrapper.sv"
module L1C_data(
    input clk,
    input rst,
    // Core to cache
    input [`AXI_ADDR_BITS-1:0] core_addr,
    input core_req,
    input core_write,
    input [`DATA_BITS-1:0] core_in,
    input [`CACHE_TYPE_BITS-1:0] core_type,
    input [3:0] core_strobe,
    // cache to CPU wrapper
    input [`AXI_DATA_BITS-1:0] D_out,
    input D_wait,
    input D_valid,  // return data is valid
    // cache to core
    output logic [`DATA_BITS-1:0] core_out,
    output logic core_wait,
    // CPU wrapper to cache
    output logic                        D_req,
    output logic [`AXI_ADDR_BITS-1:0]   D_addr,
    output logic                        D_write,
    output logic [`AXI_DATA_BITS-1:0]   D_in,
    output logic [`CACHE_TYPE_BITS-1:0] D_type,
    output logic [`AXI_STRB_BITS-1:0]   D_strobe,
    output logic                        D_burst
);

    logic [`CACHE_INDEX_BITS-1:0]   index;
    logic [`CACHE_DATA_BITS-1:0]    DA_out;
    logic [`CACHE_DATA_BITS-1:0]    DA_in;
    logic [`CACHE_WRITE_BITS-1:0]   DA_write;
    logic                           DA_read;
    logic [`CACHE_TAG_BITS-1:0]     TA_out;
    logic [`CACHE_TAG_BITS-1:0]     TA_in;
    logic                           TA_write;
    logic                           TA_read;
    logic [`CACHE_LINES-1:0]        valid;

    //--------------- complete this part by yourself -----------------//

    localparam IDLE             = 3'd0;
    localparam READ             = 3'd1;
    localparam READ_TWO         = 3'd2;
    localparam READ_UNCACHE     = 3'd3;
    localparam WRITE            = 3'd4;
    localparam WRITE_UNCACHE    = 3'd5;

    logic                       hit, read_miss;
    logic                       ca_update;  
    logic                       read_finish;
    logic                       valid_reg;
    // logic             accept_new_req;
    logic                       core_read_req;
    logic                       read_cnt;
    logic [2:0]                 state, next_state;
    logic [`AXI_DATA_BITS-1:0]  DA_in64;
    logic [`DATA_BITS-1:0]      DA_out32;
    
    logic                       core_write_now;
    logic [3:0]                 core_strobe_now;
    logic [`DATA_BITS-1:0]      core_in_now;
    logic [`DATA_BITS-1:0]      core_addr_now;
    logic [`CACHE_TYPE_BITS-1:0]core_type_now;
    // logic                   core_req_reg;
    logic                       core_write_reg;
    logic [3:0]                 core_strobe_reg;
    logic [`DATA_BITS-1:0]      core_in_reg;
    logic [`DATA_BITS-1:0]      core_addr_reg;
    logic [`CACHE_TYPE_BITS-1:0]core_type_reg;

    // sensor and PLIC cannot be cache
    logic cacheable;
    assign cacheable = (core_addr[31:16] != 16'h1000 && !core_addr[30]);

    always_comb begin
        case (state)
        IDLE: begin
            if (core_req) begin
                if (core_write) begin
                    next_state = WRITE;
                end
                else if (~cacheable) begin
                    next_state = READ_UNCACHE;
                end
                else begin
                    next_state = READ;
                end
            end 
            else begin
                next_state = IDLE;
            end
        end
        READ: begin
            if (hit) begin
                next_state = IDLE;
            end
            else begin
                next_state = READ_TWO;
            end
        end
        READ_TWO: begin
            if (read_finish && D_valid) begin
                next_state = IDLE;
            end
            else begin
                next_state = READ_TWO;
            end
        end
        READ_UNCACHE: begin
            next_state = IDLE;
        end
        WRITE, WRITE_UNCACHE: begin
            next_state = IDLE;
        end
        default: begin
            next_state = IDLE;
        end
        endcase
    end

    always_ff @(posedge clk or posedge rst)begin
        if(rst) begin
            state <= IDLE; 
        end
        else begin
            state <= next_state;
        end
    end

    assign index      = core_addr_now[9:4];
    assign ca_update  = (state == READ_TWO || (state == WRITE && hit));
    assign read_miss  = (state == READ && ~hit);
    
    assign D_write  = core_write_now;
    assign D_in     = (core_addr_now[2]) ? {core_in_now, 32'd0} : {32'd0, core_in_now};
    assign D_type   = core_type_now;
    assign D_strobe = (core_addr_now[2]) ? {core_strobe_now, 4'hf} : {4'hf, core_strobe_now};

    assign DA_read  = ~ca_update; 

    assign TA_read  = (state != READ_TWO); 
    assign TA_in    = core_addr_now[31:10];
    assign TA_write = ~(state == READ_TWO);  // low active

    always_comb begin
        if(~TA_write) begin
            hit = 1'b0;
        end
        else begin
            hit = (TA_out == core_addr_reg[31:10] & valid_reg);
        end
    end

    always_comb begin
        if ((read_miss || ca_update) && !core_write_now) begin
            D_addr = {core_addr_now[31:4], read_cnt, 3'd0};
        end
        else begin
            D_addr = core_addr_now;
        end
    end

    assign core_read_req = core_req & ~core_write;

    always_comb begin
        case (state)
        IDLE: begin
            if(core_read_req) begin
                if(cacheable) begin
                    core_wait = 1'b1;
                end
                else begin
                    core_wait = 1'b0;
                end
            end          
            else begin
                core_wait = D_wait;
            end
        end
        READ: begin
            if (hit) begin
                core_wait = 1'b0;
            end
            else begin
                core_wait = 1'b1;
            end
        end
        READ_TWO: begin
            if(next_state == IDLE) begin
                core_wait = 1'b0;
            end
            else begin
                core_wait = 1'b1;
            end
        end
        READ_UNCACHE: begin
            core_wait = 1'b0;
        end
        WRITE, WRITE_UNCACHE: begin
            if(core_req) begin
                core_wait = 1'b1;
            end
            else begin
                core_wait = 1'b0;
            end
        end
        default: begin
            core_wait = 1'b0;
        end
        endcase
    end

    always_comb begin
        case (state)
        IDLE: begin
            if(core_req & core_write) begin
                D_req = 1'b1;
            end
            else if (core_read_req) begin
                if(cacheable) begin
                    D_req = 1'b0;
                end
                else begin
                    D_req = 1'b1;
                end
            end   
            else begin
                D_req = 1'b0;
            end
        end
        READ:
            if (hit) begin
                D_req = 1'b0;
            end
            else begin
                D_req = 1'b1;
            end
        READ_TWO: begin
            D_req = 1'b1;
        end
        READ_UNCACHE: begin
            D_req = 1'b0;
        end
        WRITE, WRITE_UNCACHE: begin
            D_req = 1'b0;
        end
        default: begin
            D_req = 1'b0;
        end
        endcase
    end

    always_comb begin
        if(core_read_req && ~cacheable) begin
            D_burst = 1'b0;
        end
        else begin
            D_burst = 1'b1;
        end
    end

    always_ff @( posedge clk or posedge rst) begin
        if(rst) begin
            read_cnt <= 1'd0;
        end
        else if(state == READ || next_state == READ) begin
            read_cnt <= 1'd0;
        end
        else if(state == READ_TWO && D_valid) begin
            read_cnt <= read_cnt + 1'd1;
        end
    end

    assign read_finish = (read_cnt == 1'd1);

    always_comb begin
        if (state == WRITE && hit) begin
            unique case (core_addr_now[3:2])
            2'b00: begin
                DA_write = {12'hfff, core_strobe_now}; 
            end
            2'b01: begin
                DA_write = {8'hff, core_strobe_now, 4'hf}; 
            end
            2'b10: begin
                DA_write = {4'hf, core_strobe_now, 8'hff}; 
            end
            2'b11: begin
                DA_write = {core_strobe_now, 12'hfff}; 
            end
            endcase
        end 
        else if (state == READ_TWO) begin
            unique case (D_addr[3]) 
            1'b0: begin
                DA_write = {8'hff, 8'h00};
            end
            1'b1: begin
                DA_write = {8'h0, 8'hff};
            end
            endcase
        end
        else begin
            DA_write = 16'hffff;
        end
    end

    //Input data signal to DA
    always_comb begin
        if (state == READ_TWO) begin
            DA_in64 = D_out;
        end
        else if (D_addr[2]) begin
            DA_in64 = {core_in_now, 32'd0};
        end
        else begin
            DA_in64 = {32'd0, core_in_now};
        end
    end
    always_comb begin
        unique case (D_addr[3]) 
        1'b0: begin
            DA_in = {64'd0, DA_in64};
        end
        1'b1: begin
            DA_in = {DA_in64, 64'd0};
        end
        endcase
    end

    //Output data from DA
    always_comb begin
        case (core_addr_reg[3:2])
        2'b00: begin
            DA_out32 = DA_out[31:0];
        end
        2'b01: begin
            DA_out32 = DA_out[63:32];
        end
        2'b10: begin
            DA_out32 = DA_out[95:64];
        end
        2'b11: begin
            DA_out32 = DA_out[127:96];
        end
        endcase
    end

    always_comb begin
        if(state == READ_UNCACHE) begin
            core_out = D_out[31:0];
        end
        else begin
            core_out = DA_out32;
        end
    end

    //Valid array
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            valid <= {`CACHE_LINES{1'b0}};
        end
        else if (ca_update) begin
            valid[index] <= 1'b1;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_reg <= 1'b0;
        end
        else begin
            valid_reg <= valid[index];
        end
    end

    always_ff @( posedge clk ) begin 
        if(core_req && state == IDLE) begin
            core_addr_reg   <= core_addr;
            core_write_reg  <= core_write;
            core_in_reg     <= core_in;
            core_type_reg   <= core_type;
            core_strobe_reg <= core_strobe;
        end
    end

    always_comb begin 
        if(core_req && state == IDLE) begin
            core_addr_now   = core_addr;
            core_write_now  = core_write;
            core_in_now     = core_in;
            core_type_now   = core_type;
            core_strobe_now = core_strobe;
        end
        else begin
            core_addr_now   = core_addr_reg;
            core_write_now  = core_write_reg;
            core_in_now     = core_in_reg;
            core_type_now   = core_type_reg;
            core_strobe_now = core_strobe_reg;
        end
    end

    // compute hit rate
    logic         compute_hit_rate;
    logic [31:0]  n_hit, n_total;

    assign compute_hit_rate = (state == READ || state == WRITE || state == READ_UNCACHE);

    always_ff @( posedge clk or posedge rst) begin
        if(rst) begin
            n_total <= 32'd0;
            n_hit <= 32'd0;
        end
        else if(compute_hit_rate) begin
            n_total <= n_total + 1;
            if(state != READ_UNCACHE && hit) begin
                n_hit <= n_hit + 1;
            end
        end
    end
  
    data_array_wrapper DA(
        .A(index),
        .DO(DA_out),
        .DI(DA_in),
        .CK(clk),
        .WEB(DA_write),
        .OE(DA_read),
        .CS(1'b1)
    );
   
    tag_array_wrapper  TA(
        .A(index),
        .DO(TA_out),
        .DI(TA_in),
        .CK(clk),
        .WEB(TA_write),
        .OE(TA_read),
        .CS(1'b1)
    );

endmodule

