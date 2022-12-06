//================================================
// Auther:      Chang Wan-Yun (Claire)            
// Filename:    top.v                            
// Description: Top module of AXI bridge VIP                
// Version:     1.0 
// ----------DO NOT MODIFY THIS FILE-------------
//================================================

module top #(parameter bit COVERAGE_ON = 0) ();
   
    
    // user defined AXI parameters
    localparam DATA_WIDTH              = 32;
    localparam ADDR_WIDTH              = 32;
    localparam ID_WIDTH                = 4;
    localparam IDS_WIDTH               = 8;
    localparam LEN_WIDTH               = 4;
    localparam MAXLEN                  = 2;
    // fixed AXI parameters
    localparam STRB_WIDTH              = DATA_WIDTH/8;
    localparam SIZE_WIDTH              = 3;
    localparam BURST_WIDTH             = 2;  
    localparam CACHE_WIDTH             = 4;  
    localparam PROT_WIDTH              = 3;  
    localparam BRESP_WIDTH             = 2; 
    localparam RRESP_WIDTH             = 2;      
    localparam AWUSER_WIDTH            = 32; // Size of AWUser field
    localparam WUSER_WIDTH             = 32; // Size of WUser field
    localparam BUSER_WIDTH             = 32; // Size of BUser field
    localparam ARUSER_WIDTH            = 32; // Size of ARUser field
    localparam RUSER_WIDTH             = 32; // Size of RUser field
    localparam QOS_WIDTH               = 4;  // Size of QOS field
    localparam REGION_WIDTH            = 4;  // Size of Region field



    // Clock and reset    
    wire                        aclk_m;
    wire                        aresetn_m;
    // Clock and reset    
    wire                        aclk_s;
    wire                        aresetn_s;

    // ----------slave 0---------- //
    // Write address channel signals
    wire    [IDS_WIDTH-1:0]     awid_s0;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_s0;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_s0;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_s0;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_s0;   // Write address burst type
    wire                        awlock_s0;    // Write address lock type
    wire    [PROT_WIDTH-1:0]    awprot_s0;    // Write address protection level
    wire    [QOS_WIDTH-1:0]     awqos_s0;     // Write address Quality of service
    wire    [REGION_WIDTH-1:0]  awregion_s0;  // Write address slave address region
    wire    [AWUSER_WIDTH-1:0]  awuser_s0;    // Write address user signal

    wire    [CACHE_WIDTH-1:0]   awcache_s0;   // Write address cache type
    wire                        awvalid_s0;   // Write address valid
    wire                        awready_s0;   // Write address ready

    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_s0;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_s0;     // Write strobe
    wire                        wlast_s0;     // Write last
    wire                        wvalid_s0;    // Write valid
    wire                        wready_s0;    // Write ready
    wire    [WUSER_WIDTH-1:0]   wuser_s0;     // Write user signal

    // Write response channel signals
    wire    [IDS_WIDTH-1:0]     bid_s0;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]   bresp_s0;     // Write response
    wire                        bvalid_s0;    // Write response valid
    wire                        bready_s0;    // Write response ready
    wire    [BUSER_WIDTH-1:0]   buser_s0;     // Write response user signal
    
    // Read address channel signals
    wire    [IDS_WIDTH-1:0]     arid_s0;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_s0;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_s0;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_s0;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_s0;   // Read address burst type
    wire                        arlock_s0;    // Read address lock type
    wire    [PROT_WIDTH-1:0]    arprot_s0;    // Read address protection level
    wire    [QOS_WIDTH-1:0]     arqos_s0;     // Read address Quality of service
    wire    [REGION_WIDTH-1:0]  arregion_s0;  // Read address slave address region
    wire    [ARUSER_WIDTH-1:0]  aruser_s0;    // Read address user signal

    wire    [CACHE_WIDTH-1:0]   arcache_s0;   // Read address cache type
    wire                        arvalid_s0;   // Read address valid
    wire                        arready_s0;   // Read address ready

    // Read data channel signals
    wire    [IDS_WIDTH-1:0]     rid_s0;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_s0;     // Read data
    wire                        rlast_s0;     // Read last
    wire                        rvalid_s0;    // Read valid
    wire                        rready_s0;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_s0;     // Read response
    wire    [RUSER_WIDTH-1:0]   ruser_s0;     // Read address user signal

    // ----------slave1---------- //
    // Write address channel signals
    wire    [IDS_WIDTH-1:0]     awid_s1;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_s1;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_s1;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_s1;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_s1;   // Write address burst type
    wire                        awlock_s1;    // Write address lock type
    wire    [PROT_WIDTH-1:0]    awprot_s1;    // Write address protection level
    wire    [QOS_WIDTH-1:0]     awqos_s1;     // Write address Quality of service
    wire    [REGION_WIDTH-1:0]  awregion_s1;  // Write address slave address region
    wire    [AWUSER_WIDTH-1:0]  awuser_s1;    // Write address user signal

    wire    [CACHE_WIDTH-1:0]   awcache_s1;   // Write address cache type
    wire                        awvalid_s1;   // Write address valid
    wire                        awready_s1;   // Write address ready

    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_s1;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_s1;     // Write strobe
    wire                        wlast_s1;     // Write last
    wire                        wvalid_s1;    // Write valid
    wire                        wready_s1;    // Write ready
    wire    [WUSER_WIDTH-1:0]   wuser_s1;     // Write user signal

    // Write response channel signals
    wire    [IDS_WIDTH-1:0]     bid_s1;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]   bresp_s1;     // Write response
    wire                        bvalid_s1;    // Write response valid
    wire                        bready_s1;    // Write response ready
    wire    [BUSER_WIDTH-1:0]   buser_s1;     // Write response user signal

    // Read address channel signals
    wire    [IDS_WIDTH-1:0]     arid_s1;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_s1;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_s1;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_s1;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_s1;   // Read address burst type
    wire                        arlock_s1;    // Read address lock type
    wire    [PROT_WIDTH-1:0]    arprot_s1;    // Read address protection level
    wire    [QOS_WIDTH-1:0]     arqos_s1;     // Read address Quality of service
    wire    [REGION_WIDTH-1:0]  arregion_s1;  // Read address slave address region
    wire    [ARUSER_WIDTH-1:0]  aruser_s1;    // Read address user signal

    wire    [CACHE_WIDTH-1:0]   arcache_s1;   // Read address cache type
    wire                        arvalid_s1;   // Read address valid
    wire                        arready_s1;   // Read address ready

    // Read data channel signals
    wire    [IDS_WIDTH-1:0]     rid_s1;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_s1;     // Read data
    wire                        rlast_s1;     // Read last
    wire                        rvalid_s1;    // Read valid
    wire                        rready_s1;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_s1;     // Read response
    wire    [RUSER_WIDTH-1:0]   ruser_s1;     // Read address user signal


    // ----------master0---------- //
    // Read address channel signals
    wire    [ID_WIDTH-1:0]      arid_m0;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_m0;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_m0;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_m0;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_m0;   // Read address burst type
    wire                        arlock_m0;    // Read address lock type
    wire    [PROT_WIDTH-1:0]    arprot_m0;    // Read address protection level
    wire    [CACHE_WIDTH-1:0]   arcache_m0;   // Read address cache type
    wire                        arvalid_m0;   // Read address valid
    wire                        arready_m0;   // Read address ready
    wire    [QOS_WIDTH-1:0]     arqos_m0;     // Read address Quality of service
    wire    [REGION_WIDTH-1:0]  arregion_m0;  // Read address slave address region
    wire    [ARUSER_WIDTH-1:0]  aruser_m0;    // Read address user signal

    // Read data channel signals
    wire    [ID_WIDTH-1:0]      rid_m0;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_m0;     // Read data
    wire                        rlast_m0;     // Read last
    wire                        rvalid_m0;    // Read valid
    wire                        rready_m0;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_m0;     // Read response
    wire    [RUSER_WIDTH-1:0]   ruser_m0;     // Read address user signal

    // ----------master1---------- //
    // Write address channel signals
    wire    [ID_WIDTH-1:0]      awid_m1;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_m1;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_m1;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_m1;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_m1;   // Write address burst type
    wire                        awlock_m1;    // Write address lock type
    wire    [PROT_WIDTH-1:0]    awprot_m1;    // Write address protection level
    wire    [CACHE_WIDTH-1:0]   awcache_m1;   // Write address cache type
    wire                        awvalid_m1;   // Write address valid
    wire                        awready_m1;   // Write address ready
    wire    [QOS_WIDTH-1:0]     awqos_m1;     // Write address Quality of service
    wire    [REGION_WIDTH-1:0]  awregion_m1;  // Write address slave address region
    wire    [AWUSER_WIDTH-1:0]  awuser_m1;    // Write address user signal

    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_m1;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_m1;     // Write strobe
    wire                        wlast_m1;     // Write last
    wire                        wvalid_m1;    // Write valid
    wire                        wready_m1;    // Write ready
    wire    [WUSER_WIDTH-1:0]   wuser_m1;     // Write user signal
    // Write response channel signals
    wire    [ID_WIDTH-1:0]      bid_m1;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]    bresp_m1;     // Write response
    wire                        bvalid_m1;    // Write response valid
    wire                        bready_m1;    // Write response ready
    wire    [BUSER_WIDTH-1:0]   buser_m1;     // Write response user signal
    // Read address channel signals
    wire    [ID_WIDTH-1:0]      arid_m1;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_m1;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_m1;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_m1;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_m1;   // Read address burst type
    wire                        arlock_m1;    // Read address lock type
    wire    [PROT_WIDTH-1:0]    arprot_m1;    // Read address protection level
    wire    [CACHE_WIDTH-1:0]   arcache_m1;   // Read address cache type
    wire                        arvalid_m1;   // Read address valid
    wire                        arready_m1;   // Read address ready
    wire    [QOS_WIDTH-1:0]     arqos_m1;     // Read address Quality of service
    wire    [REGION_WIDTH-1:0]  arregion_m1;  // Read address slave address region
    wire    [ARUSER_WIDTH-1:0]  aruser_m1;    // Read address user signal

    // Read data channel signals
    wire    [ID_WIDTH-1:0]      rid_m1;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_m1;     // Read data
    wire                        rlast_m1;     // Read last
    wire                        rvalid_m1;    // Read valid
    wire                        rready_m1;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_m1;     // Read response
    wire    [RUSER_WIDTH-1:0]   ruser_m1;     // Read address user signal

    // Low power signals
    wire                        csysreq;     // Low Power - Power Off Request
    wire                        csysack;     // Low Power - Power Off Acknowledge
    wire                        cactive;     // Low Power - activate

    // Instance of the AXI bridge DUV
    AXI axi_duv_bridge(
	 .ACLK       (aclk_m      ),
	 .ARESETn    (aresetn_m   ),
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

    axi4_slave axi_slave_0 (
        .aclk            (aclk_s),
        .aresetn         (aresetn_s),
        .awid            (awid_s0),
        .awaddr          (awaddr_s0),
        .awlen           (awlen_s0),
        .awsize          (awsize_s0),
        .awburst         (awburst_s0),
        .awlock          (awlock_s0),
        .awcache         (awcache_s0),
        .awprot          (awprot_s0),
        .awvalid         (awvalid_s0),
        .awready         (awready_s0),
        .awqos           (awqos_s0),  
        .awregion        (awregion_s0),  
        .awuser          (awuser_s0),   
	.ruser           (ruser_s0),
        .arqos           (arqos_s0),  
        .arregion        (arregion_s0),  
        .aruser          (aruser_s0),
        .buser           (buser_s0),
	.wuser           (wuser_s0),
      
        .wdata           (wdata_s0),
        .wstrb           (wstrb_s0),
        .wlast           (wlast_s0),
        .wvalid          (wvalid_s0),
        .wready          (wready_s0),
        
        .bid             (bid_s0),
        .bresp           (bresp_s0),
        .bvalid          (bvalid_s0),
        .bready          (bready_s0),
        
        .arid            (arid_s0),
        .araddr          (araddr_s0),
        .arlen           (arlen_s0),
        .arsize          (arsize_s0),
        .arburst         (arburst_s0),
        .arlock          (arlock_s0),
        .arcache         (arcache_s0),
        .arprot          (arprot_s0),
        .arvalid         (arvalid_s0),
        .arready         (arready_s0),
        
        .rid             (rid_s0),
        .rdata           (rdata_s0),
        .rresp           (rresp_s0),
        .rlast           (rlast_s0),
        .rvalid          (rvalid_s0),
        .rready          (rready_s0),
        
        .csysreq         (csysreq),
        .csysack         (csysack),
        .cactive         (cactive)
    );

    defparam axi_slave_0.ADDR_WIDTH              = ADDR_WIDTH;
    defparam axi_slave_0.DATA_WIDTH              = DATA_WIDTH;
    defparam axi_slave_0.ID_WIDTH                = IDS_WIDTH;
    defparam axi_slave_0.LEN_WIDTH               = LEN_WIDTH;
    defparam axi_slave_0.MAXLEN                  = MAXLEN;
    defparam axi_slave_0.READ_INTERLEAVE_ON      = 0;
    defparam axi_slave_0.BYTE_STROBE_ON          = 0;
    defparam axi_slave_0.EXCL_ACCESS_ON          = 0;
    defparam axi_slave_0.DATA_BEFORE_CONTROL_ON  = 0;
    defparam axi_slave_0.COVERAGE_ON             = COVERAGE_ON;
    


    axi4_slave axi_slave_1 (
        .aclk            (aclk_s),
        .aresetn         (aresetn_s),
        .awid            (awid_s1),
        .awaddr          (awaddr_s1),
        .awlen           (awlen_s1),
        .awsize          (awsize_s1),
        .awburst         (awburst_s1),
        .awlock          (awlock_s1),
        .awcache         (awcache_s1),
        .awprot          (awprot_s1),
        .awvalid         (awvalid_s1),
        .awready         (awready_s1),
        .awqos           (awqos_s1),  
        .awregion        (awregion_s1),  
        .awuser          (awuser_s1),   
	.ruser           (ruser_s1),
        .arqos           (arqos_s1),  
        .arregion        (arregion_s1),  
        .aruser          (aruser_s1),
        .buser           (buser_s1),
	.wuser           (wuser_s1),
      
        .wdata           (wdata_s1),
        .wstrb           (wstrb_s1),
        .wlast           (wlast_s1),
        .wvalid          (wvalid_s1),
        .wready          (wready_s1),
        
        .bid             (bid_s1),
        .bresp           (bresp_s1),
        .bvalid          (bvalid_s1),
        .bready          (bready_s1),
        
        .arid            (arid_s1),
        .araddr          (araddr_s1),
        .arlen           (arlen_s1),
        .arsize          (arsize_s1),
        .arburst         (arburst_s1),
        .arlock          (arlock_s1),
        .arcache         (arcache_s1),
        .arprot          (arprot_s1),
        .arvalid         (arvalid_s1),
        .arready         (arready_s1),
        
        .rid             (rid_s1),
        .rdata           (rdata_s1),
        .rresp           (rresp_s1),
        .rlast           (rlast_s1),
        .rvalid          (rvalid_s1),
        .rready          (rready_s1),
        
        .csysreq         (csysreq),
        .csysack         (csysack),
        .cactive         (cactive)
    );

    defparam axi_slave_1.ADDR_WIDTH              = ADDR_WIDTH;
    defparam axi_slave_1.DATA_WIDTH              = DATA_WIDTH;
    defparam axi_slave_1.ID_WIDTH                = IDS_WIDTH;
    defparam axi_slave_1.LEN_WIDTH               = LEN_WIDTH;
    defparam axi_slave_1.MAXLEN                  = MAXLEN;
    defparam axi_slave_1.READ_INTERLEAVE_ON      = 0;
   // defparam axi_slave_1.READ_RESP_IN_ORDER_ON  = 1;
    defparam axi_slave_1.BYTE_STROBE_ON          = 0;
    defparam axi_slave_1.EXCL_ACCESS_ON          = 0;
    defparam axi_slave_1.DATA_BEFORE_CONTROL_ON  = 0;
    defparam axi_slave_1.COVERAGE_ON             = COVERAGE_ON;


    // Instance of the AXI Master (connects to the slave interface of the bridge)
    axi4_master axi_master_0 (
        .aclk            (aclk_m),
        .aresetn         (aresetn_m),
        .awid            (awid_m0),
        .awaddr          (awaddr_m0),
        .awlen           (awlen_m0),
        .awsize          (awsize_m0),
        .awburst         (awburst_m0),
        .awlock          (awlock_m0),
        .awcache         (awcache_m0),
        .awprot          (awprot_m0),
        .awvalid         (awvalid_m0),
        .awready         (awready_m0),
        .awqos          (awqos_m0),  
        .awregion        (awregion_m0),  
        .awuser          (awuser_m0),   
	.ruser           (ruser_m0),
        .arqos           (arqos_m0),  
        .arregion        (arregion_m0),  
        .aruser          (aruser_m0),
        .buser           (buser_m0),
	.wuser           (wuser_m0),
       
        .wdata           (wdata_m0),
        .wstrb           (wstrb_m0),
        .wlast           (wlast_m0),
        .wvalid          (wvalid_m0),
        .wready          (wready_m0),
        
        .bid             (bid_m0),
        .bresp           (bresp_m0),
        .bvalid          (0),
        .bready          (bready_m0),
        
        .arid            (arid_m0),
        .araddr          (araddr_m0),
        .arlen           (arlen_m0),
        .arsize          (arsize_m0),
        .arburst         (arburst_m0),
        .arlock          (arlock_m0),
        .arcache         (arcache_m0),
        .arprot          (arprot_m0),
        .arvalid         (arvalid_m0),
        .arready         (arready_m0),
        
        .rid             (rid_m0),
        .rdata           (rdata_m0),
        .rresp           (rresp_m0),
        .rlast           (rlast_m0),
        .rvalid          (rvalid_m0),
        .rready          (rready_m0),
        
        .csysreq         (csysreq),
        .csysack         (csysack),
        .cactive         (cactive)
    );

    defparam axi_master_0.ADDR_WIDTH              = ADDR_WIDTH;
    defparam axi_master_0.DATA_WIDTH              = DATA_WIDTH;
    defparam axi_master_0.ID_WIDTH                = ID_WIDTH;
    defparam axi_master_0.LEN_WIDTH               = LEN_WIDTH;
    defparam axi_master_0.MAXLEN                  = MAXLEN;
    defparam axi_master_0.READ_INTERLEAVE_ON      = 0;
    defparam axi_master_0.BYTE_STROBE_ON          = 0;
    defparam axi_master_0.EXCL_ACCESS_ON          = 0;
    defparam axi_master_0.DATA_BEFORE_CONTROL_ON  = 0;
    defparam axi_master_0.COVERAGE_ON             = COVERAGE_ON;
    

    axi4_master axi_master_1 (
        .aclk            (aclk_m),
        .aresetn         (aresetn_m),
        .awid            (awid_m1),
        .awaddr          (awaddr_m1),
        .awlen           (awlen_m1),
        .awsize          (awsize_m1),
        .awburst         (awburst_m1),
        .awlock          (awlock_m1),
        .awcache         (awcache_m1),
        .awprot          (awprot_m1),
        .awvalid         (awvalid_m1),
        .awready         (awready_m1),
        .awqos          (awqos_m1),  
        .awregion        (awregion_m1),  
        .awuser          (awuser_m1),   
	.ruser           (ruser_m1),
        .arqos           (arqos_m1),  
        .arregion        (arregion_m1),  
        .aruser          (aruser_m1),
        .buser           (buser_m1),
	.wuser           (wuser_m1),
       
        .wdata           (wdata_m1),
        .wstrb           (wstrb_m1),
        .wlast           (wlast_m1),
        .wvalid          (wvalid_m1),
        .wready          (wready_m1),
        
        .bid             (bid_m1),
        .bresp           (bresp_m1),
        .bvalid          (bvalid_m1),
        .bready          (bready_m1),
        
        .arid            (arid_m1),
        .araddr          (araddr_m1),
        .arlen           (arlen_m1),
        .arsize          (arsize_m1),
        .arburst         (arburst_m1),
        .arlock          (arlock_m1),
        .arcache         (arcache_m1),
        .arprot          (arprot_m1),
        .arvalid         (arvalid_m1),
        .arready         (arready_m1),
        
        .rid             (rid_m1),
        .rdata           (rdata_m1),
        .rresp           (rresp_m1),
        .rlast           (rlast_m1),
        .rvalid          (rvalid_m1),
        .rready          (rready_m1),
        
        .csysreq         (csysreq),
        .csysack         (csysack),
        .cactive         (cactive)
    );

    defparam axi_master_1.ADDR_WIDTH              = ADDR_WIDTH;
    defparam axi_master_1.DATA_WIDTH              = DATA_WIDTH;
    defparam axi_master_1.ID_WIDTH                = ID_WIDTH;
    defparam axi_master_1.LEN_WIDTH               = LEN_WIDTH;
    defparam axi_master_1.MAXLEN                  = MAXLEN;
    defparam axi_master_1.READ_INTERLEAVE_ON      = 0;
    defparam axi_master_1.BYTE_STROBE_ON          = 0;
    defparam axi_master_1.EXCL_ACCESS_ON          = 0;
    defparam axi_master_1.DATA_BEFORE_CONTROL_ON  = 0;
    defparam axi_master_1.COVERAGE_ON             = COVERAGE_ON;

endmodule 
