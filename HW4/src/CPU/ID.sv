// `include "Control.sv"
// `include "Imm.sv"
// `include "R_File.sv"
// `include "Hazard.sv"
`include "CPU/Control.sv"
`include "CPU/Imm.sv"
`include "CPU/R_File.sv"
`include "CPU/Hazard.sv"
`include "CPU/Intr_control.sv"
`include "CPU/CSR.sv"

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

    output logic [11:0]     csr_addr_reg,
    output logic            csr_rsrc_reg,
    output logic [31:0]     csr_uimm_reg, csr_data_reg,
    output logic [1:0]      csr_op_reg,
    output logic            csr_write_reg,

    input                   EXE_jumpBranch,
    input                   WB_RegWrite,
    input [4:0]             WB_writeRegister,
    input [31:0]            WB_writeData,

    output                  hazardStall,
    input                   AXI_MEM_stall,
    input                   AXI_IF_stall,
    input [31:0]            pc_store,
    output logic            pc_wfi, pc_mret, ctrl_intr,
    output logic [31:0]     csr_pc,

    input [31:0]            csr_write_data,
    input                   csr_write_en,
    input [11:0]            csr_write_addr,

    input                   wrapper_intr

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

// logic imm_src, csr_src;
logic csr_write, csr_read;
logic [1:0] csr_op;
logic csr_rsrc;

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
    .ImmOp(ImmOp),

    .csr_write(csr_write),
    .csr_read(csr_read),
    .csr_op(csr_op),
    .csr_rsrc(csr_rsrc)   
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

// logic pc_wfi, pc_mret;
logic csr_intr, csr_intr_end;
logic inst_invalid;

logic [31:0] csr_read_data;
// logic [31:0] csr_pc;
logic csr_meie, csr_mie;

Intr_ctrl intr_ctrl(
    .clk(clk),
    .rst(rst),

    .instruction(instruction),
    .pc_wfi(pc_wfi),
    .pc_mret(pc_mret),

    .csr_meie(csr_meie),
    .csr_mie(csr_mie),
    .csr_intr(csr_intr),
    .csr_intr_end(csr_intr_end),

    .interrupt(wrapper_intr),
    .AXI_IF_stall(AXI_IF_stall),
    .AXI_MEM_stall(AXI_MEM_stall),
    .inst_invalid(inst_invalid)
);
assign ctrl_intr = csr_intr;

CSR csr(
    .clk(clk),
    .rst(rst),

    .read_addr(instruction[31:20]),
    .write_addr(csr_write_addr),

    .write_data(csr_write_data),
    .write_en(csr_write_en),

    .read(csr_read),
    .read_data(csr_read_data),

    .intr(csr_intr),
    .intr_end(csr_intr_end),
    .pc_store(pc_store),
    .csr_pc(csr_pc),

    .csr_meie(csr_meie), 
    .csr_mie(csr_mie),

    .inst_stall(AXI_MEM_stall || AXI_IF_stall)
);

//reg
// always_ff @(posedge clk) begin
//     if(rst || IDClear || EXE_jumpBranch || inst_invalid) begin
//         JAL_reg         <= 1'b0; 
//         JALR_reg        <= 1'b0;
//         Branch_reg      <= 1'b0;
//         MemRead_reg     <= 1'b0; 
//         MemWrite_reg    <= 1'b0;
//         RegWrite_reg    <= 1'b0;
//         ALUSrc1_reg     <= 1'b0;
//         ALUSrc2_reg     <= 1'b0;
//         ALUOp_reg       <= 5'd0;
//         DataWidth_reg   <= 3'd0;

//         immediate_reg   <= 32'd0;
//         pc_reg          <= 32'd0;

//         rs1_reg         <= 5'd0;
//         rs2_reg         <= 5'd0;
//         rd_reg          <= 5'd0;
//         readData1_reg   <= 32'd0;
//         readData2_reg   <= 32'd0;

//         csr_addr_reg    <= 32'b0;
//         csr_rsrc_reg    <= 1'b0;
//         csr_uimm_reg    <= 32'b0;
//         csr_data_reg    <= 32'b0;
//         csr_op_reg      <= 2'b0;
//         csr_write_reg   <= 1'b0;

