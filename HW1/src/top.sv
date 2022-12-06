`include "IF.sv"
`include "ID.sv"
`include "EXE.sv"
`include "WB.sv"
`include "MEM.sv"
`include "SRAM_wrapper.sv"

module top (
    input clk,rst
);

logic [31:0] IF_instruction_reg, IF_pc_reg;

logic [13:0] IMIn;
logic [31:0] IMOut;
//**********************************************************************

logic           ID_JAL_reg;
logic           ID_JALR_reg;
logic           ID_Branch_reg;
//logic           ID_MemRW_reg;
logic           ID_MemRead_reg;
logic           ID_MemWrite_reg;
logic           ID_RegWrite_reg;
//logic           ID_ALUSrc1_reg;
logic           ID_ALUSrc2_reg;
logic [4:0]     ID_ALUOp_reg;
logic [2:0]     ID_DataWidth_reg;  
logic [31:0]    ID_immediate_reg;
logic [31:0]    ID_pc_reg;
logic [4:0]     ID_rs1_reg;  
logic [4:0]     ID_rs2_reg;
logic [4:0]     ID_rd_reg;
logic [31:0]    ID_readData1_reg;
logic [31:0]    ID_readData2_reg;

logic           ID_hazardStall;
//***********************************************************************
logic           EXE_MemRead_reg;
logic           EXE_MemWrite_reg;
logic           EXE_RegWrite_reg;
//logic [1:0]     EXE_rdSrc_reg;
logic [2:0]     EXE_DataWidth_reg;
logic [4:0]     EXE_rd_reg;
logic [31:0]    EXE_readData2_reg;
logic [31:0]    EXE_aluResult_reg;
//logic [31:0]    EXE_adderResult_reg;

logic           EXE_jumpBranch;
logic [31:0]    EXE_adderResult;
//***********************************************************************

logic           MEM_MemRead_reg;
logic           MEM_RegWrite_reg;
logic [2:0]     MEM_DataWidth_reg;    
logic [4:0]     MEM_rd_reg;
logic [31:0]    MEM_aluResult_reg;
//logic [31:0]    MEM_adderResult_reg;

//logic [4:0]     MEM_rd;
//logic [1:0]     MEM_MemRead;

logic [3:0]     MEM_writeEn;
logic [31:0]    MEM_storeData;
logic [13:0]    MEM_memAddr;

logic [31:0]    memData;

logic [4:0]     WB_writeRegister;
logic           WB_RegWrite;
logic [31:0]    WB_writeData;

logic [4:0]     RFile_rd;
logic           RFile_RegWrite;
logic [31:0]    RFile_writeData;



IF IF(
    .clk                (clk)               ,
    .rst                (rst)               ,
    .EXE_jumpBranchAddr (EXE_adderResult)   ,
    .EXE_jumpBranch     (EXE_jumpBranch)    ,
    .ID_hazardStall     (ID_hazardStall)    ,

    .instruction        (IF_instruction_reg),
    .pc_reg             (IF_pc_reg)         ,

    .IMIn               (IMIn)              ,
    .IMOut              (IMOut)             
);


