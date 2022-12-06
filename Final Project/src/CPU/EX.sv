`include "CPU_def.svh"

module EX (
    input               clk, 
    input               rst,
    input               stall,
    input [31:0]        PCFromID,
    input [31:0]        PC_4FromID,
    input [31:0]        rs1,
    input [31:0]        rs2FromID,
    input [31:0]        imm,
    input [3:0]         aluOp,
    input [2:0]         beuOp,
    input [1:0]         op1Sel,
    input [1:0]         op2Sel,
    input               LDSTSelFromID,
    input [1:0]         MEMLengthFromID,
    input [2:0]         WBSelFromID,
    input [4:0]         rdIdxFromID,
    input [1:0]         op1FwSel,
    input [1:0]         op2FwSel,
    input [31:0]        srcFromMEM,
    input [31:0]        srcFromWB,
    input               instValidFromID,
    input [31:0]        csr_from_CSR,    
    input [1:0]         bra_src_fromID,
    input               csr_fw,
    input [31:0]        alu_res_mask_reg,
    output logic        branchTaken,
    output logic [31:0] PC_4ToMEM,
    output logic [31:0] EX_alu_res,
    output logic [31:0] EX_alu_res_reg,
    output logic [31:0] rs2ToMEM,
    output logic        LDSTSelToMEM,
    output logic [1:0]  MEMLengthToMEM,
    output logic [2:0]  WBSelToMEM,
    output logic [4:0]  rdIdxToMEM,
    output logic [31:0] csr_toMEM,
    output logic        instValidToMEM,
    output logic [1:0]  bra_src_fromEX
);
logic [31:0] forwardedRS1, op1, forwardedRS2, op2, forwardedCSR;
logic preBranchTaken, branchTakenComb;

assign forwardedCSR = csr_from_CSR; // 2 cycle do 1 inst, no need to fw csr value

/* op1 select */
always_comb begin
    unique case (op1FwSel)
        `EXFromID: begin
            forwardedRS1 = rs1;
        end
        `EXFwFromEX: begin
            forwardedRS1 = EX_alu_res_reg;
        end
        `EXFwFromMEM: begin
            forwardedRS1 = srcFromMEM;
        end 
        `EXFwFromWB: begin
            forwardedRS1 = srcFromWB;
        end
    endcase
end
always_comb begin
    unique case (op1Sel)
        `Op1FromRs1:
            op1 = forwardedRS1;
        `Op1FromPC:
            op1 = PCFromID;
        `Op1FromCSR:
            op1 = forwardedCSR;
        `Op1FromZero:
            op1 = 32'd0;
    endcase
end

/* op2 select */
always_comb begin
    unique case (op2FwSel)
        `EXFromID: begin
            forwardedRS2 = rs2FromID;
        end
        `EXFwFromEX: begin
            forwardedRS2 = EX_alu_res_reg;
        end 
        `EXFwFromMEM: begin
            forwardedRS2 = srcFromMEM;
        end
        `EXFwFromWB: begin
            forwardedRS2 = srcFromWB;
        end
    endcase
end
always_comb begin
    unique case (op2Sel)
        `Op2FromRs2:
            op2 = forwardedRS2;
        `Op2FromImm:
            op2 = imm;
        `Op2FromRs1:
            op2 = forwardedRS1;
        default:
            op2 = 32'd0;
    endcase
end

/* ALU */
always_comb begin
    unique case (aluOp)
        `ADD:
            EX_alu_res = op1 + op2;
        `SLL:
            EX_alu_res = op1 << (op2[4:0]);
        `SLT:
            EX_alu_res = {31'd0, $signed(op1) < $signed(op2)};
        `SLTU:
            EX_alu_res = {31'd0, $unsigned(op1) < $unsigned(op2)};
        `XOR:
            EX_alu_res = op1 ^ op2;
        `SRL:
            EX_alu_res = op1 >> (op2[4:0]);
        `OR:
            EX_alu_res = op1 | op2;
        `AND:
            EX_alu_res = op1 & op2;
        `AND_N:
            EX_alu_res = op1 & ~op2;
        `SUB:
            EX_alu_res = op1 - op2;
        `SRA:
            EX_alu_res = $signed(op1) >>> (op2[4:0]);
        default:
            EX_alu_res = 32'h0;
    endcase
end
always_ff @(posedge clk) begin
    if (rst) begin
        EX_alu_res_reg <= 32'd0;
    end
    else if (!stall) begin
        EX_alu_res_reg <= EX_alu_res;
    end
end

/* BEU */
always_comb begin
    unique case (beuOp[2:1])
        `EQ:
            preBranchTaken = (forwardedRS1 == forwardedRS2);
        `LT:
            preBranchTaken = ($signed(forwardedRS1) < $signed(forwardedRS2));
        `LTU:
            preBranchTaken = ($unsigned(forwardedRS1) < $unsigned(forwardedRS2));
        default:
            preBranchTaken = 1'b1;
    endcase
end

always_comb begin
    branchTakenComb = preBranchTaken ^ beuOp[0];
end

/* rs2, LDSTSel, MEMLength, WBSel, rdIdx, PC_4 */
always_ff @(posedge clk) begin
    if (rst || branchTaken) begin
        rs2ToMEM <= 32'd0;
        LDSTSelToMEM <= 1'd0;
        MEMLengthToMEM <= `NoMEM;
        WBSelToMEM <= 3'd0;
        rdIdxToMEM <= 5'd0;
        PC_4ToMEM <= 32'd0;
        csr_toMEM <= 32'd0;
        branchTaken <= 1'b0;
        bra_src_fromEX <= 2'd0;
    end
    else if (!stall) begin
        rs2ToMEM <= forwardedRS2;
        LDSTSelToMEM <= LDSTSelFromID;
        MEMLengthToMEM <= MEMLengthFromID;
        WBSelToMEM <= WBSelFromID;
        rdIdxToMEM <= rdIdxFromID;
        PC_4ToMEM <= PC_4FromID;
        branchTaken <= branchTakenComb;
        csr_toMEM <= forwardedCSR;
        bra_src_fromEX <= bra_src_fromID;
    end
end

always_ff @(posedge clk) begin
    if (rst || branchTaken) begin
        instValidToMEM <= 1'b0;
    end
    else if (!stall) begin
        instValidToMEM <= instValidFromID;
    end
end

endmodule
