`include "PC.sv"
// `include "CPU/PC.sv"

module IF (
    input                   clk,rst,

    input [31:0]            EXE_jumpBranchAddr,
    input                   EXE_jumpBranch,
    input                   ID_hazardStall,

    output logic [31:0]     instruction_reg,
    output logic [31:0]     pc_reg,

    output logic [31:0]     IM_addr,
    output logic            IM_read,
    input  [31:0]           IM_instruction,

    input                   AXI_IF_stall,
    input                   AXI_MEM_stall
);

logic [31:0] pcOut;
logic [31:0] pcAdd4;
assign pcAdd4 = pcOut + 4;

logic jumpBranch_reg;
logic [31:0] jb_addr_reg;

PC pc(
    .clk(clk), 
    .rst(rst),

    .pcAdd4(pcAdd4),
    .jumpBranchAddr(jb_addr_reg),

    .pcOut(pcOut),

    .hazard_stall(ID_hazardStall),
    .AXI_IF_stall(AXI_IF_stall),
    .jump_branch(jumpBranch_reg),
    .AXI_MEM_stall(AXI_MEM_stall)
);


always_ff @(posedge clk) begin
    if(rst) jumpBranch_reg <= 1'b0;
    else if(EXE_jumpBranch) jumpBranch_reg <= 1'b1;
    else if(~AXI_IF_stall) jumpBranch_reg <= 1'b0;//deasserted by AXI_IF_stall
end


always_ff @(posedge clk) begin
    if(rst) jb_addr_reg <= 'b0;
    else if(EXE_jumpBranch) jb_addr_reg <= EXE_jumpBranchAddr;
    else if(~AXI_IF_stall) jb_addr_reg <= 32'd0;//deasserted by AXI_IF_stall
end

//register suppose to be flushed when hazard or jump or branch
//since pc needs extra cycle to load new address
//instruction goes directly through register, since IM already needs a cycle to load

logic init;
always_ff @(posedge clk) begin
    if(rst) init <= 1'b1;
    else init <= 1'b0 ;
end

// logic stall_reg;
// always_ff @(posedge clk) begin
//     if(rst) stall_reg <= 1'b0;
//     else if(ID_hazardStall) stall_reg <= 1'b1;
//     else stall_reg <= 1'b0;
// end

// logic [31:0] instruction_for_stall;
// always_ff @(posedge clk) begin
//     if(rst) instruction_for_stall <= 32'd0;
//     else instruction_for_stall <= IM_instruction;
// end

//IM_addr
always_comb begin
    //if(EXE_jumpBranch) IM_addr = EXE_jumpBranchAddr;
    //else IM_addr = pcOut[13:0];//>>2
    IM_addr = pcOut;
end

always_ff @(posedge clk) begin
    if(rst) IM_read <= 1'b0;
    else    IM_read <= 1'b1;
end

// always_comb begin
//     if(AXI_IF_stall) instruction = 32'd0;
//     //else if(stall_reg) instruction = instruction_for_stall;
//     else instruction = IM_instruction;
// end 

always_ff @(posedge clk) begin
    if(rst || AXI_IF_stall || init || jumpBranch_reg)begin
        pc_reg          <= 32'b0;
        instruction_reg <= 32'b0;
    end
    else begin
        if(AXI_MEM_stall || ID_hazardStall)begin
            pc_reg          <= pc_reg;
            instruction_reg <= instruction_reg;
        end
        else begin
            pc_reg          <= pcOut;
            instruction_reg <= IM_instruction;
        end
    end
end

//assign IM_addr = pcOut[13:0] >> 2;

/*always_ff @( posedge clk )begin
    if(rst || EXE_jumpBranch)begin
        pc_reg <= 32'd0;
    end
    else if(ID_hazardStall)begin
        pc_reg <= pc_reg;
    end
    else begin
        pc_reg <= pcOut;
    end
end*/
    
endmodule 
