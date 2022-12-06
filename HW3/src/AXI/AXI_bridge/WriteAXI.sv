// `include "WriteArbiter.sv"
// `include "WriteDecoder.sv"
`include "AXI/AXI_bridge/WriteArbiter.sv"
`include "AXI/AXI_bridge/WriteDecoder.sv"

module WriteAXI(
    input clock,
	input reset,
    
    // ======= Master =======

    // WRITE ADDRESS M1 (Data)
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output logic AWREADY_M1,
	// WRITE DATA M1 (Data)
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,
	// WRITE RESPONSE M1 (Data)
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,

    // ======= Slave =======

    // WRITE ADDRESS S0 (ROM)
	// output logic [`AXI_IDS_BITS-1:0] AWID_S0,
	// output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	// output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
	// output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	// output logic [1:0] AWBURST_S0,
	// output logic AWVALID_S0,
	// input AWREADY_S0,
	// WRITE DATA S0 (ROM)
	// output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	// output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	// output logic WLAST_S0,
	// output logic WVALID_S0,
	// input WREADY_S0,
	// WRITE RESPONSE S0 (ROM)
	// input [`AXI_IDS_BITS-1:0] BID_S0,
	// input [1:0] BRESP_S0,
	// input BVALID_S0,
	// output logic BREADY_S0,

	// WRITE ADDRESS S1 (IM SRAM)
	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
	input AWREADY_S1,
	// WRITE DATA S1 (IM SRAM)
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
	// WRITE RESPONSE S1 (IM SRAM)
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,

    // WRITE ADDRESS S2 (DM SRAM)
    output logic [`AXI_IDS_BITS-1:0] AWID_S2,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
	output logic [1:0] AWBURST_S2,
	output logic AWVALID_S2,
	input AWREADY_S2,
	// WRITE DATA S2 (DM SRAM)
	output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output logic WLAST_S2,
	output logic WVALID_S2,
	input WREADY_S2,
	// WRITE RESPONSE S2 (DM SRAM)
	input [`AXI_IDS_BITS-1:0] BID_S2,
	input [1:0] BRESP_S2,
	input BVALID_S2,
	output logic BREADY_S2,

	// WRITE ADDRESS S3 (Sensor)
	// output logic [`AXI_IDS_BITS-1:0] AWID_S3,
	// output logic [`AXI_ADDR_BITS-1:0] AWADDR_S3,
	// output logic [`AXI_LEN_BITS-1:0] AWLEN_S3,
	// output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3,
	// output logic [1:0] AWBURST_S3,
	// output logic AWVALID_S3,
	// input AWREADY_S3,
	// WRITE DATA S3 (Sensor)
	// output logic [`AXI_DATA_BITS-1:0] WDATA_S3,
	// output logic [`AXI_STRB_BITS-1:0] WSTRB_S3,
	// output logic WLAST_S3,
	// output logic WVALID_S3,
	// input WREADY_S3,
	// WRITE RESPONSE S3 (Sensor)
	// input [`AXI_IDS_BITS-1:0] BID_S3,
	// input [1:0] BRESP_S3,
	// input BVALID_S3,
	// output logic BREADY_S3,

	// WRITE ADDRESS S4 (DRAM)
	output logic [`AXI_IDS_BITS-1:0] AWID_S4,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S4,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S4,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S4,
	output logic [1:0] AWBURST_S4,
	output logic AWVALID_S4,
	input AWREADY_S4,
	// WRITE DATA S4 (DRAM)
	output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
	output logic WLAST_S4,
	output logic WVALID_S4,
	input WREADY_S4,
	// WRITE RESPONSE S4 (DRAM)
	input [`AXI_IDS_BITS-1:0] BID_S4,
	input [1:0] BRESP_S4,
	input BVALID_S4,
	output logic BREADY_S4
);
    // Register
    logic addressDoneReg;
    logic dataDoneReg;
    logic [`AXI_IDS_BITS-1:0] IDReg;
    // Wire
    logic addressDone;
    logic dataDone;

    // Wire
    // Write Arbiter
    logic                      WriteArbiter_AWVALID_WriteDecoder_AWVALID;
    logic [`AXI_ADDR_BITS-1:0] WriteArbiter_AWADDR_WriteDecoder_AWADDR;
    logic [`AXI_ID_BITS-1:0]   WriteArbiter_MasterID;
    logic [1:0]                WriteArbiter_WriteAddressSel;
    logic [1:0]                WriteArbiter_WriteDataSel;
    logic [1:0]                WriteArbiter_WriteResponseSel;
    // Write Decoder
    logic       WriteDecoder_AWREADY_WriteArbiter_AWREADY;
    logic       WriteDecoder_finish_WriteArbiter_finish;
    logic [2:0] WriteDecoder_WriteAddressSel;
    logic [2:0] WriteDecoder_WriteDataSel;
    logic [2:0] WriteDecoder_WriteResponseSel;
    // Bridge
    // Write Address Channel 
    logic [`AXI_IDS_BITS-1:0] AWID;
	logic [`AXI_ADDR_BITS-1:0] AWADDR;
	logic [`AXI_LEN_BITS-1:0] AWLEN;
	logic [`AXI_SIZE_BITS-1:0] AWSIZE;
	logic [1:0] AWBURST;
	logic AWVALID;
	logic AWREADY;
	// Write Data Channel 
	logic [`AXI_DATA_BITS-1:0] WDATA;
	logic [`AXI_STRB_BITS-1:0] WSTRB;
	logic WLAST;
	logic WVALID;
	logic WREADY;
    // Write Response Channel
    logic [`AXI_ID_BITS-1:0] BID;
	logic [1:0] BRESP;
	logic BVALID;
	logic BREADY;

    // Module
    WriteArbiter writeArbiter
    (
        .clock(clock),
        .reset(reset),
        // Master Write Signal
        .AWVALID_M1(AWVALID_M1),
        .AWADDR_M1(AWADDR_M1),
        // Signal to AXI & Siganl to Decoder
        .AWVALID(WriteArbiter_AWVALID_WriteDecoder_AWVALID),
        .AWADDR(WriteArbiter_AWADDR_WriteDecoder_AWADDR),
        .MasterID(WriteArbiter_MasterID),
        // Decoder to Arbiter
        .AWREADY(WriteDecoder_AWREADY_WriteArbiter_AWREADY),
        .finish(WriteDecoder_finish_WriteArbiter_finish),
        // Bridge Selection
        .WriteAddressSel(WriteArbiter_WriteAddressSel),
        .WriteDataSel(WriteArbiter_WriteDataSel),
        .WriteResponseSel(WriteArbiter_WriteResponseSel)
    );
    WriteDecoder writeDecoder
    (
        .clock(clock),
        .reset(reset),
        // Arbiter to Decoder
        .AWVALID(WriteArbiter_AWVALID_WriteDecoder_AWVALID),
        .AWADDR(WriteArbiter_AWADDR_WriteDecoder_AWADDR),
        // Decoder to Arbiter
        .AWREADY(WriteDecoder_AWREADY_WriteArbiter_AWREADY),
        .finish(WriteDecoder_finish_WriteArbiter_finish),
        // Master Signal
        .BREADY(BREADY),
        // Slave Signal
        // .AWREADY_S0(AWREADY_S0),
        .AWREADY_S1(AWREADY_S1),
        .AWREADY_S2(AWREADY_S2),
        // .AWREADY_S3(AWREADY_S3),
        .AWREADY_S4(AWREADY_S4),
        .BVALID(BVALID),
        // Bridge Selection
        .WriteAddressSel(WriteDecoder_WriteAddressSel),
        .WriteDataSel(WriteDecoder_WriteDataSel),
        .WriteResponseSel(WriteDecoder_WriteResponseSel)
    );

    // Wrong Address State Machine
    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            addressDoneReg <= `FALSE;
            dataDoneReg <= `FALSE;
            IDReg <= 8'd0;
        end
        else if (WriteDecoder_finish_WriteArbiter_finish)
        begin
            addressDoneReg <= `FALSE;
            dataDoneReg <= `FALSE;
            IDReg <= 8'd0;
        end
        else if (WriteDecoder_WriteAddressSel == `WRONGADDRESS || 
                 WriteDecoder_WriteDataSel == `WRONGADDRESS || 
                 WriteDecoder_WriteResponseSel == `WRONGADDRESS)
        begin
            if (addressDoneReg == `FALSE && addressDone == `TRUE)
            begin
                addressDoneReg <= `TRUE;
                IDReg <= AWID;
            end
            else 
            begin
                addressDoneReg <= addressDoneReg;
            end
            if (dataDoneReg == `FALSE && dataDone == `TRUE)
            begin
                dataDoneReg <= `TRUE;
            end
            else 
            begin
                dataDoneReg <= dataDoneReg;
            end
        end
        else 
        begin
            addressDoneReg <= `FALSE;
            dataDoneReg <= `FALSE;
            IDReg <= 8'd0;
        end
    end

    // Write Address Channel
    // Master MUX
    always_comb
    begin
        if (WriteArbiter_WriteAddressSel == `M1MUX)
        begin
            AWID = {WriteArbiter_MasterID, AWID_M1};
            AWADDR = WriteArbiter_AWADDR_WriteDecoder_AWADDR;
            AWLEN = AWLEN_M1;
            AWSIZE = AWSIZE_M1;
            AWBURST = AWBURST_M1;
            AWVALID = WriteArbiter_AWVALID_WriteDecoder_AWVALID;
            AWREADY_M1 = AWREADY;
        end
        else 
        begin
            AWID = 8'd0;
            AWADDR = 32'd0;
            AWLEN = 4'd0;
            AWSIZE = 3'd0;
            AWBURST = 2'd0;
            AWVALID = 1'd0;
            AWREADY_M1 = 1'd0;
        end
    end

    // Write Address Channel
    // Slave MUX
    always_comb 
    begin
        // WRITE S0 (ROM)
        // AWID_S0 = 8'd0;
        // AWADDR_S0 = 32'd0;
        // AWLEN_S0 = 4'd0;
        // AWSIZE_S0 = 3'd0;
        // AWBURST_S0 = 2'd0;
        // AWVALID_S0 = 1'd0;
        // WRITE S1 (IM SRAM)
        AWID_S1 = 8'd0;
        AWADDR_S1 = 32'd0;
        AWLEN_S1 = 4'd0;
        AWSIZE_S1 = 3'd0;
        AWBURST_S1 = 2'd0;
        AWVALID_S1 = 1'd0;
        // WRITE S2 (DM SRAM)
        AWID_S2 = 8'd0;
        AWADDR_S2 = 32'd0;
        AWLEN_S2 = 4'd0;
        AWSIZE_S2 = 3'd0;
        AWBURST_S2 = 2'd0;
        AWVALID_S2 = 1'd0;
        // WRITE S3 (Sensor)
        // AWID_S3 = 8'd0;
        // AWADDR_S3 = 32'd0;
        // AWLEN_S3 = 4'd0;
        // AWSIZE_S3 = 3'd0;
        // AWBURST_S3 = 2'd0;
        // AWVALID_S3 = 1'd0;
        // WRITE S4 (DRAM)
        AWID_S4 = 8'd0;
        AWADDR_S4 = 32'd0;
        AWLEN_S4 = 4'd0;
        AWSIZE_S4 = 3'd0;
        AWBURST_S4 = 2'd0;
        AWVALID_S4 = 1'd0;
        // Default AWREADY
        AWREADY = `FALSE;
        // Default Address Done
        addressDone = `FALSE;

        // if (WriteDecoder_WriteAddressSel == `S0MUX)
        // begin
        //     AWID_S0 = AWID;
        //     AWADDR_S0 = AWADDR;
        //     AWLEN_S0 = AWLEN;
        //     AWSIZE_S0 = AWSIZE;
        //     AWBURST_S0 = AWBURST;
        //     AWVALID_S0 = AWVALID;
        //     AWREADY = AWREADY_S0;
        // end
        if (WriteDecoder_WriteAddressSel == `S1MUX) 
        begin
            AWID_S1 = AWID;
            AWADDR_S1 = AWADDR;
            AWLEN_S1 = AWLEN;
            AWSIZE_S1 = AWSIZE;
            AWBURST_S1 = AWBURST;
            AWVALID_S1 = AWVALID;
            AWREADY = AWREADY_S1;
        end
        else if (WriteDecoder_WriteAddressSel == `S2MUX) 
        begin
            AWID_S2 = AWID;
            AWADDR_S2 = AWADDR;
            AWLEN_S2 = AWLEN;
            AWSIZE_S2 = AWSIZE;
            AWBURST_S2 = AWBURST;
            AWVALID_S2 = AWVALID;
            AWREADY = AWREADY_S2;
        end
        // else if (WriteDecoder_WriteAddressSel == `S3MUX) 
        // begin
        //     AWID_S3 = AWID;
        //     AWADDR_S3 = AWADDR;
        //     AWLEN_S3 = AWLEN;
        //     AWSIZE_S3 = AWSIZE;
        //     AWBURST_S3 = AWBURST;
        //     AWVALID_S3 = AWVALID;
        //     AWREADY = AWREADY_S3;
        // end
        else if (WriteDecoder_WriteAddressSel == `S4MUX) 
        begin
            AWID_S4 = AWID;
            AWADDR_S4 = AWADDR;
            AWLEN_S4 = AWLEN;
            AWSIZE_S4 = AWSIZE;
            AWBURST_S4 = AWBURST;
            AWVALID_S4 = AWVALID;
            AWREADY = AWREADY_S4;
        end
        else if (WriteDecoder_WriteAddressSel == `WRONGADDRESS)
        begin
            // Address Channel Handshake
            if (addressDoneReg == `FALSE)
            begin
                AWREADY = `TRUE;
                if (AWVALID)
                begin
                    addressDone = `TRUE;
                end
                else 
                begin
                    addressDone = `FALSE;
                end
            end
            else 
            begin
                AWREADY = `FALSE;
                addressDone = `FALSE;
            end
        end
    end

    // Write Data Channel
    // Master MUX
    always_comb 
    begin
        if (WriteArbiter_WriteDataSel == `M1MUX)
        begin
            WDATA = WDATA_M1;
            WSTRB = WSTRB_M1;
            WLAST = WLAST_M1;
            WVALID = WVALID_M1;
            WREADY_M1 = WREADY;
        end
        else 
        begin
            WDATA = 32'd0;
            WSTRB = 4'd0;
            WLAST = 1'd0;
            WVALID = 1'd0;
            WREADY_M1 = 1'd0;
        end
    end

    // Write Data Channel
    // Slave MUX
    always_comb 
    begin
        // WRITE S0 (ROM)
        // WDATA_S0 = 32'd0;
        // WSTRB_S0 = 4'd0;
        // WLAST_S0 = 1'd0;
        // WVALID_S0 = 1'd0;
        // WRITE S1 (IM SRAM)
        WDATA_S1 = 32'd0;
        WSTRB_S1 = 4'd0;
        WLAST_S1 = 1'd0;
        WVALID_S1 = 1'd0;
        // WRITE S2 (DM SRAM)
        WDATA_S2 = 32'd0;
        WSTRB_S2 = 4'd0;
        WLAST_S2 = 1'd0;
        WVALID_S2 = 1'd0;
        // WRITE S3 (Sensor)
        // WDATA_S3 = 32'd0;
        // WSTRB_S3 = 4'd0;
        // WLAST_S3 = 1'd0;
        // WVALID_S3 = 1'd0;
        // WRITE S4 (DRAM)
        WDATA_S4 = 32'd0;
        WSTRB_S4 = 4'd0;
        WLAST_S4 = 1'd0;
        WVALID_S4 = 1'd0;
        // Default AWREADY
        WREADY = `FALSE;
        // Default Data Done
        dataDone = `FALSE;

        // if (WriteDecoder_WriteDataSel == `S0MUX)
        // begin
        //     WDATA_S0 = WDATA;
        //     WSTRB_S0 = WSTRB;
        //     WLAST_S0 = WLAST;
        //     WVALID_S0 = WVALID;
        //     WREADY = WREADY_S0;
        // end
        if (WriteDecoder_WriteDataSel == `S1MUX) 
        begin
            WDATA_S1 = WDATA;
            WSTRB_S1 = WSTRB;
            WLAST_S1 = WLAST;
            WVALID_S1 = WVALID;
            WREADY = WREADY_S1;
        end
        else if (WriteDecoder_WriteDataSel == `S2MUX) 
        begin
            WDATA_S2 = WDATA;
            WSTRB_S2 = WSTRB;
            WLAST_S2 = WLAST;
            WVALID_S2 = WVALID;
            WREADY = WREADY_S2;
        end
        // else if (WriteDecoder_WriteDataSel == `S3MUX) 
        // begin
        //     WDATA_S3 = WDATA;
        //     WSTRB_S3 = WSTRB;
        //     WLAST_S3 = WLAST;
        //     WVALID_S3 = WVALID;
        //     WREADY = WREADY_S3;
        // end
        else if (WriteDecoder_WriteDataSel == `S4MUX) 
        begin
            WDATA_S4 = WDATA;
            WSTRB_S4 = WSTRB;
            WLAST_S4 = WLAST;
            WVALID_S4 = WVALID;
            WREADY = WREADY_S4;
        end
        else if (WriteDecoder_WriteDataSel == `WRONGADDRESS) 
        begin
            // Data Channel Handshake
            if (dataDoneReg == `FALSE)
            begin
                WREADY = `TRUE;
                if (WLAST && WVALID)
                begin
                    dataDone = `TRUE;
                end
                else 
                begin
                    dataDone = `FALSE;
                end
            end
            else 
            begin
                WREADY = `FALSE;
                dataDone = `FALSE;
            end
        end
    end

    // Write Response Channel
    // Slave MUX
    always_comb 
    begin
        // Default BID
        BID = 4'd0;
        // Default BRESP
        BRESP = `AXI_RESP_OKAY;
        // Default BVALID
        BVALID = `FALSE;
        // WRITE S0 (ROM)
        // BREADY_S0 = `FALSE;
        // WRITE S1 (IM SRAM)
        BREADY_S1 = `FALSE;
        // WRITE S2 (DM SRAM)
        BREADY_S2 = `FALSE;
        // WRITE S3 (Sensor)
        // BREADY_S3 = `FALSE;
        // WRITE S4 (DRAM)
        BREADY_S4 = `FALSE;

        // if (WriteDecoder_WriteResponseSel == `S0MUX) 
        // begin
        //     BID = BID_S0[3:0];
        //     BRESP = BRESP_S0;
        //     BVALID = BVALID_S0;
        //     BREADY_S0 = BREADY;
        // end
        if (WriteDecoder_WriteResponseSel == `S1MUX)
        begin
            BID = BID_S1[3:0];
            BRESP = BRESP_S1;
            BVALID = BVALID_S1;
            BREADY_S1 = BREADY;
        end
        else if (WriteDecoder_WriteResponseSel == `S2MUX)
        begin
            BID = BID_S2[3:0];
            BRESP = BRESP_S2;
            BVALID = BVALID_S2;
            BREADY_S2 = BREADY;
        end
        // else if (WriteDecoder_WriteResponseSel == `S3MUX)
        // begin
        //     BID = BID_S3[3:0];
        //     BRESP = BRESP_S3;
        //     BVALID = BVALID_S3;
        //     BREADY_S3 = BREADY;
        // end
        else if (WriteDecoder_WriteResponseSel == `S4MUX)
        begin
            BID = BID_S4[3:0];
            BRESP = BRESP_S4;
            BVALID = BVALID_S4;
            BREADY_S4 = BREADY;
        end
        else if (WriteDecoder_WriteResponseSel == `WRONGADDRESS) 
        begin
            if (addressDoneReg && dataDoneReg)
            begin
                BID = IDReg[3:0];
                BRESP = `AXI_RESP_DECERR;
                BVALID = `TRUE;
            end
            else 
            begin
                BID = 4'd0;
                BRESP = `AXI_RESP_OKAY;
                BVALID = `FALSE;
            end
        end
    end

    // Write Response Channel
    // Master MUX
    always_comb 
    begin
        if (WriteArbiter_WriteResponseSel == `M1MUX)
        begin
            BID_M1 = BID;
            BRESP_M1 = BRESP;
            BVALID_M1 = BVALID;

            BREADY = BREADY_M1;
        end 
        else
        begin
            BID_M1 = 4'd0;
            BRESP_M1 = 2'd0;
            BVALID_M1 = 1'd0;

            BREADY = 1'd0;
        end
    end
endmodule