`include "AXI_def.svh"

module AXI_wr(
    input ACLK,
    input ARESETn,

    //SLAVE INTERFACE FOR MASTERS
    // M1
    // AW
    input [`AXI_ID_BITS-1:0]            AWID_M1,
    input [`AXI_ADDR_BITS-1:0]          AWADDR_M1,
    input [`AXI_LEN_BITS-1:0]           AWLEN_M1,
    input [`AXI_SIZE_BITS-1:0]          AWSIZE_M1,
    input [`AXI_BURST_BITS-1:0]         AWBURST_M1,
    input                               AWVALID_M1,
    output logic                        AWREADY_M1,
    // W
    input [`AXI_DATA_BITS-1:0]          WDATA_M1,
    input [`AXI_STRB_BITS-1:0]          WSTRB_M1,
    input                               WLAST_M1,
    input                               WVALID_M1,
    output logic                        WREADY_M1,
    // B
    output logic [`AXI_ID_BITS-1:0]     BID_M1,
    output logic [`AXI_RESP_BITS-1:0]   BRESP_M1,
    output logic                        BVALID_M1,
    input                               BREADY_M1,
    // M2
    // AW
    input [`AXI_ID_BITS-1:0]            AWID_M2,
    input [`AXI_ADDR_BITS-1:0]          AWADDR_M2,
    input [`AXI_LEN_BITS-1:0]           AWLEN_M2,
    input [`AXI_SIZE_BITS-1:0]          AWSIZE_M2,
    input [`AXI_BURST_BITS-1:0]         AWBURST_M2,
    input                               AWVALID_M2,
    output logic                        AWREADY_M2,
    // W
    input [`AXI_DATA_BITS-1:0]          WDATA_M2,
    input [`AXI_STRB_BITS-1:0]          WSTRB_M2,
    input                               WLAST_M2,
    input                               WVALID_M2,
    output logic                        WREADY_M2,
    // B
    output logic [`AXI_ID_BITS-1:0]     BID_M2,
    output logic [`AXI_RESP_BITS-1:0]   BRESP_M2,
    output logic                        BVALID_M2,
    input                               BREADY_M2,

    //MASTER INTERFACE FOR SLAVES
    // S1
    output logic [`AXI_IDS_BITS-1:0]    AWID_S1,
    output logic [`AXI_ADDR_BITS-1:0]   AWADDR_S1,
    output logic [`AXI_LEN_BITS-1:0]    AWLEN_S1,
    output logic [`AXI_SIZE_BITS-1:0]   AWSIZE_S1,
    output logic [`AXI_BURST_BITS-1:0]  AWBURST_S1,
    output logic                        AWVALID_S1,
    input                               AWREADY_S1,
    output logic [`AXI_DATA_BITS-1:0]   WDATA_S1,
    output logic [`AXI_STRB_BITS-1:0]   WSTRB_S1,
    output logic                        WLAST_S1,
    output logic                        WVALID_S1,
    input                               WREADY_S1,
    input [`AXI_IDS_BITS-1:0]           BID_S1,
    input [`AXI_RESP_BITS-1:0]          BRESP_S1,
    input                               BVALID_S1,
    output logic                        BREADY_S1,
    // S2
    output logic [`AXI_IDS_BITS-1:0]    AWID_S2,
    output logic [`AXI_ADDR_BITS-1:0]   AWADDR_S2,
    output logic [`AXI_LEN_BITS-1:0]    AWLEN_S2,
    output logic [`AXI_SIZE_BITS-1:0]   AWSIZE_S2,
    output logic [`AXI_BURST_BITS-1:0]  AWBURST_S2,
    output logic                        AWVALID_S2,
    input                               AWREADY_S2,
    output logic [`AXI_DATA_BITS-1:0]   WDATA_S2,
    output logic [`AXI_STRB_BITS-1:0]   WSTRB_S2,
    output logic                        WLAST_S2,
    output logic                        WVALID_S2,
    input                               WREADY_S2,
    input [`AXI_IDS_BITS-1:0]           BID_S2,
    input [`AXI_RESP_BITS-1:0]          BRESP_S2,
    input                               BVALID_S2,
    output logic                        BREADY_S2,
    // S3
    output logic [`AXI_IDS_BITS-1:0]    AWID_S3,
    output logic [`AXI_ADDR_BITS-1:0]   AWADDR_S3,
    output logic [`AXI_LEN_BITS-1:0]    AWLEN_S3,
    output logic [`AXI_SIZE_BITS-1:0]   AWSIZE_S3,
    output logic [1:0]                  AWBURST_S3,
    output logic                        AWVALID_S3,
    input                               AWREADY_S3,
    output logic [`AXI_DATA_BITS-1:0]   WDATA_S3,
    output logic [`AXI_STRB_BITS-1:0]   WSTRB_S3,
    output logic                        WLAST_S3,
    output logic                        WVALID_S3,
    input                               WREADY_S3,
    input [`AXI_IDS_BITS-1:0]           BID_S3,
    input [`AXI_RESP_BITS-1:0]          BRESP_S3,
    input                               BVALID_S3,
    output  logic                       BREADY_S3,
    // S4
    output logic [`AXI_IDS_BITS-1:0]    AWID_S4,
    output logic [`AXI_ADDR_BITS-1:0]   AWADDR_S4,
    output logic [`AXI_LEN_BITS-1:0]    AWLEN_S4,
    output logic [`AXI_SIZE_BITS-1:0]   AWSIZE_S4,
    output logic [1:0]                  AWBURST_S4,
    output logic                        AWVALID_S4,
    input                               AWREADY_S4,
    output logic [`AXI_DATA_BITS-1:0]   WDATA_S4,
    output logic [`AXI_STRB_BITS-1:0]   WSTRB_S4,
    output logic                        WLAST_S4,
    output logic                        WVALID_S4,
    input                               WREADY_S4,
    input [`AXI_IDS_BITS-1:0]           BID_S4,
    input [`AXI_RESP_BITS-1:0]          BRESP_S4,
    input                               BVALID_S4,
    output logic                        BREADY_S4,
    // S5
    output logic [`AXI_IDS_BITS-1:0]    AWID_S5,
    output logic [`AXI_ADDR_BITS-1:0]   AWADDR_S5,
    output logic [`AXI_LEN_BITS-1:0]    AWLEN_S5,
    output logic [`AXI_SIZE_BITS-1:0]   AWSIZE_S5,
    output logic [1:0]                  AWBURST_S5,
    output logic                        AWVALID_S5,
    input                               AWREADY_S5,
    output logic [`AXI_DATA_BITS-1:0]   WDATA_S5,
    output logic [`AXI_STRB_BITS-1:0]   WSTRB_S5,
    output logic                        WLAST_S5,
    output logic                        WVALID_S5,
    input                               WREADY_S5,
    input [`AXI_IDS_BITS-1:0]           BID_S5,
    input [`AXI_RESP_BITS-1:0]          BRESP_S5,
    input                               BVALID_S5,
    output logic                        BREADY_S5,
    // S6
    output logic [`AXI_IDS_BITS-1:0]    AWID_S6,
    output logic [`AXI_ADDR_BITS-1:0]   AWADDR_S6,
    output logic [`AXI_LEN_BITS-1:0]    AWLEN_S6,
    output logic [`AXI_SIZE_BITS-1:0]   AWSIZE_S6,
    output logic [1:0]                  AWBURST_S6,
    output logic                        AWVALID_S6,
    input                               AWREADY_S6,
    output logic [`AXI_DATA_BITS-1:0]   WDATA_S6,
    output logic [`AXI_STRB_BITS-1:0]   WSTRB_S6,
    output logic                        WLAST_S6,
    output logic                        WVALID_S6,
    input                               WREADY_S6,
    input [`AXI_IDS_BITS-1:0]           BID_S6,
    input [`AXI_RESP_BITS-1:0]          BRESP_S6,
    input                               BVALID_S6,
    output logic                        BREADY_S6,
    // S7
    output logic [`AXI_IDS_BITS-1:0]    AWID_S7,
    output logic [`AXI_ADDR_BITS-1:0]   AWADDR_S7,
    output logic [`AXI_LEN_BITS-1:0]    AWLEN_S7,
    output logic [`AXI_SIZE_BITS-1:0]   AWSIZE_S7,
    output logic [1:0]                  AWBURST_S7,
    output logic                        AWVALID_S7,
    input                               AWREADY_S7,
    output logic [`AXI_DATA_BITS-1:0]   WDATA_S7,
    output logic [`AXI_STRB_BITS-1:0]   WSTRB_S7,
    output logic                        WLAST_S7,
    output logic                        WVALID_S7,
    input                               WREADY_S7,
    input [`AXI_IDS_BITS-1:0]           BID_S7,
    input [`AXI_RESP_BITS-1:0]          BRESP_S7,
    input                               BVALID_S7,
    output logic                        BREADY_S7
);

localparam      IDLE    = 2'b00;
localparam      WAIT_W  = 2'b01;
localparam      WAIT_B  = 2'b10;

localparam      M1_ID   = 4'h1;
localparam      M2_ID   = 4'h2;

typedef enum logic[3:0] {
    NO_S,
    S1,
    S2,
    S3,
    S4,
    S5,
    S6,
    S7,
    DEF_S
} AXI_SlaveSel;

typedef enum logic[1:0] {
    NO_M,
    M1,
    M2
} AXI_MasterSel;

logic [1:0]     w_state;
logic           new_aw_ok;
logic           aw_handshake;
logic           w_handshake;
logic           all_w_handshake;
logic           b_handshake;
logic           awready_ok, wready_ok;
logic           w_burst;
logic           keep_aw;

AXI_MasterSel   aw_master, aw_master_reg;
AXI_SlaveSel    aw_slave, aw_slave_reg;
AXI_SlaveSel    aw_M1_slave;
AXI_SlaveSel    aw_M2_slave;
AXI_MasterSel   w_master,
                w_master_reg;
AXI_SlaveSel    w_slave,
                w_slave_reg;
AXI_MasterSel   b_master;
AXI_SlaveSel    b_slave;

logic [`AXI_IDS_BITS-1:0]   awid_reg;

