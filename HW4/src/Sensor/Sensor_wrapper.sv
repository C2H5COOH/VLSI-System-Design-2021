`ifndef AXI_SLAVE
`define AXI_SLAVE
`include "AXI/AXI_slave/AXISlave.sv"
`endif
`include "Sensor/sensor_ctrl.sv"

module Sensor_wrapper (
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
    // Sensor
    // Sensor inputs
    input sensor_ready,
    input [31:0] sensor_out,
    // Sensor outputs
    output sensor_en,
    // Core outputs
    output sctrl_interrupt
);
    // Register
    logic [9:0] AddressReg;
    logic       EnableReg;
    // Wire
    // AXI Slave
    logic [13:0] Address;
    logic ReadEnable;
    logic [`AXI_DATA_BITS-1:0] DataRead;
    logic [3:0] WriteEnable;
    logic [`AXI_DATA_BITS-1:0] DataWrite;
    // Sensor
    logic sctrl_en;
    logic sctrl_clear;
    logic [5:0] sctrl_addr;
    logic [31:0] sctrl_out;
    
    // Module
    AXISlave axiSlave
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
        // Slave
        .Address(Address),
        .ReadEnable(ReadEnable),// William
        .DataRead(DataRead),
        .WriteEnable(WriteEnable),
        .DataWrite(DataWrite)
    );
    sensor_ctrl controller
    (
        .clk(clock),
        .rst(~reset),
        // Core inputs
        .sctrl_en(sctrl_en),
        .sctrl_clear(sctrl_clear),
        .sctrl_addr(sctrl_addr),
        // Sensor inputs
        .sensor_ready(sensor_ready),
        .sensor_out(sensor_out),
        // Core outputs
        .sctrl_interrupt(sctrl_interrupt),
        .sctrl_out(sctrl_out),
        // Sensor outputs
        .sensor_en(sensor_en)
    );

    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset) 
        begin
            AddressReg <= 10'd0;
            EnableReg <= `FALSE;
        end
        else 
        begin
            AddressReg <= Address[9:0];
            // Enable Sensor
            if ((~&WriteEnable) && (Address[7:0] == 8'h40)) 
            begin
                EnableReg <= DataWrite[0];
            end
            else 
            begin
                EnableReg <= EnableReg;    
            end
        end
    end

    always_comb 
    begin
        if (ReadEnable) 
        begin
            // Read Signal
            sctrl_addr = AddressReg[5:0];
            DataRead = sctrl_out;
            // Write Signal
            sctrl_en = EnableReg;
            sctrl_clear = `FALSE;
        end
        else if (~&WriteEnable) 
        begin
            // Read Signal
            sctrl_addr = 6'd0;
            DataRead = 32'd0;
            // Write Signal
            if (Address[7:0] == 8'h40)
            begin
                sctrl_en = DataWrite[0];
                sctrl_clear = `FALSE;
            end
            else if (Address[7:0] == 8'h80)
            begin
                sctrl_en = EnableReg;
                sctrl_clear = DataWrite[0];
            end
            else 
            begin
                sctrl_en = EnableReg;
                sctrl_clear = `FALSE;
            end
        end 
        else
        begin
            // Read Signal
            sctrl_addr = 6'd0;
            DataRead = 32'd0;
            // Write Signal
            sctrl_en = EnableReg;
            sctrl_clear = `FALSE;
        end
    end
endmodule