`ifndef AXI_DEFINES_SVH
`define AXI_DEFINES_SVH

`define AXI_ID_BITS 4
`define AXI_IDS_BITS 8
`define AXI_ADDR_BITS 32
`define AXI_LEN_BITS 4
`define AXI_SIZE_BITS 3
`define AXI_DATA_BITS 32
`define AXI_STRB_BITS 4
`define AXI_BURST_BITS 2
`define AXI_RESP_BITS 2
`define AXI_LEN_ONE 4'h0
`define AXI_SIZE_BYTE 3'b000
`define AXI_SIZE_HWORD 3'b001
`define AXI_SIZE_WORD 3'b010
`define AXI_BURST_INCR 2'h1
`define AXI_BURST_WRAP 2'h2
`define AXI_STRB_WORD 4'b1111
`define AXI_STRB_HWORD 4'b0011
`define AXI_STRB_BYTE 4'b0001
`define AXI_RESP_OKAY 2'h0
`define AXI_RESP_SLVERR 2'h2
`define AXI_RESP_DECERR 2'h3

//========================= Commonly used  =========================
`define TRUE  1'b1
`define FALSE 1'b0

// AXI Bridge
// Definition
`define IDLE 1'b0
`define BUSY 1'b1
// Precedence
`define M0 1'b0
`define M1 1'b1
// Master MUX Selection
`define M0MUX 2'b00
`define M1MUX 2'b01
`define DEFAULTMMUX 2'b10
// Slave MUX Selection
`define S0MUX 3'b000
`define S1MUX 3'b001
`define S2MUX 3'b010
`define S3MUX 3'b011
`define S4MUX 3'b100
`define WRONGADDRESS 3'b101
`define DEFAULTSMUX 3'b111

// AXI Slave
// Select
`define FREE 2'b00
`define READ 2'b01
`define WRITE 2'b10
// Read State
`define ADDRESS 1'b0
`define DATA 1'b1
// Write State
`define ADDRESSDATA 1'b0
`define RESPONSE 1'b1

`endif