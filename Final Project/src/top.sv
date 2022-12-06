`include "AXI/AXI.sv"
`include "CPU_wrapper.sv"
`include "SRAM/SRAM_wrapper.sv"
`include "DRAM_wrapper.sv"
`include "ROM_wrapper.sv"
`include "Sctrl_wrapper.sv"
`include "sensor_ctrl.sv"
`include "DMA_wrapper.sv"
`include "TPU_wrapper.sv"
`include "PLIC_wrapper.sv"

module top(
    input                       clk,
    input                       rst,
    input [`ROM_DATA_BITS-1:0]  ROM_out,
    input                       sensor_ready,
    input [31:0]                sensor_out,
    input [1:0]                 DRAM_valid,
    input [`RAM_DATA_BITS-1:0]  DRAM_Q,
    output                      ROM_read,
    output                      ROM_enable,
    output [`ROM_ADDR_BITS-1:0] ROM_address,
    output                      sensor_en,
    output                      DRAM_CSn,
    output [`AXI_STRB_BITS-1:0] DRAM_WEn,
    output                      DRAM_RASn,
    output                      DRAM_CASn,
    output [`RAM_ADDR_BITS-1:0] DRAM_A,
    output [`RAM_DATA_BITS-1:0] DRAM_D
);
wire                            aresetn = ~rst;
// ----------slave 0---------- //
// Write address channel signals
// wire    [`AXI_IDS_BITS-1:0]     awid_s0;      // Write address ID tag
// wire    [`AXI_ADDR_BITS-1:0]    awaddr_s0;    // Write address
// wire    [`AXI_LEN_BITS-1:0]     awlen_s0;     // Write address burst length
// wire    [`AXI_SIZE_BITS-1:0]    awsize_s0;    // Write address burst size
// wire    [`AXI_BURST_BITS-1:0]   awburst_s0;   // Write address burst type
// wire                            awvalid_s0;   // Write address valid
// wire                            awready_s0;   // Write address ready

// // Write data channel signals
// wire    [`AXI_DATA_BITS-1:0]    wdata_s0;     // Write data
// wire    [`AXI_DATA_BITS/8-1:0]  wstrb_s0;     // Write strobe
// wire                            wlast_s0;     // Write last
// wire                            wvalid_s0;    // Write valid
// wire                            wready_s0;    // Write ready

// // Write response channel signals
// wire    [`AXI_IDS_BITS-1:0]     bid_s0;       // Write response ID tag
// wire    [`AXI_RESP_BITS-1:0]    bresp_s0;     // Write response
// wire                            bvalid_s0;    // Write response valid
// wire                            bready_s0;    // Write response ready

// Read address channel signals
wire    [`AXI_IDS_BITS-1:0]     arid_s0;      // Read address ID tag
wire    [`AXI_ADDR_BITS-1:0]    araddr_s0;    // Read address
wire    [`AXI_LEN_BITS-1:0]     arlen_s0;     // Read address burst length
wire    [`AXI_SIZE_BITS-1:0]    arsize_s0;    // Read address burst size
wire    [`AXI_BURST_BITS-1:0]   arburst_s0;   // Read address burst type
wire                            arvalid_s0;   // Read address valid
wire                            arready_s0;   // Read address ready

// Read data channel signals
wire    [`AXI_IDS_BITS-1:0]     rid_s0;       // Read ID tag
wire    [`AXI_DATA_BITS-1:0]    rdata_s0;     // Read data
wire                            rlast_s0;     // Read last
wire                            rvalid_s0;    // Read valid
wire                            rready_s0;    // Read ready
wire    [`AXI_RESP_BITS-1:0]    rresp_s0;     // Read response

// ----------slave1---------- //
// Write address channel signals
wire    [`AXI_IDS_BITS-1:0]     awid_s1;      // Write address ID tag
wire    [`AXI_ADDR_BITS-1:0]    awaddr_s1;    // Write address
wire    [`AXI_LEN_BITS-1:0]     awlen_s1;     // Write address burst length
wire    [`AXI_SIZE_BITS-1:0]    awsize_s1;    // Write address burst size
wire    [`AXI_BURST_BITS-1:0]   awburst_s1;   // Write address burst type
wire                            awvalid_s1;   // Write address valid
wire                            awready_s1;   // Write address ready

// Write data channel signals
wire    [`AXI_DATA_BITS-1:0]    wdata_s1;     // Write data
wire    [`AXI_DATA_BITS/8-1:0]  wstrb_s1;     // Write strobe
wire                            wlast_s1;     // Write last
wire                            wvalid_s1;    // Write valid
wire                            wready_s1;    // Write ready

// Write response channel signals
wire    [`AXI_IDS_BITS-1:0]     bid_s1;       // Write response ID tag
wire    [`AXI_RESP_BITS-1:0]    bresp_s1;     // Write response
wire                            bvalid_s1;    // Write response valid
wire                            bready_s1;    // Write response ready

// Read address channel signals
wire    [`AXI_IDS_BITS-1:0]     arid_s1;      // Read address ID tag
wire    [`AXI_ADDR_BITS-1:0]    araddr_s1;    // Read address
wire    [`AXI_LEN_BITS-1:0]     arlen_s1;     // Read address burst length
wire    [`AXI_SIZE_BITS-1:0]    arsize_s1;    // Read address burst size
wire    [`AXI_BURST_BITS-1:0]   arburst_s1;   // Read address burst type
wire                            arvalid_s1;   // Read address valid
wire                            arready_s1;   // Read address ready

// Read data channel signals
wire    [`AXI_IDS_BITS-1:0]     rid_s1;       // Read ID tag
wire    [`AXI_DATA_BITS-1:0]    rdata_s1;     // Read data
wire                            rlast_s1;     // Read last
wire                            rvalid_s1;    // Read valid
wire                            rready_s1;    // Read ready
wire    [`AXI_RESP_BITS-1:0]    rresp_s1;     // Read response

// ----------slave2---------- //
// Write address channel signals
wire    [`AXI_IDS_BITS-1:0]     awid_s2;      // Write address ID tag
wire    [`AXI_ADDR_BITS-1:0]    awaddr_s2;    // Write address
wire    [`AXI_LEN_BITS-1:0]     awlen_s2;     // Write address burst length
wire    [`AXI_SIZE_BITS-1:0]    awsize_s2;    // Write address burst size
wire    [`AXI_BURST_BITS-1:0]   awburst_s2;   // Write address burst type
wire                            awvalid_s2;   // Write address valid
wire                            awready_s2;   // Write address ready

// Write data channel signals
wire    [`AXI_DATA_BITS-1:0]    wdata_s2;     // Write data
wire    [`AXI_DATA_BITS/8-1:0]  wstrb_s2;     // Write strobe
wire                            wlast_s2;     // Write last
wire                            wvalid_s2;    // Write valid
wire                            wready_s2;    // Write ready

// Write response channel signals
wire    [`AXI_IDS_BITS-1:0]     bid_s2;       // Write response ID tag
wire    [`AXI_RESP_BITS-1:0]    bresp_s2;     // Write response
wire                            bvalid_s2;    // Write response valid
wire                            bready_s2;    // Write response ready