SRAM_wrapper IM1(
    .CK(clk),
    .CS(1'b1),
    .OE(1'b1),
    .WEB(4'b1111),
    .A(IMIn),
    .DI(32'd0),
    .DO(IMOut)
);


ID ID(
    .clk                (clk)               ,
    .rst                (rst)               ,

    .instruction        (IF_instruction_reg),
    .pc                 (IF_pc_reg)         ,

    .JAL_reg            (ID_JAL_reg)        ,
    .JALR_reg           (ID_JALR_reg)       ,
    .Branch_reg         (ID_Branch_reg)     ,
    //.MemRW_reg          (ID_MemRW_reg)      ,
    .MemRead_reg        (ID_MemRead_reg)    ,
    .MemWrite_reg       (ID_MemWrite_reg)   ,
    .RegWrite_reg       (ID_RegWrite_reg)   ,

    .ALUSrc1_reg        (ID_ALUSrc1_reg)    ,
    .ALUSrc2_reg        (ID_ALUSrc2_reg)    ,
    .ALUOp_reg          (ID_ALUOp_reg)      ,

    .DataWidth_reg      (ID_DataWidth_reg)  ,

    .immediate_reg      (ID_immediate_reg)  ,
    .pc_reg             (ID_pc_reg)         ,

    .rs1_reg            (ID_rs1_reg)        ,
    .rs2_reg            (ID_rs2_reg)        ,
    .rd_reg             (ID_rd_reg)         ,
    .readData1_reg      (ID_readData1_reg)  ,
    .readData2_reg      (ID_readData2_reg)  ,

    //.EXE_rd             (EXE_rd)            ,
    .EXE_jumpBranch     (EXE_jumpBranch)    ,
    //.EXE_rdSrc          (EXE_rdSrc)         ,

    .WB_RegWrite        (WB_RegWrite)       ,
    .WB_writeRegister   (WB_writeRegister)  ,
    .WB_writeData       (WB_writeData)      ,

    .hazardStall        (ID_hazardStall)
);



EXE EXE(
    .clk                (clk)               ,
    .rst                (rst)               ,

    //.rdSrc              (ID_rdSrc_reg)      , 
    .JAL                (ID_JAL_reg)        ,
    .JALR               (ID_JALR_reg)       ,
    .Branch             (ID_Branch_reg)     ,

    .MemRead            (ID_MemRead_reg)    ,
    .MemWrite           (ID_MemWrite_reg)   ,
    .RegWrite           (ID_RegWrite_reg)   ,

    .ALUSrc1            (ID_ALUSrc1_reg)    ,
    .ALUSrc2            (ID_ALUSrc2_reg)    ,
    .ALUOp              (ID_ALUOp_reg)      ,
    .DataWidth          (ID_DataWidth_reg)  ,

    .pc                 (ID_pc_reg)         ,
    .immediate          (ID_immediate_reg)  ,

    .rs1                (ID_rs1_reg)        ,
    .rs2                (ID_rs2_reg)        ,
    .rd                 (ID_rd_reg)         ,
    .readData1          (ID_readData1_reg)  ,
    .readData2          (ID_readData2_reg)  ,

    .WB_rd              (WB_writeRegister)  ,
    .RFile_rd           (RFile_rd)          ,

    .WB_RegWrite        (WB_RegWrite)       ,
    .RFile_RegWrite     (RFile_RegWrite)    ,

    .WB_writeData       (WB_writeData)      ,
    .RFile_writeData    (RFile_writeData)   ,

    .MemRead_reg        (EXE_MemRead_reg)   ,
    .MemWrite_reg       (EXE_MemWrite_reg)  ,
    .RegWrite_reg       (EXE_RegWrite_reg)  ,
    //.rdSrc_reg          (EXE_rdSrc_reg)         ,
    .DataWidth_reg      (EXE_DataWidth_reg) ,

    .rd_reg             (EXE_rd_reg)        ,
    .readData2_reg      (EXE_readData2_reg) ,
    .aluResult_reg      (EXE_aluResult_reg) ,
    //.adderResult_reg    (EXE_adderResult_reg)   ,

    .IF_ID_jumpBranch   (EXE_jumpBranch)        ,
    .IF_adderResult     (EXE_adderResult)         
);


MEM MEM(
    .clk                (clk),
    .rst                (rst),

    .MemRead            (EXE_MemRead_reg)   , 
    .MemWrite           (EXE_MemWrite_reg)  , 
    .RegWrite           (EXE_RegWrite_reg)  ,
    //.rdSrc              (EXE_rdSrc_reg)     , 
    .DataWidth          (EXE_DataWidth_reg) ,

    .rd                 (EXE_rd_reg)        ,
    .readData2          (EXE_readData2_reg) , 
    .aluResult          (EXE_aluResult_reg) , 
    //.adderResult        (EXE_adderResult_reg),

    //.rdSrc_reg          (MEM_rdSrc_reg)     ,
    .MemRead_reg        (MEM_MemRead_reg)   ,
    .RegWrite_reg       (MEM_RegWrite_reg)  ,
    .DataWidth_reg      (MEM_DataWidth_reg) ,
    .rd_reg             (MEM_rd_reg)        ,
    .aluResult_reg      (MEM_aluResult_reg) ,
    //.adderResult_reg    (MEM_adderResult_reg),   

    //.EXE_rd             (MEM_rd)            ,
    //.EXE_RegWrite       (MEM_RegWrite)      ,

    .DM_writeEn         (MEM_writeEn)       ,
    .DM_storeData       (MEM_storeData)     ,
    .DM_memAddr         (MEM_memAddr)
);

SRAM_wrapper DM1(
    .CK(clk),
    .CS(1'b1),
    .OE(1'b1),
    .WEB(MEM_writeEn),
    .A(MEM_memAddr),
    .DI(MEM_storeData),
    .DO(memData)
);

WB WB(
    .clk                (clk)               ,
    .rst                (rst)               ,

    .MemRead            (MEM_MemRead_reg)   ,
    .RegWrite           (MEM_RegWrite_reg)  ,

    .DataWidth          (MEM_DataWidth_reg) ,
    .rd                 (MEM_rd_reg)        ,
    .aluResult          (MEM_aluResult_reg) ,

    //.adderResult        (MEM_adderResult_reg),
    .memData            (memData)           ,

    .ID_writeRegister   (WB_writeRegister)  ,
    .ID_RegWrite        (WB_RegWrite)       ,
    .ID_writeData       (WB_writeData)      ,

    .RFile_rd           (RFile_rd)       ,
    .RFile_RegWrite     (RFile_RegWrite) ,
    .RFile_writeData    (RFile_writeData)
);
    
endmodule
