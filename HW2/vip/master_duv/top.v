//================================================
// Auther:      Chang Wan-Yun (Claire)            
// Filename:    top.v                            
// Description: Top module of AXI master VIP                
// Version:     1.0 
//================================================

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
    localparam BRESP_WIDTH              = 2;
    localparam RRESP_WIDTH              = 2;
    localparam AWUSER_WIDTH            = 32; // Size of AWUser field
    localparam WUSER_WIDTH             = 32; // Size of WUser field
    localparam BUSER_WIDTH             = 32; // Size of BUser field
    localparam ARUSER_WIDTH            = 32; // Size of ARUser field
    localparam RUSER_WIDTH             = 32; // Size of RUser field
    localparam QOS_WIDTH               = 4;  // Size of QOS field
    localparam REGION_WIDTH            = 4;  // Size of Region field

    // Clock and reset    
    wire                        aclk;
    wire                        aresetn;
    
    
    // ----------master0---------- //

    //--------------------------------------------//
    CPU_wrapper axi_duv_master(
        .clk(aclk),
        .rst(~aresetn),
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
    //--------------------------------------------//
    wire rst = ~aresetn;


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

    // Low power signals
    wire                        csysreq;     // Low Power - Power Off Request
    wire                        csysack;     // Low Power - Power Off Acknowledge
    wire                        cactive;     // Low Power - activate


    //-------------------------------------------//
    //----- you should put your design here -----//
    //-------------------------------------------//

    // Instance of the AXI Monitor
    axi4_slave axi_monitor_0 (
        .aclk            (aclk),
        .aresetn         (aresetn),
        .awid            (awid_m0),
        .awaddr          (awaddr_m0),
        .awlen           (awlen_m0),
        .awsize          (awsize_m0),
        .awburst         (awburst_m0),
        .awlock          (awlock_m0),
        .awcache         (awcache_m0),
        .awprot          (awprot_m0),
        .awvalid         (0),
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
        .wvalid          (0),
        .wready          (wready_m0),
        
        .bid             (bid_m0),
        .bresp           (bresp_m0),
        .bvalid          (bvalid_m0),
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

    defparam axi_monitor_0.ADDR_WIDTH              = ADDR_WIDTH;
    defparam axi_monitor_0.DATA_WIDTH              = DATA_WIDTH;
    defparam axi_monitor_0.ID_WIDTH                = ID_WIDTH;
    defparam axi_monitor_0.LEN_WIDTH               = LEN_WIDTH;
    defparam axi_monitor_0.MAXLEN                  = MAXLEN;
    defparam axi_monitor_0.READ_INTERLEAVE_ON      = 0;
    defparam axi_monitor_0.BYTE_STROBE_ON          = 0;
    defparam axi_monitor_0.EXCL_ACCESS_ON          = 0;
    defparam axi_monitor_0.DATA_BEFORE_CONTROL_ON  = 0;
    // To enable debug and coverage
    defparam axi_monitor_0.COVERAGE_ON             = COVERAGE_ON;

 
    axi4_slave axi_monitor_1 (
        .aclk            (aclk),
        .aresetn         (aresetn),
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

    defparam axi_monitor_1.ADDR_WIDTH              = ADDR_WIDTH;
    defparam axi_monitor_1.DATA_WIDTH              = DATA_WIDTH;
    defparam axi_monitor_1.ID_WIDTH                = ID_WIDTH;
    defparam axi_monitor_1.LEN_WIDTH               = LEN_WIDTH;
    defparam axi_monitor_1.MAXLEN                  = MAXLEN;
    defparam axi_monitor_1.READ_INTERLEAVE_ON      = 0;
    defparam axi_monitor_1.BYTE_STROBE_ON          = 0;
    defparam axi_monitor_1.EXCL_ACCESS_ON          = 0;
    defparam axi_monitor_1.DATA_BEFORE_CONTROL_ON  = 0;
    // To enable debug and coverage
    defparam axi_monitor_1.COVERAGE_ON             = COVERAGE_ON;


endmodule