// Read address channel signals
wire    [`AXI_IDS_BITS-1:0]     arid_s2;      // Read address ID tag
wire    [`AXI_ADDR_BITS-1:0]    araddr_s2;    // Read address
wire    [`AXI_LEN_BITS-1:0]     arlen_s2;     // Read address burst length
wire    [`AXI_SIZE_BITS-1:0]    arsize_s2;    // Read address burst size
wire    [`AXI_BURST_BITS-1:0]   arburst_s2;   // Read address burst type
wire                            arvalid_s2;   // Read address valid
wire                            arready_s2;   // Read address ready

// Read data channel signals
wire    [`AXI_IDS_BITS-1:0]     rid_s2;       // Read ID tag
wire    [`AXI_DATA_BITS-1:0]    rdata_s2;     // Read data
wire                            rlast_s2;     // Read last
wire                            rvalid_s2;    // Read valid
wire                            rready_s2;    // Read ready
wire    [`AXI_RESP_BITS-1:0]    rresp_s2;     // Read response

// ----------slave3---------- //
// Write address channel signals
wire    [`AXI_IDS_BITS-1:0]     awid_s3;      // Write address ID tag
wire    [`AXI_ADDR_BITS-1:0]    awaddr_s3;    // Write address
wire    [`AXI_LEN_BITS-1:0]     awlen_s3;     // Write address burst length
wire    [`AXI_SIZE_BITS-1:0]    awsize_s3;    // Write address burst size
wire    [`AXI_BURST_BITS-1:0]   awburst_s3;   // Write address burst type
wire                            awvalid_s3;   // Write address valid
wire                            awready_s3;   // Write address ready

// Write data channel signals
wire    [`AXI_DATA_BITS-1:0]    wdata_s3;     // Write data
wire    [`AXI_DATA_BITS/8-1:0]  wstrb_s3;     // Write strobe
wire                            wlast_s3;     // Write last
wire                            wvalid_s3;    // Write valid
wire                            wready_s3;    // Write ready

// Write response channel signals
wire    [`AXI_IDS_BITS-1:0]     bid_s3;       // Write response ID tag
wire    [`AXI_RESP_BITS-1:0]    bresp_s3;     // Write response
wire                            bvalid_s3;    // Write response valid
wire                            bready_s3;    // Write response ready

// Read address channel signals
wire    [`AXI_IDS_BITS-1:0]     arid_s3;      // Read address ID tag
wire    [`AXI_ADDR_BITS-1:0]    araddr_s3;    // Read address
wire    [`AXI_LEN_BITS-1:0]     arlen_s3;     // Read address burst length
wire    [`AXI_SIZE_BITS-1:0]    arsize_s3;    // Read address burst size
wire    [`AXI_BURST_BITS-1:0]   arburst_s3;   // Read address burst type
wire                            arvalid_s3;   // Read address valid
wire                            arready_s3;   // Read address ready

// Read data channel signals
wire    [`AXI_IDS_BITS-1:0]     rid_s3;       // Read ID tag
wire    [`AXI_DATA_BITS-1:0]    rdata_s3;     // Read data
wire                            rlast_s3;     // Read last
wire                            rvalid_s3;    // Read valid
wire                            rready_s3;    // Read ready
wire    [`AXI_RESP_BITS-1:0]    rresp_s3;     // Read response

// ----------slave4---------- //
// Write address channel signals
wire    [`AXI_IDS_BITS-1:0]     awid_s4;      // Write address ID tag
wire    [`AXI_ADDR_BITS-1:0]    awaddr_s4;    // Write address
wire    [`AXI_LEN_BITS-1:0]     awlen_s4;     // Write address burst length
wire    [`AXI_SIZE_BITS-1:0]    awsize_s4;    // Write address burst size
wire    [`AXI_BURST_BITS-1:0]   awburst_s4;   // Write address burst type
wire                            awvalid_s4;   // Write address valid
wire                            awready_s4;   // Write address ready

// Write data channel signals
wire    [`AXI_DATA_BITS-1:0]    wdata_s4;     // Write data
wire    [`AXI_DATA_BITS/8-1:0]  wstrb_s4;     // Write strobe
wire                            wlast_s4;     // Write last
wire                            wvalid_s4;    // Write valid
wire                            wready_s4;    // Write ready

// Write response channel signals
wire    [`AXI_IDS_BITS-1:0]     bid_s4;       // Write response ID tag
wire    [`AXI_RESP_BITS-1:0]    bresp_s4;     // Write response
wire                            bvalid_s4;    // Write response valid
wire                            bready_s4;    // Write response ready

// Read address channel signals
wire    [`AXI_IDS_BITS-1:0]     arid_s4;      // Read address ID tag
wire    [`AXI_ADDR_BITS-1:0]    araddr_s4;    // Read address
wire    [`AXI_LEN_BITS-1:0]     arlen_s4;     // Read address burst length
wire    [`AXI_SIZE_BITS-1:0]    arsize_s4;    // Read address burst size
wire    [`AXI_BURST_BITS-1:0]   arburst_s4;   // Read address burst type
wire                            arvalid_s4;   // Read address valid
wire                            arready_s4;   // Read address ready

// Read data channel signals
wire    [`AXI_IDS_BITS-1:0]     rid_s4;       // Read ID tag
wire    [`AXI_DATA_BITS-1:0]    rdata_s4;     // Read data
wire                            rlast_s4;     // Read last
wire                            rvalid_s4;    // Read valid
wire                            rready_s4;    // Read ready
wire    [`AXI_RESP_BITS-1:0]    rresp_s4;     // Read response

// ----------slave5---------- //
// Write address channel signals
wire    [`AXI_IDS_BITS-1:0]     awid_s5;      // Write address ID tag
wire    [`AXI_ADDR_BITS-1:0]    awaddr_s5;    // Write address
wire    [`AXI_LEN_BITS-1:0]     awlen_s5;     // Write address burst length
wire    [`AXI_SIZE_BITS-1:0]    awsize_s5;    // Write address burst size
wire    [`AXI_BURST_BITS-1:0]   awburst_s5;   // Write address burst type
wire                            awvalid_s5;   // Write address valid
wire                            awready_s5;   // Write address ready

// Write data channel signals
wire    [`AXI_DATA_BITS-1:0]    wdata_s5;     // Write data
wire    [`AXI_DATA_BITS/8-1:0]  wstrb_s5;     // Write strobe
wire                            wlast_s5;     // Write last
wire                            wvalid_s5;    // Write valid
wire                            wready_s5;    // Write ready

// Write response channel signals
wire    [`AXI_IDS_BITS-1:0]     bid_s5;       // Write response ID tag
wire    [`AXI_RESP_BITS-1:0]    bresp_s5;     // Write response
wire                            bvalid_s5;    // Write response valid
wire                            bready_s5;    // Write response ready

// Read address channel signals
wire    [`AXI_IDS_BITS-1:0]     arid_s5;      // Read address ID tag
wire    [`AXI_ADDR_BITS-1:0]    araddr_s5;    // Read address
wire    [`AXI_LEN_BITS-1:0]     arlen_s5;     // Read address burst length
wire    [`AXI_SIZE_BITS-1:0]    arsize_s5;    // Read address burst size
wire    [`AXI_BURST_BITS-1:0]   arburst_s5;   // Read address burst type
wire                            arvalid_s5;   // Read address valid
wire                            arready_s5;   // Read address ready

