// `include "../AXI/AXI_slave/AXISlave.sv"
`ifndef AXI_SLAVE
`define AXI_SLAVE
`include "AXI/AXI_slave/AXISlave.sv"
`endif

module ROM_wrapper (
    input clock,
	input reset,
     // READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output ARREADY,
	// READ DATA
	output [`AXI_IDS_BITS-1:0] RID,
	output [`AXI_DATA_BITS-1:0] RDATA,
	output [1:0] RRESP,
	output RLAST,
	output RVALID,
	input RREADY,
    // ROM
    input [`AXI_DATA_BITS-1:0] DO,
    output logic CS,
    output logic OE,
    output logic [11:0] A
);
    // Wire
    logic [13:0] Address;

    // Module
    AXISlave axiSlave
    (
        .clock(clock),
        .reset(reset),
        // READ ADDRESS
        .ARID(ARID),
        .ARADDR(ARADDR),
        .ARLEN(ARLEN),
        .ARSIZE(ARSIZE),
        .ARBURST(ARBURST),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),
        // READ DATA
        .RID(RID),
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RLAST(RLAST),
        .RVALID(RVALID),
        .RREADY(RREADY),
        // WRITE ADDRESS
        .AWID(8'd0),
        .AWADDR(32'd0),
        .AWLEN(4'd0),
        .AWSIZE(3'd0),
        .AWBURST(2'd0),
        .AWVALID(1'd0),
        .AWREADY(),
        // WRITE DATA
        .WDATA(32'd0),
        .WSTRB(4'd0),
        .WLAST(1'd0),
        .WVALID(1'd0),
        .WREADY(),
        // WRITE RESPONSE
        .BID(),
        .BRESP(),
        .BVALID(),
        .BREADY(1'd0),
        // Slave
        .Address(Address),
        .ReadEnable(OE),
        .DataRead(DO),
        .WriteEnable(),
        .DataWrite()
    );

    assign CS = 1'b1;
    assign A = Address[11:0];

endmodule