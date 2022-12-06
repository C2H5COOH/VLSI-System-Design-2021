`ifndef CPU_DEF_SVH
`define CPU_DEF_SVH

`define Op1FromRs1     2'd0
`define Op1FromPC      2'd1
`define Op1FromCSR     2'd2
`define Op1FromZero    2'd3
`define Op2FromRs2     2'd0
`define Op2FromImm     2'd1
`define Op2FromRs1     2'd2
`define MemRefLD       1'b0
`define MemRefST       1'b1
`define CSRFromNo      1'd0
`define CSRFromALU     1'd1
`define BraFromNo       2'd0
`define BraFromALU      2'd1
`define BraFromMepc     2'd2
`define BraFromMtvec    2'd3

`define WBSelALU            3'd0
`define WBSelPC             3'd1
`define WBSelMemSigned      3'd2
`define WBSelMemUnsigned    3'd3
`define WBSelCSR            3'd4
`define WBSelMemBit         1
`define MEMByte             2'd0
`define MEMHalf             2'd1
`define MEMWord             2'd2
`define NoMEM               2'd3
`define EXFromID            2'd0
`define EXFwFromEX          2'd1
`define EXFwFromMEM         2'd2
`define EXFwFromWB          2'd3

`define ADD     4'h0
`define SLL     4'h1
`define SLT     4'h2
`define SLTU    4'h3
`define XOR     4'h4
`define SRL     4'h5
`define OR      4'h6
`define AND     4'h7
`define SUB     4'h8
`define SRA     4'hd
`define AND_N   4'hf
`define NoALU   4'he

`define SR      3'b101

`define BEQ     3'b000
`define BNE     3'b001
`define BLT     3'b100
`define BGE     3'b101
`define BLTU    3'b110
`define BGEU    3'b111
`define UNCOND  3'b010
`define NOBRA   3'b011
`define EQ      2'b00
`define LT      2'b10
`define LTU     2'b11

/* Insturection Segement */
`define OPCODE32      inst[6:2]
`define FUNCT3        inst[14:12]
`define FUNCT3_Last2  inst[13:12]
`define FUNCT3_2      inst[14]
/* R-Type */
`define RDIDX       inst[11:7]
`define RS1IDX      inst[19:15]
`define RS2IDX      inst[24:20]
`define FUNCT7      inst[31:25]
`define FUNCT7_5    inst[30]
/* I-Type */
`define IMM12I      {{21{inst[31]}}, inst[30:20]}
/* S-Type */
`define IMM12S      {{21{inst[31]}}, inst[30:25], inst[11:7]}
/* B-Type */
`define IMM13       {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}
/* U-Type */
`define IMM20       {inst[31:12], 12'h0}
/* J-Type */
`define IMM21       {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}
// CSR
`define IMM5        {{27{1'b0}}, inst[19:15]}

`define NOP         32'h13

/* RV32 */
`define is32    (inst[1:0] == 2'b11)
/* R-Type */
`define RALU    5'b01100   /* from RS1, RS2 to RD */
/* I-Type */
`define IALU    5'b00100   /* from RS1, Imm to RD */
`define LD      5'b00000   /* from [RS1 + Imm]  to RD */
`define JALR    5'b11001   /* from PC + 4, RS1 + Imm to RD, PC */
/* S-Type */
`define ST      5'b01000   /* from RS2 to [RS1 + Imm] */
/* B-Type */
`define BEU     5'b11000   /* from PC + Imm, PC+4 to PC */
/* U-Type */
`define AUIPC   5'b00101   /* from PC + Imm to RD */
`define LUI     5'b01101   /* from Imm to RD */
/* J-Type */
`define JAL     5'b11011   /* from PC + 4, PC + Imm to RD, PC */
// CSR
`define CSR     5'b11100

`endif
