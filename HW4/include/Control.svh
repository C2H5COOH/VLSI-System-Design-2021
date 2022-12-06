`ifndef CONTROL_SVH
`define CONTROL_SVH

`define R_TYPE          (opcode == (7'b011_0011))
`define I_TYPE_ARITH    (opcode == (7'b001_0011))
`define LOAD            (opcode == (7'b000_0011))
`define JALR            (opcode == (7'b110_0111))
`define STORE           (opcode == (7'b010_0011))
`define BRANCH          (opcode == (7'b110_0011))
`define AUIPC           (opcode == (7'b001_0111))
`define LUI             (opcode == (7'b011_0111))
`define JAL             (opcode == (7'b110_1111))
`define CSR_TYPE        (opcode == (7'b111_0011))

//define data_width
`define WORD    (funct3 == 3'b010)
`define BYTE    (funct3 == 3'b000)
`define BYTEU   (funct3 == 3'b100)
`define HALF    (funct3 == 3'b001)
`define HALFU   (funct3 == 3'b101)

`define BYTE_WIDTH      (3'd0)
`define BYTEU_WIDTH     (3'd1)
`define HALF_WIDTH      (3'd2)
`define HALFU_WIDTH     (3'd3)
`define WORD_WIDTH      (3'd4)

//define alu_decode
`define ADD     ( (`R_TYPE) && (funct3 == 3'b000) &&  (funct7 == 7'b0000000) ) || ( (`I_TYPE_ARITH) && (funct3 == 3'b000) )

`define SUB     (funct3 == 3'b000) && (funct7 == 7'b0100000) && (`R_TYPE)
`define SLL     (funct3 == 3'b001) && ( `I_TYPE_ARITH || (`R_TYPE ) )
`define SLT     (funct3 == 3'b010) && ( `I_TYPE_ARITH || (`R_TYPE ) )
`define SLTU    (funct3 == 3'b011) && ( `I_TYPE_ARITH || (`R_TYPE ) )
`define XOR     (funct3 == 3'b100) && ( `I_TYPE_ARITH || (`R_TYPE ) )
`define SRL     (funct3 == 3'b101) && (funct7 == 7'b0000000) && (`R_TYPE || `I_TYPE_ARITH)
`define SRA     (funct3 == 3'b101) && (funct7 == 7'b0100000) && (`R_TYPE || `I_TYPE_ARITH)
`define OR      (funct3 == 3'b110) && ( `I_TYPE_ARITH || (`R_TYPE ) )
`define AND     (funct3 == 3'b111) && ( `I_TYPE_ARITH || (`R_TYPE ) )

`define BEQ     (funct3 == 3'b000) && (`BRANCH)
`define BNE     (funct3 == 3'b001) && (`BRANCH)
`define BLT     (funct3 == 3'b100) && (`BRANCH)
`define BGE     (funct3 == 3'b101) && (`BRANCH)
`define BLTU    (funct3 == 3'b110) && (`BRANCH)
`define BGEU    (funct3 == 3'b111) && (`BRANCH)

//define alu_op
`define ALU_ADD     (5'd0)
`define ALU_SUB     (5'd1)
`define ALU_SLL     (5'd2)
`define ALU_SLT     (5'd3)
`define ALU_SLTU    (5'd4)
`define ALU_XOR     (5'd5)
`define ALU_SRL     (5'd6)
`define ALU_SRA     (5'd7)
`define ALU_OR      (5'd8)
`define ALU_AND     (5'd9)
`define ALU_BEQ     (5'd10)
`define ALU_BNE     (5'd11)
`define ALU_BLT     (5'd12)
`define ALU_BGE     (5'd13)
`define ALU_BLTU    (5'd14)
`define ALU_BGEU    (5'd15)
`define ALU_JAL     (5'd16)
`define ALU_LUI     (5'd17)
`define ALU_CSR     (5'd18)
`define ALU_NOP     (5'd31)

//define imm_op
`define IMM_I_TYPE  (3'd0)
`define IMM_S_TYPE  (3'd1)
`define IMM_B_TYPE  (3'd2)
`define IMM_U_TYPE  (3'd3)
`define IMM_J_TYPE  (3'd4)
`define IMM_ELSE    (3'd5)

//define forwarding
`define FWD_R_DATA      (2'd0)
`define FWD_MEM_DATA    (2'd1)
`define FWD_WB_DATA     (2'd2)
`define FWD_RFILE_DATA  (2'd3)

//CSR instruction
`define CSRRW   (3'b001)
`define CSRRS   (3'b010)
`define CSRRC   (3'b011)
`define CSRRWI  (3'b101)
`define CSRRSI  (3'b110)
`define CSRRCI  (3'b111)

`define MRET    (32'b0011000_00010_00000_000_00000_1110011)
`define WFI     (32'b0001000_00101_00000_000_00000_1110011)

`define CSR_ASIGN   (2'b00)
`define CSR_OR      (2'b01)
`define CSR_AND     (2'b10)
`define CSR_NOP     (2'b11)


`endif

