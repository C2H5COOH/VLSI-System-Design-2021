`include "ALU.sv"
`include "Forward.sv"
// `include "CPU/ALU.sv"
// `include "CPU/Forward.sv"

module EXE (
    input               clk,rst,

    input               JAL, JALR, Branch, 
    input               MemRead, MemWrite, 
    input               RegWrite,
    input               ALUSrc1, ALUSrc2,

    input [4:0]         ALUOp,
    input [2:0]         DataWidth,

    input [31:0]        immediate,
    input [31:0]        pc,

    input [4:0]         rs1,rs2,rd,
    input [31:0]        readData1,readData2,

    input [4:0]         WB_rd,RFile_rd,
    input               WB_RegWrite,RFile_RegWrite,
    input [31:0]        WB_writeData,RFile_writeData,

    output logic        MemRead_reg, MemWrite_reg,
    output logic        RegWrite_reg,
    output logic [2:0]  DataWidth_reg,

    output logic [4:0]  rd_reg,
    output logic [31:0] readData2_reg, aluResult_reg, 
    //adderResult_reg,
   

    output              IF_ID_jumpBranch, 
    output [31:0]       IF_adderResult,

    input               AXI_MEM_stall
);

logic [31:0] alu_input1,alu_input2;
logic [31:0] aluResult;
logic aluBranch;

ALU alu(
    .aluOp  (ALUOp)        ,
    .src1   (alu_input1)   ,
    .src2   (alu_input2)   ,
    .result (aluResult)    ,
    .branch (aluBranch) 
);

//forwarding unit
logic[1:0] readDataSrc1,readDataSrc2;

Forward forward(
    .MEM_Rd         (rd_reg)        , 
    .WB_Rd          (WB_rd)         ,
    .RFile_Rd       (RFile_rd)      ,
    .rs1            (rs1)           ,
    .rs2            (rs2)           ,
    
    .MEM_RegWrite   (RegWrite_reg)  ,
    .WB_RegWrite    (WB_RegWrite)   ,
    .RFile_RegWrite (RFile_RegWrite),

    .rdataSrc1      (readDataSrc1)  ,
    .rdataSrc2      (readDataSrc2)  
    //.aluSrc1        (ALUSrc1)       ,
    //.aluSrc2        (ALUSrc2)       
);

//alu input and forwarding
logic [31:0] fwdReadData1;
always_comb begin
    case(readDataSrc1)
        `FWD_R_DATA     : fwdReadData1 = readData1;
        `FWD_MEM_DATA   : fwdReadData1 = aluResult_reg;
        `FWD_WB_DATA    : fwdReadData1 = WB_writeData;
        `FWD_RFILE_DATA : fwdReadData1 = RFile_writeData;
    endcase
    alu_input1 = (ALUSrc1)? fwdReadData1 : pc;
end

logic [31:0] fwdReadData2;
always_comb begin
    case(readDataSrc2)
        `FWD_R_DATA     : fwdReadData2 = readData2;
        `FWD_MEM_DATA   : fwdReadData2 = aluResult_reg;
        `FWD_WB_DATA    : fwdReadData2 = WB_writeData;
        `FWD_RFILE_DATA : fwdReadData2 = RFile_writeData;
    endcase
    alu_input2 = (ALUSrc2)? immediate : fwdReadData2;
end

//adder
//branch target address, JAL & JALR target addr
logic [31:0] adderResult, adderInput1, adderInput2;
assign adderResult = adderInput1 + adderInput2;
assign adderInput1 = (JALR)? fwdReadData1 : pc;
assign adderInput2 = immediate;

assign IF_adderResult = (JALR)? { adderResult[31:1], 1'b0 } : adderResult;//cut LSB

//flush
assign IF_ID_jumpBranch = JALR || JAL || (Branch && aluBranch);

//reg
always_ff @(posedge clk) begin
    if(rst)begin
        MemRead_reg     <= 1'b0;
        MemWrite_reg    <= 1'b0;
        RegWrite_reg    <= 1'b0;

        DataWidth_reg   <= 3'd0;

        rd_reg          <= 5'd0;
        readData2_reg   <= 32'd0;
        aluResult_reg   <= 32'd0;
    end
    else if(AXI_MEM_stall)begin
        MemRead_reg     <= MemRead_reg;
        MemWrite_reg    <= MemWrite_reg;
        RegWrite_reg    <= RegWrite_reg;

        DataWidth_reg   <= DataWidth_reg;
        rd_reg          <= rd_reg;
        readData2_reg   <= readData2_reg;
        aluResult_reg   <= aluResult_reg;        
    end
    else begin
        MemRead_reg     <= MemRead;
        MemWrite_reg    <= MemWrite;
        RegWrite_reg    <= RegWrite;

        DataWidth_reg   <= DataWidth;
        rd_reg          <= rd;
        readData2_reg   <= fwdReadData2;
        aluResult_reg   <= aluResult;
    end
end
    
endmodule
