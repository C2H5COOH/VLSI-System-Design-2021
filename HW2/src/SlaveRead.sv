// `include "../../../include/AXI_define.svh"
`include "../include/AXI_define.svh"

module SlaveRead(
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
    // SRAM Address
    output logic [13:0] Address,
    // SRAM DATA
    output logic ReadEnable,
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
    // Wire
    logic next;
    logic [`AXI_ADDR_BITS-1:0] temp;

    // State Register
    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            state <= `ADDRESS;
            ARIDReg <= 0;
            ARADDRReg <= 0;
            ARLENReg <= 0;
            ARSIZEReg <= 0;
            ARBURSTReg <= 0;
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
            end
            else if (state == `DATA)
            begin
                if (next)
                begin
                    ARLENReg <= ARLENReg - 1;
                    ARADDRReg <= ARADDRReg + (32'd1 << ARSIZEReg);
                end
                else 
                begin
                    ARLENReg <= ARLENReg;
                    ARADDRReg <= ARADDRReg;
                end
            end
            else if (state == `DATA && nstate == `ADDRESS)
            begin
                ARIDReg <= 0;
                ARADDRReg <= 0;
                ARLENReg <= 0;
                ARSIZEReg <= 0;
                ARBURSTReg <= 0;
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
                        Address = ARADDR[15:2];
                        ReadEnable = `FALSE;
                    end
                    else 
                    begin
                        nstate = `ADDRESS;
                        ReadEnable = `FALSE;
                        Address = 14'd0;
                    end
                end
                else if (select == `WRITE)
                begin
                    ARREADY = `FALSE;
                    nstate = `ADDRESS;
                    ReadEnable = `FALSE;
                    Address = 14'd0;
                end
                else 
                begin
                    ARREADY = `TRUE;
                    nstate = `ADDRESS;
                    ReadEnable = `FALSE;
                    Address = 14'd0;
                end
                // Data Out
                RID = 0;
                RDATA = 0;
                RRESP = 0;
                RLAST = `FALSE;
                RVALID = `FALSE;
                // Control Out
                finish = `FALSE;
                next = `FALSE;
                // SRAM Out
                temp = 0;
            end
            `DATA:
            begin
                // Address Out
                ARREADY = `FALSE;
                // Data Out
                RID = ARIDReg;
                RDATA = DataRead;
                RRESP = `AXI_RESP_OKAY;
                RVALID = `TRUE;
                // RLAST
                if (ARLENReg == 0)
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
                    if (ARLENReg != 0)
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
                // SRAM Out
                ReadEnable = `TRUE;
                if (next)
                begin
                    temp = ARADDRReg + (32'd1 << ARSIZEReg);
                end
                else 
                begin
                    temp = ARADDRReg;
                end
                Address = temp[15:2];
            end
        endcase
    end
endmodule