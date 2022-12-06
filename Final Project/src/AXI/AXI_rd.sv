`include "AXI_def.svh"

module AXI_rd(

    input                               ACLK,
    input                               ARESETn,

    //SLAVE INTERFACE FOR MASTERS
    // M0
    input [`AXI_ID_BITS-1:0]            ARID_M0,
    input [`AXI_ADDR_BITS-1:0]          ARADDR_M0,
    input [`AXI_LEN_BITS-1:0]           ARLEN_M0,
    input [`AXI_SIZE_BITS-1:0]          ARSIZE_M0,
    input [`AXI_BURST_BITS-1:0]         ARBURST_M0,
    input                               ARVALID_M0,
    output logic                        ARREADY_M0,
    output logic [`AXI_ID_BITS-1:0]     RID_M0,
    output logic [`AXI_DATA_BITS-1:0]   RDATA_M0,
    output logic [`AXI_RESP_BITS-1:0]   RRESP_M0,
    output logic                        RLAST_M0,
    output logic                        RVALID_M0,
    input                               RREADY_M0,
    // M1
    input [`AXI_ID_BITS-1:0]            ARID_M1,
    input [`AXI_ADDR_BITS-1:0]          ARADDR_M1,
    input [`AXI_LEN_BITS-1:0]           ARLEN_M1,
    input [`AXI_SIZE_BITS-1:0]          ARSIZE_M1,
    input [`AXI_BURST_BITS-1:0]         ARBURST_M1,
    input                               ARVALID_M1,
    output logic                        ARREADY_M1,
    output logic [`AXI_ID_BITS-1:0]     RID_M1,
    output logic [`AXI_DATA_BITS-1:0]   RDATA_M1,
    output logic [`AXI_RESP_BITS-1:0]   RRESP_M1,
    output logic                        RLAST_M1,
    output logic                        RVALID_M1,
    input                               RREADY_M1,
    // M2
    input [`AXI_ID_BITS-1:0]            ARID_M2,
    input [`AXI_ADDR_BITS-1:0]          ARADDR_M2,
    input [`AXI_LEN_BITS-1:0]           ARLEN_M2,
    input [`AXI_SIZE_BITS-1:0]          ARSIZE_M2,
    input [`AXI_BURST_BITS-1:0]         ARBURST_M2,
    input                               ARVALID_M2,
    output logic                        ARREADY_M2,
    output logic [`AXI_ID_BITS-1:0]     RID_M2,
    output logic [`AXI_DATA_BITS-1:0]   RDATA_M2,
    output logic [`AXI_RESP_BITS-1:0]   RRESP_M2,
    output logic                        RLAST_M2,
    output logic                        RVALID_M2,
    input                               RREADY_M2,

    //MASTER INTERFACE FOR SLAVES
    // S0
    output logic [`AXI_IDS_BITS-1:0]    ARID_S0,
    output logic [`AXI_ADDR_BITS-1:0]   ARADDR_S0,
    output logic [`AXI_LEN_BITS-1:0]    ARLEN_S0,
    output logic [`AXI_SIZE_BITS-1:0]   ARSIZE_S0,
    output logic [`AXI_BURST_BITS-1:0]  ARBURST_S0,
    output logic                        ARVALID_S0,
    input                               ARREADY_S0,
    input [`AXI_IDS_BITS-1:0]           RID_S0,
    input [`AXI_DATA_BITS-1:0]          RDATA_S0,
    input [`AXI_RESP_BITS-1:0]          RRESP_S0,
    input                               RLAST_S0,
    input                               RVALID_S0,
    output logic                        RREADY_S0,
    // S1
    output logic [`AXI_IDS_BITS-1:0]    ARID_S1,
    output logic [`AXI_ADDR_BITS-1:0]   ARADDR_S1,
    output logic [`AXI_LEN_BITS-1:0]    ARLEN_S1,
    output logic [`AXI_SIZE_BITS-1:0]   ARSIZE_S1,
    output logic [`AXI_BURST_BITS-1:0]  ARBURST_S1,
    output logic                        ARVALID_S1,
    input                               ARREADY_S1,
    input [`AXI_IDS_BITS-1:0]           RID_S1,
    input [`AXI_DATA_BITS-1:0]          RDATA_S1,
    input [`AXI_RESP_BITS-1:0]          RRESP_S1,
    input                               RLAST_S1,
    input                               RVALID_S1,
    output logic                        RREADY_S1,
    // S2
    output logic [`AXI_IDS_BITS-1:0]    ARID_S2,
    output logic [`AXI_ADDR_BITS-1:0]   ARADDR_S2,
    output logic [`AXI_LEN_BITS-1:0]    ARLEN_S2,
    output logic [`AXI_SIZE_BITS-1:0]   ARSIZE_S2,
    output logic [`AXI_BURST_BITS-1:0]  ARBURST_S2,
    output logic                        ARVALID_S2,
    input                               ARREADY_S2,
    input [`AXI_IDS_BITS-1:0]           RID_S2,
    input [`AXI_DATA_BITS-1:0]          RDATA_S2,
    input [`AXI_RESP_BITS-1:0]          RRESP_S2,
    input                               RLAST_S2,
    input                               RVALID_S2,
    output logic                        RREADY_S2,
    // S3   
    output logic [`AXI_IDS_BITS-1:0]    ARID_S3,
    output logic [`AXI_ADDR_BITS-1:0]   ARADDR_S3,
    output logic [`AXI_LEN_BITS-1:0]    ARLEN_S3,
    output logic [`AXI_SIZE_BITS-1:0]   ARSIZE_S3,
    output logic [`AXI_BURST_BITS-1:0]  ARBURST_S3,
    output logic                        ARVALID_S3,
    input                               ARREADY_S3,
    input [`AXI_IDS_BITS-1:0]           RID_S3,
    input [`AXI_DATA_BITS-1:0]          RDATA_S3,
    input [`AXI_RESP_BITS-1:0]          RRESP_S3,
    input                               RLAST_S3,
    input                               RVALID_S3,
    output logic                        RREADY_S3,
    // S4   
    output logic [`AXI_IDS_BITS-1:0]    ARID_S4,
    output logic [`AXI_ADDR_BITS-1:0]   ARADDR_S4,
    output logic [`AXI_LEN_BITS-1:0]    ARLEN_S4,
    output logic [`AXI_SIZE_BITS-1:0]   ARSIZE_S4,
    output logic [`AXI_BURST_BITS-1:0]  ARBURST_S4,
    output logic                        ARVALID_S4,
    input                               ARREADY_S4,
    input [`AXI_IDS_BITS-1:0]           RID_S4,
    input [`AXI_DATA_BITS-1:0]          RDATA_S4,
    input [`AXI_RESP_BITS-1:0]          RRESP_S4,
    input                               RLAST_S4,
    input                               RVALID_S4,
    output logic                        RREADY_S4,
    // S5   
    output logic [`AXI_IDS_BITS-1:0]    ARID_S5,
    output logic [`AXI_ADDR_BITS-1:0]   ARADDR_S5,
    output logic [`AXI_LEN_BITS-1:0]    ARLEN_S5,
    output logic [`AXI_SIZE_BITS-1:0]   ARSIZE_S5,
    output logic [`AXI_BURST_BITS-1:0]  ARBURST_S5,
    output logic                        ARVALID_S5,
    input                               ARREADY_S5,
    input [`AXI_IDS_BITS-1:0]           RID_S5,
    input [`AXI_DATA_BITS-1:0]          RDATA_S5,
    input [`AXI_RESP_BITS-1:0]          RRESP_S5,
    input                               RLAST_S5,
    input                               RVALID_S5,
    output logic                        RREADY_S5,
    // S6   
    output logic [`AXI_IDS_BITS-1:0]    ARID_S6,
    output logic [`AXI_ADDR_BITS-1:0]   ARADDR_S6,
    output logic [`AXI_LEN_BITS-1:0]    ARLEN_S6,
    output logic [`AXI_SIZE_BITS-1:0]   ARSIZE_S6,
    output logic [`AXI_BURST_BITS-1:0]  ARBURST_S6,
    output logic                        ARVALID_S6,
    input                               ARREADY_S6,
    input [`AXI_IDS_BITS-1:0]           RID_S6,
    input [`AXI_DATA_BITS-1:0]          RDATA_S6,
    input [`AXI_RESP_BITS-1:0]          RRESP_S6,
    input                               RLAST_S6,
    input                               RVALID_S6,
    output logic                        RREADY_S6,
    // S7   
    output logic [`AXI_IDS_BITS-1:0]    ARID_S7,
    output logic [`AXI_ADDR_BITS-1:0]   ARADDR_S7,
    output logic [`AXI_LEN_BITS-1:0]    ARLEN_S7,
    output logic [`AXI_SIZE_BITS-1:0]   ARSIZE_S7,
    output logic [`AXI_BURST_BITS-1:0]  ARBURST_S7,
    output logic                        ARVALID_S7,
    input                               ARREADY_S7,
    input [`AXI_IDS_BITS-1:0]           RID_S7,
    input [`AXI_DATA_BITS-1:0]          RDATA_S7,
    input [`AXI_RESP_BITS-1:0]          RRESP_S7,
    input                               RLAST_S7,
    input                               RVALID_S7,
    output logic                        RREADY_S7
);

localparam      IDLE    = 1'b0;
localparam      READ    = 1'b1;

localparam      M0_ID   = 4'h0;
localparam      M1_ID   = 4'h1;
localparam      M2_ID   = 4'h2;

typedef enum logic[3:0] {
    NO_S,
    S0,
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
    M0,
    M1,
    M2
} AXI_MasterSel;

logic           new_ar_ok;
logic           ar_handshake;
logic           r_handshake;
logic           arready_ok;
logic           keep_ar;
logic           r_state;

AXI_MasterSel   r_master;
AXI_SlaveSel    r_slave;
AXI_MasterSel   ar_master, ar_master_reg;
AXI_SlaveSel    ar_slave, ar_slave_reg;

AXI_SlaveSel    ar_M0_slave,
                ar_M1_slave,
                ar_M2_slave;

logic                       r_burst;
logic                       r_cnt_last; 
logic [`AXI_LEN_BITS-1:0] r_cnt;

