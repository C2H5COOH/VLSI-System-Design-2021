//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "cache_def.svh"
`include "data_array_wrapper.sv"
`include "tag_array_wrapper.sv"
module L1C_inst(
    input clk,
    input rst,
    // Core to cache
    input [`DATA_BITS-1:0] core_addr,
    input core_req,
    // cache to CPU wrapper
    input [`AXI_DATA_BITS-1:0] I_out,
    input I_wait,
    input I_valid,  // return data is valid
    // cache to core
    output logic [`DATA_BITS-1:0] core_out,
    output logic core_wait,
    // CPU wrapper to cache
    output logic I_req,
    output logic [`AXI_ADDR_BITS-1:0] I_addr
);

    logic [`CACHE_INDEX_BITS-1:0] index;
    logic [`CACHE_DATA_BITS-1:0] DA_out;
    logic [`CACHE_DATA_BITS-1:0] DA_in;
    logic [`CACHE_WRITE_BITS-1:0] DA_write;
    logic DA_read;
    logic [`CACHE_TAG_BITS-1:0] TA_out;
    logic [`CACHE_TAG_BITS-1:0] TA_in;
    logic TA_write;
    logic TA_read;
    logic [`CACHE_LINES-1:0] valid;

    //--------------- complete this part by yourself -----------------//

    localparam IDLE       = 2'd0;
    localparam READ       = 2'd1;
    localparam READ_DATA  = 2'd2;

    logic                       hit, read_miss;
    logic                       ca_update;  
    logic                       read_finish;
    logic                       valid_reg;
    logic                       read_cnt;
    logic [1:0]                 state;
    logic [1:0]                 next_state;
    logic [`AXI_DATA_BITS-1:0]  DA_in64;

    logic [`AXI_ADDR_BITS-1:0]  core_addr_now,
                                core_addr_reg;

    always_comb begin
        case (state)
        IDLE: begin
            if (core_req) begin
                next_state = READ;
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
                next_state = READ_DATA;
            end
        end
        default : begin // READ_DATA
            if (read_finish && I_valid) begin
                next_state = IDLE;
            end
            else begin
                next_state = READ_DATA;
            end
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

    assign index        = core_addr_now[9:4];
    assign ca_update    = (state == READ_DATA);
    assign read_miss    = ((state == READ) && ~hit);

    assign DA_read      = ~ca_update; 

    assign TA_read      = ~ca_update; 
    assign TA_in        = core_addr_now[31:10];
    assign TA_write     = ~ca_update;  // low active

    always_comb begin
        if(~TA_write) begin
            hit = 1'b0;
        end
        else begin
            hit = (TA_out == core_addr_reg[31:10] & valid_reg);
        end
    end

    always_comb begin
        if(read_miss || ca_update) begin
            I_addr = {core_addr_now[31:4], read_cnt, 3'd0};
        end
        else begin
            I_addr = core_addr_now;
        end
    end

    always_comb begin
        unique case (state)
        IDLE: begin
            if(core_req) begin
                core_wait = 1'b1;
            end
            else begin
                core_wait = I_wait;
            end
        end
        READ: begin
            if (hit) begin
                core_wait = 1'b0;
            end
            else  begin
                core_wait = 1'b1;
            end
        end
        default: begin
            if(next_state == READ) begin
                core_wait = 1'b0;
            end
            else begin
                core_wait = 1'b1;
            end
        end        
        endcase
    end

    always_comb begin
        unique case (state)
        IDLE: begin
            I_req = 1'b0;
        end
        READ: begin
            if (hit) begin
                I_req = 1'b0;
            end
            else begin
                I_req = 1'b1;
            end
        end
        default: begin // READ_DATA
            I_req = 1'b1;   
        end
        endcase
    end

    always_ff @( posedge clk or posedge rst) begin
        if(rst) begin
            read_cnt <= 1'b0;
        end
        else if(next_state == READ || state == READ) begin
            read_cnt <= 1'b0;
        end
        else if(state == READ_DATA && I_valid) begin
            read_cnt <= read_cnt + 1'b1;
        end
    end

    assign read_finish = (read_cnt == 1'b1);

    always_comb begin
        if (state == READ_DATA) begin
            unique case (I_addr[3])
            1'b0: begin
                DA_write = {8'hff, 8'h0}; 
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
    assign DA_in64 = I_out;
    always_comb begin
        case (I_addr[3])
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
            core_out = DA_out[31:0];
        end
        2'b01: begin
            core_out = DA_out[63:32];
        end
        2'b10: begin
            core_out = DA_out[95:64];
        end
        2'b11: begin
            core_out = DA_out[127:96];
        end
        endcase
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
        if(core_req && next_state != READ_DATA && state != READ_DATA) begin
            core_addr_reg <= core_addr;
        end
    end

    always_comb begin 
        if(core_req && next_state != READ_DATA && state != READ_DATA) begin
            core_addr_now = core_addr;
        end
        else begin
            core_addr_now = core_addr_reg;
        end
    end

    // compute hit rate
    logic         compute_hit_rate;
    logic [31:0]  n_hit, n_total;

    assign compute_hit_rate = (state == READ);

    always_ff @( posedge clk or posedge rst) begin
        if(rst) begin
            n_total <= 32'd0;
            n_hit <= 32'd0;
        end
        else if(compute_hit_rate) begin
            n_total <= n_total + 1;
            if(hit) begin
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

