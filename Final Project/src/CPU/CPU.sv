`include "CPU_def.svh"
`include "IF.sv"
`include "ID.sv"
`include "EX.sv"
`include "MEM.sv"
`include "WB.sv"
`include "Stall_ctrl.sv"
`include "FW.sv"
`include "CSR.sv"

module CPU (
    input               clk,
    input               rst,    
    input               m0Stall,
    input [31:0]        InstData,
    input               m1Stall,
    input [31:0]        MemRData,
    input               extern_interrupt,
    output logic [31:0] InstAddr,
    output logic        inst_req,
    output logic [31:0] MemAddr,
    output logic        data_req,
    output logic        data_write,
    output logic [2:0]  data_type,
    output logic [3:0]  data_strobe,
    output logic [31:0] MemWData
    
);
logic [31:0]    IFID_PC, IFID_PC_4;
logic [31:0]	IDEX_PC, PC_4FromID, EXMEM_PC_4, MEMWB_PC_4;
logic [31:0]    IFID_Inst;
logic [31:0]    IDEX_RS1, IDEX_RS2, IDEX_Imm, EXMEM_RS2, MEMWB_Result;
logic [31:0]    EX_alu_res, EX_alu_res_reg;
logic [31:0]    MEMWB_MEMReadData;
logic [31:0]    WBID_WBData, WBEX_WBData_Fw;
logic           EXIF_BranchTaken;
logic [4:0]     IFID_RS1Idx, IFID_RS2Idx, IDEX_RDIdx, EXMEM_RDIdx, MEMWB_RDIdx, WBID_RDIdx;
logic [3:0]     IDEX_ALUOP;
logic [2:0]     IDEX_BEUOP;
logic [1:0]     IDEX_OP1Sel, IDEX_OP2Sel;
logic           IDEX_LDSTSel, EXMEM_LDSTSel;
logic [1:0]     IDEX_MEMLength, EXMEM_MEMLength, MEMWB_MEMLength;
logic [2:0]     IDEX_WBSel, EXMEM_WBSel, MEMWB_WBSel;
logic           stallIF, ID_Clear, Global_Stall, stallPC;
logic [1:0]     OP1FWSel, OP2FWSel;
logic           IFID_InstValid, IDEX_InstValid, EXMEM_InstValid, MEMCSR_InstValid;

logic           is_MRET, is_WFI, wfi_stall;
logic           csr_src, csr_fw;
logic [1:0]     bra_src_fromEX, bra_src_fromID;
logic [11:0]    csr_long_idx;
logic [31:0]    mepc, mtvec;
logic [31:0]    csr_from_CSR, csr_FromEX, csr_fromMEM, alu_res_mask_reg;

IF IF0(
    .clk(clk),
    .rst(rst),
    .EX_alu_res_reg(EX_alu_res_reg),
    .branchTaken(EXIF_BranchTaken),
    .stall(stallIF),
    .stallPC(stallPC),
    .instFromIMem(InstData),
    .PCFromIF(IFID_PC),
    .PC_4FromIF(IFID_PC_4),
    .inst(IFID_Inst),
    .addressToIMem(InstAddr),
    .instValidToID(IFID_InstValid),
    .bra_src(bra_src_fromEX),
    .mepc(mepc),
    .mtvec(mtvec)
);

assign inst_req   = !EXIF_BranchTaken/* && !stallIF*/;
// assign inst_req = 1'b1;

ID ID0(
    .clk(clk), 
    .rst(rst),
    .clear(ID_Clear),
    .stall(Global_Stall),
    .inst_fromIF(IFID_Inst), 
    .PCFromIF(IFID_PC), 
    .PC_4FromIF(IFID_PC_4), 
    .rdIdxFromWB(WBID_RDIdx), 
    .WBDataFromWB(WBID_WBData),
    .instValidFromIF(IFID_InstValid),
    .PCToEX(IDEX_PC),
    .PC_4ToEX(PC_4FromID),
    .rs1(IDEX_RS1), 
    .rs2(IDEX_RS2),
    .imm(IDEX_Imm),
    .aluOp(IDEX_ALUOP),
    .beuOp(IDEX_BEUOP),
    .op1Sel(IDEX_OP1Sel),
    .op2Sel(IDEX_OP2Sel),
    .LDSTSel(IDEX_LDSTSel),
    .MEMLength(IDEX_MEMLength),
    .WBSelToEX(IDEX_WBSel),
    .rdIdxToEX(IDEX_RDIdx),
    .rs1IdxFromIF(IFID_RS1Idx),
    .rs2IdxFromIF(IFID_RS2Idx),
    .instValidToEX(IDEX_InstValid),
    .bra_src(bra_src_fromID),
    .csr_src(csr_src),
    .csr_long_idx(csr_long_idx),
    .is_MRET(is_MRET),
    .is_WFI(is_WFI)
);
EX EX0(
    .clk(clk), 
    .rst(rst),
    .stall(Global_Stall),
    .PCFromID(IDEX_PC),
    .PC_4FromID(PC_4FromID),
    .rs1(IDEX_RS1),
    .rs2FromID(IDEX_RS2),
    .imm(IDEX_Imm),
    .aluOp(IDEX_ALUOP),
    .beuOp(IDEX_BEUOP),
    .op1Sel(IDEX_OP1Sel),
    .op2Sel(IDEX_OP2Sel),
    .LDSTSelFromID(IDEX_LDSTSel),
    .MEMLengthFromID(IDEX_MEMLength),
    .WBSelFromID(IDEX_WBSel),
    .rdIdxFromID(IDEX_RDIdx),
    .op1FwSel(OP1FWSel),
    .op2FwSel(OP2FWSel),
    .srcFromMEM(WBID_WBData),
    .srcFromWB(WBEX_WBData_Fw),
    .instValidFromID(IDEX_InstValid),
    .csr_from_CSR(csr_from_CSR),
    .bra_src_fromID(bra_src_fromID),
    .csr_fw(csr_fw),
    .alu_res_mask_reg(alu_res_mask_reg),
    .branchTaken(EXIF_BranchTaken),
    .PC_4ToMEM(EXMEM_PC_4),
    .EX_alu_res(EX_alu_res),
    .EX_alu_res_reg(EX_alu_res_reg),
    .rs2ToMEM(EXMEM_RS2),
    .LDSTSelToMEM(EXMEM_LDSTSel),
    .MEMLengthToMEM(EXMEM_MEMLength),
    .WBSelToMEM(EXMEM_WBSel),
    .rdIdxToMEM(EXMEM_RDIdx),
    .instValidToMEM(EXMEM_InstValid),
    .csr_toMEM(csr_FromEX),
    .bra_src_fromEX(bra_src_fromEX)
);
MEM MEM0(
    .clk(clk),
    .rst(rst),
    .stall(Global_Stall),
    .PC_4FromEX(EXMEM_PC_4),
    .aluResultFromEX(EX_alu_res_reg),
    .rs2(EXMEM_RS2),
    .LDSTSel(EXMEM_LDSTSel),
    .MEMLengthFromEX(EXMEM_MEMLength),
    .WBSelFromEX(EXMEM_WBSel),
    .rdIdxFromEX(EXMEM_RDIdx),
    .memDataFromSRAM(MemRData),
    .instValidFromEX(EXMEM_InstValid),
    .csr_FromEX(csr_FromEX),
    .memAddr(MemAddr),
    .memDataToSRAM(MemWData),
    .data_strobe(data_strobe),
    .data_req(data_req),
    .data_write(data_write),
    .data_type(data_type),
    .MEMLengthToWB(MEMWB_MEMLength),
    .memResultToWB(MEMWB_MEMReadData),
    .aluResultToWB(MEMWB_Result),
    .PC_4ToWB(MEMWB_PC_4),
    .WBSelToWB(MEMWB_WBSel),
    .rdIdxToWB(MEMWB_RDIdx),
    .instValidToCSR(MEMCSR_InstValid),
    .csr_toWB(csr_fromMEM)
);

WB WB0(
    .clk(clk),
    .rst(rst),
    .WBSel(MEMWB_WBSel),
    .rdIdxFromMEM(MEMWB_RDIdx),
    .PC_4(MEMWB_PC_4),
    .aluResult(MEMWB_Result),
    .memReadData(MEMWB_MEMReadData),
    .csr_fromMEM(csr_fromMEM),
    .MEMLength(MEMWB_MEMLength),
    .WBData(WBID_WBData),
    .lastWBData(WBEX_WBData_Fw),
    .rdIdxToID(WBID_RDIdx)
);
FW FW0(
    .clk(clk),
    .rst(rst),
    .stall(Global_Stall),
    .IDrs1Idx(IFID_RS1Idx),
    .IDrs2Idx(IFID_RS2Idx),
    .EXrdIdx(IDEX_RDIdx),
    .MEMrdIdx(EXMEM_RDIdx),
    .WBrdIdx(MEMWB_RDIdx),
    .clear(ID_Clear),
    .rs1Fw(OP1FWSel),
    .rs2Fw(OP2FWSel) 
);
Stall_ctrl Stall_ctrl0(
    .rdIdxFromEX(IDEX_RDIdx),
    .IDrs1Idx(IFID_RS1Idx),
    .IDrs2Idx(IFID_RS2Idx),
    .WBSelFromEX(IDEX_WBSel),
    .branchTaken(EXIF_BranchTaken),
    .m0Stall(m0Stall),
    .m1Stall(m1Stall),
    .clearID(ID_Clear),
    .stallPC(stallPC),
    .stallIF(stallIF),
    .Global_Stall(Global_Stall),
    .wfi_stall(wfi_stall)
);
CSR CSR0 (
    .clk(clk),
    .rst(rst),
    .commitInst(MEMCSR_InstValid),
    .stall(Global_Stall),
    .is_MRET(is_MRET),
    .is_WFI(is_WFI),
    .extern_interrupt(extern_interrupt),
    .csr_src(csr_src),
    .csr_long_idx(csr_long_idx), 
    .EX_alu_res(EX_alu_res),
    .pc4(PC_4FromID), // not sure
    .csr_out(csr_from_CSR),
    .mtvec_out(mtvec),
    .mepc_out(mepc),
    .csr_fw(csr_fw),
    .alu_res_mask_reg(alu_res_mask_reg),
    .wfi_stall(wfi_stall)
);
endmodule