logic [`AXI_IDS_BITS-1:0]   arid;
logic [`AXI_ADDR_BITS-1:0]  araddr;
logic [`AXI_LEN_BITS-1:0]   arlen;
logic [`AXI_SIZE_BITS-1:0]  arsize;
logic [`AXI_BURST_BITS-1:0] arburst;
logic                       arvalid;
logic                       arready;
logic [`AXI_IDS_BITS-1:0]   rid;
logic [`AXI_DATA_BITS-1:0]  rdata;
logic [`AXI_RESP_BITS-1:0]  rresp;
logic                       rlast;
logic                       rvalid;
logic                       rready;

logic                       default_arready;
logic [`AXI_IDS_BITS-1:0]   default_rid;
logic [`AXI_DATA_BITS-1:0]  default_rdata;
logic [`AXI_RESP_BITS-1:0]  default_rresp;
logic                       default_rlast;
logic                       default_rvalid;

logic [`AXI_IDS_BITS-1:0]   rid_reg;

assign ar_handshake = arready & arvalid;
assign r_handshake = rready & rvalid;
assign r_burst = (arlen != 4'b0);

// read FSM
// ar_handshake, r_handshake, r_burst influence how it changes state
always_ff @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) begin
        r_state <= IDLE;
    end 
    else begin
        unique case (r_state)
        IDLE: 
            if(ar_handshake) begin// accept new ar request
                r_state <= READ;
            end
            else begin  // no new ar request
                r_state <= IDLE;
            end
        READ:
            if(rlast && r_handshake) begin
                r_state <= IDLE;
            end
        endcase
    end
