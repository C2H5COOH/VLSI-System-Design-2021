`include "../../include/Control.svh"

module ALU (
    input               [4:0]   aluOp,
    input  signed       [31:0]  src1,src2,
    output logic signed [31:0]  result,
    output logic                branch
);

logic [31:0]  src1_unsigned, src2_unsigned;
assign src1_unsigned = src1;
assign src2_unsigned = src2;

always_comb begin : alu_operation
    case(aluOp)
        `ALU_ADD: result = src1 +  src2;
        `ALU_SUB: result = src1 -  src2;
        `ALU_SLL: result = src1 << src2[4:0];
        `ALU_SLT: result = (src1 < src2)? 32'd1 : 32'b0;
        `ALU_SLTU: result = (src1_unsigned < src2_unsigned)? 32'd1 : 32'b0;
        `ALU_XOR: result = src1 ^ src2; 
        `ALU_SRL: result = src1_unsigned >>  src2[4:0];
        `ALU_SRA: result = src1          >>> src2[4:0];
        `ALU_OR : result = src1 | src2;
        `ALU_AND: result = src1 & src2;
        `ALU_JAL: result = src1 + 4;                                    //pc+4 //optimizable
        `ALU_LUI: result = src2;
        default:  result = 32'd0;
    endcase
end

always_comb begin
    case(aluOp)
        `ALU_BEQ : branch = (src1 == src2)? 1'b1 : 1'b0;
        `ALU_BNE : branch = (src1 != src2)? 1'b1 : 1'b0;
        `ALU_BLT : branch = (src1 <  src2)? 1'b1 : 1'b0;
        `ALU_BGE : branch = (src1 >= src2)? 1'b1 : 1'b0;
        `ALU_BLTU : branch = (src1_unsigned < src2_unsigned)? 1'b1 : 1'b0;
        `ALU_BGEU : branch = (src1_unsigned >= src2_unsigned)? 1'b1 : 1'b0;
        default : branch = 1'b0;
    endcase
end
    
endmodule
