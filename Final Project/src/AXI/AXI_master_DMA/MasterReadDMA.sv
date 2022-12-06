`include "AXI_def.svh"

module MasterReadDMA (
    input clock,
	input reset,
    // READ ADDRESS
    output logic [`AXI_ID_BITS-1:0]     ARID,
    output logic [`AXI_ADDR_BITS-1:0]   ARADDR,
    output logic [`AXI_LEN_BITS-1:0]    ARLEN,
    output logic [`AXI_SIZE_BITS-1:0]   ARSIZE,
    output logic [1:0]                  ARBURST, //only INCR type
    output logic                        ARVALID,
    input                               ARREADY,
    // READ DATA
    input [`AXI_ID_BITS-1:0]    RID,
    input [`AXI_DATA_BITS-1:0]  RDATA,
    input [1:0]                 RRESP,
    input                       RLAST,
    input                       RVALID,
    output logic                RREADY,
    // DMA
    input                      addressReady,
    input [`AXI_ADDR_BITS-1:0] address,
    input [`AXI_LEN_BITS-1:0]  length,
    output logic ARFinish,
    input                      next,
    output logic                      last,
    output logic                      RFinish,
    output logic [`AXI_DATA_BITS-1:0] DataRead     
);

    // Register
    logic [1:0] state;
    logic [1:0] nstate;
    logic [`AXI_ID_BITS-1:0]   ARID_reg;
    logic [`AXI_ADDR_BITS-1:0] ARADDR_reg;
    logic [`AXI_LEN_BITS-1:0]  ARLEN_reg;
    logic [`AXI_SIZE_BITS-1:0] ARSIZE_reg;
    logic [1:0]                ARBURST_reg; //only INCR type

    // parameter master_read = 0;

    // State Register
    always_ff @(posedge clock or negedge reset) 
    begin
        if (!reset) 
        begin
            state <= `READ_IDLE;
            ARID_reg    <= 4'd0;
            ARADDR_reg  <= 32'd0;
            ARLEN_reg   <= 4'd0;
            ARSIZE_reg  <= 3'd0;
            ARBURST_reg <= 2'd0;
        end
        else 
        begin
            state <= nstate;
            if (state == `READ_IDLE && addressReady) 
            begin
                ARID_reg    <= 4'b0;
                ARADDR_reg  <= address;
                ARLEN_reg   <= length; // length + 1
                ARSIZE_reg  <= `AXI_SIZE_DWORD;
                ARBURST_reg <= `AXI_BURST_INCR;
            end
            else if (state == `READ_WAIT_RVALID && nstate == `READ_IDLE) 
            begin
                ARID_reg    <= 4'd0;
                ARADDR_reg  <= 32'd0;
                ARLEN_reg   <= 4'd0;
                ARSIZE_reg  <= 3'd0;
                ARBURST_reg <= 2'd0;
            end
            else 
            begin
                ARID_reg    <= ARID_reg;
                ARADDR_reg  <= ARADDR_reg;
                ARLEN_reg   <= ARLEN_reg;
                ARSIZE_reg  <= ARSIZE_reg;
                ARBURST_reg <= ARBURST_reg;
            end
        end
    end

    // Next State Logic & Combination Output Logic
    always_comb 
    begin
        case (state)
            `READ_IDLE: 
            begin
                if (addressReady) 
                begin
                    nstate = `READ_WAIT_ARREADY;
                end
                else 
                begin
                    nstate = `READ_IDLE;
                end
                // AR Channel
                ARID = 4'd0;
                ARADDR = 32'd0;
                ARLEN = 4'd0;
                ARSIZE = 3'd0;
                ARBURST = 2'd0; //only INCR type
                ARVALID = `FALSE;
                // R Channel
                RREADY = `FALSE;
                // DMA
                ARFinish = `FALSE;
                last = `FALSE;
                RFinish = `FALSE;
                DataRead = `AXI_DATA_BITS'd0;
            end
            `READ_WAIT_ARREADY: 
            begin
                if(ARREADY) 
                begin
                    nstate = `READ_WAIT_RVALID;
                    ARFinish = `TRUE;
                end    
                else
                begin
                    nstate = `READ_WAIT_ARREADY;
                    ARFinish = `FALSE;
                end
                // AR Channel
                ARID = ARID_reg;       
                ARADDR = ARADDR_reg;
                ARLEN = ARLEN_reg;
                ARSIZE = ARSIZE_reg;
                ARBURST = ARBURST_reg; //only INCR type
                ARVALID = `TRUE;
                // R Channel
                RREADY = `FALSE;
                // DMA
                last = `FALSE;
                RFinish = `FALSE;
                DataRead = `AXI_DATA_BITS'd0;
            end
            `READ_WAIT_RVALID: 
            begin
                if(RLAST && RVALID && next)
                begin
                    nstate = `READ_IDLE;
                end
                else
                begin
                    nstate = `READ_WAIT_RVALID;
                end
                // AR Channel
                ARID = 4'd0;       
                ARADDR = 32'd0;
                ARLEN = 4'd0;
                ARSIZE = 3'd0;
                ARBURST = 2'd0;
                ARVALID = `FALSE;
                // R Channel
                if (next)
                begin
                    RREADY = `TRUE;
                end 
                else
                begin
                    RREADY = `FALSE;
                end
                // DMA
                ARFinish = `FALSE;
                if (RVALID && RRESP == `AXI_RESP_OKAY) 
                begin
                    RFinish = `TRUE;
                    DataRead = RDATA;
                    if (RLAST) 
                    begin
                        last = `TRUE;
                    end
                    else 
                    begin
                        last = `FALSE; 
                    end
                end
                else 
                begin
                    last = `FALSE;
                    RFinish = `FALSE;
                    DataRead = `AXI_DATA_BITS'd0;
                end
            end
            default:
            begin
                nstate = `READ_IDLE;
                // AR Channel
                ARID = 4'd0;       
                ARADDR = 32'd0;
                ARLEN = 4'd0;
                ARSIZE = 3'd0;
                ARBURST = 2'd0; //only INCR type
                ARVALID = `FALSE;
                // R Channel
                RREADY = `FALSE;
                // DMA
                ARFinish = `FALSE;
                last = `FALSE;
                RFinish = `FALSE;
                DataRead = `AXI_DATA_BITS'd0;
            end
        endcase
    end
endmodule