end

// decide which master can send read request
// M1 has higher priority
// Later M0
// Last M2
always_comb begin
    if(r_state == IDLE) begin // can accept new request
        priority if(keep_ar) begin
            ar_master = ar_master_reg;
            ar_slave = ar_slave_reg;
        end
        else if (ARVALID_M1) begin
            ar_master = M1;
            ar_slave = ar_M1_slave;
        end
        else if (ARVALID_M0) begin
            ar_master = M0;
            ar_slave = ar_M0_slave;
        end
        else if (ARVALID_M2) begin
            ar_master = M2;
            ar_slave = ar_M2_slave;
        end
        else begin // no new request
            ar_master = NO_M; 
            ar_slave = NO_S; 
        end
    end
    else begin// not yet finish current read trans, cannot accept new request
        ar_master = NO_M; 
        ar_slave = NO_S; 
    end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) begin
        keep_ar <= 1'b0;
        ar_master_reg <= NO_M;
        ar_slave_reg <= NO_S;
    end 
    else if (arvalid & ~arready) begin
        keep_ar <= 1'b1;
        ar_master_reg <= ar_master;
        ar_slave_reg <= ar_slave;
    end
    else begin
        keep_ar <= 1'b0;
        ar_master_reg <= NO_M;
        ar_slave_reg <= NO_S;
    end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) begin
        r_master <= NO_M;
        r_slave <= NO_S;
    end
    else begin
        unique case (r_state)
        IDLE: begin
            if(ar_handshake) begin // accept new ar request
                r_master <= ar_master;
                r_slave <= ar_slave;
            end
        end
        READ: begin // R_LAST
            if(r_handshake && rlast) begin
                r_master <= NO_M;
                r_slave <= NO_S;
            end
        end
        endcase
    end
