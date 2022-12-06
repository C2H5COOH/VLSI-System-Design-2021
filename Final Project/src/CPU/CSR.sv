`include "CPU_def.svh"
module CSR(
    input               clk, 
    input               rst,
    input               commitInst,
    input               stall,    
    input               is_MRET,
    input               is_WFI,
    input               extern_interrupt,
    input               csr_src,
    input [11:0]        csr_long_idx,
    input [31:0]        EX_alu_res,
    input [31:0]        pc4,
    output logic [31:0] csr_out,
    output logic [31:0] mtvec_out,
    output logic [31:0] mepc_out,
    output logic        csr_fw,
    output logic [31:0] alu_res_mask_reg,
    output logic        wfi_stall
);

logic           wfi_state;
logic           interrupt_take;
logic [3:0]     csr_rd_idx, csr_wr_idx;
logic [31:0]    alu_res_mask;
logic [31:0]    cycleNum, instNum;
logic [31:0]    CSR_RF [0:9];

localparam  mstatus     = 12'h300;
localparam  mie         = 12'h304;
localparam  mtvec       = 12'h305;
localparam  mepc        = 12'h341;
localparam  mip         = 12'h344;
localparam  mcycle      = 12'hb00;
localparam  minstret    = 12'hb02;
localparam  mcycleh     = 12'hb80;
localparam  minstreth   = 12'hb82;

localparam  mstatus_s     = 4'd1;
localparam  mie_s         = 4'd2;
localparam  mtvec_s       = 4'd3;
localparam  mepc_s        = 4'd4;
localparam  mip_s         = 4'd5;
localparam  mcycle_s      = 4'd6;
localparam  minstret_s    = 4'd7;
localparam  mcycleh_s     = 4'd8;
localparam  minstreth_s   = 4'd9;

localparam  MIE         = 32'd3;
localparam  MPIE        = 32'd7;
localparam  MEIP        = 32'd11;
localparam  MEIE        = 32'd11;

localparam mstatus_mask = 32'b0000000000000000_0001100010001000;
localparam mie_mask     = 32'h0000_0800;

localparam NORMAL_s = 1'b0;
localparam WFI_s    = 1'b1;

assign mtvec_out = CSR_RF[mtvec_s];
assign mepc_out = CSR_RF[mepc_s];

assign csr_rd_idx = get_short_idx(csr_long_idx);

// WFI stall control
always_ff @(posedge clk) begin
    if(rst)
        wfi_state <= NORMAL_s;
    else begin
        case(wfi_state)
            NORMAL_s:begin
                if(is_WFI)
                    wfi_state <= WFI_s;
            end            
            WFI_s: begin
                if(interrupt_take)
                    wfi_state <= NORMAL_s;
            end
        endcase
    end
end

assign wfi_stall = wfi_state;

always_comb begin
    unique case(csr_wr_idx)
        mstatus_s:
            alu_res_mask = EX_alu_res & mstatus_mask;
        mie_s:
            alu_res_mask = EX_alu_res & mie_mask;
        mepc_s:
            alu_res_mask = EX_alu_res;
        default:
            alu_res_mask = 32'd0;
    endcase
end

always_ff @(posedge clk) begin
    if(rst)
        alu_res_mask_reg <= 32'd0;
    else if(!stall)
        alu_res_mask_reg <= alu_res_mask;
end

// read operation is at ID stage, write operation is at EX
always_ff @(posedge clk) begin
    if(rst)
        csr_wr_idx <= 4'd0;
    else if(!stall)
        csr_wr_idx <= csr_rd_idx;
end

assign csr_fw = (csr_wr_idx == csr_rd_idx)? 1'b1 : 1'b0;

always_comb begin
    if(CSR_RF[mie_s][MEIE]) // interrupt enable
        interrupt_take = extern_interrupt;
    else
        interrupt_take = 1'b0;
end

// read CSR RegisterFile
always_ff @(posedge clk) begin
    if (rst) begin
        csr_out <= 32'd0;
    end
    else if (!stall) begin
        csr_out <=  CSR_RF[csr_rd_idx];
    end
end

always_ff @(posedge clk) begin
    if (rst)
        CSR_RF[mie_s] <= 32'd0;
    else if(csr_wr_idx == mie_s && csr_src == `CSRFromALU && !stall)
        CSR_RF[mie_s] <= alu_res_mask;
end

always_ff @(posedge clk) begin
    if (rst) begin
        CSR_RF[0] <= 32'd0;
        CSR_RF[mip_s] <= 32'd0;
        // CSR_RF[mtvec_s] <= 32'h0000_015c; // addr of ISR
        CSR_RF[mtvec_s] <= 32'h0001_0000; // addr of ISR
    end
end

always_ff @(posedge clk) begin    
    if(rst)
        CSR_RF[mstatus_s] <= 32'd0;
    else begin
        if(is_MRET) begin
            CSR_RF[mstatus_s][MPIE] <= 1'b1;
            CSR_RF[mstatus_s][MIE] <= CSR_RF[mstatus_s][MPIE];
        end
        else if (interrupt_take) begin   
            CSR_RF[mstatus_s][MPIE] <= CSR_RF[mstatus_s][MIE];
            CSR_RF[mstatus_s][MIE] <= 1'b0;
        end
        else if (csr_wr_idx == mstatus_s && csr_src == `CSRFromALU && !stall) begin
            CSR_RF[mstatus_s] <= alu_res_mask;
        end
    end
end

always_ff @(posedge clk) begin
    if(rst)
        CSR_RF[mepc_s] <= 32'd0;
    else if(interrupt_take && wfi_state == WFI_s)
        CSR_RF[mepc_s] <= pc4;
    else if (csr_wr_idx == mepc_s && csr_src == `CSRFromALU && !stall)
        CSR_RF[mepc_s] <= alu_res_mask;
end

function [3:0] get_short_idx;
    input [11:0] long_idx;
    begin
        unique case(long_idx)
            mstatus:
                get_short_idx = mstatus_s;
            mie:
                get_short_idx = mie_s;
            mtvec:
                get_short_idx = mtvec_s;
            mepc:
                get_short_idx = mepc_s;
            mip:
                get_short_idx = mip_s;
            mcycle:
                get_short_idx = mcycle_s;
            minstret:
                get_short_idx = minstret_s;
            mcycleh:
                get_short_idx = mcycleh_s;
            minstreth:
                get_short_idx = minstreth_s;
            default:
                get_short_idx = 4'd0;
        endcase
    end
endfunction

// count cycle and instruction

always_ff @(posedge clk) begin
    if (rst) begin
        CSR_RF[mcycle_s] <= 32'd0;
        CSR_RF[mcycleh_s] <= 32'd0;
    end
    else begin
        CSR_RF[mcycle_s] <= CSR_RF[mcycle_s] + 32'd1;
        if(&CSR_RF[mcycle_s]) begin  // overflow
            CSR_RF[mcycleh_s] <= CSR_RF[mcycleh_s] + 32'd1;
        end
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        CSR_RF[minstret_s] <= 32'd0;
        CSR_RF[minstreth_s] <= 32'd0;
    end
    else if (commitInst && !stall) begin
        CSR_RF[minstret_s] <= CSR_RF[minstret_s] + 32'd1;
        if(&CSR_RF[minstret_s]) begin  // overflow
            CSR_RF[minstreth_s] <= CSR_RF[minstreth_s] + 32'd1;
        end
    end
end

endmodule