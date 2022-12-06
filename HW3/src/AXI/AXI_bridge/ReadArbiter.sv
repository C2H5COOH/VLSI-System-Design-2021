// `include "../../../include/AXI_define.svh"
`include "../include/AXI_define.svh"

module ReadArbiter(
    input clock,
	input reset,
    // Master Read Signal
    input ARVALID_M0,
    input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
    input ARVALID_M1,
    input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
    // Signal to AXI & Siganl to Decoder
    output logic ARVALID,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR,
    output logic [`AXI_ID_BITS-1:0] MasterID,
    // Decoder to Arbiter
    input ARREADY,
    input finish,
    // Bridge Selection
    output logic [1:0] ReadAddressSel,
    output logic [1:0] ReadDataSel
);
    // Register
    logic state;
    logic nstate;
    logic precedence;
    logic [`AXI_ADDR_BITS-1:0] ARADDRRegister;
    logic [`AXI_ID_BITS-1:0]   MasterIDRegister;
    logic [1:0]                ReadAddressRegister;
    logic [1:0]                ReadDataRegister;
    // Wire
    logic                      ARVALIDMUX;
    logic [`AXI_ADDR_BITS-1:0] ARADDRMUX;
    logic [`AXI_ID_BITS-1:0]   MasterIDMUX;
    logic [1:0]                ReadAddressMUX;
    logic [1:0]                ReadDataMUX;
    
    // State Register
    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            state <= `IDLE;
            precedence <= `M0;
            ARADDRRegister <= 32'd0;
            MasterIDRegister <= 4'd0;
            ReadAddressRegister <= 2'd0;
            ReadDataRegister <= 2'd0;
        end
        else
        begin
            state <= nstate;
            // Precedence
            if (nstate == `IDLE)
            begin
                if (precedence == `M0)
                begin
                    precedence <= `M1;
                end
                else 
                begin
                    precedence <= `M0;
                end
            end
            else 
            begin
                precedence <= precedence;
            end
            // Output Register
            ARADDRRegister <= ARADDRMUX;
            MasterIDRegister <= MasterIDMUX;
            ReadAddressRegister <= ReadAddressMUX;
            ReadDataRegister <= ReadDataMUX;
        end
    end
    // Next State Logic
    always_comb
    begin
        case (state)
            `IDLE:
            begin
                if (ARREADY)
                begin
                    nstate = `BUSY;
                end
                else 
                begin
                    nstate = `IDLE;
                end
            end
            `BUSY:
            begin
                if (finish)
                begin
                    nstate = `IDLE;
                end
                else 
                begin
                    nstate = `BUSY;
                end
            end    
            default: 
            begin
                nstate = `IDLE;
            end
        endcase
    end
    // Combination Output Logic
    always_comb 
    begin
        if (state == `IDLE) 
        begin
            if (ARVALID_M0 && ARVALID_M1)
            begin
                if (precedence == `M0) 
                begin
                    ARVALIDMUX = ARVALID_M0;
                    ARADDRMUX = ARADDR_M0;
                    MasterIDMUX = {3'b0, `M0};
                    ReadAddressMUX = `M0MUX;
                    ReadDataMUX = `M0MUX;
                end
                else if (precedence == `M1)
                begin
                    ARVALIDMUX = ARVALID_M1;
                    ARADDRMUX = ARADDR_M1;
                    MasterIDMUX = {3'b0, `M1};
                    ReadAddressMUX = `M1MUX;
                    ReadDataMUX = `M1MUX;
                end
                else
                begin
                    ARVALIDMUX = 1'd0;
                    ARADDRMUX = 32'd0;
                    MasterIDMUX = 4'b1111;
                    ReadAddressMUX = `DEFAULTMMUX;
                    ReadDataMUX = `DEFAULTMMUX;
                end
            end
            else if (ARVALID_M0)
            begin
                ARVALIDMUX = ARVALID_M0;
                ARADDRMUX = ARADDR_M0;
                MasterIDMUX = {3'b0, `M0};
                ReadAddressMUX = `M0MUX;
                ReadDataMUX = `M0MUX;
            end
            else if (ARVALID_M1)
            begin
                ARVALIDMUX = ARVALID_M1;
                ARADDRMUX = ARADDR_M1;
                MasterIDMUX = {3'b0, `M1};
                ReadAddressMUX = `M1MUX;
                ReadDataMUX = `M1MUX;
            end
            else 
            begin
                ARVALIDMUX = 1'd0;
                ARADDRMUX = 32'd0;
                MasterIDMUX = 4'b1111;
                ReadAddressMUX = `DEFAULTMMUX;
                ReadDataMUX = `DEFAULTMMUX;
            end
        end
        else if (state == `BUSY) 
        begin
            // Hard wire ARVALID to Master
            if (ReadAddressMUX == `M0MUX)
            begin
                ARVALIDMUX = ARVALID_M0;
            end
            else 
            begin
                ARVALIDMUX = ARVALID_M1;
            end
            ARADDRMUX = ARADDRRegister;
            MasterIDMUX = MasterIDRegister;
            ReadAddressMUX = ReadAddressRegister;
            ReadDataMUX = ReadDataRegister;
        end
        else 
        begin
            ARVALIDMUX = 1'd0;
            ARADDRMUX = 32'd0;
            MasterIDMUX = 4'b1111;
            ReadAddressMUX = `DEFAULTMMUX;
            ReadDataMUX = `DEFAULTMMUX;
        end
        ARVALID = ARVALIDMUX;
        ARADDR = ARADDRMUX;
        MasterID = MasterIDMUX;
        ReadAddressSel = ReadAddressMUX;
        ReadDataSel = ReadDataMUX;
    end
endmodule