// Read data channel signals
wire    [`AXI_IDS_BITS-1:0]     rid_s5;       // Read ID tag
wire    [`AXI_DATA_BITS-1:0]    rdata_s5;     // Read data
wire                            rlast_s5;     // Read last
wire                            rvalid_s5;    // Read valid
wire                            rready_s5;    // Read ready
wire    [`AXI_RESP_BITS-1:0]    rresp_s5;     // Read response

// ----------slave6---------- //
// Write address channel signals
wire    [`AXI_IDS_BITS-1:0]     awid_s6;      // Write address ID tag
wire    [`AXI_ADDR_BITS-1:0]    awaddr_s6;    // Write address
wire    [`AXI_LEN_BITS-1:0]     awlen_s6;     // Write address burst length
wire    [`AXI_SIZE_BITS-1:0]    awsize_s6;    // Write address burst size
wire    [`AXI_BURST_BITS-1:0]   awburst_s6;   // Write address burst type
wire                            awvalid_s6;   // Write address valid
wire                            awready_s6;   // Write address ready

// Write data channel signals
wire    [`AXI_DATA_BITS-1:0]    wdata_s6;     // Write data
wire    [`AXI_DATA_BITS/8-1:0]  wstrb_s6;     // Write strobe
wire                            wlast_s6;     // Write last
wire                            wvalid_s6;    // Write valid
wire                            wready_s6;    // Write ready

// Write response channel signals
wire    [`AXI_IDS_BITS-1:0]     bid_s6;       // Write response ID tag
wire    [`AXI_RESP_BITS-1:0]    bresp_s6;     // Write response
wire                            bvalid_s6;    // Write response valid
wire                            bready_s6;    // Write response ready

// Read address channel signals
wire    [`AXI_IDS_BITS-1:0]     arid_s6;      // Read address ID tag
wire    [`AXI_ADDR_BITS-1:0]    araddr_s6;    // Read address
wire    [`AXI_LEN_BITS-1:0]     arlen_s6;     // Read address burst length
wire    [`AXI_SIZE_BITS-1:0]    arsize_s6;    // Read address burst size
wire    [`AXI_BURST_BITS-1:0]   arburst_s6;   // Read address burst type
wire                            arvalid_s6;   // Read address valid
wire                            arready_s6;   // Read address ready

// Read data channel signals
wire    [`AXI_IDS_BITS-1:0]     rid_s6;       // Read ID tag
wire    [`AXI_DATA_BITS-1:0]    rdata_s6;     // Read data
wire                            rlast_s6;     // Read last
wire                            rvalid_s6;    // Read valid
wire                            rready_s6;    // Read ready
wire    [`AXI_RESP_BITS-1:0]    rresp_s6;     // Read response

// ----------slave7---------- //
// Write address channel signals
wire    [`AXI_IDS_BITS-1:0]     awid_s7;      // Write address ID tag
wire    [`AXI_ADDR_BITS-1:0]    awaddr_s7;    // Write address
wire    [`AXI_LEN_BITS-1:0]     awlen_s7;     // Write address burst length
wire    [`AXI_SIZE_BITS-1:0]    awsize_s7;    // Write address burst size
wire    [`AXI_BURST_BITS-1:0]   awburst_s7;   // Write address burst type
wire                            awvalid_s7;   // Write address valid
wire                            awready_s7;   // Write address ready

// Write data channel signals
wire    [`AXI_DATA_BITS-1:0]    wdata_s7;     // Write data
wire    [`AXI_DATA_BITS/8-1:0]  wstrb_s7;     // Write strobe
wire                            wlast_s7;     // Write last
wire                            wvalid_s7;    // Write valid
wire                            wready_s7;    // Write ready

// Write response channel signals
wire    [`AXI_IDS_BITS-1:0]     bid_s7;       // Write response ID tag
wire    [`AXI_RESP_BITS-1:0]    bresp_s7;     // Write response
wire                            bvalid_s7;    // Write response valid
wire                            bready_s7;    // Write response ready

// Read address channel signals
wire    [`AXI_IDS_BITS-1:0]     arid_s7;      // Read address ID tag
wire    [`AXI_ADDR_BITS-1:0]    araddr_s7;    // Read address
wire    [`AXI_LEN_BITS-1:0]     arlen_s7;     // Read address burst length
wire    [`AXI_SIZE_BITS-1:0]    arsize_s7;    // Read address burst size
wire    [`AXI_BURST_BITS-1:0]   arburst_s7;   // Read address burst type
wire                            arvalid_s7;   // Read address valid
wire                            arready_s7;   // Read address ready

// Read data channel signals
wire    [`AXI_IDS_BITS-1:0]     rid_s7;       // Read ID tag
wire    [`AXI_DATA_BITS-1:0]    rdata_s7;     // Read data
wire                            rlast_s7;     // Read last
wire                            rvalid_s7;    // Read valid
wire                            rready_s7;    // Read ready
wire    [`AXI_RESP_BITS-1:0]    rresp_s7;     // Read response

// ----------master0---------- //
// Read address channel signals
wire    [`AXI_ID_BITS-1:0]      arid_m0;      // Read address ID tag
wire    [`AXI_ADDR_BITS-1:0]    araddr_m0;    // Read address
wire    [`AXI_LEN_BITS-1:0]     arlen_m0;     // Read address burst length
wire    [`AXI_SIZE_BITS-1:0]    arsize_m0;    // Read address burst size
wire    [`AXI_BURST_BITS-1:0]   arburst_m0;   // Read address burst type
wire                            arvalid_m0;   // Read address valid
wire                            arready_m0;   // Read address ready

// Read data channel signals
wire    [`AXI_ID_BITS-1:0]      rid_m0;       // Read ID tag
wire    [`AXI_DATA_BITS-1:0]    rdata_m0;     // Read data
wire                            rlast_m0;     // Read last
wire                            rvalid_m0;    // Read valid
wire                            rready_m0;    // Read ready
wire    [`AXI_RESP_BITS-1:0]    rresp_m0;     // Read response

// ----------master1---------- //
// Write address channel signals
wire    [`AXI_ID_BITS-1:0]      awid_m1;      // Write address ID tag
wire    [`AXI_ADDR_BITS-1:0]    awaddr_m1;    // Write address
wire    [`AXI_LEN_BITS-1:0]     awlen_m1;     // Write address burst length
wire    [`AXI_SIZE_BITS-1:0]    awsize_m1;    // Write address burst size
wire    [`AXI_BURST_BITS-1:0]   awburst_m1;   // Write address burst type
wire                            awvalid_m1;   // Write address valid
wire                            awready_m1;   // Write address ready

// Write data channel signals
wire    [`AXI_DATA_BITS-1:0]    wdata_m1;     // Write data
wire    [`AXI_DATA_BITS/8-1:0]  wstrb_m1;     // Write strobe
wire                            wlast_m1;     // Write last
wire                            wvalid_m1;    // Write valid
wire                            wready_m1;    // Write ready

// Write response channel signals
wire    [`AXI_ID_BITS-1:0]      bid_m1;       // Write response ID tag
wire    [`AXI_RESP_BITS-1:0]    bresp_m1;     // Write response
wire                            bvalid_m1;    // Write response valid
wire                            bready_m1;    // Write response ready

