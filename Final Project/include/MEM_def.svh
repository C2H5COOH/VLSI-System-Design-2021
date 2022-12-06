`ifndef MEM_DEF
`define MEM_DEF
`define COL_9_2(x)      ``x``[11:4]
`define COL_1_0(x)      ``x``[3:2]
`define ROW(x)          ``x``[22:12]
`define RAM_ADDR_BITS   11
`define RAM_DATA_BITS   64

`define ROM_ADDR_BITS   12
`define ROM_DATA_BITS   64
`define ROM_CNT_OFFSET  3
typedef enum logic[1:0] {
    ROM_Idle,
    ROM_Addr,
    ROM_DataLatch,
    ROM_DataOut
} ROM_State;
`endif