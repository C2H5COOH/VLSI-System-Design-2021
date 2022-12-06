// `include "../../include/AXI_define.svh"
`include "../include/AXI_define.svh"

module ReadDecoder(
    input clock,
	input reset,
    // Arbiter to Decoder
    input ARVALID,
    input [`AXI_ADDR_BITS-1:0] ARADDR,
    // Decoder to Arbiter
    output logic ARREADY,
    output logic finish,
    // Master Signal
    input RREADY,
    // Slave Signal
    input ARREADY_S0,
    input ARREADY_S1,
    input RVALID,
    input RLAST,
    // Bridge Selection
    output logic [1:0] ReadAddressSel,
    output logic [1:0] ReadDataSel
);
    // Register
    logic state;
    logic nstate;
    // Wire
    logic ARREADYWire;

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
                if (ARREADYWire) 
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
                if (RREADY && RVALID && RLAST)
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
            if (ARVALID)
            begin
                // 0x0000 ~ 0xFFFF
                if (~|(ARADDR[31:16])) 
                begin
                    ARREADYWire = ARREADY_S0;
                end
                // 0x0001_0000 ~ 0x0001_FFFF
                else if ((~|(ARADDR[31:17])) & ARADDR[16])
                begin
                    ARREADYWire = ARREADY_S1;
                end
                // 0x0002_0000 ~ ?
                else 
                begin
                    ARREADYWire = 1'b1;
                end
            end
            else 
            begin
                ARREADYWire = 1'd0;
            end
            ReadAddressSel = `DEFAULTSMUX;
            ReadDataSel = `DEFAULTSMUX;
        end
        else if (state == `BUSY)
        begin
            ARREADYWire = 1'd0;

            // 0x0000 ~ 0xFFFF
            if (~|(ARADDR[31:16])) 
            begin
                ReadAddressSel = `S0MUX;
                ReadDataSel = `S0MUX;
            end
            // 0x0001_0000 ~ 0x0001_FFFF
            else if ((~|(ARADDR[31:17])) & ARADDR[16])
            begin
                ReadAddressSel = `S1MUX;
                ReadDataSel = `S1MUX;
            end
            // 0x0002_0000 ~ ?
            else 
            begin
                ReadAddressSel = `WRONGADDRESS;
                ReadDataSel = `WRONGADDRESS;
            end
        end
        else
        begin
            ARREADYWire = 1'd0;
            
            ReadAddressSel = `DEFAULTSMUX;
            ReadDataSel = `DEFAULTSMUX;
        end
        ARREADY = ARREADYWire;
    end
endmodule