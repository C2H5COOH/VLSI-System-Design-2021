`include "CPU/Cache/L1C_inst.sv"
`include "CPU/Cache/L1C_data.sv"
`include "CPU/CPU.sv"
`include "AXI/AXI_master/AXI_master.sv"
// `include "Cache/L1C_inst.sv"
// `include "Cache/L1C_data.sv"
// `include "CPU.sv"
// `include "../AXI/AXI_master/AXI_master.sv"

module CPU_wrapper(
    input                       clk,rst,
    input                       interrupt,

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

logic           core_IF_stall;
logic [31:0]    core_IM_addr;
logic           core_IM_read;
logic [31:0]    core_IM_instruction;
logic           core_IM_jb;

logic           core_MEM_stall;
logic [31:0]    core_DM_addr;
logic           core_DM_read;
logic [31:0]    core_DM_data_read;
logic [3:0]     core_DM_write_en;
logic [31:0]    core_DM_data_write;

logic [`DATA_BITS-1:0]          I_read_data;
logic					        I_wait;

logic 					        I_req;
logic [`DATA_BITS-1:0] 	        I_addr;
logic 					        I_write;
logic [`DATA_BITS-1:0] 	        I_write_data;
logic [`CACHE_TYPE_BITS-1:0]    I_type;

logic [`DATA_BITS-1:0] 	        D_read_data;
logic					        D_wait;
logic 					        D_req_read;
logic [`DATA_BITS-1:0] 	        D_addr;
logic 					        D_write; // won't use
logic [`DATA_BITS-1:0] 	        D_write_data;
logic [`CACHE_TYPE_BITS-1:0]    D_type; // won't use
logic [3:0]				        D_strb;

CPU CPU1(
	.clk            (clk),
	.rst            (rst),

    .AXI_IF_stall   (core_IF_stall),
    .IM_addr        (core_IM_addr),
    .IM_read        (core_IM_read),
    .IM_instruction (core_IM_instruction),
    .IM_jb          (core_IM_jb),

    .AXI_MEM_stall  (core_MEM_stall),
    .DM_addr        (core_DM_addr),
    .DM_read        (core_DM_read),
    .DM_data_read   (core_DM_data_read),
    .DM_write_en    (core_DM_write_en),
    .DM_data_write  (core_DM_data_write),

    .interrupt      (interrupt)
);


L1C_inst cache_i(
    .clk        (clk),
    .rst        (rst),

    .core_addr  (core_IM_addr),
    .core_req   (core_IM_read),
    .core_jb    (core_IM_jb),

    .core_out   (core_IM_instruction),
    .core_wait  (core_IF_stall),

    .I_out      (I_read_data),
    .I_wait     (I_wait),

    .I_req      (I_req),
    .I_addr     (I_addr)
);

logic dc_core_req;
assign dc_core_req = (core_DM_read) || ~(&core_DM_write_en);

L1C_data cache_d(
    .clk        (clk),
    .rst        (rst),

    .core_addr  (core_DM_addr),
    .core_req   (dc_core_req),
    .core_in    (core_DM_data_write),
    .core_strb  (core_DM_write_en),

    .core_out   (core_DM_data_read),
    .core_wait  (core_MEM_stall),

    .D_out      (D_read_data),
    .D_wait     (D_wait),

    .D_req_read (D_req_read),
    .D_addr     (D_addr),
    .D_in       (D_write_data),
    .D_strb     (D_strb)
);

//instruction memory
AXIMaster # (
    .master(0)
    )
 axi_master0(
    .clk        (clk),
    .rst        (rst),

    .address    (I_addr),
    .read       (I_req),
    .write      (4'b1111),
    .data_in    (32'b0),
    .data_out   (I_read_data),
    .stall      (I_wait),

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

    .address    (D_addr),
    .read       (D_req_read),
    .write      (D_strb),
    .data_in    (D_write_data),
    .data_out   (D_read_data),
    .stall      (D_wait),

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
