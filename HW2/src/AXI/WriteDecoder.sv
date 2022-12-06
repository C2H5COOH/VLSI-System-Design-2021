// `include "../../include/AXI_define.svh"
`include "../include/AXI_define.svh"

module WriteDecoder(
    input clock,
	input reset,
    // Arbiter to Decoder
    input AWVALID,
    input [`AXI_ADDR_BITS-1:0] AWADDR,
    // Decoder to Arbiter
    output logic AWREADY,
    output logic finish,
    // Master Signal
    input BREADY,
    // Slave Signal
    input AWREADY_S0,
    input AWREADY_S1,
    input BVALID,
    // Bridge Selection
    output logic [1:0] WriteAddressSel,
    output logic [1:0] WriteDataSel,
    output logic [1:0] WriteResponseSel
);
    // Register
    logic state;
    logic nstate;
    // Wire
    logic AWREADYWire;

    // State Register 
    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            state <= `IDLE;
        end 
        else
        begin
            state <= nstate;
        end
    end
    // Next State Logic
    always_comb
    begin
        case (state)
            `IDLE:
            begin
                if (AWREADYWire) 
                begin
                    nstate = `BUSY;
                end
                else 
                begin
                    nstate = `IDLE;
                end
                finish = `FALSE;
            end
            `BUSY:
            begin
                if (BREADY && BVALID)
                begin
                    nstate = `IDLE;
                    finish = `TRUE;
                end
                else 
                begin
                    nstate = `BUSY;
                    finish = `FALSE;
                end
            end    
            default: 
            begin
                nstate = `IDLE;
                finish = `FALSE;
            end
        endcase
    end
    // Combination Output Logic
    always_comb 
    begin
        if (state == `IDLE)
        begin
            if (AWVALID)
            begin
                // 0x0000 ~ 0xFFFF
                if (~|(AWADDR[31:16])) 
                begin
                    AWREADYWire = AWREADY_S0;
                end
                // 0x0001_0000 ~ 0x0001_FFFF
                else if ((~|(AWADDR[31:17])) & AWADDR[16])
                begin
                    AWREADYWire = AWREADY_S1;
                end
                // 0x0002_0000 ~ ?
                else 
                begin
                    AWREADYWire = 1'b1;
                end
            end
            else 
            begin
                AWREADYWire = 1'd0;
            end
            WriteAddressSel = `DEFAULTSMUX;
            WriteDataSel = `DEFAULTSMUX;
            WriteResponseSel = `DEFAULTSMUX;
        end
        else if (state == `BUSY)
        begin
            AWREADYWire = 1'd0;

            // 0x0000 ~ 0xFFFF
            if (~|(AWADDR[31:16])) 
            begin
                WriteAddressSel = `S0MUX;
                WriteDataSel = `S0MUX;
                WriteResponseSel = `S0MUX;
            end
            // 0x0001_0000 ~ 0x0001_FFFF
            else if ((~|(AWADDR[31:17])) & AWADDR[16])
            begin
                WriteAddressSel = `S1MUX;
                WriteDataSel = `S1MUX;
                WriteResponseSel = `S1MUX;
            end
            // 0x0002_0000 ~ ?
            else 
            begin
                WriteAddressSel = `WRONGADDRESS;
                WriteDataSel = `WRONGADDRESS;
                WriteResponseSel = `WRONGADDRESS;
            end
        end
        else
        begin
            AWREADYWire = 1'd0;
            
            WriteAddressSel = `DEFAULTSMUX;
            WriteDataSel = `DEFAULTSMUX;
            WriteResponseSel = `DEFAULTSMUX;
        end
        AWREADY = AWREADYWire;
    end
endmodule