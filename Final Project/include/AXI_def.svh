// `ifndef AXI_DEF_SVH
// `define AXI_DEF_SVH

`define AXI_ID_BITS 4
`define AXI_IDS_BITS 8
`define AXI_ADDR_BITS 32
`define AXI_LEN_BITS 4
`define AXI_SIZE_BITS 3
`define AXI_DATA_BITS 64
`define AXI_STRB_BITS 8
`define AXI_BURST_BITS 2
`define AXI_RESP_BITS 2
`define AXI_LEN_ONE 4'h0
`define AXI_SIZE_BYTE 3'b000
`define AXI_SIZE_HWORD 3'b001
`define AXI_SIZE_WORD 3'b010
`define AXI_SIZE_DWORD 3'b011
`define AXI_BURST_INCR 2'h1
`define AXI_BURST_WRAP 2'h2
`define AXI_STRB_DWORD 8'b11111111
`define AXI_STRB_WORD 8'b00001111
`define AXI_STRB_HWORD 8'b00000011
`define AXI_STRB_BYTE 8'b00000001
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

// AXI Slave
// Select
`define FREE 2'b00
`define READ 2'b01
`define WRITE 2'b10
`define TRANSFER 2'b11
// Read State
`define ADDRESS 1'b0
`define DATA 1'b1
// Write State
`define ADDRESSDATA 1'b0
`define RESPONSE 1'b1

// AXI Master Read
`define READ_IDLE 2'b00
`define READ_WAIT_ARREADY 2'b01
`define READ_WAIT_RVALID 2'b10

// AXI Master Write
`define WRITE_IDLE          2'b00
`define WRITE_WAIT_AWREADY  2'b01
`define WRITE_WAIT_WREADY   2'b10
`define WRITE_WAIT_BVALID   2'b11

// DMA
`define DMA_WAIT_CLEAR      4'b0000
`define DMA_WAIT_SOURCE     4'b0001
`define DMA_WAIT_TARGET     4'b0010
`define DMA_WAIT_MODE       4'b0011
`define DMA_WAIT_TIMES      4'b0100
`define DMA_WAIT_STRIDE     4'b0101
`define DMA_WAIT_LENGTH     4'b0110
`define DMA_CONNECT         4'b0111
`define DMA_FIRST_READ      4'b1000
`define DMA_READ_WRITE      4'b1001
`define DMA_LAST_WRITE      4'b1010

`define S_F_T_F 2'b00
`define S_F_T_A 2'b01
`define S_A_T_F 2'b10
`define S_A_T_A 2'b11

// `endif
