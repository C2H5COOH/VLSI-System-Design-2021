// `include "../../../include/AXI_define.svh"
`include "../include/AXI_define.svh"

module SlaveReadDRAM(
    input clock,
	input reset,
    // READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output logic ARREADY,
	// READ DATA
	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input RREADY,
    // Control Signal
    input [1:0] select,
    output logic finish,
    // DRAM Address
    output logic [`AXI_ADDR_BITS-1:0] Address,
    output logic ReadyRead,
    // DRAM DATA
    input CompleteRead,
    input [`AXI_DATA_BITS-1:0] DataRead
);
    // Register
    logic state;
    logic nstate;
    logic [`AXI_IDS_BITS-1:0] ARIDReg;
	logic [`AXI_ADDR_BITS-1:0] ARADDRReg;
	logic [`AXI_LEN_BITS-1:0] ARLENReg;
	logic [`AXI_SIZE_BITS-1:0] ARSIZEReg;
	logic [1:0] ARBURSTReg;
    logic CompleteReadReg;
    logic [`AXI_DATA_BITS-1:0] DataReadReg;
    logic nextReg;
    // Wire
    logic next;

    // State Register
    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            state <= `ADDRESS;
            ARIDReg <= 8'd0;
            ARADDRReg <= 32'd0;
            ARLENReg <= 4'd0;
            ARSIZEReg <= 3'd0;
            ARBURSTReg <= 2'd0;
            CompleteReadReg <= `FALSE;
            DataReadReg <= 32'd0;
            nextReg <= `FALSE;
        end
        else
        begin
            state <= nstate;
            if (state == `ADDRESS && nstate == `DATA)
            begin
                ARIDReg <= ARID;
                ARADDRReg <= ARADDR;
                ARLENReg <= ARLEN;
                ARSIZEReg <= ARSIZE;
                ARBURSTReg <= ARBURST;
                CompleteReadReg <= `FALSE;
                DataReadReg <= 32'd0;
                nextReg <= `FALSE;
            end
            else if (state == `DATA)
            begin
                if (next)
                begin
                    ARLENReg <= ARLENReg - 1'b1;
                    ARADDRReg <= ARADDRReg + (32'd1 << ARSIZEReg);
                    CompleteReadReg <= `FALSE;
                    DataReadReg <= 32'd0;
                    nextReg <= `TRUE;
                end
                else 
                begin
                    ARLENReg <= ARLENReg;
                    if (CompleteRead) 
                    begin
                        ARADDRReg <= 32'd0;
                        CompleteReadReg <= `TRUE;
                        DataReadReg <= DataRead;
                    end
                    else 
                    begin
                        ARADDRReg <= ARADDRReg;
                        CompleteReadReg <= CompleteReadReg; 
                        DataReadReg <= DataReadReg;   
                    end
                    nextReg <= `FALSE;
                end
            end
            else if (state == `DATA && nstate == `ADDRESS)
            begin
                ARIDReg <= 8'd0;
                ARADDRReg <= 32'd0;
                ARLENReg <= 4'd0;
                ARSIZEReg <= 3'd0;
                ARBURSTReg <= 2'd0;
                CompleteReadReg <= `FALSE;
                DataReadReg <= 32'd0;
                nextReg <= `FALSE;
            end
        end
    end
    // Next State Logic & Combination Output Logic
    always_comb
    begin
        case (state)
            `ADDRESS:
            begin
                if (select == `READ)
                begin
                    ARREADY = `TRUE;
                    if (ARVALID)
                    begin
                        nstate = `DATA;
                        ReadyRead = `TRUE;
                        Address = ARADDR;
                    end
                    else 
                    begin
                        nstate = `ADDRESS;
                        ReadyRead = `FALSE;
                        Address = 32'd0;
                    end
                end
                else if (select == `WRITE)
                begin
                    ARREADY = `FALSE;
                    nstate = `ADDRESS;
                    ReadyRead = `FALSE;
                    Address = 32'd0;
                end
                else 
                begin
                    ARREADY = `TRUE;
                    nstate = `ADDRESS;
                    ReadyRead = `FALSE;
                    Address = 32'd0;
                end
                // Data Out
                RID = 8'd0;
                RDATA = 32'd0;
                RRESP = 2'd0;
                RLAST = `FALSE;
                RVALID = `FALSE;
                // Control Out
                finish = `FALSE;
                next = `FALSE;
            end
            `DATA:
            begin
                // Address Out
                ARREADY = `FALSE;
                // Wait for DRAM finish read
                if (CompleteRead || CompleteReadReg) 
                begin
                    ReadyRead = `FALSE;
                    // Data Out
                    RID = ARIDReg;
                    RRESP = `AXI_RESP_OKAY;
                    RVALID = `TRUE;
                    // RDATA
                    RDATA = DataRead;
                    // if (CompleteRead) 
                    // begin
                    //     RDATA = DataRead;
                    // end
                    // else if (CompleteReadReg) 
                    // begin
                    //     RDATA = DataReadReg;
                    // end
                    // begin
                    //     RDATA = 0;
                    // end
                    // RLAST
                    if (ARLENReg == 4'd0)
                    begin
                        RLAST = `TRUE;
                    end
                    else 
                    begin
                        RLAST = `FALSE;
                    end
                    // RREADY && Control Out
                    if (RREADY)
                    begin
                        if (ARLENReg != 4'd0)
                        begin
                            next = `TRUE;
                            finish = `FALSE;
                            nstate = `DATA;
                        end
                        else 
                        begin
                            next = `FALSE;
                            finish = `TRUE;
                            nstate = `ADDRESS;
                        end
                    end
                    else 
                    begin
                        next = `FALSE;
                        finish = `FALSE;
                        nstate = `DATA;
                    end
                    if (next)
                    begin
                        Address = ARADDRReg + (32'd1 << ARSIZEReg);
                    end
                    else 
                    begin
                        Address = ARADDRReg;
                    end
                end
                else if (nextReg)
                begin
                    // Data Out
                    RID = 8'd0;
                    RDATA = 32'd0;
                    RRESP = 2'd0;
                    RLAST = `FALSE;
                    RVALID = `FALSE;
                    // Control Out
                    finish = `FALSE;
                    next = `FALSE;
                    // DRAM out
                    ReadyRead = `TRUE;
                    Address = ARADDRReg;
                    // Next State
                    nstate = `DATA;
                end
                else 
                begin
                    ReadyRead = `FALSE;
                    // Data Out
                    RID = 8'd0;
                    RDATA = 32'd0;
                    RRESP = 2'd0;
                    RLAST = `FALSE;
                    RVALID = `FALSE;
                    // Control Out
                    finish = `FALSE;
                    next = `FALSE;
                    // DRAM out
                    Address = ARADDRReg;
                    // Next State
                    nstate = `DATA;
                end
            end
        endcase
    end
endmodule