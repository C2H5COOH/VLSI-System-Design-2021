`include "CPU_def.svh"

module ID (
    input               clk, 
    input               rst,
    input               clear,
    input               stall,
    input [31:0]        inst_fromIF, 
    input [31:0]        PCFromIF, 
    input [31:0]        PC_4FromIF, 
    input [4:0]         rdIdxFromWB, 
    input [31:0]        WBDataFromWB,
    input               instValidFromIF,
    output logic [31:0] PCToEX,
    output logic [31:0] PC_4ToEX,
    output logic [31:0] rs1, 
    output logic [31:0] rs2,
    output logic [31:0] imm,
    output logic [3:0]  aluOp,
    output logic [2:0]  beuOp,
    output logic [1:0]  op1Sel,
    output logic [1:0]  op2Sel,
    output logic        LDSTSel,
    output logic [1:0]  MEMLength,
    output logic [2:0]  WBSelToEX,
    output logic [4:0]  rdIdxToEX,
    output logic [4:0]  rs1IdxFromIF,
    output logic [4:0]  rs2IdxFromIF,
    output logic        instValidToEX,
    output logic [1:0]  bra_src,
    output logic        csr_src,
    output logic [11:0] csr_long_idx,
    output logic        is_MRET,
    output logic        is_WFI
);

logic [31:0]    RF [0:31];
logic [31:0]    inst;
integer         i, j;
logic           lastClear, lastClearOfThisStall, lastStall, LDSTSel_reg;
logic [1:0]     MEMLength_reg;

logic  is_MRETorWFI;
assign is_MRETorWFI = (`OPCODE32 == `CSR && `FUNCT3 == 3'b000);
assign is_MRET = (is_MRETorWFI && inst[29]);
assign is_WFI = (is_MRETorWFI && ~inst[29]);

