// Developer:         Johnson Liu
// Modified by William
`include "CPU_wrapper.sv"
`include "AXI/AXI.sv"
`include "SRAM_wrapper.sv"

module top (
    input clk, 
    input rst
);
  
// ---------------------------------master--------------------------------- //
    // ---------master0------------ //
    // Read address channel signals
    logic    [`AXI_ID_BITS-1:0]      arid_m0;      // Read address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    araddr_m0;    // Read address
    logic    [`AXI_LEN_BITS-1:0]     arlen_m0;     // Read address burst length
    logic    [`AXI_SIZE_BITS-1:0]    arsize_m0;    // Read address burst size
    logic    [`AXI_BURST_BITS-1:0]   arburst_m0;   // Read address burst type
    logic                        arvalid_m0;   // Read address valid
    logic                        arready_m0;   // Read address ready

    // Read data channel signals
    logic    [`AXI_ID_BITS-1:0]      rid_m0;       // Read ID tag
    logic    [`AXI_DATA_BITS-1:0]    rdata_m0;     // Read data
    logic                        rlast_m0;     // Read last
    logic                        rvalid_m0;    // Read valid
    logic                        rready_m0;    // Read ready
    logic    [`AXI_RESP_BITS-1:0]   rresp_m0;     // Read response

    // ----------master1---------- //
    // Write address channel signals
    logic    [`AXI_ID_BITS-1:0]      awid_m1;      // Write address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    awaddr_m1;    // Write address
    logic    [`AXI_LEN_BITS-1:0]     awlen_m1;     // Write address burst length
    logic    [`AXI_SIZE_BITS-1:0]    awsize_m1;    // Write address burst size
    logic    [`AXI_BURST_BITS-1:0]   awburst_m1;   // Write address burst type
    logic                        awvalid_m1;   // Write address valid
    logic                        awready_m1;   // Write address ready

    // Write data channel signals
    logic    [`AXI_DATA_BITS-1:0]    wdata_m1;     // Write data
    logic    [`AXI_STRB_BITS-1:0]  wstrb_m1;     // Write strobe
    logic                        wlast_m1;     // Write last
    logic                        wvalid_m1;    // Write valid
    logic                        wready_m1;    // Write ready
    // Write response channel signals
    logic    [`AXI_ID_BITS-1:0]      bid_m1;       // Write response ID tag
    logic    [`AXI_RESP_BITS-1:0]   bresp_m1;     // Write response
    logic                        bvalid_m1;    // Write response valid
    logic                        bready_m1;    // Write response ready
    // Read address channel signals
    logic    [`AXI_ID_BITS-1:0]      arid_m1;      // Read address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    araddr_m1;    // Read address
    logic    [`AXI_LEN_BITS-1:0]     arlen_m1;     // Read address burst length
    logic    [`AXI_SIZE_BITS-1:0]    arsize_m1;    // Read address burst size
    logic    [`AXI_BURST_BITS-1:0]   arburst_m1;   // Read address burst type
    logic                        arvalid_m1;   // Read address valid
    logic                        arready_m1;   // Read address ready

    // Read data channel signals
    logic    [`AXI_ID_BITS-1:0]      rid_m1;       // Read ID tag
    logic    [`AXI_DATA_BITS-1:0]    rdata_m1;     // Read data
    logic                        rlast_m1;     // Read last
    logic                        rvalid_m1;    // Read valid
    logic                        rready_m1;    // Read ready
    logic    [`AXI_RESP_BITS-1:0]   rresp_m1;     // Read response

// ---------------------------------slave--------------------------------- //
    // ----------slave0---------- //
    // Write address channel signals
    logic    [`AXI_IDS_BITS-1:0]      awid_s0;      // Write address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    awaddr_s0;    // Write address
    logic    [`AXI_LEN_BITS-1:0]     awlen_s0;     // Write address burst length
    logic    [`AXI_SIZE_BITS-1:0]    awsize_s0;    // Write address burst size
    logic    [`AXI_BURST_BITS-1:0]   awburst_s0;   // Write address burst type

    logic                        awvalid_s0;   // Write address valid
    logic                        awready_s0;   // Write address ready
    // Write data channel signals
    logic    [`AXI_DATA_BITS-1:0]    wdata_s0;     // Write data
    logic    [`AXI_STRB_BITS-1:0]  wstrb_s0;     // Write strobe
    logic                        wlast_s0;     // Write last
    logic                        wvalid_s0;    // Write valid
    logic                        wready_s0;    // Write ready
    // Write response channel signals
    logic    [`AXI_IDS_BITS-1:0]      bid_s0;       // Write response ID tag
    logic    [`AXI_RESP_BITS-1:0]    bresp_s0;     // Write response
    logic                        bvalid_s0;    // Write response valid
    logic                       bready_s0;    // Write response ready
    // Read address channel signals
    logic    [`AXI_IDS_BITS-1:0]      arid_s0;      // Read address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    araddr_s0;    // Read address
    logic    [`AXI_LEN_BITS-1:0]     arlen_s0;     // Read address burst length
    logic    [`AXI_SIZE_BITS-1:0]    arsize_s0;    // Read address burst size
    logic    [`AXI_BURST_BITS-1:0]   arburst_s0;   // Read address burst type
    logic                        arvalid_s0;   // Read address valid
    logic                        arready_s0;   // Read address ready
    // Read data channel signals
    logic    [`AXI_IDS_BITS-1:0]      rid_s0;       // Read ID tag
    logic    [`AXI_DATA_BITS-1:0]    rdata_s0;     // Read data
    logic                       rlast_s0;     // Read last
    logic                       rvalid_s0;    // Read valid
    logic                        rready_s0;    // Read ready
    logic    [`AXI_RESP_BITS-1:0]    rresp_s0;     // Read response

    // ----------slave1---------- //
    logic    [`AXI_IDS_BITS-1:0]      awid_s1;      // Write address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    awaddr_s1;    // Write address
    logic    [`AXI_LEN_BITS-1:0]     awlen_s1;     // Write address burst length
    logic    [`AXI_SIZE_BITS-1:0]    awsize_s1;    // Write address burst size
    logic    [`AXI_BURST_BITS-1:0]   awburst_s1;   // Write address burst type

    logic                        awvalid_s1;   // Write address valid
    logic                        awready_s1;   // Write address ready
    // Write data channel signals
    logic    [`AXI_DATA_BITS-1:0]    wdata_s1;     // Write data
    logic    [`AXI_STRB_BITS-1:0]  wstrb_s1;     // Write strobe
    logic                        wlast_s1;     // Write last
    logic                        wvalid_s1;    // Write valid
    logic                        wready_s1;    // Write ready
    // Write response channel signals
    logic    [`AXI_IDS_BITS-1:0]      bid_s1;       // Write response ID tag
    logic    [`AXI_RESP_BITS-1:0]    bresp_s1;     // Write response
    logic                        bvalid_s1;    // Write response valid
    logic                       bready_s1;    // Write response ready
    // Read address channel signals
    logic    [`AXI_IDS_BITS-1:0]      arid_s1;      // Read address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    araddr_s1;    // Read address
    logic    [`AXI_LEN_BITS-1:0]     arlen_s1;     // Read address burst length
    logic    [`AXI_SIZE_BITS-1:0]    arsize_s1;    // Read address burst size
    logic    [`AXI_BURST_BITS-1:0]   arburst_s1;   // Read address burst type
    logic                        arvalid_s1;   // Read address valid
    logic                        arready_s1;   // Read address ready
    // Read data channel signals
    logic    [`AXI_IDS_BITS-1:0]      rid_s1;       // Read ID tag
    logic    [`AXI_DATA_BITS-1:0]    rdata_s1;     // Read data
    logic                       rlast_s1;     // Read last
    logic                       rvalid_s1;    // Read valid
    logic                        rready_s1;    // Read ready
    logic    [`AXI_RESP_BITS-1:0]    rresp_s1;     // Read response

    // CPU
    CPU_wrapper cpu(
        .clk(clk),
        .rst(rst),

        .AWID_M1(awid_m1),
        .AWADDR_M1(awaddr_m1),
        .AWLEN_M1(awlen_m1),
        .AWSIZE_M1(awsize_m1),
        .AWBURST_M1(awburst_m1),
        .AWVALID_M1(awvalid_m1),
        .AWREADY_M1(awready_m1),

        .WDATA_M1(wdata_m1),
        .WSTRB_M1(wstrb_m1),
        .WLAST_M1(wlast_m1),
        .WVALID_M1(wvalid_m1),
        .WREADY_M1(wready_m1),

        .BID_M1(bid_m1),
        .BRESP_M1(bresp_m1),
        .BVALID_M1(bvalid_m1),
        .BREADY_M1(bready_m1),

        .ARID_M0(arid_m0),
        .ARADDR_M0(araddr_m0),
        .ARLEN_M0(arlen_m0),
        .ARSIZE_M0(arsize_m0),
        .ARBURST_M0(arburst_m0),
        .ARVALID_M0(arvalid_m0),
        .ARREADY_M0(arready_m0),

        .RID_M0(rid_m0),
        .RDATA_M0(rdata_m0),
        .RRESP_M0(rresp_m0),
        .RLAST_M0(rlast_m0),
        .RVALID_M0(rvalid_m0),
        .RREADY_M0(rready_m0),

        .ARID_M1(arid_m1),
        .ARADDR_M1(araddr_m1),
        .ARLEN_M1(arlen_m1),
        .ARSIZE_M1(arsize_m1),
        .ARBURST_M1(arburst_m1),
        .ARVALID_M1(arvalid_m1),
        .ARREADY_M1(arready_m1),

        .RID_M1(rid_m1),
        .RDATA_M1(rdata_m1),
        .RRESP_M1(rresp_m1),
        .RLAST_M1(rlast_m1),
        .RVALID_M1(rvalid_m1),
        .RREADY_M1(rready_m1)
    );

    // Bridge
    AXI axi_duv_bridge(
        .ACLK       (clk ),
        .ARESETn    (~rst ),
        .AWID_M1    (awid_m1   ),
        .AWADDR_M1  (awaddr_m1 ),
        .AWLEN_M1   (awlen_m1  ),
        .AWSIZE_M1  (awsize_m1 ),
        .AWBURST_M1 (awburst_m1),
        .AWVALID_M1 (awvalid_m1),
        .AWREADY_M1 (awready_m1),
        .WDATA_M1   (wdata_m1  ),
        .WSTRB_M1   (wstrb_m1  ),
        .WLAST_M1   (wlast_m1  ),
        .WVALID_M1  (wvalid_m1 ),
        .WREADY_M1  (wready_m1 ),
        .BID_M1     (bid_m1    ),
        .BRESP_M1   (bresp_m1  ),
        .BVALID_M1  (bvalid_m1 ),
        .BREADY_M1  (bready_m1 ),
        .ARID_M0    (arid_m0   ),
        .ARADDR_M0  (araddr_m0 ),
        .ARLEN_M0   (arlen_m0  ),
        .ARSIZE_M0  (arsize_m0 ),
        .ARBURST_M0 (arburst_m0),
        .ARVALID_M0 (arvalid_m0),
        .ARREADY_M0 (arready_m0),
        .RID_M0     (rid_m0    ),
        .RDATA_M0   (rdata_m0  ),
        .RRESP_M0   (rresp_m0  ),
        .RLAST_M0   (rlast_m0  ),
        .RVALID_M0  (rvalid_m0 ),
        .RREADY_M0  (rready_m0 ),
        .ARID_M1    (arid_m1   ),
        .ARADDR_M1  (araddr_m1 ),
        .ARLEN_M1   (arlen_m1  ),
        .ARSIZE_M1  (arsize_m1 ),
        .ARBURST_M1 (arburst_m1),
        .ARVALID_M1 (arvalid_m1),
        .ARREADY_M1 (arready_m1),
        .RID_M1     (rid_m1    ),
        .RDATA_M1   (rdata_m1  ),
        .RRESP_M1   (rresp_m1  ),
        .RLAST_M1   (rlast_m1  ),
        .RVALID_M1  (rvalid_m1 ),
        .RREADY_M1  (rready_m1 ),
        .AWID_S0    (awid_s0   ),
        .AWADDR_S0  (awaddr_s0 ),
        .AWLEN_S0   (awlen_s0  ),
        .AWSIZE_S0  (awsize_s0 ),
        .AWBURST_S0 (awburst_s0),
        .AWVALID_S0 (awvalid_s0),
        .AWREADY_S0 (awready_s0),
        .WDATA_S0   (wdata_s0  ),
        .WSTRB_S0   (wstrb_s0  ),
        .WLAST_S0   (wlast_s0  ),
        .WVALID_S0  (wvalid_s0 ),
        .WREADY_S0  (wready_s0 ),
        .BID_S0     (bid_s0    ),
        .BRESP_S0   (bresp_s0  ),
        .BVALID_S0  (bvalid_s0 ),
        .BREADY_S0  (bready_s0 ),
        .AWID_S1    (awid_s1   ),
        .AWADDR_S1  (awaddr_s1 ),
        .AWLEN_S1   (awlen_s1  ),
        .AWSIZE_S1  (awsize_s1 ),
        .AWBURST_S1 (awburst_s1),
        .AWVALID_S1 (awvalid_s1),
        .AWREADY_S1 (awready_s1),
        .WDATA_S1   (wdata_s1  ),
        .WSTRB_S1   (wstrb_s1  ),
        .WLAST_S1   (wlast_s1  ),
        .WVALID_S1  (wvalid_s1 ),
        .WREADY_S1  (wready_s1 ),
        .BID_S1     (bid_s1    ),
        .BRESP_S1   (bresp_s1  ),
        .BVALID_S1  (bvalid_s1 ),
        .BREADY_S1  (bready_s1 ),
        .ARID_S0    (arid_s0   ),
        .ARADDR_S0  (araddr_s0 ),
        .ARLEN_S0   (arlen_s0  ),
        .ARSIZE_S0  (arsize_s0 ),
        .ARBURST_S0 (arburst_s0),
        .ARVALID_S0 (arvalid_s0),
        .ARREADY_S0 (arready_s0),
        .RID_S0     (rid_s0    ),
        .RDATA_S0   (rdata_s0  ),
        .RRESP_S0   (rresp_s0  ),
        .RLAST_S0   (rlast_s0  ),
        .RVALID_S0  (rvalid_s0 ),
        .RREADY_S0  (rready_s0 ),
        .ARID_S1    (arid_s1   ),
        .ARADDR_S1  (araddr_s1 ),
        .ARLEN_S1   (arlen_s1  ),
        .ARSIZE_S1  (arsize_s1 ),
        .ARBURST_S1 (arburst_s1),
        .ARVALID_S1 (arvalid_s1),
        .ARREADY_S1 (arready_s1),
        .RID_S1     (rid_s1    ),
        .RDATA_S1   (rdata_s1  ),
        .RRESP_S1   (rresp_s1  ),
        .RLAST_S1   (rlast_s1  ),
        .RVALID_S1  (rvalid_s1 ),
        .RREADY_S1  (rready_s1 )
	);

    // SRAM
    SRAM_wrapper IM1
    (
        .clock  (clk),
        .reset  (~rst),
            // READ ADDRESS
        .ARID   (arid_s0),
        .ARADDR (araddr_s0),
        .ARLEN  (arlen_s0),
        .ARSIZE (arsize_s0),
        .ARBURST(arburst_s0),
        .ARVALID(arvalid_s0),
        .ARREADY(arready_s0),
        // READ DATA
        .RID    (rid_s0),
        .RDATA  (rdata_s0),
        .RRESP  (rresp_s0),
        .RLAST  (rlast_s0),
        .RVALID (rvalid_s0),
        .RREADY (rready_s0),
            // WRITE ADDRESS
        .AWID   (awid_s0),
        .AWADDR (awaddr_s0),
        .AWLEN  (awlen_s0),
        .AWSIZE (awsize_s0),
        .AWBURST(awburst_s0),
        .AWVALID(awvalid_s0),
        .AWREADY(awready_s0),
        // WRITE DATA
        .WDATA  (wdata_s0),
        .WSTRB  (wstrb_s0),
        .WLAST  (wlast_s0),
        .WVALID (wvalid_s0),
        .WREADY (wready_s0),
        // WRITE RESPONSE
        .BID    (bid_s0),
        .BRESP  (bresp_s0),
        .BVALID (bvalid_s0),
        .BREADY (bready_s0)
    );

    // SRAM
    SRAM_wrapper DM1
    (
        .clock  (clk),
        .reset  (~rst),
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


    
endmodule