end

// decode araddr, decide which slave
assign ar_M0_slave = AXI_SlaveSel'(getSlave(ARADDR_M0));
assign ar_M1_slave = AXI_SlaveSel'(getSlave(ARADDR_M1));
assign ar_M2_slave = AXI_SlaveSel'(getSlave(ARADDR_M2));

function logic[3:0] getSlave; //AXI_SlaveSel
    input [31:0] addr;
    begin
        unique if(~|addr[31:14]) begin// ROM   0x0000_0000 ~ 0x0000_3FFF
            getSlave = S0;
        end
        else if(~|addr[31:17] && addr[16]) begin// IM 0x0001_0000 ~ 0x0001_FFFF
            getSlave = S1;
        end
        else if(~|{addr[31:18], addr[16]} && addr[17]) begin// DM 0x0002_0000 ~ 0x0002_FFFF
            getSlave = S2;
        end
        else if(~|{addr[31:29], addr[27:10]} && addr[28]) begin// Sctrl 0x1000_0000 ~ 0x1000_03FF
            getSlave = S3;
        end
        else if(~|{addr[31:30],addr[28:25]} && addr[29]) begin // DRAM 0x2000_0000 ~ 0x21FF_FFFF
            getSlave = S4;
        end
        else if(~|{addr[31:30], addr[27:12]} && &addr[29:28]) begin// DMA 0x3000_0000 ~ 0x3000_0FFF
            getSlave = S5;
        end
        else if(~|{addr[31:30], addr[27:13], addr[11:4]} && &addr[29:28] && addr[12]) begin// TPU 0x3000_1000 ~ 0x3000_100F
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

