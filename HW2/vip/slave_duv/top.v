//================================================
// Auther:      Chang Wan-Yun (Claire)            
// Filename:    top.v                            
// Description: Top module of AXI master VIP                
// Version:     1.0 
//================================================

module top #(parameter bit COVERAGE_ON = 0) ();

    // user defined AXI parameters
    localparam DATA_WIDTH              = 32;
    localparam ADDR_WIDTH              = 16;
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
    reg                        aclk;
    reg                        aresetn;

    // Write address channel signals
    wire    [ID_WIDTH-1:0]      awid;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst;   // Write address burst type
    wire                        awlock;    // Write address lock type
    wire    [PROT_WIDTH-1:0]    awprot;    // Write address protection level
    wire    [CACHE_WIDTH-1:0]   awcache;   // Write address cache type
    wire                        awvalid;   // Write address valid
    wire                        awready;   // Write address ready
    wire    [QOS_WIDTH-1:0]     awqos;     // Write address Quality of service
    wire    [REGION_WIDTH-1:0]  awregion;  // Write address slave address region
    wire    [AWUSER_WIDTH-1:0]  awuser;    // Write address user signal

    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb;     // Write strobe
    wire                        wlast;     // Write last
    wire                        wvalid;    // Write valid
    wire                        wready;    // Write ready
    wire    [WUSER_WIDTH-1:0]   wuser;     // Write user signal
    // Write response channel signals
    wire    [ID_WIDTH-1:0]      bid;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]    bresp;     // Write response
    wire                        bvalid;    // Write response valid
    wire                       bready;    // Write response ready
    wire    [BUSER_WIDTH-1:0]   buser;     // Write response user signal
    // Read address channel signals
    wire    [ID_WIDTH-1:0]      arid;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst;   // Read address burst type
    wire                        arlock;    // Read address lock type
    wire    [PROT_WIDTH-1:0]    arprot;    // Read address protection level
    wire    [CACHE_WIDTH-1:0]   arcache;   // Read address cache type
    wire                        arvalid;   // Read address valid
    wire                        arready;   // Read address ready
    wire    [QOS_WIDTH-1:0]     arqos;     // Read address Quality of service
    wire    [REGION_WIDTH-1:0]  arregion;  // Read address slave address region
    wire    [ARUSER_WIDTH-1:0]  aruser;    // Read address user signal

    // Read data channel signals
    wire    [ID_WIDTH-1:0]      rid;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata;     // Read data
    wire                       rlast;     // Read last
    wire                       rvalid;    // Read valid
    wire                        rready;    // Read ready
    wire    [RRESP_WIDTH-1:0]    rresp;     // Read response
    wire    [RUSER_WIDTH-1:0]   ruser;     // Read address user signal

    // AXI 4 Bridge GLobal Interface (connects to low power controller)

    // Low power signals
    wire                        csysreq;     // Low Power - Power Off Request
    wire                        csysack;     // Low Power - Power Off Acknowledge
    wire                        cactive;     // Low Power - activate



    //-------------------------------------------//
    SRAM_wrapper axi_duv_slave
    (
        .clock(aclk),
	.reset(aresetn),
        // READ ADDRESS
	.ARID(arid),
	.ARADDR(araddr),
	.ARLEN(arlen),
	.ARSIZE(arsize),
	.ARBURST(arburst),
	.ARVALID(arvalid),
	.ARREADY(arready),
	// READ DATA
	.RID(rid),
	.RDATA(rdata),
	.RRESP(rresp),
	.RLAST(rlast),
	.RVALID(rvalid),
	.RREADY(rready),
        // WRITE ADDRESS
	.AWID(awid),
	.AWADDR(awaddr),
	.AWLEN(awlen),
	.AWSIZE(awsize),
	.AWBURST(awburst),
	.AWVALID(awvalid),
	.AWREADY(awready),
	// WRITE DATA
	.WDATA(wdata),
	.WSTRB(wstrb),
	.WLAST(wlast),
	.WVALID(wvalid),
	.WREADY(wready),
	// WRITE RESPONSE
	.BID(bid),
	.BRESP(bresp),
	.BVALID(bvalid),
	.BREADY(bready)
    );
    //-------------------------------------------//

     axi4_master axi_monitor 
     (
        .aclk            (aclk),
        .aresetn         (aresetn),
        .awid            (awid),
        .awaddr          (awaddr),
        .awlen           (awlen),
        .awsize          (awsize),
        .awburst         (awburst),
        .awlock          (awlock),
        .awcache         (awcache),
        .awprot          (awprot),
        .awvalid         (awvalid),
        .awready         (awready),
        .awqos           (awqos),  
        .awregion        (awregion),  
        .awuser          (awuser),   
	.ruser           (ruser),
        .arqos           (arqos),  
        .arregion        (arregion),  
        .aruser          (aruser),
        .buser           (buser),
	.wuser           (wuser),
     
        .wdata           (wdata),
        .wstrb           (wstrb),
        .wlast           (wlast),
        .wvalid          (wvalid),
        .wready          (wready),
        
        .bid             (bid),
        .bresp           (bresp),
        .bvalid          (bvalid),
        .bready          (bready),
        
        .arid            (arid),
        .araddr          (araddr),
        .arlen           (arlen),
        .arsize          (arsize),
        .arburst         (arburst),
        .arlock          (arlock),
        .arcache         (arcache),
        .arprot          (arprot),
        .arvalid         (arvalid),
        .arready         (arready),
        
        .rid             (rid),
        .rdata           (rdata),
        .rresp           (rresp),
        .rlast           (rlast),
        .rvalid          (rvalid),
        .rready          (rready),
        
        .csysreq         (csysreq),
        .csysack         (csysack),
        .cactive         (cactive)
    );

    defparam axi_monitor.ADDR_WIDTH              = ADDR_WIDTH;
    defparam axi_monitor.DATA_WIDTH              = DATA_WIDTH;
    defparam axi_monitor.ID_WIDTH                = IDS_WIDTH;
    defparam axi_monitor.LEN_WIDTH               = LEN_WIDTH;
    defparam axi_monitor.MAXLEN                  = MAXLEN;
    defparam axi_monitor.READ_INTERLEAVE_ON      = 0;
    defparam axi_monitor.BYTE_STROBE_ON          = 0;
    defparam axi_monitor.EXCL_ACCESS_ON          = 0;
    defparam axi_monitor.DATA_BEFORE_CONTROL_ON  = 0;
    // To enable debug and coverage
    defparam axi_monitor.COVERAGE_ON             = COVERAGE_ON;   

endmodule
