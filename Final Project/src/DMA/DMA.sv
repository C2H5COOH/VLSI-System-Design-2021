`include "AXI_def.svh"

module DMA (
    input clock,
	input reset,
    // AXI Slave
    input [`AXI_ADDR_BITS-1:0]        addressSlave,
    input                             readEnable,
    output logic [`AXI_DATA_BITS-1:0] dataReadSlave,
    input [`AXI_STRB_BITS-1:0]        writeEnableSlave,
    input [`AXI_DATA_BITS-1:0]        dataWriteSlave,
    output logic                      busy,
    // AXI Master Read
    output logic                      addressReadyRead,
    output logic [`AXI_ADDR_BITS-1:0] addressMasterRead,
    output logic [`AXI_LEN_BITS-1:0]  lengthRead,
    input                             arFinish,
    output logic                      nextRead,
    input                             lastRead,
    input                             rFinish,
    input [`AXI_DATA_BITS-1:0]        dataReadMaster,
    // AXI Master Write
    output logic                      addressReadyWrite,
    output logic [`AXI_ADDR_BITS-1:0] addressMasterWrite, 
    output logic [`AXI_LEN_BITS-1:0]  lengthWrite,
    input                             awFinish,
    output logic                      nextWrite,
    output logic                      lastWrite,
    output logic [`AXI_STRB_BITS-1:0] writeEnableMaster,
    output logic [`AXI_DATA_BITS-1:0] dataWriteMaster,
    input                             wFinish,
    // Interrupt
    output logic interrupt
);
    // Register
    logic [3:0] state;
    logic [3:0] nstate;
    logic [`AXI_DATA_BITS - 1:0] sourceDC;
    logic [`AXI_DATA_BITS - 1:0] sourceC;
    logic [`AXI_DATA_BITS - 1:0] targetDC;
    logic [`AXI_DATA_BITS - 1:0] targetC;
    logic [1:0]                  mode;
    logic [`AXI_DATA_BITS - 1:0] times;
    logic [`AXI_DATA_BITS - 1:0] stride;
    logic [`AXI_DATA_BITS - 1:0] length;
    logic [`AXI_DATA_BITS - 1:0] remain; 
    logic [`AXI_LEN_BITS - 1:0]  burst;
    logic [`AXI_DATA_BITS - 1:0] data;
    logic                        last;
    logic arFinish_reg;
    logic awFinish_reg;
    logic rFinish_reg;
    logic wFinish_reg;
    logic firstRead;
    logic                        first;
    logic [`AXI_STRB_BITS - 1:0] lastEnable;
    logic finish;
    // Wire
    logic [`AXI_DATA_BITS - 1:0] realLength;
    logic [`AXI_DATA_BITS - 1:0] sourceStride;
    logic [`AXI_DATA_BITS - 1:0] targetStride;

    // State Register
    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            state <= `DMA_WAIT_SOURCE;
            sourceDC <= 64'd0;
            sourceC <= 64'd0;
            targetDC <= 64'd0;
            targetC <= 64'd0;
            mode <= 2'd0;
            times <= 64'd0;
            stride <= 64'd0;
            length <= 64'd0;
            remain <= 64'd0;
            burst <= 4'd0;
            data <= 64'd0;
            last <= `FALSE;
            arFinish_reg <= `FALSE;
            awFinish_reg <= `FALSE;
            rFinish_reg <= `FALSE;
            wFinish_reg <= `FALSE;
            firstRead <= `FALSE;
            first <= `FALSE;
            lastEnable <= 8'd0;
            finish <= `FALSE;
        end
        else 
        begin
            state <= nstate;
            if ((state == `DMA_WAIT_CLEAR) && (addressSlave[10:0] == 11'h000) && (~&writeEnableSlave)) 
            begin
                sourceDC <= 64'd0;
                sourceC <= 64'd0;
                targetDC <= 64'd0;
                targetC <= 64'd0;
                mode <= 2'd0;
                times <= 64'd0;
                stride <= 64'd0;
                length <= 64'd0;
                remain <= 64'd0;
                burst <= 4'd0;
                data <= 64'd0;
                last <= `FALSE;
                arFinish_reg <= `FALSE;
                awFinish_reg <= `FALSE;
                rFinish_reg <= `FALSE;
                wFinish_reg <= `FALSE;
                firstRead <= `FALSE;
                first <= `FALSE;
                lastEnable <= 8'd0;
                finish <= `FALSE;
            end
            else if ((state == `DMA_WAIT_SOURCE) && (addressSlave[10:0] == 11'h100) && (~&writeEnableSlave)) 
            begin
                sourceDC <= dataWriteSlave;
            end
            else if ((state == `DMA_WAIT_TARGET) && (addressSlave[10:0] == 11'h200) && (~&writeEnableSlave)) 
            begin
                targetDC <= dataWriteSlave;
            end
            else if ((state == `DMA_WAIT_MODE) && (addressSlave[10:0] == 11'h300) && (~&writeEnableSlave)) 
            begin
                mode <= dataWriteSlave[1:0];
            end
            else if ((state == `DMA_WAIT_TIMES) && (addressSlave[10:0] == 11'h400) && (~&writeEnableSlave)) 
            begin
                times <= dataWriteSlave;
            end
            else if ((state == `DMA_WAIT_STRIDE) && (addressSlave[10:0] == 11'h500) && (~&writeEnableSlave)) 
            begin
                stride <= dataWriteSlave;
            end
            else if ((state == `DMA_WAIT_LENGTH) && (addressSlave[10:0] == 11'h600) && (~&writeEnableSlave)) 
            begin
                length <= dataWriteSlave;
                if (realLength > 64'd8) 
                begin
                    if (realLength > (64'd2 ** (`AXI_LEN_BITS + 3))) 
                    begin
                        remain <= realLength - (64'd2 ** (`AXI_LEN_BITS + 3));
                        burst <= 4'b1111;
                        // burst <= (64'd2 ** `AXI_LEN_BITS) - 64'd1;
                        // Last Write Enable for continuous burst
                        lastEnable <= 8'd0;
                    end
                    else 
                    begin
                        remain <= 64'd0;
                        burst <= (realLength >> 3) - {63'd0, ~|(realLength[2:0])};
                        // Last Write Enable for one burst
                        case (realLength[2:0])
                            3'b000:
                            begin
                                lastEnable <= `AXI_STRB_DWORD;
                            end
                            3'b001:
                            begin
                                lastEnable <= 8'b00000001;
                            end
                            3'b010:
                            begin
                                lastEnable <= 8'b00000011;
                            end
                            3'b011:
                            begin
                                lastEnable <= 8'b00000111;
                            end
                            3'b100:
                            begin
                                lastEnable <= 8'b00001111;
                            end
                            3'b101:
                            begin
                                lastEnable <= 8'b00011111;
                            end
                            3'b110:
                            begin
                                lastEnable <= 8'b00111111;
                            end
                            3'b111:
                            begin
                                lastEnable <= 8'b01111111;
                            end
                            // default:
                            // begin
                            //     lastEnable <= 8'b00000000;
                            // end
                        endcase
                    end
                end
                else 
                begin
                    remain <= 64'd0;
                    burst <= 4'd0;
                    // Last Write Enable for some bytes
                    if (dataWriteSlave[3:0] == 4'd8) 
                    begin
                        lastEnable <= `AXI_STRB_DWORD;
                    end
                    else 
                    begin
                        // Start Address
                        case(sourceDC[2:0])
                            3'b000:
                            begin
                                // Length
                                case(dataWriteSlave[2:0])
                                    3'b001:
                                    begin
                                        lastEnable <= 8'b00000001;
                                    end
                                    3'b010:
                                    begin
                                        lastEnable <= 8'b00000011;
                                    end
                                    3'b011:
                                    begin
                                        lastEnable <= 8'b00000111;
                                    end
                                    3'b100:
                                    begin
                                        lastEnable <= 8'b00001111;
                                    end
                                    3'b101:
                                    begin
                                        lastEnable <= 8'b00011111;
                                    end
                                    3'b110:
                                    begin
                                        lastEnable <= 8'b00111111;
                                    end
                                    3'b111:
                                    begin
                                        lastEnable <= 8'b01111111;
                                    end
                                    // default:
                                    // begin
                                    //     lastEnable <= 8'b00000000;
                                    // end
                                endcase
                            end
                            3'b001:
                            begin
                                // Length
                                case(dataWriteSlave[2:0])
                                    3'b001:
                                    begin
                                        lastEnable <= 8'b00000010;
                                    end
                                    3'b010:
                                    begin
                                        lastEnable <= 8'b00000110;
                                    end
                                    3'b011:
                                    begin
                                        lastEnable <= 8'b00001110;
                                    end
                                    3'b100:
                                    begin
                                        lastEnable <= 8'b00011110;
                                    end
                                    3'b101:
                                    begin
                                        lastEnable <= 8'b00111110;
                                    end
                                    3'b110:
                                    begin
                                        lastEnable <= 8'b01111110;
                                    end
                                    3'b111:
                                    begin
                                        lastEnable <= 8'b11111110;
                                    end
                                    default:
                                    begin
                                        lastEnable <= 8'b00000000;
                                    end
                                endcase
                            end
                            3'b010:
                            begin
                                // Length
                                case(dataWriteSlave[2:0])
                                    3'b001:
                                    begin
                                        lastEnable <= 8'b00000100;
                                    end
                                    3'b010:
                                    begin
                                        lastEnable <= 8'b00001100;
                                    end
                                    3'b011:
                                    begin
                                        lastEnable <= 8'b00011100;
                                    end
                                    3'b100:
                                    begin
                                        lastEnable <= 8'b00111100;
                                    end
                                    3'b101:
                                    begin
                                        lastEnable <= 8'b01111100;
                                    end
                                    3'b110:
                                    begin
                                        lastEnable <= 8'b11111100;
                                    end
                                    default:
                                    begin
                                        lastEnable <= 8'b00000000;
                                    end
                                endcase
                            end
                            3'b011:
                            begin
                                // Length
                                case(dataWriteSlave[2:0])
                                    3'b001:
                                    begin
                                        lastEnable <= 8'b00001000;
                                    end
                                    3'b010:
                                    begin
                                        lastEnable <= 8'b00011000;
                                    end
                                    3'b011:
                                    begin
                                        lastEnable <= 8'b00111000;
                                    end
                                    3'b100:
                                    begin
                                        lastEnable <= 8'b01111000;
                                    end
                                    3'b101:
                                    begin
                                        lastEnable <= 8'b11111000;
                                    end
                                    default:
                                    begin
                                        lastEnable <= 8'b00000000;
                                    end
                                endcase
                            end
                            3'b100:
                            begin
                                // Length
                                case(dataWriteSlave[2:0])
                                    3'b001:
                                    begin
                                        lastEnable <= 8'b00010000;
                                    end
                                    3'b010:
                                    begin
                                        lastEnable <= 8'b00110000;
                                    end
                                    3'b011:
                                    begin
                                        lastEnable <= 8'b01110000;
                                    end
                                    3'b100:
                                    begin
                                        lastEnable <= 8'b11110000;
                                    end
                                    default:
                                    begin
                                        lastEnable <= 8'b00000000;
                                    end
                                endcase
                            end
                            3'b101:
                            begin
                                // Length
                                case(dataWriteSlave[2:0])
                                    3'b001:
                                    begin
                                        lastEnable <= 8'b00100000;
                                    end
                                    3'b010:
                                    begin
                                        lastEnable <= 8'b01100000;
                                    end
                                    3'b011:
                                    begin
                                        lastEnable <= 8'b11100000;
                                    end
                                    default:
                                    begin
                                        lastEnable <= 8'b00000000;
                                    end
                                endcase
                            end
                            3'b110:
                            begin
                                // Length
                                case(dataWriteSlave[2:0])
                                    3'b001:
                                    begin
                                        lastEnable <= 8'b01000000;
                                    end
                                    3'b010:
                                    begin
                                        lastEnable <= 8'b11000000;
                                    end
                                    default:
                                    begin
                                        lastEnable <= 8'b00000000;
                                    end
                                endcase
                            end
                            3'b111:
                            begin
                                // Length
                                case(dataWriteSlave[2:0])
                                    3'b001:
                                    begin
                                        lastEnable <= 8'b10000000;
                                    end
                                    default:
                                    begin
                                        lastEnable <= 8'b00000000;
                                    end
                                endcase
                            end
                            // default:
                            // begin
                            //     lastEnable <= 8'b00000000;
                            // end
                        endcase
                    end
                end
                // Times
                times <= times - 64'b1;
                sourceC <= {sourceDC[63:3], 3'd0};
                targetC <= {targetDC[63:3], 3'd0};
                first <= `TRUE;
            end
            else if (state == `DMA_CONNECT) 
            begin
                // AR Channel
                if (arFinish) 
                begin
                    arFinish_reg <= `TRUE;
                end
                else
                begin
                    arFinish_reg <= arFinish_reg;
                end
                // AW Channel
                if (awFinish)
                begin
                    awFinish_reg <= `TRUE;
                end
                else 
                begin
                    awFinish_reg <= awFinish_reg;
                end
            end
            else if (state == `DMA_FIRST_READ) 
            begin
                if (rFinish && nextRead) 
                begin
                    data <= dataReadMaster;
                    last <= lastRead;
                    finish <= `TRUE;
                    firstRead <= `TRUE;
                end
                else 
                begin
                    data <= data;
                    last <= last;
                    finish <= finish;
                    firstRead <= firstRead;
                end
            end
            else if (state == `DMA_READ_WRITE) 
            begin
                // Read
                if (rFinish && nextRead) 
                begin
                    data <= dataReadMaster;
                    last <= lastRead;
                    if (!wFinish)
                    begin
                        rFinish_reg <= `TRUE;
                    end
                    else
                    begin
                        rFinish_reg <= rFinish_reg;
                    end
                end
                else
                begin
                    data <= data;
                    last <= last;
                    if (rFinish_reg && wFinish) 
                    begin
                        rFinish_reg <= `FALSE;
                    end
                    else
                    begin
                        rFinish_reg <= rFinish_reg;
                    end
                end
                // Write
                if (wFinish && !rFinish && !rFinish_reg)
                begin
                    wFinish_reg <= `TRUE;
                end
                else if(wFinish_reg && rFinish)
                begin
                    wFinish_reg <= `FALSE;
                end
                else
                begin
                    rFinish_reg <= rFinish_reg;
                end
                // First Read
                if (firstRead)
                begin
                    firstRead <= `FALSE;
                end
                else 
                begin
                    firstRead <= firstRead;
                end
                // First Write of continuous address
                if (first) 
                begin
                    first <= `FALSE;
                end
                else 
                begin
                    first <= first;    
                end
                // Finish Write Judge
                if (finish && nextWrite && !wFinish) 
                begin
                    finish <= `FALSE;
                end
                else if (!finish && rFinish && wFinish)
                begin
                    finish <= `TRUE;
                end
                else
                begin
                    finish <= finish;
                end
            end
            else if (state == `DMA_LAST_WRITE) 
            begin
                if (nstate == `DMA_WAIT_CLEAR) 
                begin
                    sourceDC <= 64'd0;
                    sourceC <= 64'd0;
                    targetDC <= 64'd0;
                    targetC <= 64'd0;
                    mode <= 2'd0;
                    times <= 64'd0;
                    stride <= 64'd0;
                    length <= 64'd0;
                    remain <= 64'd0;
                    burst <= 4'd0;
                    data <= 64'd0;
                    last <= `FALSE;
                    arFinish_reg <= `FALSE;
                    awFinish_reg <= `FALSE;
                    rFinish_reg <= `FALSE;
                    wFinish_reg <= `FALSE;
                    firstRead <= `FALSE;
                    first <= `FALSE;
                    lastEnable <= 8'd0;
                    finish <= `FALSE;
                end
                else if (nstate == `DMA_CONNECT) 
                begin
                    // Address Shift
                    case(mode)
                        `S_F_T_F:
                        begin
                            // Source
                            sourceDC <= sourceDC;
                            sourceC <= sourceC;
                            // Target
                            targetDC <= targetDC;
                            targetC <= targetC;
                        end
                        `S_F_T_A:
                        begin
                            // Source
                            sourceDC <= sourceDC;
                            sourceC <= sourceC;
                            // Target 
                            if (remain == 64'd0) 
                            begin
                                targetDC <= targetStride;
                                targetC <= {targetStride[63:3], 3'd0};
                            end
                            else 
                            begin
                                targetDC <= targetDC;
                                targetC <= targetC + (64'd2 ** (`AXI_LEN_BITS + 3));
                            end
                        end
                        `S_A_T_F:
                        begin
                            // Source
                            if (remain == 64'd0) 
                            begin
                                sourceDC <= sourceStride;
                                sourceC <= {sourceStride[63:3], 3'd0};
                            end
                            else 
                            begin
                                sourceDC <= sourceDC;
                                sourceC <= sourceC + (64'd2 ** (`AXI_LEN_BITS + 3));
                            end
                            // Target
                            targetDC <= targetDC;
                            targetC <= targetC;
                        end
                        `S_A_T_A:
                        begin
                            // Source
                            if (remain == 64'd0) 
                            begin
                                sourceDC <= sourceStride;
                                sourceC <= {sourceStride[63:3], 3'd0};
                            end
                            else 
                            begin
                                sourceDC <= sourceDC;
                                sourceC <= sourceC + (64'd2 ** (`AXI_LEN_BITS + 3));
                            end
                            // Target
                            if (remain == 64'd0) 
                            begin
                                targetDC <= targetStride;
                                targetC <= {targetStride[63:3], 3'd0};
                            end
                            else 
                            begin
                                targetDC <= targetDC;
                                targetC <= targetC + (64'd2 ** (`AXI_LEN_BITS + 3));
                            end
                        end
                        // default:
                        // begin
                        //     // Source
                        //     sourceDC <= sourceDC;
                        //     sourceC <= sourceC;
                        //     // Target
                        //     targetDC <= targetDC;
                        //     targetC <= targetC;
                        // end
                    endcase
                    // Mode
                    mode <= mode;
                    // Times
                    if (remain == 64'd0) 
                    begin
                        times <= times - 64'd1;
                    end
                    else 
                    begin
                        times <= times;
                    end
                    // Stride
                    stride <= stride;
                    // Length
                    length <= length;
                    // Remain & Burst & Last Enable
                    if (remain == 64'd0)
                    begin
                        if (realLength > 64'd8) 
                        begin
                            if (realLength > (64'd2 ** (`AXI_LEN_BITS + 3))) 
                            begin
                                remain <= realLength - (64'd2 ** (`AXI_LEN_BITS + 3));
                                burst <= 4'b1111;
                                // burst <= (64'd2 ** `AXI_LEN_BITS) - 64'd1;
                                // Last Write Enable for continuous burst
                                lastEnable <= 8'd0;
                            end
                            else 
                            begin
                                remain <= 64'd0;
                                burst <= (realLength >> 3) - {63'd0, ~|(realLength[2:0])};
                                // Last Write Enable for one burst
                                case (realLength[2:0])
                                    3'b000:
                                    begin
                                        lastEnable <= `AXI_STRB_DWORD;
                                    end
                                    3'b001:
                                    begin
                                        lastEnable <= 8'b00000001;
                                    end
                                    3'b010:
                                    begin
                                        lastEnable <= 8'b00000011;
                                    end
                                    3'b011:
                                    begin
                                        lastEnable <= 8'b00000111;
                                    end
                                    3'b100:
                                    begin
                                        lastEnable <= 8'b00001111;
                                    end
                                    3'b101:
                                    begin
                                        lastEnable <= 8'b00011111;
                                    end
                                    3'b110:
                                    begin
                                        lastEnable <= 8'b00111111;
                                    end
                                    3'b111:
                                    begin
                                        lastEnable <= 8'b01111111;
                                    end
                                    // default:
                                    // begin
                                    //     lastEnable <= 8'b00000000;
                                    // end
                                endcase
                            end
                        end
                        else 
                        begin
                            remain <= 64'd0;
                            burst <= 4'd0;
                            // Last Write Enable for some bytes
                            if (length[3:0] == 4'd8) 
                            begin
                                lastEnable <= `AXI_STRB_DWORD;
                            end
                            else 
                            begin
                                // Start Address
                                case(sourceStride[2:0])
                                    3'b000:
                                    begin
                                        // Length
                                        case(length[2:0])
                                            3'b001:
                                            begin
                                                lastEnable <= 8'b00000001;
                                            end
                                            3'b010:
                                            begin
                                                lastEnable <= 8'b00000011;
                                            end
                                            3'b011:
                                            begin
                                                lastEnable <= 8'b00000111;
                                            end
                                            3'b100:
                                            begin
                                                lastEnable <= 8'b00001111;
                                            end
                                            3'b101:
                                            begin
                                                lastEnable <= 8'b00011111;
                                            end
                                            3'b110:
                                            begin
                                                lastEnable <= 8'b00111111;
                                            end
                                            3'b111:
                                            begin
                                                lastEnable <= 8'b01111111;
                                            end
                                            default:
                                            begin
                                                lastEnable <= 8'b00000000;
                                            end
                                        endcase
                                    end
                                    3'b001:
                                    begin
                                        // Length
                                        case(length[2:0])
                                            3'b001:
                                            begin
                                                lastEnable <= 8'b00000010;
                                            end
                                            3'b010:
                                            begin
                                                lastEnable <= 8'b00000110;
                                            end
                                            3'b011:
                                            begin
                                                lastEnable <= 8'b00001110;
                                            end
                                            3'b100:
                                            begin
                                                lastEnable <= 8'b00011110;
                                            end
                                            3'b101:
                                            begin
                                                lastEnable <= 8'b00111110;
                                            end
                                            3'b110:
                                            begin
                                                lastEnable <= 8'b01111110;
                                            end
                                            3'b111:
                                            begin
                                                lastEnable <= 8'b11111110;
                                            end
                                            default:
                                            begin
                                                lastEnable <= 8'b00000000;
                                            end
                                        endcase
                                    end
                                    3'b010:
                                    begin
                                        // Length
                                        case(length[2:0])
                                            3'b001:
                                            begin
                                                lastEnable <= 8'b00000100;
                                            end
                                            3'b010:
                                            begin
                                                lastEnable <= 8'b00001100;
                                            end
                                            3'b011:
                                            begin
                                                lastEnable <= 8'b00011100;
                                            end
                                            3'b100:
                                            begin
                                                lastEnable <= 8'b00111100;
                                            end
                                            3'b101:
                                            begin
                                                lastEnable <= 8'b01111100;
                                            end
                                            3'b110:
                                            begin
                                                lastEnable <= 8'b11111100;
                                            end
                                            default:
                                            begin
                                                lastEnable <= 8'b00000000;
                                            end
                                        endcase
                                    end
                                    3'b011:
                                    begin
                                        // Length
                                        case(length[2:0])
                                            3'b001:
                                            begin
                                                lastEnable <= 8'b00001000;
                                            end
                                            3'b010:
                                            begin
                                                lastEnable <= 8'b00011000;
                                            end
                                            3'b011:
                                            begin
                                                lastEnable <= 8'b00111000;
                                            end
                                            3'b100:
                                            begin
                                                lastEnable <= 8'b01111000;
                                            end
                                            3'b101:
                                            begin
                                                lastEnable <= 8'b11111000;
                                            end
                                            default:
                                            begin
                                                lastEnable <= 8'b00000000;
                                            end
                                        endcase
                                    end
                                    3'b100:
                                    begin
                                        // Length
                                        case(length[2:0])
                                            3'b001:
                                            begin
                                                lastEnable <= 8'b00010000;
                                            end
                                            3'b010:
                                            begin
                                                lastEnable <= 8'b00110000;
                                            end
                                            3'b011:
                                            begin
                                                lastEnable <= 8'b01110000;
                                            end
                                            3'b100:
                                            begin
                                                lastEnable <= 8'b11110000;
                                            end
                                            default:
                                            begin
                                                lastEnable <= 8'b00000000;
                                            end
                                        endcase
                                    end
                                    3'b101:
                                    begin
                                        // Length
                                        case(length[2:0])
                                            3'b001:
                                            begin
                                                lastEnable <= 8'b00100000;
                                            end
                                            3'b010:
                                            begin
                                                lastEnable <= 8'b01100000;
                                            end
                                            3'b011:
                                            begin
                                                lastEnable <= 8'b11100000;
                                            end
                                            default:
                                            begin
                                                lastEnable <= 8'b00000000;
                                            end
                                        endcase
                                    end
                                    3'b110:
                                    begin
                                        // Length
                                        case(length[2:0])
                                            3'b001:
                                            begin
                                                lastEnable <= 8'b01000000;
                                            end
                                            3'b010:
                                            begin
                                                lastEnable <= 8'b11000000;
                                            end
                                            default:
                                            begin
                                                lastEnable <= 8'b00000000;
                                            end
                                        endcase
                                    end
                                    3'b111:
                                    begin
                                        // Length
                                        case(length[2:0])
                                            3'b001:
                                            begin
                                                lastEnable <= 8'b10000000;
                                            end
                                            default:
                                            begin
                                                lastEnable <= 8'b00000000;
                                            end
                                        endcase
                                    end
                                    // default:
                                    // begin
                                    //     lastEnable <= 8'b00000000;
                                    // end
                                endcase
                            end
                        end
                    end
                    else
                    begin
                        if (remain > (64'd2 ** (`AXI_LEN_BITS + 3))) 
                        begin
                            remain <= remain - (64'd2 ** (`AXI_LEN_BITS + 3));
                            burst <= 4'b1111;
                            // burst <= (64'd2 ** `AXI_LEN_BITS) - 64'd1;
                            // Last Write Enable for continuous burst
                            lastEnable <= 8'd0;
                        end
                        else 
                        begin
                            remain <= 64'd0;
                            burst <= (remain >> 3) - {63'd0, ~|(remain[2:0])};
                            // Last Write Enable for one burst
                            case (remain[2:0])
                                3'b000:
                                begin
                                    lastEnable <= `AXI_STRB_DWORD;
                                end
                                3'b001:
                                begin
                                    lastEnable <= 8'b00000001;
                                end
                                3'b010:
                                begin
                                    lastEnable <= 8'b00000011;
                                end
                                3'b011:
                                begin
                                    lastEnable <= 8'b00000111;
                                end
                                3'b100:
                                begin
                                    lastEnable <= 8'b00001111;
                                end
                                3'b101:
                                begin
                                    lastEnable <= 8'b00011111;
                                end
                                3'b110:
                                begin
                                    lastEnable <= 8'b00111111;
                                end
                                3'b111:
                                begin
                                    lastEnable <= 8'b01111111;
                                end
                                // default:
                                // begin
                                //     lastEnable <= 8'b00000000;
                                // end
                            endcase
                        end
                    end
                    // Data
                    data <= 64'd0;
                    last <= `FALSE;
                    arFinish_reg <= `FALSE;
                    awFinish_reg <= `FALSE;
                    firstRead <= `FALSE;
                    rFinish_reg <= `FALSE;
                    wFinish_reg <= `FALSE;
                    // First
                    if (remain == 64'd0) 
                    begin
                        first <= `TRUE;
                    end
                    else
                    begin
                        first <= first;
                    end
                    // Finish
                    if (remain == 64'd0) 
                    begin
                        finish <= `FALSE;
                    end
                    else
                    begin
                        finish <= finish;
                    end
                end
                else
                begin
                    sourceDC <= sourceDC;
                    sourceC <= sourceC;
                    targetDC <= targetDC;
                    targetC <= targetC;
                    mode <= mode;
                    times <= times;
                    stride <= stride;
                    length <= length;
                    remain <= remain;
                    burst <= burst;
                    data <= data;
                    last <= last;
                    arFinish_reg <= arFinish_reg;
                    awFinish_reg <= awFinish_reg;
                    firstRead <= `FALSE;
                    rFinish_reg <= `FALSE;
                    wFinish_reg <= `FALSE;
                    first <= first;
                    lastEnable <= lastEnable;
                    finish <= finish;
                end
                // Finish Write Judge
                if (finish && nextWrite && !wFinish) 
                begin
                    finish <= `FALSE;
                end
                else
                begin
                    finish <= finish;
                end
            end
            else 
            begin
                sourceDC <= sourceDC;
                sourceC <= sourceC;
                targetDC <= targetDC;
                targetC <= targetC;
                mode <= mode;
                times <= times;
                stride <= stride;
                length <= length;
                remain <= remain;
                burst <= burst;
                data <= data;
                last <= last;
                arFinish_reg <= arFinish_reg;
                awFinish_reg <= awFinish_reg;
            end
        end
    end
    // Next State Logic & Combination Output Logic
    always_comb
    begin
        case (state)
            `DMA_WAIT_CLEAR:
            begin
                if ((addressSlave[10:0] == 11'h000) && (~&writeEnableSlave) && (|dataWriteSlave)) 
                begin
                    nstate = `DMA_WAIT_SOURCE;
                end
                else 
                begin
                    nstate = `DMA_WAIT_CLEAR;
                end
                // AXI Slave
                dataReadSlave = 64'd0;
                busy = `FALSE;
                // AXI Master Read
                addressReadyRead = `FALSE;
                addressMasterRead = 32'd0;
                lengthRead = 4'd0;
                nextRead = `FALSE;
                // AXI Master Write
                addressReadyWrite = `FALSE;
                addressMasterWrite = 32'd0;
                lengthWrite = 4'd0;
                nextWrite = `FALSE;
                lastWrite = `FALSE;
                writeEnableMaster = 8'b00000000;
                dataWriteMaster = 64'd0;
                // Interrupt
                interrupt = `TRUE;
                // Wire
                realLength = 64'd0;
                sourceStride = 64'd0;
                targetStride = 64'd0;
            end 
            `DMA_WAIT_SOURCE:
            begin
                if ((addressSlave[10:0] == 11'h100) && (~&writeEnableSlave)) 
                begin
                    nstate = `DMA_WAIT_TARGET;
                end
                else 
                begin
                    nstate = `DMA_WAIT_SOURCE;
                end
                // AXI Slave
                dataReadSlave = 64'd0;
                busy = `FALSE;
                // AXI Master Read
                addressReadyRead = `FALSE;
                addressMasterRead = 32'd0;
                lengthRead = 4'd0;
                nextRead = `FALSE;
                // AXI Master Write
                addressReadyWrite = `FALSE;
                addressMasterWrite = 32'd0;
                lengthWrite = 4'd0;
                nextWrite = `FALSE;
                lastWrite = `FALSE;
                writeEnableMaster = 8'b00000000;
                dataWriteMaster = 64'd0;
                // Interrupt
                interrupt = `FALSE;
                // Wire
                realLength = 64'd0;
                sourceStride = 64'd0;
                targetStride = 64'd0;
            end 
            `DMA_WAIT_TARGET:
            begin
                if ((addressSlave[10:0] == 11'h200) && (~&writeEnableSlave)) 
                begin
                    nstate = `DMA_WAIT_MODE;
                end
                else 
                begin
                    nstate = `DMA_WAIT_TARGET;
                end
                // AXI Slave
                dataReadSlave = 64'd0;
                busy = `FALSE;
                // AXI Master Read
                addressReadyRead = `FALSE;
                addressMasterRead = 32'd0;
                lengthRead = 4'd0;
                nextRead = `FALSE;
                // AXI Master Write
                addressReadyWrite = `FALSE;
                addressMasterWrite = 32'd0;
                lengthWrite = 4'd0;
                nextWrite = `FALSE;
                lastWrite = `FALSE;
                writeEnableMaster = 8'b00000000;
                dataWriteMaster = 64'd0;
                // Interrupt
                interrupt = `FALSE;
                // Wire
                realLength = 64'd0;
                sourceStride = 64'd0;
                targetStride = 64'd0;
            end 
            `DMA_WAIT_MODE:
            begin
                if ((addressSlave[10:0] == 11'h300) && (~&writeEnableSlave)) 
                begin
                    nstate = `DMA_WAIT_TIMES;
                end
                else 
                begin
                    nstate = `DMA_WAIT_MODE;
                end
                // AXI Slave
                dataReadSlave = 64'd0;
                busy = `FALSE;
                // AXI Master Read
                addressReadyRead = `FALSE;
                addressMasterRead = 32'd0;
                lengthRead = 4'd0;
                nextRead = `FALSE;
                // AXI Master Write
                addressReadyWrite = `FALSE;
                addressMasterWrite = 32'd0;
                lengthWrite = 4'd0;
                nextWrite = `FALSE;
                lastWrite = `FALSE;
                writeEnableMaster = 8'b00000000;
                dataWriteMaster = 64'd0;
                // Interrupt
                interrupt = `FALSE;
                // Wire
                realLength = 64'd0;
                sourceStride = 64'd0;
                targetStride = 64'd0;
            end
            `DMA_WAIT_TIMES:
            begin
                if ((addressSlave[10:0] == 11'h400) && (~&writeEnableSlave)) 
                begin
                    nstate = `DMA_WAIT_STRIDE;
                end
                else 
                begin
                    nstate = `DMA_WAIT_TIMES;
                end
                // AXI Slave
                dataReadSlave = 64'd0;
                busy = `FALSE;
                // AXI Master Read
                addressReadyRead = `FALSE;
                addressMasterRead = 32'd0;
                lengthRead = 4'd0;
                nextRead = `FALSE;
                // AXI Master Write
                addressReadyWrite = `FALSE;
                addressMasterWrite = 32'd0;
                lengthWrite = 4'd0;
                nextWrite = `FALSE;
                lastWrite = `FALSE;
                writeEnableMaster = 8'b00000000;
                dataWriteMaster = 64'd0;
                // Interrupt
                interrupt = `FALSE;
                // Wire
                realLength = 64'd0;
                sourceStride = 64'd0;
                targetStride = 64'd0;
            end
            `DMA_WAIT_STRIDE:
            begin
                if ((addressSlave[10:0] == 11'h500) && (~&writeEnableSlave)) 
                begin
                    nstate = `DMA_WAIT_LENGTH;
                end
                else 
                begin
                    nstate = `DMA_WAIT_STRIDE;
                end
                // AXI Slave
                dataReadSlave = 64'd0;
                busy = `FALSE;
                // AXI Master Read
                addressReadyRead = `FALSE;
                addressMasterRead = 32'd0;
                lengthRead = 4'd0;
                nextRead = `FALSE;
                // AXI Master Write
                addressReadyWrite = `FALSE;
                addressMasterWrite = 32'd0;
                lengthWrite = 4'd0;
                nextWrite = `FALSE;
                lastWrite = `FALSE;
                writeEnableMaster = 8'b00000000;
                dataWriteMaster = 64'd0;
                // Interrupt
                interrupt = `FALSE;
                // Wire
                realLength = 64'd0;
                sourceStride = 64'd0;
                targetStride = 64'd0;
            end
            `DMA_WAIT_LENGTH:
            begin
                if ((addressSlave[10:0] == 11'h600) && (~&writeEnableSlave)) 
                begin
                    nstate = `DMA_CONNECT;
                end
                else 
                begin
                    nstate = `DMA_WAIT_LENGTH;
                end
                // AXI Slave
                dataReadSlave = 64'd0;
                busy = `FALSE;
                // AXI Master Read
                addressReadyRead = `FALSE;
                addressMasterRead = 32'd0;
                lengthRead = 4'd0;
                nextRead = `FALSE;
                // AXI Master Write
                addressReadyWrite = `FALSE;
                addressMasterWrite = 32'd0;
                lengthWrite = 4'd0;
                nextWrite = `FALSE;
                lastWrite = `FALSE;
                writeEnableMaster = 8'b00000000;
                dataWriteMaster = 64'd0;
                // Interrupt
                interrupt = `FALSE;
                // Real Length of continuous transfer
                realLength = dataWriteSlave + {61'd0, sourceDC[2:0]};
                // Wire
                sourceStride = 64'd0;
                targetStride = 64'd0;
            end
            `DMA_CONNECT: 
            begin
                if ((arFinish || arFinish_reg) && (awFinish || awFinish_reg)) 
                begin
                    nstate = `DMA_FIRST_READ;
                end
                else 
                begin
                    nstate = `DMA_CONNECT;
                end
                // AXI Slave
                dataReadSlave = 64'd0;
                busy = `TRUE;
                // AXI Master Read
                if (!arFinish_reg) 
                begin
                    addressReadyRead = `TRUE;
                    addressMasterRead = sourceC[31:0];
                    lengthRead = burst;
                end
                else 
                begin
                    addressReadyRead = `FALSE;
                    addressMasterRead = 32'd0;
                    lengthRead = 4'd0;
                end
                nextRead = `FALSE;
                // AXI Master Write
                if (!awFinish_reg) 
                begin
                    addressReadyWrite = `TRUE;
                    addressMasterWrite = targetC[31:0];
                    lengthWrite = burst;
                end
                else 
                begin
                    addressReadyWrite = `FALSE;
                    addressMasterWrite = 32'd0;
                    lengthWrite = 4'd0;
                end
                nextWrite = `FALSE;
                lastWrite = `FALSE;
                writeEnableMaster = 8'b00000000;
                dataWriteMaster = 64'd0;
                // Interrupt
                interrupt = `FALSE;
                // Wire
                realLength = 64'd0;
                sourceStride = 64'd0;
                targetStride = 64'd0;
            end
            `DMA_FIRST_READ: 
            begin
                if (rFinish) 
                begin
                    if (lastRead) 
                    begin
                        nstate = `DMA_LAST_WRITE;
                    end
                    else 
                    begin
                        nstate = `DMA_READ_WRITE;    
                    end
                end
                else 
                begin
                    nstate = `DMA_FIRST_READ;
                end
                // AXI Slave
                dataReadSlave = 64'd0;
                busy = `TRUE;                
                // AXI Master Read
                addressReadyRead = `FALSE;
                addressMasterRead = 32'd0;
                lengthRead = 4'd0;
                nextRead = `TRUE;
                // AXI Master Write
                addressReadyWrite = `FALSE;
                addressMasterWrite = 32'd0;
                lengthWrite = 4'd0;
                nextWrite = `FALSE;
                lastWrite = `FALSE;
                writeEnableMaster = 8'b00000000;
                dataWriteMaster = 64'd0;
                // Interrupt
                interrupt = `FALSE;
                // Wire
                realLength = 64'd0;
                sourceStride = 64'd0;
                targetStride = 64'd0;
            end
            `DMA_READ_WRITE: 
            begin
                if (rFinish && lastRead && wFinish) 
                begin
                    nstate = `DMA_LAST_WRITE;
                end
                else 
                begin
                    nstate = `DMA_READ_WRITE;
                end
                // AXI Slave
                dataReadSlave = 64'd0;
                busy = `TRUE;
                // AXI Master Read
                addressReadyRead = `FALSE;
                addressMasterRead = 32'd0;
                lengthRead = 4'd0;
                if (wFinish || wFinish_reg) 
                begin
                    nextRead = `TRUE;
                end
                else 
                begin
                    nextRead = `FALSE;
                end
                // AXI Master Write
                addressReadyWrite = `FALSE;
                addressMasterWrite = 32'd0;
                lengthWrite = 4'd0;
                if (firstRead || (((rFinish || (!rFinish_reg)) && (!wFinish_reg))))
                begin
                    nextWrite = `TRUE;
                    // Address may not be alligned
                    if (first) 
                    begin
                        // Decide Write Enable
                        case(sourceDC[2:0])
                            3'b000:
                            begin
                                writeEnableMaster = `AXI_STRB_DWORD;
                            end
                            3'b001:
                            begin
                                writeEnableMaster = 8'b11111110;
                            end
                            3'b010:
                            begin
                                writeEnableMaster = 8'b11111100;
                            end
                            3'b011:
                            begin
                                writeEnableMaster = 8'b11111000;
                            end
                            3'b100:
                            begin
                                writeEnableMaster = 8'b11110000;
                            end
                            3'b101:
                            begin
                                writeEnableMaster = 8'b11100000;
                            end
                            3'b110:
                            begin
                                writeEnableMaster = 8'b11000000;
                            end
                            3'b111:
                            begin
                                writeEnableMaster = 8'b10000000;
                            end
                            // default:
                            // begin
                            //     writeEnableMaster = 8'b00000000;
                            // end
                        endcase
                    end
                    else 
                    begin
                        writeEnableMaster = `AXI_STRB_DWORD;
                    end
                    dataWriteMaster = data;
                end
                else 
                begin
                    nextWrite = `FALSE;
                    writeEnableMaster = 8'b00000000;
                    dataWriteMaster = 64'd0;
                end
                lastWrite = `FALSE;
                // Interrupt
                interrupt = `FALSE;
                // Wire
                realLength = 64'd0;
                sourceStride = 64'd0;
                targetStride = 64'd0;
            end
            `DMA_LAST_WRITE: 
            begin
                if (wFinish) 
                begin
                    if (times == 64'd0 && remain == 64'd0) 
                    begin
                        nstate = `DMA_WAIT_CLEAR;
                    end
                    else 
                    begin
                        nstate = `DMA_CONNECT;
                    end
                end
                else 
                begin
                    nstate = `DMA_LAST_WRITE;
                end
                // AXI Slave
                dataReadSlave = 64'd0;
                busy = `TRUE;                
                // AXI Master Read
                addressReadyRead = `FALSE;
                addressMasterRead = 32'd0;
                lengthRead = 4'd0;
                nextRead = `FALSE;
                // AXI Master Write
                addressReadyWrite = `FALSE;
                addressMasterWrite = 32'd0;
                lengthWrite = 4'd0;
                if (finish) 
                begin
                    nextWrite = `TRUE;
                    lastWrite = last;
                    if (remain == 64'd0) 
                    begin
                        writeEnableMaster = lastEnable;
                    end
                    else
                    begin
                        writeEnableMaster = `AXI_STRB_DWORD;
                    end
                    dataWriteMaster = data;
                end
                else 
                begin
                    nextWrite = `FALSE;
                    lastWrite = `FALSE;
                    writeEnableMaster = 8'b00000000;
                    dataWriteMaster = 64'd0;
                end
                // Interrupt
                interrupt = `FALSE;
                // Address Stride
                if (remain == 64'd0) 
                begin
                    sourceStride = sourceDC + stride;
                    targetStride = targetDC + stride;
                    realLength = length + {61'd0, sourceStride[2:0]};
                end
                else
                begin
                    sourceStride = 64'd0;
                    targetStride = 64'd0;
                    realLength = 64'd0;
                end
            end
            default: 
            begin
                nstate = `DMA_LAST_WRITE;
                // AXI Slave
                dataReadSlave = 64'd0;
                busy = `FALSE;
                // AXI Master Read
                addressReadyRead = `FALSE;
                addressMasterRead = 32'd0;
                lengthRead = 4'd0;
                nextRead = `FALSE;
                // AXI Master Write
                addressReadyWrite = `FALSE;
                addressMasterWrite = 32'd0;
                lengthWrite = 4'd0;
                nextWrite = `FALSE;
                lastWrite = `FALSE;
                writeEnableMaster = 8'b00000000;
                dataWriteMaster = 64'd0;
                // Interrupt
                interrupt = `FALSE;
                // Wire
                realLength = 64'd0;
                sourceStride = 64'd0;
                targetStride = 64'd0;
            end
        endcase
    end
endmodule