// select ar input
always_comb begin
    unique case (ar_master)
    M0: begin
        arid     = {ARID_M0, M0_ID};
        araddr   = ARADDR_M0;
        arlen    = ARLEN_M0;
        arsize   = ARSIZE_M0;
        arburst  = ARBURST_M0;
        arvalid  = ARVALID_M0;
    end
    M1: begin
        arid     = {ARID_M1, M1_ID};
        araddr   = ARADDR_M1;
        arlen    = ARLEN_M1;
        arsize   = ARSIZE_M1;
        arburst  = ARBURST_M1;
        arvalid  = ARVALID_M1;
    end
    M2: begin
        arid     = {ARID_M2, M2_ID};
        araddr   = ARADDR_M2;
        arlen    = ARLEN_M2;
        arsize   = ARSIZE_M2;
        arburst  = ARBURST_M2;
        arvalid  = ARVALID_M2;
    end
    default: begin // NO_M
        arid     = `AXI_IDS_BITS'd0;
        araddr   = `AXI_ADDR_BITS'd0;
        arlen    = `AXI_LEN_BITS'd0;
        arsize   = `AXI_SIZE_BITS'd0;
        arburst  = `AXI_BURST_BITS'd0;
        arvalid  = 1'b0;
    end
    endcase
end 

always_comb begin
    unique case (ar_slave)
    S0: begin
        arready = ARREADY_S0;
    end
    S1: begin
        arready = ARREADY_S1;
    end
    S2: begin
        arready = ARREADY_S2;
    end
    S3: begin
        arready = ARREADY_S3;
    end
    S4: begin
        arready = ARREADY_S4;
    end
    S5: begin
        arready = ARREADY_S5;
    end
    S6: begin
        arready = ARREADY_S6;
    end
    S7: begin
        arready = ARREADY_S7;
    end
    DEF_S: begin
        arready = default_arready;
    end
    default: begin // NO_S
        arready = 1'b0;
    end
    endcase
end

// select r input
always_comb begin
    unique case (r_master)
    M0: begin
        rready = RREADY_M0;
    end
    M1: begin
        rready = RREADY_M1;
    end
    M2: begin
        rready = RREADY_M2;
    end
    default: begin // NO_M
        rready = 1'b0;
    end
    endcase
end

always_comb begin
    unique case (r_slave)
    S0: begin
        rid     = RID_S0;
        rdata   = RDATA_S0;
        rresp   = RRESP_S0;
        rlast   = RLAST_S0;
        rvalid  = RVALID_S0;
    end
    S1: begin
        rid     = RID_S1;
        rdata   = RDATA_S1;
        rresp   = RRESP_S1;
        rlast   = RLAST_S1;
        rvalid  = RVALID_S1;
    end
    S2: begin
        rid     = RID_S2;
        rdata   = RDATA_S2;
        rresp   = RRESP_S2;
        rlast   = RLAST_S2;
        rvalid  = RVALID_S2;
    end
    S3: begin
        rid     = RID_S3;
        rdata   = RDATA_S3;
        rresp   = RRESP_S3;
        rlast   = RLAST_S3;
        rvalid  = RVALID_S3;
    end
    S4: begin
        rid     = RID_S4;
        rdata   = RDATA_S4;
        rresp   = RRESP_S4;
        rlast   = RLAST_S4;
        rvalid  = RVALID_S4;
    end
    S5: begin
        rid     = RID_S5;
        rdata   = RDATA_S5;
        rresp   = RRESP_S5;
        rlast   = RLAST_S5;
        rvalid  = RVALID_S5;
    end
    S6: begin
        rid     = RID_S6;
        rdata   = RDATA_S6;
        rresp   = RRESP_S6;
        rlast   = RLAST_S6;
        rvalid  = RVALID_S6;
    end
    S7: begin
        rid     = RID_S7;
        rdata   = RDATA_S7;
        rresp   = RRESP_S7;
        rlast   = RLAST_S7;
        rvalid  = RVALID_S7;
    end
    DEF_S: begin
        rid     = default_rid;
        rdata   = default_rdata;
        rresp   = default_rresp;
        rlast   = default_rlast;
        rvalid  = default_rvalid;
    end
    default: begin // NO_S
        rid     = `AXI_IDS_BITS'd0;
        rdata   = `AXI_DATA_BITS'd0;
        rresp   = `AXI_RESP_BITS'd0;
        rlast   = 1'b0;
        rvalid  = 1'b0;
    end
    endcase
end

// output

