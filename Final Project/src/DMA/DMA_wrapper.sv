
`include "AXI/AXI_slave_DMA/AXISlaveDMA.sv"
`include "AXI/AXI_master_DMA/MasterReadDMA.sv"
`include "AXI/AXI_master_DMA/MasterWriteDMA.sv"
`include "DMA.sv"

module DMA_wrapper (
    input clock,
	input reset,
    // AXI Slave
    // READ ADDRESS
	input  [`AXI_IDS_BITS-1:0] ARID_S,
	input  [`AXI_ADDR_BITS-1:0] ARADDR_S,
	input  [`AXI_LEN_BITS-1:0] ARLEN_S,
	input  [`AXI_SIZE_BITS-1:0] ARSIZE_S,
	input  [1:0] ARBURST_S,
	input  ARVALID_S,
	output ARREADY_S,
	// READ DATA
	output [`AXI_IDS_BITS-1:0] RID_S,
	output [`AXI_DATA_BITS-1:0] RDATA_S,
	output [1:0] RRESP_S,
	output RLAST_S,
	output RVALID_S,
	input  RREADY_S,
    // WRITE ADDRESS
	input  [`AXI_IDS_BITS-1:0] AWID_S,
	input  [`AXI_ADDR_BITS-1:0] AWADDR_S,
	input  [`AXI_LEN_BITS-1:0] AWLEN_S,
	input  [`AXI_SIZE_BITS-1:0] AWSIZE_S,
	input  [1:0] AWBURST_S,
	input  AWVALID_S,
	output AWREADY_S,
	// WRITE DATA
	input  [`AXI_DATA_BITS-1:0] WDATA_S,
	input  [`AXI_STRB_BITS-1:0] WSTRB_S,
	input  WLAST_S,
	input  WVALID_S,
	output WREADY_S,
	// WRITE RESPONSE
	output [`AXI_IDS_BITS-1:0] BID_S,
	output [1:0] BRESP_S,
	output BVALID_S,
	input  BREADY_S,
    // AXI Master Read
    // READ ADDRESS
	output [`AXI_ID_BITS-1:0] ARID_M,
	output [`AXI_ADDR_BITS-1:0] ARADDR_M,
	output [`AXI_LEN_BITS-1:0] ARLEN_M,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_M,
	output [1:0] ARBURST_M,
	output ARVALID_M,
	input  ARREADY_M,
	// READ DATA
	input  [`AXI_ID_BITS-1:0] RID_M,
	input  [`AXI_DATA_BITS-1:0] RDATA_M,
	input  [1:0] RRESP_M,
	input  RLAST_M,
	input  RVALID_M,
	output RREADY_M,
    // AXI Master Write
    // WRITE ADDRESS
	output [`AXI_ID_BITS-1:0] AWID_M,
	output [`AXI_ADDR_BITS-1:0] AWADDR_M,
	output [`AXI_LEN_BITS-1:0] AWLEN_M,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_M,
	output [1:0] AWBURST_M,
	output AWVALID_M,
	input  AWREADY_M,
	// WRITE DATA
	output [`AXI_DATA_BITS-1:0] WDATA_M,
	output [`AXI_STRB_BITS-1:0] WSTRB_M,
	output WLAST_M,
	output WVALID_M,
	input  WREADY_M,
	// WRITE RESPONSE
	input  [`AXI_ID_BITS-1:0] BID_M,
	input  [1:0] BRESP_M,
	input  BVALID_M,
	output BREADY_M,
    // Interrupt
    output interrupt
);
    // Wire
    // DMA & AXI Slave
    logic [`AXI_ADDR_BITS-1:0] addressSlave;
    logic                      readEnable;
    logic [`AXI_DATA_BITS-1:0] dataReadSlave;
    logic [`AXI_STRB_BITS-1:0] writeEnableSlave;
    logic [`AXI_DATA_BITS-1:0] dataWriteSlave;
    logic                      busy;
    // DMA & AXI Master Read
    logic                      addressReadyRead;
    logic [`AXI_ADDR_BITS-1:0] addressMasterRead;
    logic [`AXI_LEN_BITS-1:0]  lengthRead;
    logic                      arFinish;
    logic                      nextRead;
    logic                      lastRead;
    logic                      rFinish;
    logic [`AXI_DATA_BITS-1:0] dataReadMaster;
    // DMA & AXI Master Write
    logic                      addressReadyWrite;
    logic [`AXI_ADDR_BITS-1:0] addressMasterWrite;
    logic [`AXI_LEN_BITS-1:0]  lengthWrite;
    logic                      awFinish;
    logic                      nextWrite;
    logic                      lastWrite;
    logic [`AXI_STRB_BITS-1:0] writeEnableMaster;
    logic [`AXI_DATA_BITS-1:0] dataWriteMaster;
    logic                      wFinish;

    // Module
    // AXI Slave
    AXISlaveDMA axiSlaveDMA
    (
        .clock(clock),
        .reset(reset),
        // READ ADDRESS
        .ARID(ARID_S),
        .ARADDR(ARADDR_S),
        .ARLEN(ARLEN_S),
        .ARSIZE(ARSIZE_S),
        .ARBURST(ARBURST_S),
        .ARVALID(ARVALID_S),
        .ARREADY(ARREADY_S),
        // READ DATA
        .RID(RID_S),
        .RDATA(RDATA_S),
        .RRESP(RRESP_S),
        .RLAST(RLAST_S),
        .RVALID(RVALID_S),
        .RREADY(RREADY_S),
        // WRITE ADDRESS
        .AWID(AWID_S),
        .AWADDR(AWADDR_S),
        .AWLEN(AWLEN_S),
        .AWSIZE(AWSIZE_S),
        .AWBURST(AWBURST_S),
        .AWVALID(AWVALID_S),
        .AWREADY(AWREADY_S),
        // WRITE DATA
        .WDATA(WDATA_S),
        .WSTRB(WSTRB_S),
        .WLAST(WLAST_S),
        .WVALID(WVALID_S),
        .WREADY(WREADY_S),
        // WRITE RESPONSE
        .BID(BID_S),
        .BRESP(BRESP_S),
        .BVALID(BVALID_S),
        .BREADY(BREADY_S),
        // DMA
        .Address(addressSlave),
        .ReadEnable(readEnable),
        .DataRead(dataReadSlave),
        .WriteEnable(writeEnableSlave),
        .DataWrite(dataWriteSlave),
        .busy(busy)
    );
    // AXI Master Read
    MasterReadDMA masterReadDMA 
    (
        .clock(clock),
        .reset(reset),
        // READ ADDRESS
        .ARID(ARID_M),
        .ARADDR(ARADDR_M),
        .ARLEN(ARLEN_M),
        .ARSIZE(ARSIZE_M),
        .ARBURST(ARBURST_M), //only INCR type
        .ARVALID(ARVALID_M),
        .ARREADY(ARREADY_M),
        // READ DATA
        .RID(RID_M),
        .RDATA(RDATA_M),
        .RRESP(RRESP_M),
        .RLAST(RLAST_M),
        .RVALID(RVALID_M),
        .RREADY(RREADY_M),
        // DMA
        .addressReady(addressReadyRead),
        .address(addressMasterRead),
        .length(lengthRead),
        .ARFinish(arFinish),
        .next(nextRead),
        .last(lastRead),
        .RFinish(rFinish),
        .DataRead(dataReadMaster)     
    );
    // AXI Master Write
    MasterWriteDMA masterWriteDMA 
    (
        .clock(clock),
        .reset(reset),
        // WRITE ADDRESS
        .AWID(AWID_M),
        .AWADDR(AWADDR_M),
        .AWLEN(AWLEN_M),
        .AWSIZE(AWSIZE_M),
        .AWBURST(AWBURST_M),
        .AWVALID(AWVALID_M),
        .AWREADY(AWREADY_M),
        // WRITE DATA
        .WDATA(WDATA_M),
        .WSTRB(WSTRB_M),
        .WLAST(WLAST_M),
        .WVALID(WVALID_M),
        .WREADY(WREADY_M),
        // WRITE RESPONSE
        .BID(BID_M),
        .BRESP(BRESP_M),
        .BVALID(BVALID_M),
        .BREADY(BREADY_M),
        // DMA
        .addressReady(addressReadyWrite),
        .address(addressMasterWrite), 
        .length(lengthWrite),
        .AWFinish(awFinish),
        .next(nextWrite),
        .last(lastWrite),
        .writeEnable(writeEnableMaster),
        .dataWrite(dataWriteMaster),
        .WFinish(wFinish)
    );
    DMA dma
    (
        .clock(clock),
        .reset(reset),
        // AXI Slave
        .addressSlave(addressSlave),
        .readEnable(readEnable),
        .dataReadSlave(dataReadSlave),
        .writeEnableSlave(writeEnableSlave),
        .dataWriteSlave(dataWriteSlave),
        .busy(busy),
        // AXI Master Read
        .addressReadyRead(addressReadyRead),
        .addressMasterRead(addressMasterRead),
        .lengthRead(lengthRead),
        .arFinish(arFinish),
        .nextRead(nextRead),
        .lastRead(lastRead),
        .rFinish(rFinish),
        .dataReadMaster(dataReadMaster),
        // AXI Master Write
        .addressReadyWrite(addressReadyWrite),
        .addressMasterWrite(addressMasterWrite),
        .lengthWrite(lengthWrite),
        .awFinish(awFinish),
        .nextWrite(nextWrite),
        .lastWrite(lastWrite),
        .writeEnableMaster(writeEnableMaster),
        .dataWriteMaster(dataWriteMaster),
        .wFinish(wFinish),
        // Interrupt
        .interrupt(interrupt)
    );
endmodule