//     end
//     else if(AXI_MEM_stall)begin
//         JAL_reg         <= JAL_reg; 
//         JALR_reg        <= JALR_reg;
//         Branch_reg      <= Branch_reg;
//         MemRead_reg     <= MemRead_reg; 
//         MemWrite_reg    <= MemWrite_reg;
//         RegWrite_reg    <= RegWrite_reg;
//         ALUSrc1_reg     <= ALUSrc1_reg;
//         ALUSrc2_reg     <= ALUSrc2_reg;
//         ALUOp_reg       <= ALUOp_reg;
//         DataWidth_reg   <= DataWidth_reg;

//         pc_reg          <= pc_reg;    
//         immediate_reg   <= immediate_reg;

//         rs1_reg         <= rs1_reg;
//         rs2_reg         <= rs2_reg;
//         rd_reg          <= rd_reg;
//         readData1_reg   <= readData1_reg;
//         readData2_reg   <= readData2_reg;

//         csr_addr_reg    <= csr_addr_reg;
//         csr_rsrc_reg    <= csr_rsrc_reg;
//         csr_uimm_reg    <= csr_uimm_reg;
//         csr_data_reg    <= csr_data_reg;
//         csr_op_reg      <= csr_op_reg;
//         csr_write_reg   <= csr_write_reg;
//     end
//     else begin
//         JAL_reg         <= JAL; 
//         JALR_reg        <= JALR;
//         Branch_reg      <= Branch;
//         MemRead_reg     <= MemRead; 
//         MemWrite_reg    <= MemWrite;
//         RegWrite_reg    <= RegWrite;
//         ALUSrc1_reg     <= ALUSrc1;
//         ALUSrc2_reg     <= ALUSrc2;
//         ALUOp_reg       <= ALUOp;
//         DataWidth_reg   <= DataWidth;

//         pc_reg          <= pc;    
//         immediate_reg   <= immediate;

//         rs1_reg         <= rs1;
//         rs2_reg         <= rs2;
//         rd_reg          <= rd;
//         readData1_reg   <= readData1;
//         readData2_reg   <= readData2;

//         csr_addr_reg    <= instruction[31:20];
//         csr_rsrc_reg    <= csr_rsrc;
//         csr_uimm_reg    <= { 27'b0, instruction[19:15] };
//         csr_data_reg    <= csr_read_data;
//         csr_op_reg      <= csr_op;
//         csr_write_reg   <= csr_write;
  
//     end
// end

always_ff @(posedge clk) begin
    if(rst || IDClear || inst_invalid) begin
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

        pc_reg          <= 32'd0;
        immediate_reg   <= 32'd0;

        rs1_reg         <= 5'd0;
        rs2_reg         <= 5'd0;
        rd_reg          <= 5'd0;
        readData1_reg   <= 32'd0;
        readData2_reg   <= 32'd0;

        csr_addr_reg    <= 32'b0;
        csr_rsrc_reg    <= 1'b0;
        csr_uimm_reg    <= 32'b0;
        csr_data_reg    <= 32'b0;
        csr_op_reg      <= 2'b0;
        csr_write_reg   <= 1'b0;
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

        csr_addr_reg    <= csr_addr_reg;
        csr_rsrc_reg    <= csr_rsrc_reg;
        csr_uimm_reg    <= csr_uimm_reg;
        csr_data_reg    <= csr_data_reg;
        csr_op_reg      <= csr_op_reg;
        csr_write_reg   <= csr_write_reg;
    end
    else if(EXE_jumpBranch) begin
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

        pc_reg          <= 32'd0;
        immediate_reg   <= 32'd0;

        rs1_reg         <= 5'd0;
        rs2_reg         <= 5'd0;
        rd_reg          <= 5'd0;
        readData1_reg   <= 32'd0;
        readData2_reg   <= 32'd0;

        csr_addr_reg    <= 32'b0;
        csr_rsrc_reg    <= 1'b0;
        csr_uimm_reg    <= 32'b0;
        csr_data_reg    <= 32'b0;
        csr_op_reg      <= 2'b0;
        csr_write_reg   <= 1'b0;
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
        // readData1_reg <= (WB_RegWrite && (WB_writeRegister == rs1))? WB_writeData : readData1;
        // readData2_reg   <= readData2;
        readData2_reg <= (WB_RegWrite && (WB_writeRegister == rs2))? WB_writeData : readData2;

        csr_addr_reg    <= instruction[31:20];
        csr_rsrc_reg    <= csr_rsrc;
        csr_uimm_reg    <= { 27'b0, instruction[19:15] };
        csr_data_reg    <= csr_read_data;
        csr_op_reg      <= csr_op;
        csr_write_reg   <= csr_write;
  
    end
end

endmodule
