`include "CPU.sv"
`include "AXI_master.sv"
// `include "CPU/CPU.sv"
// `include "CPU/AXI_master/AXI_master.sv"

module CPU_wrapper(
    input                       clk,rst,

    output [`AXI_ID_BITS-1:0]   AWID_M1,
	output [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	output [`AXI_LEN_BITS-1:0]  AWLEN_M1,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	output [1:0]                AWBURST_M1,
	output                      AWVALID_M1,
	input                       AWREADY_M1,
	//WRITE DATA
	output [`AXI_DATA_BITS-1:0] WDATA_M1,
	output [`AXI_STRB_BITS-1:0] WSTRB_M1,
	output                      WLAST_M1,
	output                      WVALID_M1,
	input                       WREADY_M1,
	//WRITE RESPONSE
	input [`AXI_ID_BITS-1:0]    BID_M1, 
	input [1:0]                 BRESP_M1,
	input                       BVALID_M1,
	output                      BREADY_M1,

	//READ ADDRESS0
	output [`AXI_ID_BITS-1:0]   ARID_M0,
	output [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	output [`AXI_LEN_BITS-1:0]  ARLEN_M0,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	output [1:0]                ARBURST_M0,
	output                      ARVALID_M0,
	input                       ARREADY_M0,
	//READ DATA0
	input [`AXI_ID_BITS-1:0]    RID_M0,
	input [`AXI_DATA_BITS-1:0]  RDATA_M0,
	input [1:0]                 RRESP_M0,
	input                       RLAST_M0,
	input                       RVALID_M0,
	output                      RREADY_M0,
	//READ ADDRESS1
	output [`AXI_ID_BITS-1:0]   ARID_M1,
	output [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	output [`AXI_LEN_BITS-1:0]  ARLEN_M1,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	output [1:0]                ARBURST_M1,
	output                      ARVALID_M1,
	input                       ARREADY_M1,
	//READ DATA1
	input [`AXI_ID_BITS-1:0]    RID_M1,
	input [`AXI_DATA_BITS-1:0]  RDATA_M1,
	input [1:0]                 RRESP_M1,
	input                       RLAST_M1,
	input                       RVALID_M1,
	output                      RREADY_M1
);

logic           AXI_IF_stall;
logic [31:0]    IM_addr;
logic           IM_read;
logic [31:0]    IM_instruction;

logic           AXI_MEM_stall;
logic [31:0]    DM_addr;
logic           DM_read;
logic [31:0]    DM_data_read;
logic [3:0]     DM_write_en;
logic [31:0]    DM_data_write;

CPU CPU1(
	.clk            (clk),
	.rst            (rst),

    .AXI_IF_stall   (AXI_IF_stall),
    .IM_addr        (IM_addr),
    .IM_read        (IM_read),
    .IM_instruction (IM_instruction),

    .AXI_MEM_stall  (AXI_MEM_stall),
    .DM_addr        (DM_addr),
    .DM_read        (DM_read),
    .DM_data_read   (DM_data_read),
    .DM_write_en    (DM_write_en),
    .DM_data_write  (DM_data_write)
);

//instruction memory
AXIMaster # (
    .master(0)
    )
 axi_master0(
    .clk        (clk),
    .rst        (rst),

    .address    (IM_addr),
    .read       (IM_read),
    .write      (4'b1111),
    .data_in    (32'b0),
    .data_out   (IM_instruction),
    .stall      (AXI_IF_stall),

    .ARID       (ARID_M0),
    .ARADDR     (ARADDR_M0),
    .ARLEN      (ARLEN_M0),
    .ARSIZE     (ARSIZE_M0),
    .ARBURST    (ARBURST_M0),
    .ARVALID    (ARVALID_M0),
    .ARREADY    (ARREADY_M0),

    .RID        (RID_M0),
    .RDATA      (RDATA_M0),
    .RRESP      (RRESP_M0),
    .RLAST      (RLAST_M0),
    .RVALID     (RVALID_M0),
    .RREADY     (RREADY_M0)
);

AXIMaster #(
    .master(1)
    )
 axi_master1(
    .clk        (clk),
    .rst        (rst),

    .address    (DM_addr),
    .read       (DM_read),
    .write      (DM_write_en),
    .data_in    (DM_data_write),
    .data_out   (DM_data_read),
    .stall      (AXI_MEM_stall),

    .ARID       (ARID_M1),
    .ARADDR     (ARADDR_M1),
    .ARLEN      (ARLEN_M1),
    .ARSIZE     (ARSIZE_M1),
    .ARBURST    (ARBURST_M1),
    .ARVALID    (ARVALID_M1),
    .ARREADY    (ARREADY_M1),

    .RID        (RID_M1),
    .RDATA      (RDATA_M1),
    .RRESP      (RRESP_M1),
    .RLAST      (RLAST_M1),
    .RVALID     (RVALID_M1),
    .RREADY     (RREADY_M1),

    .AWID       (AWID_M1),
    .AWADDR     (AWADDR_M1),
    .AWLEN      (AWLEN_M1),
    .AWSIZE     (AWSIZE_M1),
    .AWBURST    (AWBURST_M1),
    .AWVALID    (AWVALID_M1),
    .AWREADY    (AWREADY_M1),

    .WDATA      (WDATA_M1),
    .WSTRB      (WSTRB_M1),
    .WLAST      (WLAST_M1),
    .WVALID     (WVALID_M1),
    .WREADY     (WREADY_M1), 

    .BID        (BID_M1),
    .BRESP      (BRESP_M1),
    .BVALID     (BVALID_M1),
    .BREADY     (BREADY_M1)
);


endmodule
