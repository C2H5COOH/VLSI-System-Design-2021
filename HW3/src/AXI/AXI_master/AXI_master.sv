// `include "Master_read.sv"
// `include "Master_write.sv"
`include "AXI/AXI_master/Master_read.sv"
`include "AXI/AXI_master/Master_write.sv"

module AXIMaster(
    input                       clk,rst,

    input [31:0]                address,
    input                       read,
    input [3:0]                 write,
    input [31:0]                data_in,
    output [31:0]               data_out,
    output                      stall,

    output [`AXI_ID_BITS-1:0]       ARID,
    output [`AXI_ADDR_BITS-1:0]     ARADDR,
    output [`AXI_LEN_BITS-1:0]      ARLEN,
    output [`AXI_SIZE_BITS-1:0]     ARSIZE,
    output [1:0]                    ARBURST,
    output                          ARVALID,
    input                       ARREADY,

    input [`AXI_ID_BITS-1:0]    RID,
    input [`AXI_DATA_BITS-1:0]  RDATA,
    input [1:0]                 RRESP,
    input                       RLAST,
    input                       RVALID,
    output                          RREADY,

    output [`AXI_ID_BITS-1:0]       AWID,
    output [`AXI_ADDR_BITS-1:0]     AWADDR,
    output [`AXI_LEN_BITS-1:0]      AWLEN,
    output [`AXI_SIZE_BITS-1:0]     AWSIZE,
    output [1:0]                    AWBURST, //only INCR type
    output                          AWVALID,
    input                       AWREADY,

    output [`AXI_DATA_BITS-1:0]     WDATA,
    output [`AXI_STRB_BITS-1:0]     WSTRB,
    output                          WLAST,
    output                          WVALID,
    input                       WREADY, 

    input [`AXI_ID_BITS-1:0]    BID,
    input [1:0]                 BRESP,
    input                       BVALID,
    output                          BREADY
);

parameter master = 0;

logic read_stall;

MasterRead # (
    .master_read(master)
    )
MasterRead(
    .clk(clk),
    .rst(rst),

    .address(address), 
    .read(read),

    .stall(read_stall),
    .data(data_out),

    .ARID(ARID),
    .ARADDR(ARADDR),
    .ARLEN(ARLEN),
    .ARSIZE(ARSIZE),
    .ARBURST(ARBURST), 
    .ARVALID(ARVALID),
    .ARREADY(ARREADY),

    .RID(RID),
    .RDATA(RDATA),
    .RRESP(RRESP),
    .RLAST(RLAST),
    .RVALID(RVALID),
    .RREADY(RREADY)                    
);

logic write_stall;

MasterWrite #(
    .master_write(master)
    )
MasterWrite(
    .clk(clk),
    .rst(rst),

    .address(address), 
    .write(write),
    .data(data_in),

    .stall(write_stall),

    .AWID(AWID),
    .AWADDR(AWADDR),
    .AWLEN(AWLEN),
    .AWSIZE(AWSIZE),
    .AWBURST(AWBURST),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),

    .WDATA(WDATA),
    .WSTRB(WSTRB),
    .WLAST(WLAST),
    .WVALID(WVALID),
    .WREADY(WREADY), 

    .BID(BID),
    .BRESP(BRESP),
    .BVALID(BVALID),
    .BREADY(BREADY)
);

assign stall = read_stall || write_stall;
    
endmodule