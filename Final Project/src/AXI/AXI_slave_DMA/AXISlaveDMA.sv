`include "AXI_slave_DMA/SlaveReadDMA.sv"
`include "AXI_slave_DMA/SlaveWriteDMA.sv"

module AXISlaveDMA (
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
    // DMA
    output logic [`AXI_ADDR_BITS-1:0] Address,
    output logic ReadEnable,
    input [`AXI_DATA_BITS-1:0] DataRead,
    output logic [`AXI_STRB_BITS-1:0] WriteEnable,
    output logic [`AXI_DATA_BITS-1:0] DataWrite,
    input busy
);
    // Register
    logic state;
    logic nstate;
    logic [1:0] selectReg;
    // Wire
    logic [1:0] select;
    logic finishRead;
    logic finishWrite;
    logic [`AXI_ADDR_BITS-1:0] addressRead;
    logic [`AXI_ADDR_BITS-1:0] addressWrite;
    logic readEnable;
    logic [`AXI_STRB_BITS-1:0] writeEnable;
    logic [`AXI_DATA_BITS-1:0] writeData;
    
    // Module
    SlaveReadDMA slaveReadDMA
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
        // Control Signal
        .select(select),
        .finish(finishRead),
        // DMA Address
        .Address(addressRead),
        // DMA DATA
        .ReadEnable(readEnable),
        .DataRead(DataRead)
    );
    SlaveWriteDMA slaveWriteDMA
    (
        .clock(clock),
        .reset(reset),
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
        // Control Signal
        .select(select),
        .finish(finishWrite),
        // DMA Address
        .Address(addressWrite),
        // DMA DATA
        .WriteEnable(writeEnable),
        .DataWrite(writeData)
    );

    // State Register
    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            state <= `IDLE;
            selectReg <= `FREE;
        end
        else 
        begin
            state <= nstate;
            if (state == `IDLE && nstate == `BUSY)
            begin
                selectReg <= select;
            end
            else if (state == `BUSY && nstate == `IDLE)
            begin
                selectReg <= `FREE;
            end
            else if (state == `BUSY)
            begin
                selectReg <= selectReg;
            end
            else 
            begin
                if (state == `IDLE && select == `TRANSFER) 
                begin
                    selectReg <= select;
                end
                else 
                begin
                    selectReg <= `FREE;
                end
            end
        end
    end
    // Next State Logic
    always_comb
    begin
        case (state)
            `IDLE:
            begin
                if (busy) 
                begin
                    select = `TRANSFER;
                    nstate = `IDLE;
                end
                else 
                begin
                    if (ARVALID)
                    begin
                        select = `READ;
                        nstate = `BUSY;
                    end
                    else if (AWVALID)
                    begin
                        select = `WRITE;
                        nstate = `BUSY;
                    end
                    else 
                    begin
                        select = `FREE;
                        nstate = `IDLE;
                    end
                end
            end
            `BUSY:
            begin
                if (selectReg == `READ) 
                begin
                    select = selectReg;
                    if (finishRead)
                    begin
                        nstate = `IDLE;
                    end
                    else 
                    begin
                        nstate = `BUSY;
                    end
                end
                else if (selectReg == `WRITE) 
                begin
                    select = selectReg;
                    if (finishWrite)
                    begin
                        nstate = `IDLE;
                    end
                    else 
                    begin
                        nstate = `BUSY;
                    end
                end
                else if (selectReg == `TRANSFER) 
                begin
                    select = selectReg;
                    nstate = `IDLE;
                end
                else 
                begin
                    select = `FREE;
                    nstate = `IDLE;
                end
            end 
            // default: 
            // begin
            //     select = `FREE;
            //     nstate = `IDLE;
            // end
        endcase
    end
    // Combination Output Logic
    always_comb 
    begin
        if (select == `FREE)
        begin
            Address = 32'd0;
            ReadEnable = `FALSE;
            DataWrite = `AXI_DATA_BITS'd0;
            WriteEnable = 8'b11111111;
        end
        else if (select == `READ)
        begin
            Address = addressRead;
            ReadEnable = readEnable;
            DataWrite = `AXI_DATA_BITS'd0;
            WriteEnable = 8'b11111111;
        end
        else if (select == `WRITE)
        begin
            Address = addressWrite;
            ReadEnable = `FALSE;
            DataWrite = writeData;
            WriteEnable = writeEnable;
        end
        else if (select == `TRANSFER) 
        begin
            Address = 32'd0;
            ReadEnable = `FALSE;
            DataWrite = `AXI_DATA_BITS'd0;
            WriteEnable = 8'b11111111;
        end
        else 
        begin
            Address = 32'd0;
            ReadEnable = `FALSE;
            DataWrite = `AXI_DATA_BITS'd0;
            WriteEnable = 8'b11111111;
        end
    end
endmodule