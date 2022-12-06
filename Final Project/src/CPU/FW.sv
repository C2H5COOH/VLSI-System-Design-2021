`include "CPU_def.svh"

module FW (
    input               clk,
    input               rst, 
    input [4:0]         IDrs1Idx,
    input [4:0]         IDrs2Idx,
    input [4:0]         EXrdIdx,
    input [4:0]         MEMrdIdx,
    input [4:0]         WBrdIdx,
    input               clear,
    input               stall,
    output logic [1:0]  rs1Fw,
    output logic [1:0]  rs2Fw  
);
always_ff @(posedge clk) begin
    if (rst || clear) begin
        rs1Fw <= `EXFromID;
    end
    else begin
        if (EXrdIdx > 5'd0 && IDrs1Idx == EXrdIdx) begin
            rs1Fw <= `EXFwFromEX;
        end
        else if (MEMrdIdx > 5'd0 && IDrs1Idx == MEMrdIdx) begin
            rs1Fw <= `EXFwFromMEM;
        end
        else if (WBrdIdx > 5'd0 && IDrs1Idx == WBrdIdx) begin
            rs1Fw <= `EXFwFromWB;
        end
        else begin
            rs1Fw <= `EXFromID;
        end
    end
end
always_ff @(posedge clk) begin
    if (rst || clear) begin
        rs2Fw <= `EXFromID;
    end
    else begin
        if (EXrdIdx > 5'd0 && IDrs2Idx == EXrdIdx) begin
            rs2Fw <= `EXFwFromEX;
        end
        else if (MEMrdIdx > 5'd0 && IDrs2Idx == MEMrdIdx) begin
            rs2Fw <= `EXFwFromMEM;
        end
        else if (WBrdIdx > 5'd0 && IDrs2Idx == WBrdIdx) begin
            rs2Fw <= `EXFwFromWB;
        end
        else begin
            rs2Fw <= `EXFromID;
        end
    end
end
endmodule