`include "AXI_def.svh"

module MasterWriteDMA (
    input clock,
	input reset,
    // WRITE ADDRESS
    output logic [`AXI_ID_BITS-1:0]     AWID,
    output logic [`AXI_ADDR_BITS-1:0]   AWADDR,
    output logic [`AXI_LEN_BITS-1:0]    AWLEN,
    output logic [`AXI_SIZE_BITS-1:0]   AWSIZE,
    output logic [1:0]                  AWBURST, //only INCR type
    output logic                        AWVALID,
    input                               AWREADY,
    // WRITE DATA
    output logic [`AXI_DATA_BITS-1:0]   WDATA,
    output logic [`AXI_STRB_BITS-1:0]   WSTRB,
    output logic                        WLAST,
    output logic                        WVALID,
    input                               WREADY, 
    // WRITE RESPONSE
    input [`AXI_ID_BITS-1:0]            BID,
    input [1:0]                         BRESP,
    input                               BVALID,
    output logic                        BREADY, 
    // DMA
    input                       addressReady,
    input [`AXI_ADDR_BITS-1:0]  address, 
    input [`AXI_LEN_BITS-1:0]   length,
    output logic AWFinish,
    input                       next,
    input                       last,
    input [`AXI_STRB_BITS-1:0]  writeEnable,
    input [`AXI_DATA_BITS-1:0]  dataWrite,
    output logic WFinish
);

    // Register
    logic [1:0] state;
    logic [1:0] nstate;
    logic [`AXI_ID_BITS-1:0]    AWID_reg;
    logic [`AXI_ADDR_BITS-1:0]  AWADDR_reg;
    logic [`AXI_LEN_BITS-1:0]   AWLEN_reg;
    logic [`AXI_SIZE_BITS-1:0]  AWSIZE_reg;
    logic [1:0]                 AWBURST_reg; //only INCR type
    logic [`AXI_DATA_BITS-1:0]  WDATA_reg;
    logic [`AXI_STRB_BITS-1:0]  WSTRB_reg;
    logic                       WLAST_reg;
    logic                       next_reg;

    // parameter master_write = 0;

    // State Register
    always_ff @(posedge clock or negedge reset) 
    begin
        if(!reset) 
        begin
            state <= `WRITE_IDLE;

            AWID_reg    <= 4'd0;
            AWADDR_reg  <= 32'd0;
            AWLEN_reg   <= 4'd0;
            AWSIZE_reg  <= 3'd0;
            AWBURST_reg <= 2'd0;

            WDATA_reg <= 64'd0;
            WSTRB_reg <= 8'b00000000; // In AXI spec, WSTRB is active high
            WLAST_reg <= `FALSE;

            next_reg <= `FALSE;
        end
        else
        begin
            state <= nstate;

            if (state == `WRITE_IDLE && addressReady) 
            begin
                AWID_reg    <= 4'd0;
                AWADDR_reg  <= address;
                AWLEN_reg   <= length;
                AWSIZE_reg  <= `AXI_SIZE_DWORD;
                AWBURST_reg <= `AXI_BURST_INCR;
            end
            else if (state == `WRITE_WAIT_BVALID && nstate == `WRITE_IDLE) 
            begin
                AWID_reg    <= 4'd0;
                AWADDR_reg  <= 32'd0;
                AWLEN_reg   <= 4'd0;
                AWSIZE_reg  <= 3'd0;
                AWBURST_reg <= 2'd0;
            end
            else 
            begin
                AWID_reg <= AWID_reg;
                AWADDR_reg <= AWADDR_reg;
                AWLEN_reg <= AWLEN_reg;
                AWSIZE_reg <= AWSIZE_reg;
                AWBURST_reg <= AWBURST_reg;
            end

            if (state == `WRITE_WAIT_WREADY && !WFinish && next) 
            begin
                WDATA_reg <= dataWrite;
                WSTRB_reg <= writeEnable;
                WLAST_reg <= last;

                next_reg <= `TRUE;
            end
            else if (state == `WRITE_WAIT_WREADY && WFinish) 
            begin
                WDATA_reg <= 64'd0;
                WSTRB_reg <= 8'b00000000; 
                WLAST_reg <= `FALSE;

                next_reg <= `FALSE;
            end
            else 
            begin
                WDATA_reg <= WDATA_reg;
                WSTRB_reg <= WSTRB_reg;
                WLAST_reg <= WLAST_reg;

                next_reg <= next_reg;
            end
        end
    end

    // Next State Logic & Combination Output Logic
    always_comb 
    begin
        case(state)
            `WRITE_IDLE: 
            begin
                if (addressReady) 
                begin
                    nstate = `WRITE_WAIT_AWREADY;
                end
                else 
                begin
                    nstate = `WRITE_IDLE;
                end
                // AW Channel
                AWID = 4'd0;
                AWADDR = 32'd0;
                AWLEN = 4'd0;
                AWSIZE = 3'd0;
                AWBURST = 2'd0;
                AWVALID = `FALSE;
                // W Channel
                WDATA = 64'd0;
                WSTRB = 8'b00000000;
                WLAST = `FALSE;
                WVALID = `FALSE;
                // B Channel
                BREADY = `FALSE;
                // DMA
                AWFinish = `FALSE;
                WFinish = `FALSE;
            end
            `WRITE_WAIT_AWREADY: 
            begin
                if (AWREADY) 
                begin
                    nstate = `WRITE_WAIT_WREADY;
                    AWFinish = `TRUE;
                end
                else 
                begin
                    nstate = `WRITE_WAIT_AWREADY;
                    AWFinish = `FALSE;
                end
                // AW Channel
                AWID = AWID_reg;
                AWADDR = AWADDR_reg;
                AWLEN = AWLEN_reg;
                AWSIZE = AWSIZE_reg;
                AWBURST = AWBURST_reg;
                AWVALID = `TRUE;
                // W Channel
                WDATA = 64'd0;
                WSTRB = 8'b00000000;
                WLAST = `FALSE;
                WVALID = `FALSE;
                // B Channel
                BREADY = `FALSE;
                // DMA
                WFinish = `FALSE;
            end
            `WRITE_WAIT_WREADY: 
            begin
                if (WREADY && (next || next_reg) && (last || WLAST_reg)) 
                begin
                    nstate = `WRITE_WAIT_BVALID;
                end
                else 
                begin
                    nstate = `WRITE_WAIT_WREADY;
                end
                // AW Channel
                AWID = 4'd0;
                AWADDR = 32'd0;
                AWLEN = 4'd0;
                AWSIZE = 3'd0;
                AWBURST = 2'd0;
                AWVALID = `FALSE;
                // W Channel
                if (next) 
                begin
                    WDATA = dataWrite;
                    WSTRB = writeEnable;
                    WLAST = last;
                    WVALID = `TRUE;
                end
                else if (next_reg) 
                begin
                    WDATA = WDATA_reg;
                    WSTRB = WSTRB_reg;
                    WLAST = WLAST_reg;
                    WVALID = `TRUE;
                end
                else 
                begin
                    WDATA = 64'd0;
                    WSTRB = 8'b00000000;
                    WLAST = `FALSE;
                    WVALID = `FALSE;
                end
                // B Channel
                BREADY = `FALSE;
                // DMA
                AWFinish = `FALSE;
                if (WREADY) 
                begin
                    WFinish = `TRUE;
                end
                else
                begin
                    WFinish = `FALSE;
                end
            end
            `WRITE_WAIT_BVALID :
            begin
                if(BVALID && BRESP == `AXI_RESP_OKAY)
                begin
                    nstate = `WRITE_IDLE;
                end
                else
                begin
                    nstate = `WRITE_WAIT_BVALID;
                end
                // AW Channel
                AWID = 4'd0;
                AWADDR = 32'd0;
                AWLEN = 4'd0;
                AWSIZE = 3'd0;
                AWBURST = 2'd0;
                AWVALID = `FALSE;
                // W Channel
                WDATA = 64'd0;
                WSTRB = 8'b00000000;
                WLAST = `FALSE;
                WVALID = `FALSE;
                // B Channel
                BREADY = `TRUE;
                // DMA
                AWFinish = `FALSE;
                WFinish = `FALSE;
            end
            // default:
            // begin
            //     nstate = `WRITE_IDLE;
            //     // AW Channel
            //     AWID = 4'd0;
            //     AWADDR = 32'd0;
            //     AWLEN = 4'd0;
            //     AWSIZE = 3'd0;
            //     AWBURST = 2'd0;
            //     AWVALID = `FALSE;
            //     // W Channel
            //     WDATA = 64'd0;
            //     WSTRB = 8'b00000000;
            //     WLAST = `FALSE;
            //     WVALID = `FALSE;
            //     // B Channel
            //     BREADY = `FALSE;
            //     // DMA
            //     AWFinish = `FALSE;
            //     WFinish = `FALSE;
            // end 
        endcase
    end
endmodule