assign inst = clear? `NOP : inst_fromIF;

assign csr_long_idx = inst[31:20];

/* imm */
always_ff @(posedge clk) begin
    if (rst) begin
        imm <= 32'd0;
    end
    else if (!stall) begin
        case (`OPCODE32)
            `IALU, `LD, `JALR: 
                imm <= `IMM12I;
            `ST:
                imm <= `IMM12S;
            `BEU:
                imm <= `IMM13;
            `AUIPC, `LUI:
                imm <= `IMM20;
            `JAL:
                imm <= `IMM21;
            `CSR:
                imm <= `IMM5;
            default:
                imm <= 32'd0;
        endcase
    end
end

/* aluop */
always_ff @(posedge clk) begin
    if (rst) begin
        aluOp <= 4'h0;
    end
    else if (!stall) begin
        case (`OPCODE32)
            `RALU: begin
                aluOp <= {`FUNCT7_5, `FUNCT3};
            end
            `IALU: begin
                aluOp <= (`FUNCT3 == `SR) ? {`FUNCT7_5, `FUNCT3} : {1'b0, `FUNCT3};
            end
            `CSR: begin
                case(`FUNCT3_Last2)
                    2'b00:
                        aluOp <= `NoALU;
                    2'b01:
                        aluOp <= `ADD;
                    2'b10:
                        aluOp <= `OR;
                    2'b11:
                        aluOp <= `AND_N;
                endcase
            end
            `LD, `JALR, `ST, `BEU, `AUIPC, `LUI, `JAL: begin
                aluOp <= `ADD;
            end
            default: begin
                aluOp <= `ADD;
            end
        endcase
    end
end

/* beuop */
always_ff @(posedge clk) begin
    if (rst) begin
        beuOp <= `NOBRA;
    end
    else if (!stall) begin
        case(`OPCODE32)
            `BEU:
                beuOp <= `FUNCT3;
            `JAL, `JALR:
                beuOp <= `UNCOND;
            `CSR: begin
                if(is_MRETorWFI)
                    beuOp <= `UNCOND;
                else
                    beuOp <= `NOBRA;
            end
            default:
                beuOp <= `NOBRA;
        endcase
    end
end

always_ff @(posedge clk) begin
    if(rst) begin
        bra_src <= `BraFromNo;
    end
    else if (!stall) begin
        unique if(is_MRET)
            bra_src <= `BraFromMepc;
        else if(is_WFI)
            bra_src <= `BraFromMtvec;
        else
            bra_src <= `BraFromALU;
    end
end

/* source sel */ // change
always_ff @(posedge clk) begin
    if (rst) begin
        op1Sel <= 2'b0;
    end
    else if (!stall) begin
        case(`OPCODE32)
            `BEU, `AUIPC, `JAL:
                op1Sel <= `Op1FromPC;
            `CSR: begin
                if(`FUNCT3_Last2 <= 2'b01)
                    op1Sel <= `Op1FromZero;
                else
                    op1Sel <= `Op1FromCSR;
            end                
            default:
                op1Sel <= `Op1FromRs1;
        endcase
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        op2Sel <= 2'b0;
    end
    else if (!stall) begin
        if (`OPCODE32 == `RALU) begin
            op2Sel <= `Op2FromRs2;
        end
        else if(`OPCODE32 == `CSR) begin
            if(~`FUNCT3_2) // CSRRW CSRRS CSRRC
                op2Sel <= `Op2FromRs1;
            else    // CSRRWI CSRRSI CSRRCI
                op2Sel <= `Op2FromImm;
        end
        else begin
            op2Sel <= `Op2FromImm;
        end
    end
end

// /* mem ref, r/w */
// always_ff @(posedge clk) begin
//     if (rst) begin //Edited by Parker
//         LDSTSel <= 1'b0;
//     end
//     else if (!stall) begin
//         if (`OPCODE32 == `ST) begin
//             LDSTSel <= `MemRefST;
//         end
//         else begin
//             LDSTSel <= `MemRefLD;
//         end
//     end
// end

/* mem ref, r/w */
always_ff @(posedge clk) begin
    if (rst) begin //Edited by Parker
        LDSTSel_reg <= 1'b0;
    end
    else if (!stall) begin
        if (`OPCODE32 == `ST) begin
            LDSTSel_reg <= `MemRefST;
        end
        else begin
            LDSTSel_reg <= `MemRefLD;
        end
    end
end
always_comb begin
    LDSTSel = LDSTSel_reg;
end

/* WBSel, rdIdx */
always_ff @(posedge clk) begin
    if (rst) begin
        rdIdxToEX <= 5'd0;
    end
    else if (!stall) begin
        if (`OPCODE32 == `ST || `OPCODE32 == `BEU || is_MRETorWFI) begin
            rdIdxToEX <= 5'd0;
        end
        else begin
            rdIdxToEX <= `RDIDX;
        end
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        WBSelToEX <= `WBSelALU;
    end
    else if (!stall) begin
        if (`OPCODE32 == `JAL || `OPCODE32 == `JALR) begin
            WBSelToEX <= `WBSelPC;
        end
        else if (`OPCODE32 == `LD) begin
            WBSelToEX <= (`FUNCT3_2) ? `WBSelMemUnsigned : `WBSelMemSigned;
        end
        else if(`OPCODE32 == `CSR) begin
            WBSelToEX <= `WBSelCSR;
        end
        else begin
            WBSelToEX <= `WBSelALU;
        end
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        csr_src <= `CSRFromNo;
    end
    else if (!stall) begin
        if(`OPCODE32 == `CSR && ~is_MRETorWFI)
            csr_src <= `CSRFromALU;
        else
            csr_src <= `CSRFromNo;
    end
end

// /* mem length */
// always_ff @(posedge clk) begin
//     if (rst) begin
//         MEMLength <= `NoMEM;
//     end
//     else if (!stall && (`OPCODE32 == `LD || `OPCODE32 == `ST)) begin
//         MEMLength <= `FUNCT3_Last2;
//     end
//     else begin
//         MEMLength <= `NoMEM;
//     end
// end

/* mem length */
always_ff @(posedge clk) begin
    if (rst) begin
        MEMLength_reg <= `NoMEM;
    end
    else if (!stall && (`OPCODE32 == `LD || `OPCODE32 == `ST)) begin
        MEMLength_reg <= `FUNCT3_Last2;
    end
    else if (!stall) begin
        MEMLength_reg <= `NoMEM;
    end
end
always_comb begin
    if (stall)
        MEMLength = `NoMEM;
    else
        MEMLength = MEMLength_reg;
end



/* rs1, rs2 */
always_comb begin
    rs1IdxFromIF = (`OPCODE32 == `LUI) ? 5'd0 : `RS1IDX;
    rs2IdxFromIF = `RS2IDX;
end
always_ff @(posedge clk) begin
    if (rst) begin
        rs1 <= 32'd0;
        rs2 <= 32'd0;
    end
    else if (!stall) begin
        rs1 <= RF[rs1IdxFromIF];
        rs2 <= RF[rs2IdxFromIF];
    end
end

/* RF */
always_ff @(posedge clk) begin
    if (rst) begin
        RF[0] <= 32'd0;
    end
    else if (|rdIdxFromWB  && !stall) begin
        RF[rdIdxFromWB] <= WBDataFromWB;
    end
end

/* PC */
always_ff @(posedge clk) begin
    if (rst) begin
        PCToEX <= 32'h0;
        PC_4ToEX <= 32'h0;
    end
    else if (!stall) begin
        PCToEX <= PCFromIF;
        PC_4ToEX <= PC_4FromIF;
    end
end
/* Last Clear */
always_ff @(posedge clk) begin
    if (rst) begin
        lastClear <= 1'b0;
        lastClearOfThisStall <= 1'b0;
        lastStall <= 1'b0;
    end
    else begin
        lastClear <= clear;
        lastClearOfThisStall <= (stall) ? lastClearOfThisStall : clear;
        lastStall <= stall;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        instValidToEX <= 1'b0;
    end
    else if (!stall) begin
        instValidToEX <= instValidFromIF;
    end
end


endmodule
