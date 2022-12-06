// `include "../../../include/AXI_define.svh"
`include "../include/AXI_define.svh"

module WriteArbiter(
    input clock,
	input reset,
    // Master Write Signal
    // input AWVALID_M0,
    // input [`AXI_ADDR_BITS-1:0] AWADDR_M0,
    input AWVALID_M1,
    input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
    // Signal to AXI & Siganl to Decoder
    output logic AWVALID,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR,
    output logic [`AXI_ID_BITS-1:0] MasterID,
    // Decoder to Arbiter
    input AWREADY,
    input finish,
    // Bridge Selection
    output logic [1:0] WriteAddressSel,
    output logic [1:0] WriteDataSel,
    output logic [1:0] WriteResponseSel
);
    // Register
    logic state;
    logic nstate;
    // logic precedence;
    logic [`AXI_ADDR_BITS-1:0] AWADDRRegister;
    logic [`AXI_ID_BITS-1:0]   MasterIDRegister;
    logic [1:0]                WriteAddressRegister;
    logic [1:0]                WriteDataRegister;
    logic [1:0]                WriteResponseRegister;
    // Wire
    logic                      AWVALIDMUX;
    logic [`AXI_ADDR_BITS-1:0] AWADDRMUX;
    logic [`AXI_ID_BITS-1:0]   MasterIDMUX;
    logic [1:0]                WriteAddressMUX;
    logic [1:0]                WriteDataMUX;
    logic [1:0]                WriteResponseMUX;
    
    // State Register 
    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            state <= `IDLE;
            AWADDRRegister <= 32'd0;
            MasterIDRegister <= 4'd0;
            WriteAddressRegister <= 2'd0;
            WriteDataRegister <= 2'd0;
            WriteResponseRegister <= 2'd0;
        end
        else
        begin
            state <= nstate;
            // Output Register
            AWADDRRegister <= AWADDRMUX;
            MasterIDRegister <= MasterIDMUX;
            WriteAddressRegister <= WriteAddressMUX;
            WriteDataRegister <= WriteDataMUX;
            WriteResponseRegister <= WriteResponseMUX;
        end
    end
    // Next State Logic
    always_comb
    begin
        case (state)
            `IDLE:
            begin
                if (AWREADY) 
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
            if (AWVALID_M1)
            begin
                AWVALIDMUX = AWVALID_M1;
                AWADDRMUX = AWADDR_M1;
                MasterIDMUX = {3'b0, `M1};
                WriteAddressMUX = `M1MUX;
                WriteDataMUX = `M1MUX;
                WriteResponseMUX = `M1MUX;
            end
            else 
            begin
                AWVALIDMUX = 1'd0;
                AWADDRMUX = 32'd0;
                MasterIDMUX = 4'b1111;
                WriteAddressMUX = `DEFAULTMMUX;
                WriteDataMUX = `DEFAULTMMUX;
                WriteResponseMUX = `DEFAULTMMUX;
            end
        end
        else if (state == `BUSY) 
        begin
            AWVALIDMUX = AWVALID_M1;
            AWADDRMUX = AWADDRRegister;
            MasterIDMUX = MasterIDRegister;
            WriteAddressMUX = WriteAddressRegister;
            WriteDataMUX = WriteDataRegister;
            WriteResponseMUX = WriteResponseRegister;
        end
        else 
        begin
            AWVALIDMUX = 1'd0;
            AWADDRMUX = 32'd0;
            MasterIDMUX = 4'b1111;
            WriteAddressMUX = `DEFAULTMMUX;
            WriteDataMUX = `DEFAULTMMUX;
            WriteResponseMUX = `DEFAULTMMUX;
        end        
        AWVALID = AWVALIDMUX;
        AWADDR = AWADDRMUX;
        MasterID = MasterIDMUX;
        WriteAddressSel = WriteAddressMUX;
        WriteDataSel = WriteDataMUX;
        WriteResponseSel = WriteResponseMUX;
    end
endmodule