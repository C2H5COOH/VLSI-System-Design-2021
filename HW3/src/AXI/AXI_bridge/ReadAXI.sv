// `include "ReadArbiter.sv"
// `include "ReadDecoder.sv"
`include "AXI/AXI_bridge/ReadArbiter.sv"
`include "AXI/AXI_bridge/ReadDecoder.sv"

module ReadAXI(
    input clock,
	input reset,

    // ======= Master =======

	// READ ADDRESS M0 (Instruction)
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,
	// READ DATA M0 (Instruction)
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0,

	// READ ADDRESS M1 (Data)
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
	// READ DATA M1 (Data)
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,

    // ======= Slave =======

    // READ ADDRESS S0 (ROM)
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
	input ARREADY_S0,
	// READ DATA S0 (ROM)
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,

	// READ ADDRESS S1 (IM SRAM)
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	input ARREADY_S1,
	// READ DATA S1 (IM SRAM)
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1,
	
	// READ ADDRESS S2 (DM SRAM)
	output logic [`AXI_IDS_BITS-1:0] ARID_S2,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2,
	output logic [1:0] ARBURST_S2,
	output logic ARVALID_S2,
	input ARREADY_S2,
	// READ DATA S2 (DM SRAM)
	input [`AXI_IDS_BITS-1:0] RID_S2,
	input [`AXI_DATA_BITS-1:0] RDATA_S2,
	input [1:0] RRESP_S2,
	input RLAST_S2,
	input RVALID_S2,
	output logic RREADY_S2,

	// READ ADDRESS S3 (Sensor)
	// output logic [`AXI_IDS_BITS-1:0] ARID_S3,
	// output logic [`AXI_ADDR_BITS-1:0] ARADDR_S3,
	// output logic [`AXI_LEN_BITS-1:0] ARLEN_S3,
	// output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3,
	// output logic [1:0] ARBURST_S3,
	// output logic ARVALID_S3,
	// input ARREADY_S3,
	// READ DATA S3 (Sensor)
	// input [`AXI_IDS_BITS-1:0] RID_S3,
	// input [`AXI_DATA_BITS-1:0] RDATA_S3,
	// input [1:0] RRESP_S3,
	// input RLAST_S3,
	// input RVALID_S3,
	// output logic RREADY_S3,

	// READ ADDRESS S4 (DRAM)
	output logic [`AXI_IDS_BITS-1:0] ARID_S4,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S4,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S4,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S4,
	output logic [1:0] ARBURST_S4,
	output logic ARVALID_S4,
	input ARREADY_S4,
	// READ DATA S4 (DRAM)
	input [`AXI_IDS_BITS-1:0] RID_S4,
	input [`AXI_DATA_BITS-1:0] RDATA_S4,
	input [1:0] RRESP_S4,
	input RLAST_S4,
	input RVALID_S4,
	output logic RREADY_S4
);
    // Wrong Address Handler
    // Register
    logic addressDoneReg;
    logic [`AXI_IDS_BITS-1:0] IDReg;
    logic [`AXI_LEN_BITS-1:0] ARLENReg;
    // Wire
    logic addressDone;

    // Wire
    // Read Arbiter
    logic                      ReadArbiter_ARVALID_ReadDecoder_ARVALID;
    logic [`AXI_ADDR_BITS-1:0] ReadArbiter_ARADDR_ReadDecoder_ARADDR;
    logic [`AXI_ID_BITS-1:0]   ReadArbiter_MasterID;
    logic [1:0]                ReadArbiter_ReadAddressSel;
    logic [1:0]                ReadArbiter_ReadDataSel;
    // Read Decoder
    logic       ReadDecoder_ARREADY_ReadArbiter_ARREADY;
    logic       ReadDecoder_finish_ReadArbiter_finish;
    logic [2:0] ReadDecoder_ReadAddressSel;
    logic [2:0] ReadDecoder_ReadDataSel;
    // Bridge
    // Read Address Channel 
    logic [`AXI_IDS_BITS-1:0] ARID;
	logic [`AXI_ADDR_BITS-1:0] ARADDR;
	logic [`AXI_LEN_BITS-1:0] ARLEN;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE;
	logic [1:0] ARBURST;
	logic ARVALID;
	logic ARREADY;
	// Read Data Channel 
	logic [`AXI_ID_BITS-1:0] RID;
	logic [`AXI_DATA_BITS-1:0] RDATA;
	logic [1:0] RRESP;
	logic RLAST;
	logic RVALID;
	logic RREADY;

    // Module
    ReadArbiter readArbiter
    (
        .clock(clock),
        .reset(reset),
        // Master Read Signal
        .ARVALID_M0(ARVALID_M0),
        .ARADDR_M0(ARADDR_M0),
        .ARVALID_M1(ARVALID_M1),
        .ARADDR_M1(ARADDR_M1),
        // Signal to AXI & Siganl to Decoder
        .ARVALID(ReadArbiter_ARVALID_ReadDecoder_ARVALID),
        .ARADDR(ReadArbiter_ARADDR_ReadDecoder_ARADDR),
        .MasterID(ReadArbiter_MasterID),
        // Decoder to Arbiter
        .ARREADY(ReadDecoder_ARREADY_ReadArbiter_ARREADY),
        .finish(ReadDecoder_finish_ReadArbiter_finish),
        // Bridge Selection
        .ReadAddressSel(ReadArbiter_ReadAddressSel),
        .ReadDataSel(ReadArbiter_ReadDataSel)
    );
    ReadDecoder readDecoder
    (
        .clock(clock),
        .reset(reset),
        // Arbiter to Decoder
        .ARVALID(ReadArbiter_ARVALID_ReadDecoder_ARVALID),
        .ARADDR(ReadArbiter_ARADDR_ReadDecoder_ARADDR),
        // Decoder to Arbiter
        .ARREADY(ReadDecoder_ARREADY_ReadArbiter_ARREADY),
        .finish(ReadDecoder_finish_ReadArbiter_finish),
        // Master Signal
        .RREADY(RREADY),
        // Slave Signal
        .ARREADY_S0(ARREADY_S0),
        .ARREADY_S1(ARREADY_S1),
        .ARREADY_S2(ARREADY_S2),
        // .ARREADY_S3(ARREADY_S3),
        .ARREADY_S4(ARREADY_S4),
        .RVALID(RVALID),
        .RLAST(RLAST),
        // Bridge Selection
        .ReadAddressSel(ReadDecoder_ReadAddressSel),
        .ReadDataSel(ReadDecoder_ReadDataSel)
    );

    // Wrong Address State Machine
    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            addressDoneReg <= `FALSE;
            IDReg <= 8'd0;
            ARLENReg <= 4'd0;
        end
        else if (ReadDecoder_finish_ReadArbiter_finish)
        begin
            addressDoneReg <= `FALSE;
            IDReg <= 8'd0;
            ARLENReg <= 4'd0;
        end
        else if (ReadDecoder_ReadAddressSel == `WRONGADDRESS || 
                 ReadDecoder_ReadDataSel == `WRONGADDRESS)
        begin
            if (addressDoneReg == `FALSE && addressDone == `TRUE)
            begin
                addressDoneReg <= `TRUE;
                IDReg <= ARID;
                ARLENReg <= ARLEN;
            end
            else 
            begin
                addressDoneReg <= addressDoneReg;
                if (ARLENReg != 4'd0 && RREADY)
                begin
                    ARLENReg <= ARLENReg - 1;
                end
                else 
                begin
                    ARLENReg <= ARLENReg;
                end
            end
        end
        else 
        begin
            addressDoneReg <= `FALSE;
            IDReg <= 8'd0;
            ARLENReg <= 4'd0;
        end
    end

    // Read Address Channel
    // Master MUX
    always_comb
    begin
        if (ReadArbiter_ReadAddressSel == `M0MUX)
        begin
            ARID = {ReadArbiter_MasterID, ARID_M0};
            ARADDR = ReadArbiter_ARADDR_ReadDecoder_ARADDR;
            ARLEN = ARLEN_M0;
            ARSIZE = ARSIZE_M0;
            ARBURST = ARBURST_M0;
            ARVALID = ReadArbiter_ARVALID_ReadDecoder_ARVALID;
            ARREADY_M0 = ARREADY;

            ARREADY_M1 = 1'd0;
        end
        else if (ReadArbiter_ReadAddressSel == `M1MUX)
        begin
            ARID = {ReadArbiter_MasterID, ARID_M1};
            ARADDR = ReadArbiter_ARADDR_ReadDecoder_ARADDR;
            ARLEN = ARLEN_M1;
            ARSIZE = ARSIZE_M1;
            ARBURST = ARBURST_M1;
            ARVALID = ReadArbiter_ARVALID_ReadDecoder_ARVALID;
            ARREADY_M1 = ARREADY;
            
            ARREADY_M0 = 1'd0;
        end
        else 
        begin
            ARID = 8'd0;
            ARADDR = 32'd0;
            ARLEN = 4'd0;
            ARSIZE = 3'd0;
            ARBURST = 2'd0;
            ARVALID = 1'd0;

            ARREADY_M0 = 1'd0;
            ARREADY_M1 = 1'd0;
        end
    end
    // Read Address Channel
    // Slave MUX
    always_comb
    begin
        // READ S0 (ROM)
        ARID_S0 = 8'd0;
        ARADDR_S0 = 32'd0;
        ARLEN_S0 = 4'd0;
        ARSIZE_S0 = 3'd0;
        ARBURST_S0 = 2'd0;
        ARVALID_S0 = 1'd0;
        // READ S1 (IM SRAM)
        ARID_S1 = 8'd0;
        ARADDR_S1 = 32'd0;
        ARLEN_S1 = 4'd0;
        ARSIZE_S1 = 3'd0;
        ARBURST_S1 = 2'd0;
        ARVALID_S1 = 1'd0;
        // READ S2 (DM SRAM)
        ARID_S2 = 8'd0;
        ARADDR_S2 = 32'd0;
        ARLEN_S2 = 4'd0;
        ARSIZE_S2 = 3'd0;
        ARBURST_S2 = 2'd0;
        ARVALID_S2 = 1'd0;
        // READ S3 (Sensor)
        // ARID_S3 = 8'd0;
        // ARADDR_S3 = 32'd0;
        // ARLEN_S3 = 4'd0;
        // ARSIZE_S3 = 3'd0;
        // ARBURST_S3 = 2'd0;
        // ARVALID_S3 = 1'd0;
        // READ S4 (DRAM)
        ARID_S4 = 8'd0;
        ARADDR_S4 = 32'd0;
        ARLEN_S4 = 4'd0;
        ARSIZE_S4 = 3'd0;
        ARBURST_S4 = 2'd0;
        ARVALID_S4 = 1'd0;
        // Default ARREADY
        ARREADY = `FALSE;
        // Default Address Done
        addressDone = `FALSE;

        if (ReadDecoder_ReadAddressSel == `S0MUX)
        begin
            ARID_S0 = ARID;
            ARADDR_S0 = ARADDR;
            ARLEN_S0 = ARLEN;
            ARSIZE_S0 = ARSIZE;
            ARBURST_S0 = ARBURST;
            ARVALID_S0 = ARVALID;
            ARREADY = ARREADY_S0;
        end
        else if (ReadDecoder_ReadAddressSel == `S1MUX) 
        begin
            ARID_S1 = ARID;
            ARADDR_S1 = ARADDR;
            ARLEN_S1 = ARLEN;
            ARSIZE_S1 = ARSIZE;
            ARBURST_S1 = ARBURST;
            ARVALID_S1 = ARVALID;
            ARREADY = ARREADY_S1;
        end
        else if (ReadDecoder_ReadAddressSel == `S2MUX) 
        begin
            ARID_S2 = ARID;
            ARADDR_S2 = ARADDR;
            ARLEN_S2 = ARLEN;
            ARSIZE_S2 = ARSIZE;
            ARBURST_S2 = ARBURST;
            ARVALID_S2 = ARVALID;
            ARREADY = ARREADY_S2;
        end
        // else if (ReadDecoder_ReadAddressSel == `S3MUX) 
        // begin
        //     ARID_S3 = ARID;
        //     ARADDR_S3 = ARADDR;
        //     ARLEN_S3 = ARLEN;
        //     ARSIZE_S3 = ARSIZE;
        //     ARBURST_S3 = ARBURST;
        //     ARVALID_S3 = ARVALID;
        //     ARREADY = ARREADY_S3;
        // end
        else if (ReadDecoder_ReadAddressSel == `S4MUX) 
        begin
            ARID_S4 = ARID;
            ARADDR_S4 = ARADDR;
            ARLEN_S4 = ARLEN;
            ARSIZE_S4 = ARSIZE;
            ARBURST_S4 = ARBURST;
            ARVALID_S4 = ARVALID;
            ARREADY = ARREADY_S4;
        end
        else if (ReadDecoder_ReadAddressSel == `WRONGADDRESS) 
        begin
            // Address Channel Handshake
            if (addressDoneReg == `FALSE)
            begin
                ARREADY = `TRUE;
                if (ARVALID)
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
                ARREADY = `FALSE;
                addressDone = `FALSE;
            end
        end
    end

    // Read Data Channel
    // Slave MUX
    always_comb 
    begin
        // Default RID
        RID = 4'd0;
        // Default RDATA
        RDATA = 32'd0;
        // Default RRESP
        RRESP = `AXI_RESP_OKAY;
        // Default RLAST
        RLAST = `FALSE;
        // Default RVALID
        RVALID = `FALSE;
        // READ S0 (ROM)
        RREADY_S0 = `FALSE;
        // READ S1 (IM SRAM)
        RREADY_S1 = `FALSE;
        // READ S2 (DM SRAM)
        RREADY_S2 = `FALSE;
        // READ S3 (Sensor)
        // RREADY_S3 = `FALSE;
        // READ S4 (DRAM)
        RREADY_S4 = `FALSE;

        if (ReadDecoder_ReadDataSel == `S0MUX) 
        begin
            RID = RID_S0[3:0];
	        RDATA = RDATA_S0;
	        RRESP = RRESP_S0;
	        RLAST = RLAST_S0;
	        RVALID = RVALID_S0;
	        RREADY_S0 = RREADY;
        end
        else if (ReadDecoder_ReadDataSel == `S1MUX)
        begin
            RID = RID_S1[3:0];
	        RDATA = RDATA_S1;
	        RRESP = RRESP_S1;
	        RLAST = RLAST_S1;
	        RVALID = RVALID_S1;
            RREADY_S1 = RREADY;
        end
        else if (ReadDecoder_ReadDataSel == `S2MUX)
        begin
            RID = RID_S2[3:0];
	        RDATA = RDATA_S2;
	        RRESP = RRESP_S2;
	        RLAST = RLAST_S2;
	        RVALID = RVALID_S2;
            RREADY_S2 = RREADY;
        end
        // else if (ReadDecoder_ReadDataSel == `S3MUX)
        // begin
        //     RID = RID_S3[3:0];
	    //     RDATA = RDATA_S3;
	    //     RRESP = RRESP_S3;
	    //     RLAST = RLAST_S3;
	    //     RVALID = RVALID_S3;
        //     RREADY_S3 = RREADY;
        // end
        else if (ReadDecoder_ReadDataSel == `S4MUX)
        begin
            RID = RID_S4[3:0];
	        RDATA = RDATA_S4;
	        RRESP = RRESP_S4;
	        RLAST = RLAST_S4;
	        RVALID = RVALID_S4;
            RREADY_S4 = RREADY;
        end
        else if (ReadDecoder_ReadDataSel == `WRONGADDRESS)
        begin
            if (addressDoneReg)
            begin
                RID = IDReg[3:0];
                RDATA = 32'd0;
                RRESP = `AXI_RESP_DECERR;
                if (ARLENReg == 4'd0) 
                begin
                    RLAST = `TRUE;
                end
                else 
                begin
                    RLAST = `FALSE;
                end
                RVALID = `TRUE;
            end
            else 
            begin
                RID = 4'd0;
                RDATA = 32'd0;
                RRESP = `AXI_RESP_OKAY;
                RLAST = `FALSE;
                RVALID = `FALSE;
            end
        end
    end

    // Read Data Channel
    // Master MUX
    always_comb 
    begin
        if (ReadArbiter_ReadDataSel == `M0MUX)
        begin
            RID_M0 = RID;
            RDATA_M0 = RDATA;
            RRESP_M0 = RRESP;
            RLAST_M0 = RLAST;
            RVALID_M0 = RVALID;
            RREADY = RREADY_M0;

            RID_M1 = 4'd0;
            RDATA_M1 = 32'd0;
            RRESP_M1 = 2'd0;
            RLAST_M1 = 1'd0;
            RVALID_M1 = 1'd0;
        end
        else if (ReadArbiter_ReadDataSel == `M1MUX)
        begin
            RID_M0 = 4'd0;
            RDATA_M0 = 32'd0;
            RRESP_M0 = 2'd0;
            RLAST_M0 = 1'd0;
            RVALID_M0 = 1'd0;

            RID_M1 = RID;
            RDATA_M1 = RDATA;
            RRESP_M1 = RRESP;
            RLAST_M1 = RLAST;
            RVALID_M1 = RVALID;
            RREADY = RREADY_M1;
        end 
        else
        begin
            RID_M0 = 4'd0;
            RDATA_M0 = 32'd0;
            RRESP_M0 = 2'd0;
            RLAST_M0 = 1'd0;
            RVALID_M0 = 1'd0;

            RID_M1 = 4'd0;
            RDATA_M1 = 32'd0;
            RRESP_M1 = 2'd0;
            RLAST_M1 = 1'd0;
            RVALID_M1 = 1'd0;

            RREADY = 1'd0;
        end
    end
endmodule