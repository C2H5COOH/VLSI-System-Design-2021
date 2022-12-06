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

    output logic        MemRead_reg,
    output logic        RegWrite_reg,
    output logic [2:0]  DataWidth_reg,
    output logic [4:0]  rd_reg,
    
    output logic [31:0] aluResult_reg,
    output logic [31:0] data_read_reg,

    output              DM_read,
    input  [31:0]       DM_data_read,
    output logic [3:0]  DM_write_en,
    output logic [31:0] DM_data_write,
    output [31:0]       DM_addr,

    input               AXI_MEM_stall
);

//write enable
//logic [3:0] DM_write_en;
always_comb begin
    if(MemWrite == 1'b1)begin

        case(DataWidth)
            `BYTE_WIDTH,`BYTEU_WIDTH : begin
                case(aluResult[1:0])
                    2'd0 : DM_write_en = 4'b1110;
                    2'd1 : DM_write_en = 4'b1101;
                    2'd2 : DM_write_en = 4'b1011;
                    2'd3 : DM_write_en = 4'b0111;
                endcase
            end

            `HALF_WIDTH,`HALFU_WIDTH : begin
                case(aluResult[1:0])
                    2'd0 :     DM_write_en = 4'b1100;
                    2'd1 :     DM_write_en = 4'b1001;
                    2'd2 :     DM_write_en = 4'b0011;
                    default:   DM_write_en = 4'b1111;
                endcase
            end

            `WORD_WIDTH : begin
                DM_write_en = 4'b0000;
            end

            default: DM_write_en = 4'b1111;
        endcase

    end
    else DM_write_en = 4'b1111;
end

//store data
always_comb begin

    case(DataWidth)    
        `BYTE_WIDTH : begin
            case(aluResult[1:0])
                2'd0: DM_data_write = { 24'b0, readData2[7:0] };
                2'd1: DM_data_write = { 16'b0, readData2[7:0], 8'b0 };
                2'd2: DM_data_write = { 8'b0, readData2[7:0], 16'b0 };
                2'd3: DM_data_write = { readData2[7:0], 24'b0 }; 
            endcase                     
        end

        `HALF_WIDTH : begin
            case(aluResult[1:0])
                2'd0:      DM_data_write = { 16'b0, readData2[15:0] };
                2'd1:      DM_data_write = { 8'b0,  readData2[15:0], 8'b0 };
                2'd2:      DM_data_write = { readData2[15:0], 16'b0 };
                default:   DM_data_write = 32'b0;
            endcase
        end

        `WORD_WIDTH : begin
            DM_data_write = readData2;
        end        

        default : DM_data_write = 32'd0;

    endcase

end

assign DM_addr = aluResult;
assign DM_read = MemRead;

always_ff @(posedge clk) begin
    if(rst || AXI_MEM_stall)begin
        MemRead_reg         <= 1'b0;
        RegWrite_reg        <= 1'b0;
        rd_reg              <= 5'd0;
        DataWidth_reg       <= 3'd0;

        aluResult_reg       <= 32'd0;
        data_read_reg       <= 32'd0;
    end
    else begin
        MemRead_reg         <= MemRead;
        RegWrite_reg        <= RegWrite;
        rd_reg              <= rd;
        DataWidth_reg       <= DataWidth;

        aluResult_reg       <= aluResult;
        data_read_reg       <= DM_data_read;
    end
end
    
endmodule