// Read address channel signals
wire    [`AXI_ID_BITS-1:0]      arid_m1;      // Read address ID tag
wire    [`AXI_ADDR_BITS-1:0]    araddr_m1;    // Read address
wire    [`AXI_LEN_BITS-1:0]     arlen_m1;     // Read address burst length
wire    [`AXI_SIZE_BITS-1:0]    arsize_m1;    // Read address burst size
wire    [`AXI_BURST_BITS-1:0]   arburst_m1;   // Read address burst type
wire                            arvalid_m1;   // Read address valid
wire                            arready_m1;   // Read address ready

// Read data channel signals
wire    [`AXI_ID_BITS-1:0]      rid_m1;       // Read ID tag
wire    [`AXI_DATA_BITS-1:0]    rdata_m1;     // Read data
wire                            rlast_m1;     // Read last
wire                            rvalid_m1;    // Read valid
wire                            rready_m1;    // Read ready
wire    [`AXI_RESP_BITS-1:0]    rresp_m1;     // Read response

// ----------master2---------- //
// Write address channel signals
wire    [`AXI_ID_BITS-1:0]      awid_m2;      // Write address ID tag
wire    [`AXI_ADDR_BITS-1:0]    awaddr_m2;    // Write address
wire    [`AXI_LEN_BITS-1:0]     awlen_m2;     // Write address burst length
wire    [`AXI_SIZE_BITS-1:0]    awsize_m2;    // Write address burst size
wire    [`AXI_BURST_BITS-1:0]   awburst_m2;   // Write address burst type
wire                            awvalid_m2;   // Write address valid
wire                            awready_m2;   // Write address ready

// Write data channel signals
wire    [`AXI_DATA_BITS-1:0]    wdata_m2;     // Write data
wire    [`AXI_DATA_BITS/8-1:0]  wstrb_m2;     // Write strobe
wire                            wlast_m2;     // Write last
wire                            wvalid_m2;    // Write valid
wire                            wready_m2;    // Write ready

// Write response channel signals
wire    [`AXI_ID_BITS-1:0]      bid_m2;       // Write response ID tag
wire    [`AXI_RESP_BITS-1:0]    bresp_m2;     // Write response
wire                            bvalid_m2;    // Write response valid
wire                            bready_m2;    // Write response ready

// Read address channel signals
wire    [`AXI_ID_BITS-1:0]      arid_m2;      // Read address ID tag
wire    [`AXI_ADDR_BITS-1:0]    araddr_m2;    // Read address
wire    [`AXI_LEN_BITS-1:0]     arlen_m2;     // Read address burst length
wire    [`AXI_SIZE_BITS-1:0]    arsize_m2;    // Read address burst size
wire    [`AXI_BURST_BITS-1:0]   arburst_m2;   // Read address burst type
wire                            arvalid_m2;   // Read address valid
wire                            arready_m2;   // Read address ready

