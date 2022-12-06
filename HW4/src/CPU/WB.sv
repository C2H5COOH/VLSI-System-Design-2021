`include "../../include/Control.svh"

module WB (
    input               clk,rst,

    input               MemRead,
    input               RegWrite,

    input [2:0]         DataWidth,
    input [4:0]         rd,
    input [31:0]        aluResult,
    //input [31:0]        adderResult,
    input [31:0]        memData,

    output [4:0]        ID_writeRegister,
    output              ID_RegWrite,
    output logic [31:0] ID_writeData,

    output logic [4:0]  RFile_rd,
    output logic        RFile_RegWrite,
    output logic [31:0] RFile_writeData
);

logic [31:0] loadData;
always_comb begin
    if( (DataWidth == `BYTE_WIDTH) || (DataWidth == `BYTEU_WIDTH) )begin
        case(aluResult[1:0])
            2'd0 : loadData[7:0] = memData[7:0];
            2'd1 : loadData[7:0] = memData[15:8];
            2'd2 : loadData[7:0] = memData[23:16];
            2'd3 : loadData[7:0] = memData[31:24];
        endcase
        loadData[31:8] = ( DataWidth == `BYTE_WIDTH )? { 24{loadData[7]} } : 24'h0;
    end
    else if((DataWidth == `HALF_WIDTH) || (DataWidth == `HALFU_WIDTH))begin
        case(aluResult[1:0])
            2'd0 : loadData[15:0] = memData[15:0];
            2'd1 : loadData[15:0] = memData[23:8];
            2'd2 : loadData[15:0] = memData[31:16];
            default : loadData[15:0] = 16'd0;
        endcase
        loadData[31:16] = ( DataWidth == `HALF_WIDTH )? { 16{loadData[15]} } : 16'h0;         
    end
    else if (DataWidth == `WORD_WIDTH)begin
        loadData = memData;
    end
    else loadData = 32'd0;
end

always_comb begin
    case(MemRead)
        1'b1 : ID_writeData = loadData;
        //`ADDER      : ID_writeData = adderResult;
        default : ID_writeData = aluResult;
        //default     : ID_writeData = 32'd0;
    endcase
end

assign ID_RegWrite = RegWrite;
assign ID_writeRegister = rd;

always_ff @(posedge clk) begin
    if(rst)begin
        RFile_rd        <= 5'b0;
        RFile_RegWrite  <= 1'b0;
        RFile_writeData <= 32'b0;
    end
    else begin
        RFile_rd        <= ID_writeRegister;
        RFile_RegWrite  <= ID_RegWrite;
        RFile_writeData <= ID_writeData;
    end
end
    
endmodule