// ar channel
// S0
always_comb begin
    if (ar_slave == S0) begin
        ARID_S0    = arid;
        ARADDR_S0  = {16'd0, araddr[15:0]};
        ARLEN_S0   = arlen;
        ARSIZE_S0  = arsize;
        ARBURST_S0 = arburst;
        ARVALID_S0 = arvalid;
    end 
    else begin
        ARID_S0    = `AXI_IDS_BITS'd0;
        ARADDR_S0  = `AXI_ADDR_BITS'd0;
        ARLEN_S0   = `AXI_LEN_BITS'd0;
        ARSIZE_S0  = `AXI_SIZE_BITS'd0;
        ARBURST_S0 = `AXI_BURST_BITS'd0;
        ARVALID_S0 = 1'b0;
    end
end

always_comb begin
    if(r_slave == S0) begin
        RREADY_S0 = rready;
    end
    else begin
        RREADY_S0 = 1'b0;
    end
end

//S1
always_comb begin
    if (ar_slave == S1) begin
        ARID_S1    = arid;
        ARADDR_S1  = {16'd0, araddr[15:0]};
        ARLEN_S1   = arlen;
        ARSIZE_S1  = arsize;
        ARBURST_S1 = arburst;
        ARVALID_S1 = arvalid;
    end 
    else begin
        ARID_S1    = `AXI_IDS_BITS'd0;
        ARADDR_S1  = `AXI_ADDR_BITS'd0;
        ARLEN_S1   = `AXI_LEN_BITS'd0;
        ARSIZE_S1  = `AXI_SIZE_BITS'd0;
        ARBURST_S1 = `AXI_BURST_BITS'd0;
        ARVALID_S1 = 1'b0;
    end
end

always_comb begin
    if(r_slave == S1) begin
        RREADY_S1 = rready;
    end
    else begin
        RREADY_S1 = 1'b0;
    end
end

//S2
always_comb begin
    if (ar_slave == S2) begin
        ARID_S2    = arid;
        ARADDR_S2  = {16'd0, araddr[15:0]};
        ARLEN_S2   = arlen;
        ARSIZE_S2  = arsize;
        ARBURST_S2 = arburst;
        ARVALID_S2 = arvalid;
    end 
    else begin
        ARID_S2    = `AXI_IDS_BITS'd0;
        ARADDR_S2  = `AXI_ADDR_BITS'd0;
        ARLEN_S2   = `AXI_LEN_BITS'd0;
        ARSIZE_S2  = `AXI_SIZE_BITS'd0;
        ARBURST_S2 = `AXI_BURST_BITS'd0;
        ARVALID_S2 = 1'b0;
    end
end

always_comb begin
    if(r_slave == S2) begin
        RREADY_S2 = rready;
    end
    else begin
        RREADY_S2 = 1'b0;
    end
end

//S3
always_comb begin
    if (ar_slave == S3) begin
        ARID_S3    = arid;
        ARADDR_S3  = {22'd0, araddr[9:0]};
        ARLEN_S3   = arlen;
        ARSIZE_S3  = arsize;
        ARBURST_S3 = arburst;
        ARVALID_S3 = arvalid;
    end 
    else begin
        ARID_S3    = `AXI_IDS_BITS'd0;
        ARADDR_S3  = `AXI_ADDR_BITS'd0;
        ARLEN_S3   = `AXI_LEN_BITS'd0;
        ARSIZE_S3  = `AXI_SIZE_BITS'd0;
        ARBURST_S3 = `AXI_BURST_BITS'd0;
        ARVALID_S3 = 1'b0;
    end
end

always_comb begin
    if(r_slave == S3) begin
        RREADY_S3 = rready;
    end
    else begin
        RREADY_S3 = 1'b0;
    end
end

//S4
always_comb begin
    if (ar_slave == S4) begin
        ARID_S4    = arid;
        ARADDR_S4  = {7'd0, araddr[24:0]};
        ARLEN_S4   = arlen;
        ARSIZE_S4  = arsize;
        ARBURST_S4 = arburst;
        ARVALID_S4 = arvalid;
    end 
    else begin
        ARID_S4    = `AXI_IDS_BITS'd0;
        ARADDR_S4  = `AXI_ADDR_BITS'd0;
        ARLEN_S4   = `AXI_LEN_BITS'd0;
        ARSIZE_S4  = `AXI_SIZE_BITS'd0;
        ARBURST_S4 = `AXI_BURST_BITS'd0;
        ARVALID_S4 = 1'b0;
    end
end

always_comb begin
    if(r_slave == S4) begin
        RREADY_S4 = rready;
    end
    else begin
        RREADY_S4 = 1'b0;
    end
end

//S5
always_comb begin
    if (ar_slave == S5) begin
        ARID_S5    = arid;
        ARADDR_S5  = {20'd0, araddr[11:0]};
        ARLEN_S5   = arlen;
        ARSIZE_S5  = arsize;
        ARBURST_S5 = arburst;
        ARVALID_S5 = arvalid;
    end 
    else begin
        ARID_S5    = `AXI_IDS_BITS'd0;
        ARADDR_S5  = `AXI_ADDR_BITS'd0;
        ARLEN_S5   = `AXI_LEN_BITS'd0;
        ARSIZE_S5  = `AXI_SIZE_BITS'd0;
        ARBURST_S5 = `AXI_BURST_BITS'd0;
        ARVALID_S5 = 1'b0;
    end
end

always_comb begin
    if(r_slave == S5) begin
        RREADY_S5 = rready;
    end
    else begin
        RREADY_S5 = 1'b0;
    end
end

//S6
always_comb begin
    if (ar_slave == S6) begin
        ARID_S6    = arid;
        ARADDR_S6  = {28'd0, araddr[3:0]};
        ARLEN_S6   = arlen;
        ARSIZE_S6  = arsize;
        ARBURST_S6 = arburst;
        ARVALID_S6 = arvalid;
    end 
    else begin
        ARID_S6    = `AXI_IDS_BITS'd0;
        ARADDR_S6  = `AXI_ADDR_BITS'd0;
        ARLEN_S6   = `AXI_LEN_BITS'd0;
        ARSIZE_S6  = `AXI_SIZE_BITS'd0;
        ARBURST_S6 = `AXI_BURST_BITS'd0;
        ARVALID_S6 = 1'b0;
    end
end

always_comb begin
    if(r_slave == S6) begin
        RREADY_S6 = rready;
    end
    else begin
        RREADY_S6 = 1'b0;
    end
end

//S7
always_comb begin
    if (ar_slave == S7) begin
        ARID_S7    = arid;
        ARADDR_S7  = {18'd0, araddr[13:0]};
        ARLEN_S7   = arlen;
        ARSIZE_S7  = arsize;
        ARBURST_S7 = arburst;
        ARVALID_S7 = arvalid;
    end 
    else begin
        ARID_S7    = `AXI_IDS_BITS'd0;
        ARADDR_S7  = `AXI_ADDR_BITS'd0;
        ARLEN_S7   = `AXI_LEN_BITS'd0;
        ARSIZE_S7  = `AXI_SIZE_BITS'd0;
        ARBURST_S7 = `AXI_BURST_BITS'd0;
        ARVALID_S7 = 1'b0;
    end
end

always_comb begin
    if(r_slave == S7) begin
        RREADY_S7 = rready;
    end
    else begin
        RREADY_S7 = 1'b0;
    end
end

// M0
always_comb begin
    if(ar_master == M0) begin
        ARREADY_M0 = arready;
    end
    else begin
        ARREADY_M0 = 1'b0;
    end
end

always_comb begin
    if (r_master == M0) begin
        RID_M0     = rid[7:4];
        RDATA_M0   = rdata;
        RRESP_M0   = rresp;
        RVALID_M0  = rvalid;
        RLAST_M0   = rlast;
    end else begin
        RID_M0     = `AXI_ID_BITS'd0;
        RDATA_M0   = `AXI_DATA_BITS'd0;
        RRESP_M0   = `AXI_RESP_OKAY;
        RVALID_M0  = 1'b0;
        RLAST_M0   = 1'b0;
    end
end

//M1
always_comb begin
    if(ar_master == M1) begin
        ARREADY_M1 = arready;
    end
    else begin
        ARREADY_M1 = 1'b0;
    end
end

always_comb begin
    if (r_master == M1) begin
        RID_M1     = rid[7:4];
        RDATA_M1   = rdata;
        RRESP_M1   = rresp;
        RVALID_M1  = rvalid;
        RLAST_M1   = rlast;
    end 
    else begin
        RID_M1     = `AXI_ID_BITS'd0;
        RDATA_M1   = `AXI_DATA_BITS'd0;
        RRESP_M1   = `AXI_RESP_OKAY;
        RVALID_M1  = 1'b0;
        RLAST_M1   = 1'b0;
    end
end

//M2
always_comb begin
    if(ar_master == M2) begin
        ARREADY_M2 = arready;
    end
    else begin
        ARREADY_M2 = 1'b0;
    end
end

always_comb begin
    if (r_master == M2) begin
        RID_M2     = rid[7:4];
        RDATA_M2   = rdata;
        RRESP_M2   = rresp;
        RVALID_M2  = rvalid;
        RLAST_M2   = rlast;
    end 
    else begin
        RID_M2     = `AXI_ID_BITS'd0;
        RDATA_M2   = `AXI_DATA_BITS'd0;
        RRESP_M2   = `AXI_RESP_OKAY;
        RVALID_M2  = 1'b0;
        RLAST_M2   = 1'b0;
    end
end

// default slave
assign default_rdata = `AXI_DATA_BITS'd0;
assign default_rresp = `AXI_RESP_DECERR;

always_comb begin
    if(r_state == IDLE) begin
        default_arready = 1'b1;
        default_rvalid  = 1'b0;
        default_rid     = `AXI_IDS_BITS'd0;
    end
    else begin
        default_arready = 1'b0;
        default_rvalid  = 1'b1;
        default_rid     = rid_reg;
    end
end

always_ff @( posedge ACLK or negedge ARESETn ) begin
    if(~ARESETn) begin
        r_cnt <= `AXI_LEN_BITS'd0;
    end
    else if(ar_handshake) begin
        r_cnt <= arlen;
    end
    else if(r_handshake) begin
        r_cnt <= r_cnt - `AXI_LEN_BITS'd1;
    end
end

assign r_cnt_last = (r_cnt == `AXI_LEN_BITS'd0);

always_comb begin
    if(r_state == READ && r_cnt_last) begin
        default_rlast = 1'b1;
    end
    else begin
        default_rlast = 1'b0;
    end
end

always_ff @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) begin
        rid_reg <= `AXI_IDS_BITS'd0;
    end
    else if(ar_handshake) begin
        rid_reg <= arid;
    end
end

endmodule
