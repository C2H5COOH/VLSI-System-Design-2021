// `include "../AXI/AXI_slave_DRAM/AXISlaveDRAM.sv"
`include "AXI/AXI_slave_DRAM/AXISlaveDRAM.sv"

`define ACTIVEROW 2'b00
`define ACTIVECOLUMN 2'b01
`define PRECHARGE 2'b10
`define DRAM_tRP_DELAY 5
`define DRAM_tRCD_DELAY 5
`define DRAM_CL_DELAY 5

module DRAM_wrapper (
    input clock,
	input reset,
    // READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output ARREADY,
	// READ DATA
	output [`AXI_IDS_BITS-1:0] RID,
	output [`AXI_DATA_BITS-1:0] RDATA,
	output [1:0] RRESP,
	output RLAST,
	output RVALID,
	input RREADY,
    // WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0] AWID,
	input [`AXI_ADDR_BITS-1:0] AWADDR,
	input [`AXI_LEN_BITS-1:0] AWLEN,
	input [`AXI_SIZE_BITS-1:0] AWSIZE,
	input [1:0] AWBURST,
	input AWVALID,
	output AWREADY,
	// WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA,
	input [`AXI_STRB_BITS-1:0] WSTRB,
	input WLAST,
	input WVALID,
	output WREADY,
	// WRITE RESPONSE
	output [`AXI_IDS_BITS-1:0] BID,
	output [1:0] BRESP,
	output BVALID,
	input BREADY,
    // DRAM
    output logic CS,
    output logic RAS,
    output logic CAS,
    output logic [3:0] WEB,
    output logic [10:0] A,
    output logic [`AXI_DATA_BITS-1:0] DI,
    input [`AXI_DATA_BITS-1:0] DO,
    input valid
);
    // Register
    logic [1:0] state;
    logic [1:0] nstate;
    logic [2:0] counter;
    logic [10:0] rowAddressReg;
    logic [`AXI_ADDR_BITS-1:0] addressReg;
    logic [`AXI_STRB_BITS-1:0] writeEnableReg;
    logic [`AXI_DATA_BITS-1:0] dataWriteReg;
    logic readyReadReg;
    logic readyWriteReg;

    // Wire
    // DRAM Control
    logic [1:0] rw;
    logic [`AXI_ADDR_BITS-1:0] address;
    // READ
    logic readyRead;
    logic completeRead;
    // WRTIE
    logic                      readyWrite;
    logic [`AXI_STRB_BITS-1:0] writeEnable;
    logic [`AXI_DATA_BITS-1:0] dataWrite;
    logic completeWrite;

    // Module
    AXISlaveDRAM axiSlaveDRAM
    (
        .clock(clock),
        .reset(reset),
        // READ ADDRESS
        .ARID(ARID),
        .ARADDR(ARADDR),
        .ARLEN(ARLEN),
        .ARSIZE(ARSIZE),
        .ARBURST(ARBURST),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),
        // READ DATA
        .RID(RID),
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RLAST(RLAST),
        .RVALID(RVALID),
        .RREADY(RREADY),
        // WRITE ADDRESS
        .AWID(AWID),
        .AWADDR(AWADDR),
        .AWLEN(AWLEN),
        .AWSIZE(AWSIZE),
        .AWBURST(AWBURST),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),
        // WRITE DATA
        .WDATA(WDATA),
        .WSTRB(WSTRB),
        .WLAST(WLAST),
        .WVALID(WVALID),
        .WREADY(WREADY),
        // WRITE RESPONSE
        .BID(BID),
        .BRESP(BRESP),
        .BVALID(BVALID),
        .BREADY(BREADY),
        // DRAM
        .rw(rw),
        .Address(address),
        .ReadyRead(readyRead),
        .CompleteRead(completeRead),
        .DataRead(DO),
        .ReadyWrite(readyWrite),
        .WriteEnable(writeEnable),
        .DataWrite(dataWrite),
        .CompleteWrite(completeWrite)
    );

    assign CS = 1'b0;

    // DRAM Controller
    // State Register
    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            state <= `ACTIVECOLUMN;
            counter <= 3'd0;
            rowAddressReg <= 11'd0;
            addressReg <= 32'd0;
            writeEnableReg <= 4'b1111;
            dataWriteReg <= 32'd0;
            readyReadReg <= `FALSE;
            readyWriteReg <= `FALSE;
        end
        else 
        begin
            state <= nstate;
            case (state)
                `ACTIVEROW:
                begin
                    if (counter == 3'd0) 
                    begin
                        rowAddressReg <= addressReg[22:12];
                    end
                    else 
                    begin
                        rowAddressReg <= rowAddressReg;
                    end
                    if (counter == `DRAM_tRCD_DELAY) 
                    begin
                        counter <= 3'd0;
                    end
                    else 
                    begin
                        counter <= counter + 1'b1;
                    end
                end
                `ACTIVECOLUMN:
                begin
                    case (rw)
                        `READ:
                        begin
                            if (readyRead) 
                            begin
                                addressReg <= address;
                                readyReadReg <= `TRUE;
                            end
                            else 
                            begin
                                if (completeRead) 
                                begin
                                    addressReg <= 32'd0;
                                end
                                else 
                                begin
                                    addressReg <= addressReg;
                                end
                            end
                            if (nstate == `PRECHARGE)
                            begin
                                counter <= 3'd0;
                            end
                            else if (counter == `DRAM_CL_DELAY)
                            begin
                                counter <= 3'd0;
                                readyReadReg <= `FALSE;
                            end
                            else if (readyRead || readyReadReg)
                            begin
                                counter <= counter + 1'b1;
                            end
                        end 
                        `WRITE:
                        begin
                            if (readyWrite) 
                            begin
                                addressReg <= address;
                                dataWriteReg <= dataWrite;
                                writeEnableReg <= writeEnable;
                                readyWriteReg <= `TRUE;
                            end
                            else 
                            begin
                                addressReg <= addressReg; 
                                dataWriteReg <= dataWriteReg;
                                writeEnableReg <= writeEnableReg;
                            end
                            if (nstate == `PRECHARGE)
                            begin
                                counter <= 3'd0;
                            end
                            else if (counter == `DRAM_CL_DELAY)
                            begin
                                counter <= 3'd0;
                                readyWriteReg <= `FALSE;
                            end
                            else if (readyWrite || readyWriteReg)
                            begin
                                counter <= counter + 1'b1;
                            end
                        end
                    endcase
                end
                `PRECHARGE:
                begin
                    if (counter == `DRAM_tRP_DELAY) 
                    begin
                        counter <= 3'd0;
                    end
                    else 
                    begin
                        counter <= counter + 1'b1;
                    end
                end
                default: 
                begin
                    state <= `ACTIVECOLUMN;
                    counter <= 3'd0;
                    rowAddressReg <= 11'd0;
                    addressReg <= 32'd0;
                    writeEnableReg <= 4'b1111;
                    dataWriteReg <= 32'd0;
                    readyReadReg <= `FALSE;
                    readyWriteReg <= `FALSE;
                end
            endcase
        end
    end
    // Next State Logic & Combination Output Logic
    always_comb 
    begin
        // Default
        // DRAM Control
        RAS = 1'b1;
        CAS = 1'b1;
        WEB = 4'b1111;
        A = 11'd0;
        DI = 32'd0;

        case (state)
            `ACTIVEROW:
            begin
                if (counter == 3'd0) 
                begin
                    RAS = 1'b0;
                end
                else 
                begin
                    RAS = 1'b1;
                end
                A = addressReg[22:12];
                // Next State
                if (counter == `DRAM_tRCD_DELAY) 
                begin
                    nstate = `ACTIVECOLUMN;
                end
                else 
                begin
                    nstate = `ACTIVEROW;
                end
            end
            `ACTIVECOLUMN:
            begin
                case (rw)
                    `READ:
                    begin
                        if (readyRead) 
                        begin
                            if (rowAddressReg != address[22:12]) 
                            begin
                                CAS = 1'b1;
                                nstate = `PRECHARGE;
                            end
                            else 
                            begin
                                A = address[11:2];
                                CAS = 1'b0;
                                nstate = `ACTIVECOLUMN;
                            end
                        end
                        else 
                        begin
                            if (counter == 3'd0 && readyReadReg) 
                            begin
                                CAS = 1'b0;
                            end
                            else 
                            begin
                                CAS = 1'b1;
                            end
                            A = addressReg[11:2];
                            nstate = `ACTIVECOLUMN;
                        end
                    end
                    `WRITE:
                    begin
                        if (readyWrite) 
                        begin
                            if (rowAddressReg != address[22:12]) 
                            begin
                                CAS = 1'b1;
                                nstate = `PRECHARGE;
                            end
                            else 
                            begin
                                A = address[11:2];
                                DI = dataWrite;
                                WEB = writeEnable;
                                CAS = 1'b0;
                                nstate = `ACTIVECOLUMN;
                            end
                        end
                        else 
                        begin
                            if (counter == 3'd0 && readyWriteReg)
                            begin
                                CAS = 1'b0;
                                WEB = writeEnableReg;
                            end
                            else 
                            begin
                                CAS = 1'b1;
                            end
                            A = addressReg[11:2];
                            DI = dataWriteReg;
                            nstate = `ACTIVECOLUMN;
                        end
                    end
                    default:
                    begin
                        WEB = 4'b1111;
                        RAS = 1'b1;
                        CAS = 1'b1;
                        A = 11'd0;
                        DI = 32'd0;
                        nstate = `ACTIVECOLUMN;
                    end 
                endcase
            end
            `PRECHARGE:
            begin
                if (counter == 3'd0) 
                begin
                    RAS = 1'b0;
                    WEB = 4'b0000;
                end
                else 
                begin
                    RAS = 1'b1;
                    WEB = 4'b1111;
                end
                A = rowAddressReg;
                // Next State
                if (counter == `DRAM_tRCD_DELAY) 
                begin
                    nstate = `ACTIVEROW;
                end
                else 
                begin
                    nstate = `PRECHARGE;
                end
            end 
            default:
            begin
                nstate = `ACTIVECOLUMN;
                WEB = 4'b1111;
                RAS = 1'b1;
                CAS = 1'b1;
                A = 11'd0;
                DI = 32'd0;
            end 
        endcase
    end

    always_comb 
    begin
        case (state)
            `ACTIVEROW:
            begin
                completeRead = `FALSE;
                completeWrite = `FALSE;
            end
            `ACTIVECOLUMN:
            begin
                if (counter == `DRAM_CL_DELAY) 
                begin
                    if (rw == `READ) 
                    begin
                        completeRead = `TRUE;
                        completeWrite = `FALSE;
                    end
                    else if (rw == `WRITE) 
                    begin
                        completeRead = `FALSE;
                        completeWrite = `TRUE;
                    end
                    else 
                    begin
                        completeRead = `FALSE;
                        completeWrite = `FALSE;
                    end
                end
                else 
                begin
                    completeRead = `FALSE;
                    completeWrite = `FALSE;
                end
            end
            `PRECHARGE:
            begin
                completeRead = `FALSE;
                completeWrite = `FALSE;
            end
            default:
            begin
                completeRead = `FALSE;
                completeWrite = `FALSE;
            end
        endcase
    end
endmodule