// Read data channel signals
wire    [`AXI_ID_BITS-1:0]      rid_m2;       // Read ID tag
wire    [`AXI_DATA_BITS-1:0]    rdata_m2;     // Read data
wire                            rlast_m2;     // Read last
wire                            rvalid_m2;    // Read valid
wire                            rready_m2;    // Read ready
wire    [`AXI_RESP_BITS-1:0]    rresp_m2;     // Read response

// Sensor control interconnections
wire    [31:0]                  sctrl_data;
wire    [5:0]                   sctrl_addr;
wire                            sctrl_en;
wire                            sctrl_clear;
wire                            sctrl_interrupt;

wire                            dma_interrupt;
wire                            tpu_interrupt;
wire                            extern_interrupt;

ROM_wrapper ROM0(
    .clk    (clk),
    .rst    (rst),
    //READ ADDRESS
    .ARId   (arid_s0),
    .ARAddr (araddr_s0),
    .ARLen  (arlen_s0),
    .ARSize (arsize_s0),
    .ARBurst(arburst_s0),
    .ARValid(arvalid_s0),
    .ARReady(arready_s0),
    //READ DATA
    .RId    (rid_s0),
    .RData  (rdata_s0),
    .RResp  (rresp_s0),
    .RLast  (rlast_s0),
    .RValid (rvalid_s0),
    .RReady (rready_s0),
    //ROM Pins
    .CS(ROM_enable),
    .OE(ROM_read),
    .addrToROM(ROM_address),
    .dataFromROM(ROM_out)
);
// SRAM
SRAM_wrapper IM1
(
    .clock  (clk),
    .reset  (aresetn),
    // READ ADDRESS
    .ARID   (arid_s1),
    .ARADDR (araddr_s1),
    .ARLEN  (arlen_s1),
    .ARSIZE (arsize_s1),
    .ARBURST(arburst_s1),
    .ARVALID(arvalid_s1),
    .ARREADY(arready_s1),
    // READ DATA
    .RID    (rid_s1),
    .RDATA  (rdata_s1),
    .RRESP  (rresp_s1),
    .RLAST  (rlast_s1),
    .RVALID (rvalid_s1),
    .RREADY (rready_s1),
    // WRITE ADDRESS
    .AWID   (awid_s1),
    .AWADDR (awaddr_s1),
    .AWLEN  (awlen_s1),
    .AWSIZE (awsize_s1),
    .AWBURST(awburst_s1),
    .AWVALID(awvalid_s1),
    .AWREADY(awready_s1),
    // WRITE DATA
    .WDATA  (wdata_s1),
    .WSTRB  (wstrb_s1),
    .WLAST  (wlast_s1),
    .WVALID (wvalid_s1),
    .WREADY (wready_s1),
    // WRITE RESPONSE
    .BID    (bid_s1),
    .BRESP  (bresp_s1),
    .BVALID (bvalid_s1),
    .BREADY (bready_s1)
);
// SRAM
SRAM_wrapper DM1
(
    .clock  (clk),
    .reset  (aresetn),
    // READ ADDRESS
    .ARID   (arid_s2),
    .ARADDR (araddr_s2),
    .ARLEN  (arlen_s2),
    .ARSIZE (arsize_s2),
    .ARBURST(arburst_s2),
    .ARVALID(arvalid_s2),
    .ARREADY(arready_s2),
    // READ DATA
    .RID    (rid_s2),
    .RDATA  (rdata_s2),
    .RRESP  (rresp_s2),
    .RLAST  (rlast_s2),
    .RVALID (rvalid_s2),
    .RREADY (rready_s2),
    // WRITE ADDRESS
    .AWID   (awid_s2),
    .AWADDR (awaddr_s2),
    .AWLEN  (awlen_s2),
    .AWSIZE (awsize_s2),
    .AWBURST(awburst_s2),
    .AWVALID(awvalid_s2),
    .AWREADY(awready_s2),
    // WRITE DATA
    .WDATA  (wdata_s2),
    .WSTRB  (wstrb_s2),
    .WLAST  (wlast_s2),
    .WVALID (wvalid_s2),
    .WREADY (wready_s2),
    // WRITE RESPONSE
    .BID    (bid_s2),
    .BRESP  (bresp_s2),
    .BVALID (bvalid_s2),
    .BREADY (bready_s2)
);
CPU_wrapper CPU(
    .clk        (clk),
    .rst        (rst),

    /* AR Channel 0 */
    .ARId0      (arid_m0),
    .ARAddr0    (araddr_m0),
    .ARLen0     (arlen_m0),
    .ARSize0    (arsize_m0),
    .ARBurst0   (arburst_m0),
    .ARValid0   (arvalid_m0),
    .ARReady0   (arready_m0),
    /* R Channel 0 */
    .RId0       (rid_m0),
    .RData0     (rdata_m0),
    .RResp0     (rresp_m0),
    .RLast0     (rlast_m0),
    .RValid0    (rvalid_m0),
    .RReady0    (rready_m0),
    /* AR Channel 1 */
    .ARId1      (arid_m1),
    .ARAddr1    (araddr_m1),
    .ARLen1     (arlen_m1),
    .ARSize1    (arsize_m1),
    .ARBurst1   (arburst_m1),
    .ARValid1   (arvalid_m1),
    .ARReady1   (arready_m1),
    /* R Channel 1 */
    .RId1       (rid_m1),
    .RData1     (rdata_m1),
    .RResp1     (rresp_m1),
    .RLast1     (rlast_m1),
    .RValid1    (rvalid_m1),
    .RReady1    (rready_m1),
    /* AW Channel 1 */
    .AWId1      (awid_m1),
    .AWAddr1    (awaddr_m1),
    .AWLen1     (awlen_m1),
    .AWSize1    (awsize_m1),
    .AWBurst1   (awburst_m1),
    .AWValid1   (awvalid_m1),
    .AWReady1   (awready_m1),
    /* W Channel 1 */
    .WData1     (wdata_m1),
    .WStrb1     (wstrb_m1),
    .WLast1     (wlast_m1),
    .WValid1    (wvalid_m1),
    .WReady1    (wready_m1),
    /* B Channel 1 */
    .BId1       (bid_m1),
    .BResp1     (bresp_m1),
    .BValid1    (bvalid_m1),
    .BReady1    (bready_m1),

    .extern_interrupt(extern_interrupt)
);
AXI axi0(
    .ACLK(clk),
    .ARESETn(aresetn),
    //SLAVE INTERFACE FOR MASTERS
    //WRITE ADDRESS1
    .AWID_M1    (awid_m1   ),
    .AWADDR_M1  (awaddr_m1 ),
    .AWLEN_M1   (awlen_m1  ),
    .AWSIZE_M1  (awsize_m1 ),
    .AWBURST_M1 (awburst_m1),
    .AWVALID_M1 (awvalid_m1),
    .AWREADY_M1 (awready_m1),
    //WRITE DATA1
    .WDATA_M1   (wdata_m1  ),
    .WSTRB_M1   (wstrb_m1  ),
    .WLAST_M1   (wlast_m1  ),
    .WVALID_M1  (wvalid_m1 ),
    .WREADY_M1  (wready_m1 ),
    //WRITE RESPONSE1
    .BID_M1     (bid_m1    ),
    .BRESP_M1   (bresp_m1  ),
    .BVALID_M1  (bvalid_m1 ),
    .BREADY_M1  (bready_m1 ),

    //WRITE ADDRESS2
    .AWID_M2    (awid_m2   ),
    .AWADDR_M2  (awaddr_m2 ),
    .AWLEN_M2   (awlen_m2  ),
    .AWSIZE_M2  (awsize_m2 ),
    .AWBURST_M2 (awburst_m2),
    .AWVALID_M2 (awvalid_m2),
    .AWREADY_M2 (awready_m2),
    //WRITE DATA2
    .WDATA_M2   (wdata_m2  ),
    .WSTRB_M2   (wstrb_m2  ),
    .WLAST_M2   (wlast_m2  ),
    .WVALID_M2  (wvalid_m2 ),
    .WREADY_M2  (wready_m2 ),
    //WRITE RESPONSE2
    .BID_M2     (bid_m2    ),
    .BRESP_M2   (bresp_m2  ),
    .BVALID_M2  (bvalid_m2 ),
    .BREADY_M2  (bready_m2 ),

    //READ ADDRESS0
    .ARID_M0    (arid_m0   ),
    .ARADDR_M0  (araddr_m0 ),
    .ARLEN_M0   (arlen_m0  ),
    .ARSIZE_M0  (arsize_m0 ),
    .ARBURST_M0 (arburst_m0),
    .ARVALID_M0 (arvalid_m0),
    .ARREADY_M0 (arready_m0),
    //READ DATA0
    .RID_M0     (rid_m0    ),
    .RDATA_M0   (rdata_m0  ),
    .RRESP_M0   (rresp_m0  ),
    .RLAST_M0   (rlast_m0  ),
    .RVALID_M0  (rvalid_m0 ),
    .RREADY_M0  (rready_m0 ),
    //READ ADDRESS1
    .ARID_M1    (arid_m1   ),
    .ARADDR_M1  (araddr_m1 ),
    .ARLEN_M1   (arlen_m1  ),
    .ARSIZE_M1  (arsize_m1 ),
    .ARBURST_M1 (arburst_m1),
    .ARVALID_M1 (arvalid_m1),
    .ARREADY_M1 (arready_m1),
    //READ DATA1
    .RID_M1     (rid_m1    ),
    .RDATA_M1   (rdata_m1  ),
    .RRESP_M1   (rresp_m1  ),
    .RLAST_M1   (rlast_m1  ),
    .RVALID_M1  (rvalid_m1 ),
    .RREADY_M1  (rready_m1 ),
    //READ ADDRESS2
    .ARID_M2    (arid_m2   ),
    .ARADDR_M2  (araddr_m2 ),
    .ARLEN_M2   (arlen_m2  ),
    .ARSIZE_M2  (arsize_m2 ),
    .ARBURST_M2 (arburst_m2),
    .ARVALID_M2 (arvalid_m2),
    .ARREADY_M2 (arready_m2),
    //READ DATA2
    .RID_M2     (rid_m2    ),
    .RDATA_M2   (rdata_m2  ),
    .RRESP_M2   (rresp_m2  ),
    .RLAST_M2   (rlast_m2  ),
    .RVALID_M2  (rvalid_m2 ),
    .RREADY_M2  (rready_m2 ),

    //MASTER INTERFACE FOR SLAVES
    //WRITE ADDRESS0
    /*.AWID_S0    (awid_s0   ),
    .AWADDR_S0  (awaddr_s0 ),
    .AWLEN_S0   (awlen_s0  ),
    .AWSIZE_S0  (awsize_s0 ),
    .AWBURST_S0 (awburst_s0),
    .AWVALID_S0 (awvalid_s0),
    .AWREADY_S0 (awready_s0),
    //WRITE DATA0
    .WDATA_S0   (wdata_s0  ),
    .WSTRB_S0   (wstrb_s0  ),
    .WLAST_S0   (wlast_s0  ),
    .WVALID_S0  (wvalid_s0 ),
    .WREADY_S0  (wready_s0 ),
    //WRITE RESPONSE0
    .BID_S0     (bid_s0    ),
    .BRESP_S0   (bresp_s0  ),
    .BVALID_S0  (bvalid_s0 ),
    .BREADY_S0  (bready_s0 ),
    */

    //WRITE ADDRESS1
    .AWID_S1    (awid_s1   ),
    .AWADDR_S1  (awaddr_s1 ),
    .AWLEN_S1   (awlen_s1  ),
    .AWSIZE_S1  (awsize_s1 ),
    .AWBURST_S1 (awburst_s1),
    .AWVALID_S1 (awvalid_s1),
    .AWREADY_S1 (awready_s1),
    //WRITE DATA1
    .WDATA_S1   (wdata_s1  ),
    .WSTRB_S1   (wstrb_s1  ),
    .WLAST_S1   (wlast_s1  ),
    .WVALID_S1  (wvalid_s1 ),
    .WREADY_S1  (wready_s1 ),
    //WRITE RESPONSE1
    .BID_S1     (bid_s1    ),
    .BRESP_S1   (bresp_s1  ),
    .BVALID_S1  (bvalid_s1 ),
    .BREADY_S1  (bready_s1 ),

    //WRITE ADDRESS2
    .AWID_S2    (awid_s2   ),
    .AWADDR_S2  (awaddr_s2 ),
    .AWLEN_S2   (awlen_s2  ),
    .AWSIZE_S2  (awsize_s2 ),
    .AWBURST_S2 (awburst_s2),
    .AWVALID_S2 (awvalid_s2),
    .AWREADY_S2 (awready_s2),
    //WRITE DATA2
    .WDATA_S2   (wdata_s2  ),
    .WSTRB_S2   (wstrb_s2  ),
    .WLAST_S2   (wlast_s2  ),
    .WVALID_S2  (wvalid_s2 ),
    .WREADY_S2  (wready_s2 ),
    //WRITE RESPONSE2
    .BID_S2     (bid_s2    ),
    .BRESP_S2   (bresp_s2  ),
    .BVALID_S2  (bvalid_s2 ),
    .BREADY_S2  (bready_s2 ),

    //WRITE ADDRESS3
    .AWID_S3    (awid_s3   ),
    .AWADDR_S3  (awaddr_s3 ),
    .AWLEN_S3   (awlen_s3  ),
    .AWSIZE_S3  (awsize_s3 ),
    .AWBURST_S3 (awburst_s3),
    .AWVALID_S3 (awvalid_s3),
    .AWREADY_S3 (awready_s3),
    //WRITE DATA3
    .WDATA_S3   (wdata_s3  ),
    .WSTRB_S3   (wstrb_s3  ),
    .WLAST_S3   (wlast_s3  ),
    .WVALID_S3  (wvalid_s3 ),
    .WREADY_S3  (wready_s3 ),
    //WRITE RESPONSE3
    .BID_S3     (bid_s3    ),
    .BRESP_S3   (bresp_s3  ),
    .BVALID_S3  (bvalid_s3 ),
    .BREADY_S3  (bready_s3 ),

    //WRITE ADDRESS4
    .AWID_S4    (awid_s4   ),
    .AWADDR_S4  (awaddr_s4 ),
    .AWLEN_S4   (awlen_s4  ),
    .AWSIZE_S4  (awsize_s4 ),
    .AWBURST_S4 (awburst_s4),
    .AWVALID_S4 (awvalid_s4),
    .AWREADY_S4 (awready_s4),
    //WRITE DATA4
    .WDATA_S4   (wdata_s4  ),
    .WSTRB_S4   (wstrb_s4  ),
    .WLAST_S4   (wlast_s4  ),
    .WVALID_S4  (wvalid_s4 ),
    .WREADY_S4  (wready_s4 ),
    //WRITE RESPONSE4
    .BID_S4     (bid_s4    ),
    .BRESP_S4   (bresp_s4  ),
    .BVALID_S4  (bvalid_s4 ),
    .BREADY_S4  (bready_s4 ),

    //WRITE ADDRESS5
    .AWID_S5    (awid_s5   ),
    .AWADDR_S5  (awaddr_s5 ),
    .AWLEN_S5   (awlen_s5  ),
    .AWSIZE_S5  (awsize_s5 ),
    .AWBURST_S5 (awburst_s5),
    .AWVALID_S5 (awvalid_s5),
    .AWREADY_S5 (awready_s5),
    //WRITE DATA5
    .WDATA_S5   (wdata_s5  ),
    .WSTRB_S5   (wstrb_s5  ),
    .WLAST_S5   (wlast_s5  ),
    .WVALID_S5  (wvalid_s5 ),
    .WREADY_S5  (wready_s5 ),
    //WRITE RESPONSE5
    .BID_S5     (bid_s5    ),
    .BRESP_S5   (bresp_s5  ),
    .BVALID_S5  (bvalid_s5 ),
    .BREADY_S5  (bready_s5 ),

    //WRITE ADDRESS6
    .AWID_S6    (awid_s6   ),
    .AWADDR_S6  (awaddr_s6 ),
    .AWLEN_S6   (awlen_s6  ),
    .AWSIZE_S6  (awsize_s6 ),
    .AWBURST_S6 (awburst_s6),
    .AWVALID_S6 (awvalid_s6),
    .AWREADY_S6 (awready_s6),
    //WRITE DATA6
    .WDATA_S6   (wdata_s6  ),
    .WSTRB_S6   (wstrb_s6  ),
    .WLAST_S6   (wlast_s6  ),
    .WVALID_S6  (wvalid_s6 ),
    .WREADY_S6  (wready_s6 ),
    //WRITE RESPONSE6
    .BID_S6     (bid_s6    ),
    .BRESP_S6   (bresp_s6  ),
    .BVALID_S6  (bvalid_s6 ),
    .BREADY_S6  (bready_s6 ),

    //WRITE ADDRESS7
    .AWID_S7    (awid_s7   ),
    .AWADDR_S7  (awaddr_s7 ),
    .AWLEN_S7   (awlen_s7  ),
    .AWSIZE_S7  (awsize_s7 ),
    .AWBURST_S7 (awburst_s7),
    .AWVALID_S7 (awvalid_s7),
    .AWREADY_S7 (awready_s7),
    //WRITE DATA7
    .WDATA_S7   (wdata_s7  ),
    .WSTRB_S7   (wstrb_s7  ),
    .WLAST_S7   (wlast_s7  ),
    .WVALID_S7  (wvalid_s7 ),
    .WREADY_S7  (wready_s7 ),
    //WRITE RESPONSE7
    .BID_S7     (bid_s7    ),
    .BRESP_S7   (bresp_s7  ),
    .BVALID_S7  (bvalid_s7 ),
    .BREADY_S7  (bready_s7 ),

    //READ ADDRESS0
    .ARID_S0    (arid_s0   ),
    .ARADDR_S0  (araddr_s0 ),
    .ARLEN_S0   (arlen_s0  ),
    .ARSIZE_S0  (arsize_s0 ),
    .ARBURST_S0 (arburst_s0),
    .ARVALID_S0 (arvalid_s0),
    .ARREADY_S0 (arready_s0),
    //READ DATA0
    .RID_S0     (rid_s0    ),
    .RDATA_S0   (rdata_s0  ),
    .RRESP_S0   (rresp_s0  ),
    .RLAST_S0   (rlast_s0  ),
    .RVALID_S0  (rvalid_s0 ),
    .RREADY_S0  (rready_s0 ),

    //READ ADDRESS1
    .ARID_S1    (arid_s1   ),
    .ARADDR_S1  (araddr_s1 ),
    .ARLEN_S1   (arlen_s1  ),
    .ARSIZE_S1  (arsize_s1 ),
    .ARBURST_S1 (arburst_s1),
    .ARVALID_S1 (arvalid_s1),
    .ARREADY_S1 (arready_s1),
    //READ DATA1
    .RID_S1     (rid_s1    ),
    .RDATA_S1   (rdata_s1  ),
    .RRESP_S1   (rresp_s1  ),
    .RLAST_S1   (rlast_s1  ),
    .RVALID_S1  (rvalid_s1 ),
    .RREADY_S1  (rready_s1 ),

    //READ ADDRESS2
    .ARID_S2    (arid_s2   ),
    .ARADDR_S2  (araddr_s2 ),
    .ARLEN_S2   (arlen_s2  ),
    .ARSIZE_S2  (arsize_s2 ),
    .ARBURST_S2 (arburst_s2),
    .ARVALID_S2 (arvalid_s2),
    .ARREADY_S2 (arready_s2),
    //READ DATA2
    .RID_S2     (rid_s2    ),
    .RDATA_S2   (rdata_s2  ),
    .RRESP_S2   (rresp_s2  ),
    .RLAST_S2   (rlast_s2  ),
    .RVALID_S2  (rvalid_s2 ),
    .RREADY_S2  (rready_s2 ),

    //READ ADDRESS3
    .ARID_S3    (arid_s3   ),
    .ARADDR_S3  (araddr_s3 ),
    .ARLEN_S3   (arlen_s3  ),
    .ARSIZE_S3  (arsize_s3 ),
    .ARBURST_S3 (arburst_s3),
    .ARVALID_S3 (arvalid_s3),
    .ARREADY_S3 (arready_s3),
    //READ DATA3
    .RID_S3     (rid_s3    ),
    .RDATA_S3   (rdata_s3  ),
    .RRESP_S3   (rresp_s3  ),
    .RLAST_S3   (rlast_s3  ),
    .RVALID_S3  (rvalid_s3 ),
    .RREADY_S3  (rready_s3 ),

    //READ ADDRESS4
    .ARID_S4    (arid_s4   ),
    .ARADDR_S4  (araddr_s4 ),
    .ARLEN_S4   (arlen_s4  ),
    .ARSIZE_S4  (arsize_s4 ),
    .ARBURST_S4 (arburst_s4),
    .ARVALID_S4 (arvalid_s4),
    .ARREADY_S4 (arready_s4),
    //READ DATA4
    .RID_S4     (rid_s4    ),
    .RDATA_S4   (rdata_s4  ),
    .RRESP_S4   (rresp_s4  ),
    .RLAST_S4   (rlast_s4  ),
    .RVALID_S4  (rvalid_s4 ),
    .RREADY_S4  (rready_s4 ),

    //READ ADDRESS5
    .ARID_S5    (arid_s5   ),
    .ARADDR_S5  (araddr_s5 ),
    .ARLEN_S5   (arlen_s5  ),
    .ARSIZE_S5  (arsize_s5 ),
    .ARBURST_S5 (arburst_s5),
    .ARVALID_S5 (arvalid_s5),
    .ARREADY_S5 (arready_s5),
    //READ DATA5
    .RID_S5     (rid_s5    ),
    .RDATA_S5   (rdata_s5  ),
    .RRESP_S5   (rresp_s5  ),
    .RLAST_S5   (rlast_s5  ),
    .RVALID_S5  (rvalid_s5 ),
    .RREADY_S5  (rready_s5 ),

    //READ ADDRESS6
    .ARID_S6    (arid_s6   ),
    .ARADDR_S6  (araddr_s6 ),
    .ARLEN_S6   (arlen_s6  ),
    .ARSIZE_S6  (arsize_s6 ),
    .ARBURST_S6 (arburst_s6),
    .ARVALID_S6 (arvalid_s6),
    .ARREADY_S6 (arready_s6),
    //READ DATA6
    .RID_S6     (rid_s6    ),
    .RDATA_S6   (rdata_s6  ),
    .RRESP_S6   (rresp_s6  ),
    .RLAST_S6   (rlast_s6  ),
    .RVALID_S6  (rvalid_s6 ),
    .RREADY_S6  (rready_s6 ),
    
    //READ ADDRESS7
    .ARID_S7    (arid_s7   ),
    .ARADDR_S7  (araddr_s7 ),
    .ARLEN_S7   (arlen_s7  ),
    .ARSIZE_S7  (arsize_s7 ),
    .ARBURST_S7 (arburst_s7),
    .ARVALID_S7 (arvalid_s7),
    .ARREADY_S7 (arready_s7),
    //READ DATA7
    .RID_S7     (rid_s7    ),
    .RDATA_S7   (rdata_s7  ),
    .RRESP_S7   (rresp_s7  ),
    .RLAST_S7   (rlast_s7  ),
    .RVALID_S7  (rvalid_s7 ),
    .RREADY_S7  (rready_s7 )
);

DRAM_wrapper DRAM0 (
    .clk    (clk),
    .rst    (rst),
    //READ ADDRESS
    .ARId   (arid_s4),
    .ARAddr (araddr_s4),
    .ARLen  (arlen_s4),
    .ARSize (arsize_s4),
    .ARBurst(arburst_s4),
    .ARValid(arvalid_s4),
    .ARReady(arready_s4),
    //READ DATA
    .RId    (rid_s4),
    .RData  (rdata_s4),
    .RResp  (rresp_s4),
    .RLast  (rlast_s4),
    .RValid (rvalid_s4),
    .RReady (rready_s4),
    //WRITE ADDRESS
    .AWId   (awid_s4),
    .AWAddr (awaddr_s4),
    .AWLen  (awlen_s4),
    .AWSize (awsize_s4),
    .AWBurst(awburst_s4),
    .AWValid(awvalid_s4),
    .AWReady(awready_s4),
    //WRITE DATA
    .WData  (wdata_s4),
    .WStrb  (wstrb_s4),
    .WLast  (wlast_s4),
    .WValid (wvalid_s4),
    .WReady (wready_s4),
    //WRITE RESPONSE
    .BId    (bid_s4),
    .BResp  (bresp_s4),
    .BValid (bvalid_s4),
    .BReady (bready_s4),
    //DRAM Pins
    .readQ(DRAM_Q),
    .CSn(DRAM_CSn),
    .WEn(DRAM_WEn),
    .RASn(DRAM_RASn),
    .CASn(DRAM_CASn),
    .addrDRAM(DRAM_A),
    .writeD(DRAM_D),
    .dramValid(DRAM_valid)
);

Sctrl_wrapper Sctrl_Wrapper0 (
    .clk(clk),
    .rst(rst),
    //READ ADDRESS
    .ARId   (arid_s3),
    .ARAddr (araddr_s3),
    .ARLen  (arlen_s3),
    .ARSize (arsize_s3),
    .ARBurst(arburst_s3),
    .ARValid(arvalid_s3),
    .ARReady(arready_s3),
    //READ DATA
    .RId    (rid_s3),
    .RData  (rdata_s3),
    .RResp  (rresp_s3),
    .RLast  (rlast_s3),
    .RValid (rvalid_s3),
    .RReady (rready_s3),
    //WRITE ADDRESS
    .AWId   (awid_s3),
    .AWAddr (awaddr_s3),
    .AWLen  (awlen_s3),
    .AWSize (awsize_s3),
    .AWBurst(awburst_s3),
    .AWValid(awvalid_s3),
    .AWReady(awready_s3),
    //WRITE DATA
    .WData  (wdata_s3),
    .WStrb  (wstrb_s3),
    .WLast  (wlast_s3),
    .WValid (wvalid_s3),
    .WReady (wready_s3),
    //WRITE RESPONSE
    .BId    (bid_s3),
    .BResp  (bresp_s3),
    .BValid (bvalid_s3),
    .BReady (bready_s3),

    .dataFromSCtrl(sctrl_data),
    .enableSCtrl(sctrl_en),
    .clearSCtrl(sctrl_clear),
    .addrToSCtrl(sctrl_addr)
);

DMA_wrapper DMA0 (
    .clock(clk),
	.reset(aresetn),
    // AXI Slave
    // READ ADDRESS
	.ARID_S(arid_s5),
	.ARADDR_S(araddr_s5),
	.ARLEN_S(arlen_s5),
	.ARSIZE_S(arsize_s5),
	.ARBURST_S(arburst_s5),
	.ARVALID_S(arvalid_s5),
	.ARREADY_S(arready_s5),
	// READ DATA
	.RID_S(rid_s5),
	.RDATA_S(rdata_s5),
	.RRESP_S(rresp_s5),
	.RLAST_S(rlast_s5),
	.RVALID_S(rvalid_s5),
	.RREADY_S(rready_s5),
    // WRITE ADDRESS
	.AWID_S(awid_s5),
	.AWADDR_S(awaddr_s5),
	.AWLEN_S(awlen_s5),
	.AWSIZE_S(awsize_s5),
	.AWBURST_S(awburst_s5),
	.AWVALID_S(awvalid_s5),
	.AWREADY_S(awready_s5),
	// WRITE DATA
	.WDATA_S(wdata_s5),
	.WSTRB_S(wstrb_s5),
	.WLAST_S(wlast_s5),
	.WVALID_S(wvalid_s5),
	.WREADY_S(wready_s5),
	// WRITE RESPONSE
	.BID_S(bid_s5),
	.BRESP_S(bresp_s5),
	.BVALID_S(bvalid_s5),
	.BREADY_S(bready_s5),
    // AXI Master Read
    // READ ADDRESS
	.ARID_M(arid_m2),
	.ARADDR_M(araddr_m2),
	.ARLEN_M(arlen_m2),
	.ARSIZE_M(arsize_m2),
	.ARBURST_M(arburst_m2),
	.ARVALID_M(arvalid_m2),
	.ARREADY_M(arready_m2),
	// READ DATA
	.RID_M(rid_m2),
	.RDATA_M(rdata_m2),
	.RRESP_M(rresp_m2),
	.RLAST_M(rlast_m2),
	.RVALID_M(rvalid_m2),
	.RREADY_M(rready_m2),
    // AXI Master Write
    // WRITE ADDRESS
	.AWID_M(awid_m2),
	.AWADDR_M(awaddr_m2),
	.AWLEN_M(awlen_m2),
	.AWSIZE_M(awsize_m2),
	.AWBURST_M(awburst_m2),
	.AWVALID_M(awvalid_m2),
	.AWREADY_M(awready_m2),
	// WRITE DATA
	.WDATA_M(wdata_m2),
	.WSTRB_M(wstrb_m2),
	.WLAST_M(wlast_m2),
	.WVALID_M(wvalid_m2),
	.WREADY_M(wready_m2),
	// WRITE RESPONSE
	.BID_M(bid_m2),
	.BRESP_M(bresp_m2),
	.BVALID_M(bvalid_m2),
	.BREADY_M(bready_m2),
    // Interrupt
    .interrupt(dma_interrupt)
);

sensor_ctrl sensor_ctrl0(
    .clk(clk),
    .rst(rst),
    // Core inputs
    .sctrl_en(sctrl_en),
    .sctrl_clear(sctrl_clear),
    .sctrl_addr(sctrl_addr),
    // Sensor inputs
    .sensor_ready(sensor_ready),
    .sensor_out(sensor_out),
    // Core outputs
    .sctrl_interrupt(sctrl_interrupt),
    .sctrl_out(sctrl_data),
    // Sensor outputs
    .sensor_en(sensor_en)
);

TPU_wrapper TPU_wrapper0(
    .clk(clk),
    .rst(rst),

    //READ ADDRESS
    .ARId(arid_s6),
    .ARAddr(araddr_s6),
    .ARLen(arlen_s6),
    .ARSize(arsize_s6),
    .ARBurst(arburst_s6),
    .ARValid(arvalid_s6),
    .ARReady(arready_s6),
    //READ DATA
    .RId(rid_s6),
    .RData(rdata_s6),
    .RResp(rresp_s6),
    .RLast(rlast_s6),
    .RValid(rvalid_s6),
    .RReady(rready_s6),
    //WRITE ADDRESS
    .AWId(awid_s6),
    .AWAddr(awaddr_s6),
    .AWLen(awlen_s6),
    .AWSize(awsize_s6),
    .AWBurst(awburst_s6),
    .AWValid(awvalid_s6),
    .AWReady(awready_s6),
    //WRITE DATA
    .WData(wdata_s6),
    .WStrb(wstrb_s6),
    .WLast(wlast_s6),
    .WValid(wvalid_s6),
    .WReady(wready_s6),
    //WRITE RESPONSE
    .BId(bid_s6),
    .BResp(bresp_s6),
    .BValid(bvalid_s6),
    .BReady(bready_s6),

    //TPU Interrupt
    .TPUDone(tpu_interrupt)
);

// PLIC
PLIC_wrapper PLIC1
(
    .clk(clk),
    .rst(rst),

    //READ ADDRESS
    .ARId(arid_s7),
    .ARAddr(araddr_s7),
    .ARLen(arlen_s7),
    .ARSize(arsize_s7),
    .ARBurst(arburst_s7),
    .ARValid(arvalid_s7),
    .ARReady(arready_s7),
    //READ DATA
    .RId(rid_s7),
    .RData(rdata_s7),
    .RResp(rresp_s7),
    .RLast(rlast_s7),
    .RValid(rvalid_s7),
    .RReady(rready_s7),
    //WRITE ADDRESS
    .AWId(awid_s7),
    .AWAddr(awaddr_s7),
    .AWLen(awlen_s7),
    .AWSize(awsize_s7),
    .AWBurst(awburst_s7),
    .AWValid(awvalid_s7),
    .AWReady(awready_s7),
    //WRITE DATA
    .WData(wdata_s7),
    .WStrb(wstrb_s7),
    .WLast(wlast_s7),
    .WValid(wvalid_s7),
    .WReady(wready_s7),
    //WRITE RESPONSE
    .BId(bid_s7),
    .BResp(bresp_s7),
    .BValid(bvalid_s7),
    .BReady(bready_s7),

    .sensor_pend(sctrl_interrupt),
    .dma_pend(dma_interrupt),
    .tpu_pend(tpu_interrupt),
    .pend_toCPU(extern_interrupt)
);

endmodule