logic [`AXI_IDS_BITS-1:0]   awid;
logic [`AXI_ADDR_BITS-1:0]  awaddr;
logic [`AXI_LEN_BITS-1:0]   awlen;
logic [`AXI_SIZE_BITS-1:0]  awsize;
logic [`AXI_BURST_BITS-1:0] awburst;
logic                       awvalid;
logic                       awready;
logic [`AXI_DATA_BITS-1:0]  wdata;
logic [`AXI_STRB_BITS-1:0]  wstrb;
logic                       wlast;
logic                       wvalid;
logic                       wready;
logic [`AXI_IDS_BITS-1:0]   bid;
logic [`AXI_RESP_BITS-1:0]  bresp;
logic                       bvalid;
logic                       bready;

logic                       default_awready;
logic                       default_wready;
logic [`AXI_IDS_BITS-1:0]   default_bid;
logic [`AXI_RESP_BITS-1:0]  default_bresp;
logic                       default_bvalid;

assign aw_handshake     = awready & awvalid;
assign w_handshake      = wready & wvalid;
assign all_w_handshake  = aw_handshake & w_handshake;
assign b_handshake      = bready & bvalid;
assign w_burst          = (awlen != 4'd0);

// write FSM
always_ff @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) begin
        w_state <= IDLE;
    end 
    else begin
        unique case (w_state)
        IDLE: begin
            if(all_w_handshake) begin // new aw & w handshake
                if(w_burst) 
                    w_state <= WAIT_W; // finish one w trans, another w trans left
                else
                    w_state <= WAIT_B;
                end
            else if (aw_handshake) begin // new aw handshake, but r handshake not yet
                w_state <= WAIT_W; 
            end
        end
        WAIT_W: begin
            if(w_handshake && wlast) begin  // finish w handshake
                w_state <= WAIT_B;
            end
        end
        default: begin// WAIT_B
            if (b_handshake) begin// finish current resp
                w_state <= IDLE;
            end
        end
        endcase
    end
end

// decide ar & r master and slave
always_comb begin
    if(w_state == IDLE) begin // can accept new request
        priority if (keep_aw) begin
            aw_master = aw_master_reg;
            aw_slave = aw_slave_reg;
            w_master = w_master_reg;
            w_slave = w_slave_reg;
        end
        else if (AWVALID_M1) begin
            aw_master = M1;
            aw_slave = aw_M1_slave;
            w_master = M1;
            w_slave = aw_M1_slave;
        end
        else if (AWVALID_M2) begin
            aw_master = M2;
            aw_slave = aw_M2_slave;
            w_master = M2;
            w_slave = aw_M2_slave;
        end
        else begin // no new request
            aw_master = NO_M; 
            aw_slave = NO_S; 
            w_master = NO_M;
            w_slave = NO_S;
        end
    end
    else begin // not yet finish current write trans, cannot accept new request
        aw_master = NO_M; 
        aw_slave = NO_S; 
        w_master = w_master_reg;
        w_slave = w_slave_reg;
    end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) begin
        keep_aw <= 1'b0;
        aw_master_reg <= NO_M;
        aw_slave_reg <= NO_S;
    end 
    else if (awvalid & ~awready) begin
        keep_aw <= 1'b1;
        aw_master_reg <= aw_master;
        aw_slave_reg <= aw_slave;
    end
    else begin
        keep_aw <= 1'b0;
        aw_master_reg <= NO_M;
        aw_slave_reg <= NO_S;
    end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) begin
        w_master_reg <= NO_M;
        w_slave_reg <= NO_S;
    end 
    else begin
        w_master_reg <= w_master;
        w_slave_reg <= w_slave;
    end
end

// decide resp master and slave
always_ff @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) begin
        b_master <= NO_M;
        b_slave <= NO_S;
    end
    else begin
        unique case (w_state)
        IDLE: begin
            if(~w_burst && all_w_handshake) begin // accept new ar request
                b_master <= w_master;
                b_slave <= w_slave;
            end
        end
        WAIT_W: begin
            if(w_handshake && wlast) begin // accept new ar request
                b_master <= w_master;
                b_slave <= w_slave;
            end
        end  
        default: begin // WAIT_B    
            if (b_handshake) begin // finish resp but not yet complete all_w_handshake
                b_master <= NO_M;
                b_slave <= NO_S;
            end
        end
        endcase
    end
end

assign aw_M1_slave = AXI_SlaveSel'(getSlave(AWADDR_M1));
assign aw_M2_slave = AXI_SlaveSel'(getSlave(AWADDR_M2));

function logic[3:0] getSlave; //AXI_SlaveSel
    input [31:0] addr;
    begin
        unique if(~|addr[31:17] && addr[16]) begin // IM 0x0001_0000 ~ 0x0001_FFFF
            getSlave = S1;
        end
        else if(~|{addr[31:18],addr[16]} && addr[17]) begin // DM 0x0002_0000 ~ 0x0002_FFFF
            getSlave = S2;
        end
        else if(~|{addr[31:29],addr[27:10]} && addr[28]) begin // Sctrl 0x1000_0000 ~ 0x1000_03FF
            getSlave = S3;
        end
        else if(~|{addr[31:30],addr[28:25]} && addr[29]) begin // DRAM 0x2000_0000 ~ 0x21FF_FFFF
            getSlave = S4;
        end
        else if(~|{addr[31:30], addr[27:12]} && &addr[29:28]) begin // DMA 0x3000_0000 ~ 0x3000_0FFF
            getSlave = S5;
        end
        else if(~|{addr[31:30], addr[27:13], addr[11:4]} && &addr[29:28] && addr[12]) begin // TPU 0x3000_1000 ~ 0x3000_100F
            getSlave = S6;
        end
        else if(~|{addr[31], addr[29:14]} && addr[30]) begin// PLIC 0x4000_0000 ~ 0x4000_3FFF
            getSlave = S7;
        end
        else begin
            getSlave = DEF_S;
        end
    end
endfunction

// master select signal
always_comb begin
    unique case (aw_master)
    M1: begin
        awid    = {AWID_M1, M1_ID};
        awaddr  = {2'd0, AWADDR_M1[29:0]};
        awlen   = AWLEN_M1;
        awsize  = AWSIZE_M1;
        awburst = AWBURST_M1;
        awvalid = AWVALID_M1;
    end
    M2: begin
        awid    = {AWID_M2, M2_ID};
        awaddr  = {2'd0, AWADDR_M2[29:0]};
        awlen   = AWLEN_M2;
        awsize  = AWSIZE_M2;
        awburst = AWBURST_M2;
        awvalid = AWVALID_M2;
    end
    default: begin // No master
        awid    = `AXI_IDS_BITS'd0;
        awaddr  = `AXI_ADDR_BITS'd0;
        awlen   = `AXI_LEN_BITS'd0;
        awsize  = `AXI_SIZE_BITS'd0;
        awburst = `AXI_BURST_BITS'd0;
        awvalid = 1'b0;
    end
    endcase
end

always_comb begin
    unique case (w_master)
    M1: begin
        wdata   = WDATA_M1;
        wstrb   = WSTRB_M1;
        wlast   = WLAST_M1;
        wvalid  = WVALID_M1;
    end
    M2: begin
        wdata   = WDATA_M2;
        wstrb   = WSTRB_M2;
        wlast   = WLAST_M2;
        wvalid  = WVALID_M2;
    end
    default: begin
        wdata   = `AXI_DATA_BITS'd0;
        wstrb   = `AXI_STRB_BITS'd0;
        wlast   = 1'b0;
        wvalid  = 1'b0;
    end
    endcase
end

always_comb begin
    unique case(b_master) 
    M1: begin
        bready = BREADY_M1;
    end
    M2: begin
        bready = BREADY_M2;
    end
    default: begin
        bready = 1'b0;
    end
    endcase
end

// slave select signal
always_comb begin
    unique case(aw_slave)
        S1: begin
            awready = AWREADY_S1;
        end
        S2: begin
            awready = AWREADY_S2;
        end
        S3: begin 
            awready = AWREADY_S3;
        end
        S4: begin
            awready = AWREADY_S4;
        end
        S5: begin
            awready = AWREADY_S5;
        end
        S6: begin
            awready = AWREADY_S6;
        end
        S7: begin
            awready = AWREADY_S7;
        end
        DEF_S: begin
            awready = default_awready;
        end
        default: begin// NO_S
            awready = 1'b0;
        end
    endcase
end

always_comb begin
    unique case(w_slave)
        S1: begin
            wready = WREADY_S1;
        end
        S2: begin
            wready = WREADY_S2;
        end
        S3: begin
            wready = WREADY_S3;
        end
        S4: begin
            wready = WREADY_S4;
        end
        S5: begin
            wready = WREADY_S5;
        end
        S6: begin
            wready = WREADY_S6;
        end
        S7: begin
            wready = WREADY_S7;
        end
        DEF_S: begin
            wready = default_wready;
        end
        default: begin// NO_S
            wready = 1'b0;
        end
    endcase
end

always_comb begin
    unique case(b_slave)
        S1: begin
            bid     = BID_S1;
            bresp   = BRESP_S1;
            bvalid  = BVALID_S1;
        end
        S2: begin
            bid     = BID_S2;
            bresp   = BRESP_S2;
            bvalid  = BVALID_S2;
        end
        S3: begin
            bid     = BID_S3;
            bresp   = BRESP_S3;
            bvalid  = BVALID_S3;
        end
        S4: begin
            bid     = BID_S4;
            bresp   = BRESP_S4;
            bvalid  = BVALID_S4;
        end
        S5: begin
            bid     = BID_S5;
            bresp   = BRESP_S5;
            bvalid  = BVALID_S5;
        end
        S6: begin
            bid     = BID_S6;
            bresp   = BRESP_S6;
            bvalid  = BVALID_S6;
        end
        S7: begin
            bid     = BID_S7;
            bresp   = BRESP_S7;
            bvalid  = BVALID_S7;
        end
        DEF_S: begin
            bid     = default_bid;
            bresp   = default_bresp;
            bvalid  = default_bvalid;
        end
        default: begin // NO_S
            bid     = {`AXI_IDS_BITS{1'b0}};
            bresp   = {`AXI_RESP_BITS{1'b0}};
            bvalid  = 1'b0;
        end
    endcase
end

// output
// M1
always_comb begin
    if (aw_master == M1) begin
        AWREADY_M1 = awready;
    end
    else begin
        AWREADY_M1 = 1'b0;
    end
end

always_comb begin
    if (w_master == M1) begin
        WREADY_M1  = wready;
    end
    else begin
        WREADY_M1  = 1'b0;
    end
end

always_comb begin
    if (b_master == M1) begin
        BID_M1     = bid[7:4];
        BRESP_M1   = bresp;
        BVALID_M1  = bvalid;
    end 
    else begin
        BID_M1     = `AXI_ID_BITS'd0;
        BRESP_M1   = `AXI_RESP_OKAY;
        BVALID_M1  = 1'b0;
    end
end

// M2
always_comb begin
    if (aw_master == M2) begin
        AWREADY_M2 = awready;
    end
    else begin
        AWREADY_M2 = 1'b0;
    end
end

always_comb begin
    if (w_master == M2) begin
        WREADY_M2  = wready;
    end
    else begin
        WREADY_M2  = 1'b0;
    end
end

always_comb begin
    if (b_master == M2) begin
        BID_M2     = bid[7:4];
        BRESP_M2   = bresp;
        BVALID_M2  = bvalid;
    end 
    else begin
        BID_M2     = `AXI_ID_BITS'd0;
        BRESP_M2   = `AXI_RESP_OKAY;
        BVALID_M2  = 1'b0;
    end
end

// S1
always_comb begin
    if(aw_slave == S1) begin
        AWID_S1    = awid;
        AWADDR_S1  = {16'd0, awaddr[15:0]};
        AWLEN_S1   = awlen;
        AWSIZE_S1  = awsize;
        AWBURST_S1 = awburst;
        AWVALID_S1 = awvalid;
    end
    else begin
        AWID_S1    = `AXI_IDS_BITS'd0;
        AWADDR_S1  = `AXI_ADDR_BITS'd0;
        AWLEN_S1   = `AXI_LEN_BITS'd0;
        AWSIZE_S1  = `AXI_SIZE_BITS'd0;
        AWBURST_S1 = `AXI_BURST_BITS'd0;
        AWVALID_S1 = 1'b0;
    end
end

always_comb begin
    if (w_slave == S1) begin
        WDATA_S1   = wdata;
        WSTRB_S1   = wstrb;
        WVALID_S1  = wvalid;
        WLAST_S1   = wlast;
    end 
    else begin
        WDATA_S1   = `AXI_DATA_BITS'd0;
        WSTRB_S1   = `AXI_STRB_BITS'd0;
        WVALID_S1  = 1'b0;
        WLAST_S1   = 1'b0;
    end
end

always_comb begin
    if(b_slave == S1) begin
        BREADY_S1  = bready;
    end
    else begin
        BREADY_S1  = 1'b0;
    end
end

// S2
always_comb begin
    if(aw_slave == S2) begin
        AWID_S2    = awid;
        AWADDR_S2  = {16'd0, awaddr[15:0]};
        AWLEN_S2   = awlen;
        AWSIZE_S2  = awsize;
        AWBURST_S2 = awburst;
        AWVALID_S2 = awvalid;
    end
    else begin
        AWID_S2    = `AXI_IDS_BITS'd0;
        AWADDR_S2  = `AXI_ADDR_BITS'd0;
        AWLEN_S2   = `AXI_LEN_BITS'd0;
        AWSIZE_S2  = `AXI_SIZE_BITS'd0;
        AWBURST_S2 = `AXI_BURST_BITS'd0;
        AWVALID_S2 = 1'b0;
    end
end

always_comb begin
    if (w_slave == S2) begin
        WDATA_S2   = wdata;
        WSTRB_S2   = wstrb;
        WVALID_S2  = wvalid;
        WLAST_S2   = wlast;
    end 
    else begin
        WDATA_S2   = `AXI_DATA_BITS'd0;
        WSTRB_S2   = `AXI_STRB_BITS'd0;
        WVALID_S2  = 1'b0;
        WLAST_S2   = 1'b0;
    end
end

always_comb begin
    if(b_slave == S2) begin
        BREADY_S2  = bready;
    end
    else begin
        BREADY_S2  = 1'b0;
    end
end

// S3
always_comb begin
    if(aw_slave == S3) begin
        AWID_S3    = awid;
        AWADDR_S3  = {22'd0, awaddr[9:0]};
        AWLEN_S3   = awlen;
        AWSIZE_S3  = awsize;
        AWBURST_S3 = awburst;
        AWVALID_S3 = awvalid;
    end
    else begin
        AWID_S3    = `AXI_IDS_BITS'd0;
        AWADDR_S3  = `AXI_ADDR_BITS'd0;
        AWLEN_S3   = `AXI_LEN_BITS'd0;
        AWSIZE_S3  = `AXI_SIZE_BITS'd0;
        AWBURST_S3 = `AXI_BURST_BITS'd0;
        AWVALID_S3 = 1'b0;
    end
end

always_comb begin
    if (w_slave == S3) begin
        WDATA_S3   = wdata;
        WSTRB_S3   = wstrb;
        WVALID_S3  = wvalid;
        WLAST_S3   = wlast;
    end 
    else begin
        WDATA_S3   = `AXI_DATA_BITS'd0;
        WSTRB_S3   = `AXI_STRB_BITS'd0;
        WVALID_S3  = 1'b0;
        WLAST_S3   = 1'b0;
    end
end

always_comb begin
    if(b_slave == S3) begin
        BREADY_S3  = bready;
    end
    else begin
        BREADY_S3  = 1'b0;
    end
end

// S4
always_comb begin
    if(aw_slave == S4) begin
        AWID_S4    = awid;
        AWADDR_S4  = {7'd0, awaddr[24:0]};
        AWLEN_S4   = awlen;
        AWSIZE_S4  = awsize;
        AWBURST_S4 = awburst;
        AWVALID_S4 = awvalid;
    end
    else begin
        AWID_S4    = `AXI_IDS_BITS'd0;
        AWADDR_S4  = `AXI_ADDR_BITS'd0;
        AWLEN_S4   = `AXI_LEN_BITS'd0;
        AWSIZE_S4  = `AXI_SIZE_BITS'd0;
        AWBURST_S4 = `AXI_BURST_BITS'd0;
        AWVALID_S4 = 1'b0;
    end
end

always_comb begin
    if (w_slave == S4) begin
        WDATA_S4   = wdata;
        WSTRB_S4   = wstrb;
        WVALID_S4  = wvalid;
        WLAST_S4   = wlast;
    end 
    else begin
        WDATA_S4   = `AXI_DATA_BITS'd0;
        WSTRB_S4   = `AXI_STRB_BITS'd0;
        WVALID_S4  = 1'b0;
        WLAST_S4   = 1'b0;
    end
end

always_comb begin
    if(b_slave == S4) begin
        BREADY_S4  = bready;
    end
    else begin
        BREADY_S4  = 1'b0;
    end
end

// S5
always_comb begin
    if(aw_slave == S5) begin
        AWID_S5    = awid;
        AWADDR_S5  = {20'd0, awaddr[11:0]};
        AWLEN_S5   = awlen;
        AWSIZE_S5  = awsize;
        AWBURST_S5 = awburst;
        AWVALID_S5 = awvalid;
    end
    else begin
        AWID_S5    = `AXI_IDS_BITS'd0;
        AWADDR_S5  = `AXI_ADDR_BITS'd0;
        AWLEN_S5   = `AXI_LEN_BITS'd0;
        AWSIZE_S5  = `AXI_SIZE_BITS'd0;
        AWBURST_S5 = `AXI_BURST_BITS'd0;
        AWVALID_S5 = 1'b0;
    end
end

always_comb begin
    if (w_slave == S5) begin
        WDATA_S5   = wdata;
        WSTRB_S5   = wstrb;
        WVALID_S5  = wvalid;
        WLAST_S5   = wlast;
    end 
    else begin
        WDATA_S5   = `AXI_DATA_BITS'd0;
        WSTRB_S5   = `AXI_STRB_BITS'd0;
        WVALID_S5  = 1'b0;
        WLAST_S5   = 1'b0;
    end
end

always_comb begin
    if(b_slave == S5) begin
        BREADY_S5  = bready;
    end
    else begin
        BREADY_S5  = 1'b0;
    end
end

// S6
always_comb begin
    if(aw_slave == S6) begin
        AWID_S6    = awid;
        AWADDR_S6  = {28'd0, awaddr[3:0]};
        AWLEN_S6   = awlen;
        AWSIZE_S6  = awsize;
        AWBURST_S6 = awburst;
        AWVALID_S6 = awvalid;
    end
    else begin
        AWID_S6    = `AXI_IDS_BITS'd0;
        AWADDR_S6  = `AXI_ADDR_BITS'd0;
        AWLEN_S6   = `AXI_LEN_BITS'd0;
        AWSIZE_S6  = `AXI_SIZE_BITS'd0;
        AWBURST_S6 = `AXI_BURST_BITS'd0;
        AWVALID_S6 = 1'b0;
    end
end

always_comb begin
    if (w_slave == S6) begin
        WDATA_S6   = wdata;
        WSTRB_S6   = wstrb;
        WVALID_S6  = wvalid;
        WLAST_S6   = wlast;
    end 
    else begin
        WDATA_S6   = `AXI_DATA_BITS'd0;
        WSTRB_S6   = `AXI_STRB_BITS'd0;
        WVALID_S6  = 1'b0;
        WLAST_S6   = 1'b0;
    end
end

always_comb begin
    if(b_slave == S6) begin
        BREADY_S6  = bready;
    end
    else begin
        BREADY_S6  = 1'b0;
    end
end

// S7
always_comb begin
    if(aw_slave == S7) begin
        AWID_S7    = awid;
        AWADDR_S7  = {18'd0, awaddr[13:0]};
        AWLEN_S7   = awlen;
        AWSIZE_S7  = awsize;
        AWBURST_S7 = awburst;
        AWVALID_S7 = awvalid;
    end
    else begin
        AWID_S7    = `AXI_IDS_BITS'd0;
        AWADDR_S7  = `AXI_ADDR_BITS'd0;
        AWLEN_S7   = `AXI_LEN_BITS'd0;
        AWSIZE_S7  = `AXI_SIZE_BITS'd0;
        AWBURST_S7 = `AXI_BURST_BITS'd0;
        AWVALID_S7 = 1'b0;
    end
end

always_comb begin
    if (w_slave == S7) begin
        WDATA_S7   = wdata;
        WSTRB_S7   = wstrb;
        WVALID_S7  = wvalid;
        WLAST_S7   = wlast;
    end 
    else begin
        WDATA_S7   = `AXI_DATA_BITS'd0;
        WSTRB_S7   = `AXI_STRB_BITS'd0;
        WVALID_S7  = 1'b0;
        WLAST_S7   = 1'b0;
    end
end

always_comb begin
    if(b_slave == S7) begin
        BREADY_S7  = bready;
    end
    else begin
        BREADY_S7  = 1'b0;
    end
end

// default slave

assign default_bresp   = `AXI_RESP_DECERR;

always_comb begin
    unique case(w_state)
    IDLE: begin
        default_awready = 1'b1;
        default_wready = 1'b1;
    end
    WAIT_W: begin
        default_awready = 1'b0;
        default_wready = 1'b1;
    end
    default: begin // WAIT_B
        default_awready = 1'b0;
        default_wready = 1'b0;
    end
    endcase
end

always_comb begin
    if(w_state == WAIT_B) begin
        default_bvalid = 1'b1;
        default_bid    = awid_reg;
    end
    else begin
        default_bvalid = 1'b0;
        default_bid    = `AXI_IDS_BITS'd0;
    end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) 
        awid_reg <= `AXI_IDS_BITS'd0;
    else if(aw_handshake)
        awid_reg <= awid;
end

endmodule
