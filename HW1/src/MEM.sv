`include "../include/Control.svh"
module MEM (
    input               clk,rst,

    input               MemRead,MemWrite, 
    input               RegWrite,
    //input [1:0]         rdSrc, 
    input [2:0]         DataWidth,
    input [4:0]         rd,
    input [31:0]        readData2, aluResult, 
    //adderResult,

    //output logic [1:0]  rdSrc_reg,
    output logic        MemRead_reg,
    output logic        RegWrite_reg,
    output logic [2:0]  DataWidth_reg,
    output logic [4:0]  rd_reg,
    output logic [31:0] aluResult_reg,
    //output logic [31:0] adderResult_reg,

    //output [4:0]        EXE_rd,
    //output              EXE_RegWrite,

    output logic [3:0]  DM_writeEn,
    output logic [31:0] DM_storeData,
    output [13:0]       DM_memAddr
);

//write enable
//logic [3:0] DM_writeEn;
always_comb begin
    if(MemWrite == 1'b1)begin

        case(DataWidth)
            `BYTE_WIDTH,`BYTEU_WIDTH : begin
                case(aluResult[1:0])
                    2'd0 : DM_writeEn = 4'b1110;
                    2'd1 : DM_writeEn = 4'b1101;
                    2'd2 : DM_writeEn = 4'b1011;
                    2'd3 : DM_writeEn = 4'b0111;
                endcase
            end

            `HALF_WIDTH,`HALFU_WIDTH : begin
                case(aluResult[1:0])
                    2'd0 :     DM_writeEn = 4'b1100;
                    2'd1 :     DM_writeEn = 4'b1001;
                    2'd2 :     DM_writeEn = 4'b0011;
                    default:   DM_writeEn = 4'b1111;
                endcase
            end

            `WORD_WIDTH : begin
                DM_writeEn = 4'b0000;
            end

            default: DM_writeEn = 4'b1111;
        endcase

    end
    else DM_writeEn = 4'b1111;
end

//store data
always_comb begin

    case(DataWidth)    
        `BYTE_WIDTH : begin
            case(aluResult[1:0])
                2'd0: DM_storeData = { 24'b0, readData2[7:0] };
                2'd1: DM_storeData = { 16'b0, readData2[7:0], 8'b0 };
                2'd2: DM_storeData = { 8'b0, readData2[7:0], 16'b0 };
                2'd3: DM_storeData = { readData2[7:0], 24'b0 }; 
            endcase                     
        end

        `HALF_WIDTH : begin
            case(aluResult[1:0])
                2'd0:      DM_storeData = { 16'b0, readData2[15:0] };
                2'd1:      DM_storeData = { 8'b0,  readData2[15:0], 8'b0 };
                2'd2:      DM_storeData = { readData2[15:0], 16'b0 };
                default:   DM_storeData = 32'b0;
            endcase
        end

        `WORD_WIDTH : begin
            DM_storeData = readData2;
        end        

        default : DM_storeData = 32'd0;

    endcase

end

//logic [13:0] DM_memAddr;
//assign DM_memAddr = aluResult >> 2;
assign DM_memAddr = aluResult[15:2];

/*SRAM_wrapper DM1(
    .CK(clk),
    .CS(1'b1),
    .OE(1'b1),
    .WEB(DM_writeEn),
    .A(DM_memAddr),
    .DI(DM_storeData),
    .DO(memData)
);*/

//assign EXE_RegWrite = RegWrite;
//assign EXE_rd       = rd;

always_ff @(posedge clk) begin
    if(rst)begin
        MemRead_reg         <= 1'b0;
        RegWrite_reg        <= 1'b0;
        rd_reg              <= 5'd0;
        aluResult_reg       <= 32'd0;
        DataWidth_reg       <= 3'd0;
    end
    else begin
        MemRead_reg         <= MemRead;
        RegWrite_reg        <= RegWrite;
        rd_reg              <= rd;
        aluResult_reg       <= aluResult;
        DataWidth_reg       <= DataWidth;
    end
end
    
endmodule
