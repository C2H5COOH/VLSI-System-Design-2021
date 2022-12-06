//==============================================
// Author:       Chang Wan-Yun (Claire)
// Filename:     top.v
// Description:  Top module of AXI bridge VIP
// Version:      1.0
// ============================================


module top #(parameter bit COVERAGE_ON = 0) ();
   
    
    // user defined AXI parameters
    localparam DATA_WIDTH              = 32;
    localparam ADDR_WIDTH              = 32;
    localparam ID_WIDTH                = 4;
    localparam IDS_WIDTH               = 8;
    localparam LEN_WIDTH               = 4;
    localparam MAXLEN                  = 1;
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

    // Slave interface (connects to a master device)

    // Clock and reset    
    wire                        aclk_m;
    wire                        aresetn_m;
    // Clock and reset    
    wire                        aclk_s;
    wire                        aresetn_s;

    // ----------slave 0---------- //
    // Write address channel signals
    /*wire    [IDS_WIDTH-1:0]     awid_s0;      // Write address ID tag
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
    */
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


    // ----------slave2---------- //
    // Write address channel signals
    wire    [IDS_WIDTH-1:0]     awid_s2;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_s2;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_s2;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_s2;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_s2;   // Write address burst type
    wire                        awlock_s2;    // Write address lock type
    wire    [PROT_WIDTH-1:0]    awprot_s2;    // Write address protection level
    wire    [QOS_WIDTH-1:0]     awqos_s2;     // Write address Quality of service
    wire    [REGION_WIDTH-1:0]  awregion_s2;  // Write address slave address region
    wire    [AWUSER_WIDTH-1:0]  awuser_s2;    // Write address user signal

    wire    [CACHE_WIDTH-1:0]   awcache_s2;   // Write address cache type
    wire                        awvalid_s2;   // Write address valid
    wire                        awready_s2;   // Write address ready

    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_s2;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_s2;     // Write strobe
    wire                        wlast_s2;     // Write last
    wire                        wvalid_s2;    // Write valid
    wire                        wready_s2;    // Write ready
    wire    [WUSER_WIDTH-1:0]   wuser_s2;     // Write user signal

    // Write response channel signals
    wire    [IDS_WIDTH-1:0]     bid_s2;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]   bresp_s2;     // Write response
    wire                        bvalid_s2;    // Write response valid
    wire                        bready_s2;    // Write response ready
    wire    [BUSER_WIDTH-1:0]   buser_s2;     // Write response user signal

    // Read address channel signals
    wire    [IDS_WIDTH-1:0]     arid_s2;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_s2;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_s2;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_s2;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_s2;   // Read address burst type
    wire                        arlock_s2;    // Read address lock type
    wire    [PROT_WIDTH-1:0]    arprot_s2;    // Read address protection level
    wire    [QOS_WIDTH-1:0]     arqos_s2;     // Read address Quality of service
    wire    [REGION_WIDTH-1:0]  arregion_s2;  // Read address slave address region
    wire    [ARUSER_WIDTH-1:0]  aruser_s2;    // Read address user signal

    wire    [CACHE_WIDTH-1:0]   arcache_s2;   // Read address cache type
    wire                        arvalid_s2;   // Read address valid
    wire                        arready_s2;   // Read address ready

    // Read data channel signals
    wire    [IDS_WIDTH-1:0]     rid_s2;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_s2;     // Read data
    wire                        rlast_s2;     // Read last
    wire                        rvalid_s2;    // Read valid
    wire                        rready_s2;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_s2;     // Read response
    wire    [RUSER_WIDTH-1:0]   ruser_s2;     // Read address user signal


    // ----------slave3---------- //
    // Write address channel signals
   /* wire    [IDS_WIDTH-1:0]     awid_s3;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_s3;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_s3;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_s3;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_s3;   // Write address burst type
    wire                        awlock_s3;    // Write address lock type
    wire    [PROT_WIDTH-1:0]    awprot_s3;    // Write address protection level
    wire    [QOS_WIDTH-1:0]     awqos_s3;     // Write address Quality of service
    wire    [REGION_WIDTH-1:0]  awregion_s3;  // Write address slave address region
    wire    [AWUSER_WIDTH-1:0]  awuser_s3;    // Write address user signal

    wire    [CACHE_WIDTH-1:0]   awcache_s3;   // Write address cache type
    wire                        awvalid_s3;   // Write address valid
    wire                        awready_s3;   // Write address ready

    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_s3;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_s3;     // Write strobe
    wire                        wlast_s3;     // Write last
    wire                        wvalid_s3;    // Write valid
    wire                        wready_s3;    // Write ready
    wire    [WUSER_WIDTH-1:0]   wuser_s3;     // Write user signal

    // Write response channel signals
    wire    [IDS_WIDTH-1:0]     bid_s3;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]   bresp_s3;     // Write response
    wire                        bvalid_s3;    // Write response valid
    wire                        bready_s3;    // Write response ready
    wire    [BUSER_WIDTH-1:0]   buser_s3;     // Write response user signal

    // Read address channel signals
    wire    [IDS_WIDTH-1:0]     arid_s3;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_s3;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_s3;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_s3;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_s3;   // Read address burst type
    wire                        arlock_s3;    // Read address lock type
    wire    [PROT_WIDTH-1:0]    arprot_s3;    // Read address protection level
    wire    [QOS_WIDTH-1:0]     arqos_s3;     // Read address Quality of service
    wire    [REGION_WIDTH-1:0]  arregion_s3;  // Read address slave address region
    wire    [ARUSER_WIDTH-1:0]  aruser_s3;    // Read address user signal

    wire    [CACHE_WIDTH-1:0]   arcache_s3;   // Read address cache type
    wire                        arvalid_s3;   // Read address valid
    wire                        arready_s3;   // Read address ready

    // Read data channel signals
    wire    [IDS_WIDTH-1:0]     rid_s3;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_s3;     // Read data
    wire                        rlast_s3;     // Read last
    wire                        rvalid_s3;    // Read valid
    wire                        rready_s3;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_s3;     // Read response
    wire    [RUSER_WIDTH-1:0]   ruser_s3;     // Read address user signal*/


    // ----------slave4---------- //
    // Write address channel signals
    wire    [IDS_WIDTH-1:0]     awid_s4;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_s4;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_s4;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_s4;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_s4;   // Write address burst type
    wire                        awlock_s4;    // Write address lock type
    wire    [PROT_WIDTH-1:0]    awprot_s4;    // Write address protection level
    wire    [QOS_WIDTH-1:0]     awqos_s4;     // Write address Quality of service
    wire    [REGION_WIDTH-1:0]  awregion_s4;  // Write address slave address region
    wire    [AWUSER_WIDTH-1:0]  awuser_s4;    // Write address user signal

    wire    [CACHE_WIDTH-1:0]   awcache_s4;   // Write address cache type
    wire                        awvalid_s4;   // Write address valid
    wire                        awready_s4;   // Write address ready

    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_s4;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_s4;     // Write strobe
    wire                        wlast_s4;     // Write last
    wire                        wvalid_s4;    // Write valid
    wire                        wready_s4;    // Write ready
    wire    [WUSER_WIDTH-1:0]   wuser_s4;     // Write user signal

    // Write response channel signals
    wire    [IDS_WIDTH-1:0]     bid_s4;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]   bresp_s4;     // Write response
    wire                        bvalid_s4;    // Write response valid
    wire                        bready_s4;    // Write response ready
    wire    [BUSER_WIDTH-1:0]   buser_s4;     // Write response user signal

    // Read address channel signals
    wire    [IDS_WIDTH-1:0]     arid_s4;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_s4;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_s4;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_s4;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_s4;   // Read address burst type
    wire                        arlock_s4;    // Read address lock type
    wire    [PROT_WIDTH-1:0]    arprot_s4;    // Read address protection level
    wire    [QOS_WIDTH-1:0]     arqos_s4;     // Read address Quality of service
    wire    [REGION_WIDTH-1:0]  arregion_s4;  // Read address slave address region
    wire    [ARUSER_WIDTH-1:0]  aruser_s4;    // Read address user signal

    wire    [CACHE_WIDTH-1:0]   arcache_s4;   // Read address cache type
    wire                        arvalid_s4;   // Read address valid
    wire                        arready_s4;   // Read address ready

    // Read data channel signals
    wire    [IDS_WIDTH-1:0]     rid_s4;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_s4;     // Read data
    wire                        rlast_s4;     // Read last
    wire                        rvalid_s4;    // Read valid
    wire                        rready_s4;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_s4;     // Read response
    wire    [RUSER_WIDTH-1:0]   ruser_s4;     // Read address user signal





    // AXI 4 Master Interface (connects to a slave device)

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
    wire    [BRESP_WIDTH-1:0]   bresp_m1;     // Write response
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
    // AXI 4 Bridge GLobal Interface (connects to low power controller)

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
	 /*.AWID_S0    (awid_s0   ),
	 .AWADDR_S0  (awaddr_s0 ),
	 .AWLEN_S0   (awlen_s0  ),
	 .AWSIZE_S0  (awsize_s0 ),
	 .AWBURST_S0 (awburst_s0),
	 .AWVALID_S0 (awvalid_s0),
	 .AWREADY_S0 (awready_s0),*/
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
	 .AWID_S2    (awid_s2   ),
	 .AWADDR_S2  (awaddr_s2 ),
	 .AWLEN_S2   (awlen_s2  ),
	 .AWSIZE_S2  (awsize_s2 ),
	 .AWBURST_S2 (awburst_s2),
	 .AWVALID_S2 (awvalid_s2),
	 .AWREADY_S2 (awready_s2),
	 .WDATA_S2   (wdata_s2  ),
	 .WSTRB_S2   (wstrb_s2  ),
	 .WLAST_S2   (wlast_s2  ),
	 .WVALID_S2  (wvalid_s2 ),
	 .WREADY_S2  (wready_s2 ),
	 .BID_S2     (bid_s2    ),
	 .BRESP_S2   (bresp_s2  ),
	 .BVALID_S2  (bvalid_s2 ),
	 .BREADY_S2  (bready_s2 ),
	 /*.AWID_S3    (awid_s3   ),
	 .AWADDR_S3  (awaddr_s3 ),
	 .AWLEN_S3   (awlen_s3  ),
	 .AWSIZE_S3  (awsize_s3 ),
	 .AWBURST_S3 (awburst_s3),
	 .AWVALID_S3 (awvalid_s3),
	 .AWREADY_S3 (awready_s3),
	 .WDATA_S3   (wdata_s3  ),
	 .WSTRB_S3   (wstrb_s3  ),
	 .WLAST_S3   (wlast_s3  ),
	 .WVALID_S3  (wvalid_s3 ),
	 .WREADY_S3  (wready_s3 ),
	 .BID_S3     (bid_s3    ),
	 .BRESP_S3   (bresp_s3  ),
	 .BVALID_S3  (bvalid_s3 ),
	 .BREADY_S3  (bready_s3 ),*/
	 .AWID_S4    (awid_s4   ),
	 .AWADDR_S4  (awaddr_s4 ),
	 .AWLEN_S4   (awlen_s4  ),
	 .AWSIZE_S4  (awsize_s4 ),
	 .AWBURST_S4 (awburst_s4),
	 .AWVALID_S4 (awvalid_s4),
	 .AWREADY_S4 (awready_s4),
	 .WDATA_S4   (wdata_s4  ),
	 .WSTRB_S4   (wstrb_s4  ),
	 .WLAST_S4   (wlast_s4  ),
	 .WVALID_S4  (wvalid_s4 ),
	 .WREADY_S4  (wready_s4 ),
	 .BID_S4     (bid_s4    ),
	 .BRESP_S4   (bresp_s4  ),
	 .BVALID_S4  (bvalid_s4 ),
	 .BREADY_S4  (bready_s4 ),

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
	 .RREADY_S1  (rready_s1 ),

	 .ARID_S2    (arid_s2   ),
	 .ARADDR_S2  (araddr_s2 ),
	 .ARLEN_S2   (arlen_s2  ),
	 .ARSIZE_S2  (arsize_s2 ),
	 .ARBURST_S2 (arburst_s2),
	 .ARVALID_S2 (arvalid_s2),
	 .ARREADY_S2 (arready_s2),
	 .RID_S2     (rid_s2    ),
	 .RDATA_S2   (rdata_s2  ),
	 .RRESP_S2   (rresp_s2  ),
	 .RLAST_S2   (rlast_s2  ),
	 .RVALID_S2  (rvalid_s2 ),
	 .RREADY_S2  (rready_s2 ),
	 /*.ARID_S3    (arid_s3   ),
	 .ARADDR_S3  (araddr_s3 ),
	 .ARLEN_S3   (arlen_s3  ),
	 .ARSIZE_S3  (arsize_s3 ),
	 .ARBURST_S3 (arburst_s3),
	 .ARVALID_S3 (arvalid_s3),
	 .ARREADY_S3 (arready_s3),
	 .RID_S3     (rid_s3    ),
	 .RDATA_S3   (rdata_s3  ),
	 .RRESP_S3   (rresp_s3  ),
	 .RLAST_S3   (rlast_s3  ),
	 .RVALID_S3  (rvalid_s3 ),
	 .RREADY_S3  (rready_s3 ),*/
	 .ARID_S4    (arid_s4   ),
	 .ARADDR_S4  (araddr_s4 ),
	 .ARLEN_S4   (arlen_s4  ),
	 .ARSIZE_S4  (arsize_s4 ),
	 .ARBURST_S4 (arburst_s4),
	 .ARVALID_S4 (arvalid_s4),
	 .ARREADY_S4 (arready_s4),
	 .RID_S4     (rid_s4    ),
	 .RDATA_S4   (rdata_s4  ),
	 .RRESP_S4   (rresp_s4  ),
	 .RLAST_S4   (rlast_s4  ),
	 .RVALID_S4  (rvalid_s4 ),
	 .RREADY_S4  (rready_s4 )
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
        .awvalid         (0/*awvalid_s0*/),
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
        .wvalid          (0/*wvalid_s0*/),
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


    axi4_slave axi_slave_2 (
        .aclk            (aclk_s),
        .aresetn         (aresetn_s),
        .awid            (awid_s2),
        .awaddr          (awaddr_s2),
        .awlen           (awlen_s2),
        .awsize          (awsize_s2),
        .awburst         (awburst_s2),
        .awlock          (awlock_s2),
        .awcache         (awcache_s2),
        .awprot          (awprot_s2),
        .awvalid         (awvalid_s2),
        .awready         (awready_s2),
        .awqos           (awqos_s2),  
        .awregion        (awregion_s2),  
        .awuser          (awuser_s2),   
	    .ruser           (ruser_s2),
        .arqos           (arqos_s2),  
        .arregion        (arregion_s2),  
        .aruser          (aruser_s2),
        .buser           (buser_s2),
	    .wuser           (wuser_s2),
      
        .wdata           (wdata_s2),
        .wstrb           (wstrb_s2),
        .wlast           (wlast_s2),
        .wvalid          (wvalid_s2),
        .wready          (wready_s2),
        
        .bid             (bid_s2),
        .bresp           (bresp_s2),
        .bvalid          (bvalid_s2),
        .bready          (bready_s2),
        
        .arid            (arid_s2),
        .araddr          (araddr_s2),
        .arlen           (arlen_s2),
        .arsize          (arsize_s2),
        .arburst         (arburst_s2),
        .arlock          (arlock_s2),
        .arcache         (arcache_s2),
        .arprot          (arprot_s2),
        .arvalid         (arvalid_s2),
        .arready         (arready_s2),
        
        .rid             (rid_s2),
        .rdata           (rdata_s2),
        .rresp           (rresp_s2),
        .rlast           (rlast_s2),
        .rvalid          (rvalid_s2),
        .rready          (rready_s2),
        
        .csysreq         (csysreq),
        .csysack         (csysack),
        .cactive         (cactive)
    );

    defparam axi_slave_2.ADDR_WIDTH              = ADDR_WIDTH;
    defparam axi_slave_2.DATA_WIDTH              = DATA_WIDTH;
    defparam axi_slave_2.ID_WIDTH                = IDS_WIDTH;
    defparam axi_slave_2.LEN_WIDTH               = LEN_WIDTH;
    defparam axi_slave_2.MAXLEN                  = MAXLEN;
    defparam axi_slave_2.READ_INTERLEAVE_ON      = 0;
   // defparam axi_slave_2.READ_RESP_IN_ORDER_ON  = 1;
    defparam axi_slave_2.BYTE_STROBE_ON          = 0;
    defparam axi_slave_2.EXCL_ACCESS_ON          = 0;
    defparam axi_slave_2.DATA_BEFORE_CONTROL_ON  = 0;
    defparam axi_slave_2.COVERAGE_ON             = COVERAGE_ON;


    /*axi4_slave axi_slave_3 (
        .aclk            (aclk_s),
        .aresetn         (aresetn_s),
        .awid            (awid_s3),
        .awaddr          (awaddr_s3),
        .awlen           (awlen_s3),
        .awsize          (awsize_s3),
        .awburst         (awburst_s3),
        .awlock          (awlock_s3),
        .awcache         (awcache_s3),
        .awprot          (awprot_s3),
        .awvalid         (awvalid_s3),
        .awready         (awready_s3),
        .awqos           (awqos_s3),  
        .awregion        (awregion_s3),  
        .awuser          (awuser_s3),   
	    .ruser           (ruser_s3),
        .arqos           (arqos_s3),  
        .arregion        (arregion_s3),  
        .aruser          (aruser_s3),
        .buser           (buser_s3),
	    .wuser           (wuser_s3),
      
        .wdata           (wdata_s3),
        .wstrb           (wstrb_s3),
        .wlast           (wlast_s3),
        .wvalid          (wvalid_s3),
        .wready          (wready_s3),
        
        .bid             (bid_s3),
        .bresp           (bresp_s3),
        .bvalid          (bvalid_s3),
        .bready          (bready_s3),
        
        .arid            (arid_s3),
        .araddr          (araddr_s3),
        .arlen           (arlen_s3),
        .arsize          (arsize_s3),
        .arburst         (arburst_s3),
        .arlock          (arlock_s3),
        .arcache         (arcache_s3),
        .arprot          (arprot_s3),
        .arvalid         (arvalid_s3),
        .arready         (arready_s3),
        
        .rid             (rid_s3),
        .rdata           (rdata_s3),
        .rresp           (rresp_s3),
        .rlast           (rlast_s3),
        .rvalid          (rvalid_s3),
        .rready          (rready_s3),
        
        .csysreq         (csysreq),
        .csysack         (csysack),
        .cactive         (cactive)
    );

    defparam axi_slave_3.ADDR_WIDTH              = ADDR_WIDTH;
    defparam axi_slave_3.DATA_WIDTH              = DATA_WIDTH;
    defparam axi_slave_3.ID_WIDTH                = IDS_WIDTH;
    defparam axi_slave_3.LEN_WIDTH               = LEN_WIDTH;
    defparam axi_slave_3.MAXLEN                  = MAXLEN;
    defparam axi_slave_3.READ_INTERLEAVE_ON      = 0;
   // defparam axi_slave_3.READ_RESP_IN_ORDER_ON  = 1;
    defparam axi_slave_3.BYTE_STROBE_ON          = 0;
    defparam axi_slave_3.EXCL_ACCESS_ON          = 0;
    defparam axi_slave_3.DATA_BEFORE_CONTROL_ON  = 0;
    defparam axi_slave_3.COVERAGE_ON             = COVERAGE_ON;*/


    axi4_slave axi_slave_4 (
        .aclk            (aclk_s),
        .aresetn         (aresetn_s),
        .awid            (awid_s4),
        .awaddr          (awaddr_s4),
        .awlen           (awlen_s4),
        .awsize          (awsize_s4),
        .awburst         (awburst_s4),
        .awlock          (awlock_s4),
        .awcache         (awcache_s4),
        .awprot          (awprot_s4),
        .awvalid         (awvalid_s4),
        .awready         (awready_s4),
        .awqos           (awqos_s4),  
        .awregion        (awregion_s4),  
        .awuser          (awuser_s4),   
	    .ruser           (ruser_s4),
        .arqos           (arqos_s4),  
        .arregion        (arregion_s4),  
        .aruser          (aruser_s4),
        .buser           (buser_s4),
	    .wuser           (wuser_s4),
      
        .wdata           (wdata_s4),
        .wstrb           (wstrb_s4),
        .wlast           (wlast_s4),
        .wvalid          (wvalid_s4),
        .wready          (wready_s4),
        
        .bid             (bid_s4),
        .bresp           (bresp_s4),
        .bvalid          (bvalid_s4),
        .bready          (bready_s4),
        
        .arid            (arid_s4),
        .araddr          (araddr_s4),
        .arlen           (arlen_s4),
        .arsize          (arsize_s4),
        .arburst         (arburst_s4),
        .arlock          (arlock_s4),
        .arcache         (arcache_s4),
        .arprot          (arprot_s4),
        .arvalid         (arvalid_s4),
        .arready         (arready_s4),
        
        .rid             (rid_s4),
        .rdata           (rdata_s4),
        .rresp           (rresp_s4),
        .rlast           (rlast_s4),
        .rvalid          (rvalid_s4),
        .rready          (rready_s4),
        
        .csysreq         (csysreq),
        .csysack         (csysack),
        .cactive         (cactive)
    );

    defparam axi_slave_4.ADDR_WIDTH              = ADDR_WIDTH;
    defparam axi_slave_4.DATA_WIDTH              = DATA_WIDTH;
    defparam axi_slave_4.ID_WIDTH                = IDS_WIDTH;
    defparam axi_slave_4.LEN_WIDTH               = LEN_WIDTH;
    defparam axi_slave_4.MAXLEN                  = MAXLEN;
    defparam axi_slave_4.READ_INTERLEAVE_ON      = 0;
   // defparam axi_slave_4.READ_RESP_IN_ORDER_ON  = 1;
    defparam axi_slave_4.BYTE_STROBE_ON          = 0;
    defparam axi_slave_4.EXCL_ACCESS_ON          = 0;
    defparam axi_slave_4.DATA_BEFORE_CONTROL_ON  = 0;
    defparam axi_slave_4.COVERAGE_ON             = COVERAGE_ON;


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
        .awqos           (awqos_m0),  
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
        .bvalid          (0/*bvalid_m0*/),
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
        .awqos           (awqos_m1),  
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

endmodule // top
