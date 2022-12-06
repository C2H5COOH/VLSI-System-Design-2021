`include "PC.sv"

module IF (
    input                   clk,rst,

    input [31:0]            EXE_jumpBranchAddr,
    input                   EXE_jumpBranch,
    input                   ID_hazardStall,

    output logic [31:0]     instruction,
    output logic [31:0]     pc_reg,

    output [13:0]           IMIn,
    input  [31:0]           IMOut
);

logic [31:0] pcOut;
logic [31:0] pcAdd4;
assign pcAdd4 = pcOut + 4;

PC pc(
    .clk(clk), 
    .rst(rst),
    .pcAdd4(pcAdd4),
    .jumpBranchAddr(EXE_jumpBranchAddr),
    .pcOut(pcOut),
    .pcStall(ID_hazardStall),
    .pcSrc(EXE_jumpBranch)
);

//register suppose to be flushed when hazard or jump or branch
//since pc needs extra cycle to load new address
//instruction goes directly through register, since IM already needs a cycle to load

logic unknown_instruction;
always_ff @(posedge clk) begin
    if(rst) unknown_instruction <= 1'b1;
    else unknown_instruction <= 1'b0 ;
end

logic stall_reg;
always_ff @(posedge clk) begin
    if(rst) stall_reg <= 1'b0;
    else if(ID_hazardStall) stall_reg <= 1'b1;
    else stall_reg <= 1'b0;
end

logic jumpBranch_reg;
always_ff @(posedge clk) begin
    if(rst) jumpBranch_reg <= 1'b0;
    else if(EXE_jumpBranch) jumpBranch_reg <= 1'b1;
    else jumpBranch_reg <= 1'b0;
end

logic [31:0] instruction_for_stall;
always_ff @(posedge clk) begin
    if(rst) instruction_for_stall <= 32'd0;
    else instruction_for_stall <= IMOut;
end


//logic stall_reg;
//assign instruction = (ID_hazardStall || stall_reg || unknown_instruction)? 0 : IMOut;
always_comb begin
    if(unknown_instruction || jumpBranch_reg) instruction = 32'd0;
    else if(stall_reg) instruction = instruction_for_stall;
    else instruction = IMOut;
end 

/*always_ff @(posedge clk) begin
    if(rst) stall_reg <= 0;
    else stall_reg <= ID_hazardStall;
end*/



assign IMIn = pcOut[13:0] >> 2;

//logic regFlush;
//assign regFlush = EXE_jumpBranch || ID_hazardStall;

always_ff @( posedge clk )begin
    if(rst || EXE_jumpBranch)begin
        pc_reg <= 32'd0;
    end
    else if(ID_hazardStall)begin
        pc_reg <= pc_reg;
    end
    else begin
        pc_reg <= pcOut;
    end
end
    
endmodule 
