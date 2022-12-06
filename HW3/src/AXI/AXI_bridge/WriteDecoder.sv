// `include "../../../include/AXI_define.svh"
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
    // input AWREADY_S0,
    input AWREADY_S1,
    input AWREADY_S2,
    // input AWREADY_S3,
    input AWREADY_S4,
    input BVALID,
    // Bridge Selection
    output logic [2:0] WriteAddressSel,
    output logic [2:0] WriteDataSel,
    output logic [2:0] WriteResponseSel
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
                // 0x0000_0000 ~ 0x0000_1FFF (ROM)
                // if (~|(AWADDR[31:13])) 
                // begin
                //     AWREADYWire = AWREADY_S0;
                // end
                // 0x0001_0000 ~ 0x0001_FFFF (IM SRAM)
                if ((~|(AWADDR[31:17])) & AWADDR[16])
                begin
                    AWREADYWire = AWREADY_S1;
                end
                // 0x0002_0000 ~ 0x0002_FFFF (DM SRAM)
                else if ((~|(AWADDR[31:18])) & AWADDR[17])
                begin
                    AWREADYWire = AWREADY_S2;
                end
                // 0x1000_0000 ~ 0x1000_03FF (Sensor)
                // else if ((~|(AWADDR[31:29])) & AWADDR[28] & (~|(AWADDR[27:10])))
                // begin
                //     AWREADYWire = AWREADY_S3;
                // end
                // 0x2000_0000 ~ 0x201F_FFFF (DRAM)
                else if ((~|(AWADDR[31:30])) & AWADDR[29] & (~|(AWADDR[28:21])))
                begin
                    AWREADYWire = AWREADY_S4;
                end
                // Other
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

            // 0x0000_0000 ~ 0x0000_1FFF (ROM)
            // if (~|(AWADDR[31:13])) 
            // begin
            //     WriteAddressSel = `S0MUX;
            //     WriteDataSel = `S0MUX;
            //     WriteResponseSel = `S0MUX;
            // end
            // 0x0001_0000 ~ 0x0001_FFFF (IM SRAM)
            if ((~|(AWADDR[31:17])) & AWADDR[16])
            begin
                WriteAddressSel = `S1MUX;
                WriteDataSel = `S1MUX;
                WriteResponseSel = `S1MUX;
            end
            // 0x0002_0000 ~ 0x0002_FFFF (DM SRAM)
            else if ((~|(AWADDR[31:18])) & AWADDR[17])
            begin
                WriteAddressSel = `S2MUX;
                WriteDataSel = `S2MUX;
                WriteResponseSel = `S2MUX;
            end
            // 0x1000_0000 ~ 0x1000_03FF (Sensor)
            // else if ((~|(AWADDR[31:29])) & AWADDR[28] & (~|(AWADDR[27:10])))
            // begin
            //     WriteAddressSel = `S3MUX;
            //     WriteDataSel = `S3MUX;
            //     WriteResponseSel = `S3MUX;
            // end
            // 0x2000_0000 ~ 0x201F_FFFF (DRAM)
            else if ((~|(AWADDR[31:30])) & AWADDR[29] & (~|(AWADDR[28:21])))
            begin
                WriteAddressSel = `S4MUX;
                WriteDataSel = `S4MUX;
                WriteResponseSel = `S4MUX;
            end
            // Other
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