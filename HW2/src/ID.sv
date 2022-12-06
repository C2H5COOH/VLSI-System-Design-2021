`include "Control.sv"
`include "Imm.sv"
`include "R_File.sv"
`include "Hazard.sv"
// `include "CPU/Control.sv"
// `include "CPU/Imm.sv"
// `include "CPU/R_File.sv"
// `include "CPU/Hazard.sv"

module ID (
    input                   clk,rst,

    input [31:0]            instruction,
    input [31:0]            pc,

    output logic            JAL_reg, JALR_reg, Branch_reg, 
    output logic            MemRead_reg, MemWrite_reg, 
    output logic            RegWrite_reg,
    output logic            ALUSrc1_reg,ALUSrc2_reg,
    output logic [4:0]      ALUOp_reg,
    output logic [2:0]      DataWidth_reg,
    
    output logic [31:0]     immediate_reg,
    output logic [31:0]     pc_reg,

    output logic [4:0]      rs1_reg, rs2_reg, rd_reg,
    output logic [31:0]     readData1_reg, readData2_reg,


    //input [4:0]             EXE_rd,
    input                   EXE_jumpBranch,
    input                   WB_RegWrite,
    input [4:0]             WB_writeRegister,
    input [31:0]            WB_writeData,

    output                  hazardStall,
    input                   AXI_MEM_stall
);

//instruction decode
logic [4:0]     rs1,rs2;
logic [4:0]     rd;
logic [6:0]     opcode;
logic [2:0]     funct3;
logic [6:0]     funct7;

always_comb begin
    rs1     = instruction[19:15];
    rs2     = instruction[24:20];
    rd      = instruction[11:7] ;
    opcode  = instruction[6:0]  ;
    funct3  = instruction[14:12];
    funct7  = instruction[31:25];
end


//control unit
logic            JAL, JALR, Branch;
logic            MemRead, MemWrite; 
logic            ALUSrc1, ALUSrc2; 
logic            RegWrite;
logic  [2:0]     DataWidth;
logic  [4:0]     ALUOp;
logic  [2:0]     ImmOp;   

Control ctrl(
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),

    .JAL(JAL),
    .JALR(JALR), 
    .Branch(Branch),

    .MemRead(MemRead),
    .MemWrite(MemWrite),

    .ALUSrc1(ALUSrc1), 
    .ALUSrc2(ALUSrc2),

    .RegWrite(RegWrite),

    .DataWidth(DataWidth),
    .ALUOp(ALUOp),
    .ImmOp(ImmOp)   
);

//immediate handler

logic [31:0] immediate;

Imm imm(
    .immOp(ImmOp),
    .inst(instruction),
    .immOut(immediate)
);

//Register File
logic [31:0] readData1,readData2;

R_File r_file(
    .clk(clk),
    .rst(rst),
    
    .rs1(rs1),
    .rs2(rs2),
    .write_reg(WB_writeRegister),
    .write_en(WB_RegWrite),
    .read_data1(readData1),
    .read_data2(readData2),
    .write_data(WB_writeData)
);

//Hazard
logic IDClear;

Hazard hazard(
    .rs1(rs1),
    .rs2(rs2),
    .EXE_rd(rd_reg),

    .EXE_MemRead(MemRead_reg),

    .stall(hazardStall),
    .IDClear(IDClear)
);

//reg
always_ff @(posedge clk) begin
    if(rst || IDClear || EXE_jumpBranch) begin
        JAL_reg         <= 1'b0; 
        JALR_reg        <= 1'b0;
        Branch_reg      <= 1'b0;

        MemRead_reg     <= 1'b0; 
        MemWrite_reg    <= 1'b0;

        RegWrite_reg    <= 1'b0;

        ALUSrc1_reg     <= 1'b0;
        ALUSrc2_reg     <= 1'b0;

        ALUOp_reg       <= 5'd0;
        DataWidth_reg   <= 3'd0;

        immediate_reg   <= 32'd0;
        pc_reg          <= 32'd0;

        rs1_reg         <= 5'd0;
        rs2_reg         <= 5'd0;
        rd_reg          <= 5'd0;
        readData1_reg   <= 32'd0;
        readData2_reg   <= 32'd0;

    end
    else if(AXI_MEM_stall)begin
        JAL_reg         <= JAL_reg; 
        JALR_reg        <= JALR_reg;
        Branch_reg      <= Branch_reg;

        MemRead_reg     <= MemRead_reg; 
        MemWrite_reg    <= MemWrite_reg;

        RegWrite_reg    <= RegWrite_reg;

        
        ALUSrc1_reg     <= ALUSrc1_reg;
        ALUSrc2_reg     <= ALUSrc2_reg;

        ALUOp_reg       <= ALUOp_reg;
        DataWidth_reg   <= DataWidth_reg;

        pc_reg          <= pc_reg;    
        immediate_reg   <= immediate_reg;

        rs1_reg         <= rs1_reg;
        rs2_reg         <= rs2_reg;
        rd_reg          <= rd_reg;
        readData1_reg   <= readData1_reg;
        readData2_reg   <= readData2_reg;
    end
    else begin
        JAL_reg         <= JAL; 
        JALR_reg        <= JALR;
        Branch_reg      <= Branch;

        MemRead_reg     <= MemRead; 
        MemWrite_reg    <= MemWrite;

        RegWrite_reg    <= RegWrite;

        
        ALUSrc1_reg     <= ALUSrc1;
        ALUSrc2_reg     <= ALUSrc2;

        ALUOp_reg       <= ALUOp;
        DataWidth_reg   <= DataWidth;

        pc_reg          <= pc;    
        immediate_reg   <= immediate;

        rs1_reg         <= rs1;
        rs2_reg         <= rs2;
        rd_reg          <= rd;
        readData1_reg   <= readData1;
        readData2_reg   <= readData2;
  
    end
end

    
endmodule
