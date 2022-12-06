`include "AXI_def.svh"

module SlaveWriteSRAM(
    input clock,
	input reset,
    // WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0] AWID,
	input [`AXI_ADDR_BITS-1:0] AWADDR,
	input [`AXI_LEN_BITS-1:0] AWLEN,
	input [`AXI_SIZE_BITS-1:0] AWSIZE,
	input [1:0] AWBURST,
	input AWVALID,
	output logic AWREADY,
	// WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA,
	input [`AXI_STRB_BITS-1:0] WSTRB,
	input WLAST,
	input WVALID,
	output logic WREADY,
	// WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0] BID,
	output logic [1:0] BRESP,
	output logic BVALID,
	input BREADY,
    // Control Signal
    input [1:0] select,
    output logic finish,
    // SRAM Address
    output logic [`AXI_ADDR_BITS-1:0] Address,
    // SRAM DATA
    output logic [`AXI_STRB_BITS-1:0] WriteEnable,
    output logic [`AXI_DATA_BITS-1:0] DataWrite
);
    // Register
    logic state;
    logic nstate;
    logic addressDoneReg;
    logic [`AXI_IDS_BITS-1:0] AWIDReg;
    logic [`AXI_ADDR_BITS-1:0] AWADDRReg;
    logic [`AXI_LEN_BITS-1:0] AWLENReg;
    logic [`AXI_SIZE_BITS-1:0] AWSIZEReg;
    logic [1:0] AWBURSTReg;
    // Wire
    logic addressDone;
    logic next;

    // State Register
    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            state <= `ADDRESSDATA;
            addressDoneReg <= `FALSE;
            AWIDReg <= 8'd0;
            AWADDRReg <= 32'd0;
            AWLENReg <= 4'd0;
            AWSIZEReg <= 3'd0;
            AWBURSTReg <= 2'd0;
        end
        else
        begin
            state <= nstate;
            if (state == `ADDRESSDATA)
            begin
                // Address
                if (addressDoneReg == `FALSE && addressDone == `TRUE)
                begin
                    addressDoneReg <= `TRUE;
                    AWIDReg <= AWID;
                    AWADDRReg <= AWADDR;
                    AWLENReg <= AWLEN;
                    AWSIZEReg <= AWSIZE;
                    AWBURSTReg <= AWBURST;
                end
                else
                begin
                    addressDoneReg <= addressDoneReg;
                end
                // Data
                if (WVALID == `TRUE && WREADY == `TRUE)
                begin
                    if (next)
                    begin
                        AWLENReg <= AWLENReg - 4'd1;
                        AWADDRReg <= AWADDRReg + (32'd1 << AWSIZEReg);
                    end
                    else 
                    begin
                        AWLENReg <= AWLENReg;
                        AWADDRReg <= AWADDRReg;
                    end
                end
            end
            else if (state == `RESPONSE && nstate == `ADDRESSDATA)
            begin
                addressDoneReg <= `FALSE;
                AWIDReg <= 8'd0;
                AWADDRReg <= 32'd0;
                AWLENReg <= 4'd0;
                AWSIZEReg <= 3'd0;
                AWBURSTReg <= 2'd0;
            end
        end
    end
    // Next State Logic & Combination Output Logic
    always_comb
    begin
        case (state)
            `ADDRESSDATA:
            begin
                if (select == `WRITE)
                begin
                    // Address Out
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
                        addressDone = `FALSE;
                        AWREADY = `FALSE;
                    end
                    // Data Out
                    if (addressDone == `TRUE) 
                    begin
                        WREADY = `TRUE;
                        if (WVALID)
                        begin
                            WriteEnable = ~WSTRB;
                            Address = AWADDR;
                            DataWrite = WDATA;
                            next = `TRUE;
                            if (WLAST)
                            begin
                                nstate = `RESPONSE;
                            end
                            else 
                            begin
                                nstate = `ADDRESSDATA;
                            end
                        end
                        else 
                        begin
                            WriteEnable = 8'b11111111;
                            Address = 32'd0;
                            DataWrite = 64'd0;
                            next = `FALSE;
                            nstate = `ADDRESSDATA;
                        end
                    end
                    else if (addressDoneReg == `TRUE) 
                    begin
                        WREADY = `TRUE;
                        if (WVALID) 
                        begin
                            WriteEnable = ~WSTRB;
                            Address = AWADDRReg;
                            DataWrite = WDATA;
                            next = `TRUE;
                            if (WLAST)
                            begin
                                nstate = `RESPONSE;
                            end
                            else 
                            begin
                                nstate = `ADDRESSDATA;
                            end
                        end
                        else 
                        begin
                            WriteEnable = 8'b11111111;
                            Address = 32'd0;
                            DataWrite = 64'd0;
                            next = `FALSE;
                            nstate = `ADDRESSDATA;
                        end
                    end
                    else 
                    begin
                        WREADY = `FALSE;
                        WriteEnable = 8'b11111111;
                        Address = 32'd0;
                        DataWrite = 64'd0;
                        next = `FALSE;
                        nstate = `ADDRESSDATA;
                    end
                    // Response Out
                    BID = 8'd0;
                    BRESP = 2'd0;
                    BVALID = `FALSE;
                    // Control Out
                    finish = `FALSE;
                end
                else if (select == `READ)
                begin
                    nstate = `ADDRESSDATA;
                    // Address Out
                    AWREADY = `FALSE;
                    next = `FALSE;
                    addressDone = `FALSE;
                    // Data Out
                    WREADY = `FALSE;
                    WriteEnable = 8'b11111111;
                    Address = 32'd0;
                    DataWrite = 64'd0;
                    // Response Out
                    BID = 8'd0;
                    BRESP = 2'd0;
                    BVALID = `FALSE;
                    // Control Out
                    finish = `FALSE;
                end
                else 
                begin
                    nstate = `ADDRESSDATA;
                    // Address Out
                    AWREADY = `TRUE;
                    next = `FALSE;
                    addressDone = `FALSE;
                    // Data Out
                    WREADY = `FALSE;
                    WriteEnable = 8'b11111111;
                    Address = 32'd0;
                    DataWrite = 64'd0;
                    // Response Out
                    BID = 8'd0;
                    BRESP = 2'd0;
                    BVALID = `FALSE;
                    // Control Out
                    finish = `FALSE;
                end
                
            end
            `RESPONSE:
            begin
                // Address Out
                AWREADY = `FALSE;
                next = `FALSE;
                addressDone = `FALSE;
                // Data Out
                WREADY = `FALSE;
                WriteEnable = 8'b11111111;
                Address = 32'd0;
                DataWrite = 64'd0;
                // Response Out && Control Out
                BID = AWIDReg;
                BRESP = `AXI_RESP_OKAY;
                BVALID = `TRUE;
                if (BREADY)
                begin
                    finish = `TRUE;
                    nstate = `ADDRESSDATA;
                end
                else 
                begin
                    finish = `FALSE;
                    nstate = `RESPONSE;
                end
            end
        endcase
    end
endmodule