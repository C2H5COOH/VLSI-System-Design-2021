`include "CPU_def.svh"

module WB (
    input               clk,
    input               rst,
    input [2:0]         WBSel,
    input [4:0]         rdIdxFromMEM,
    input [31:0]        PC_4,
    input [31:0]        aluResult,
    input [31:0]        memReadData,
    input [31:0]        csr_fromMEM,
    input [1:0]         MEMLength,
    output logic [31:0] WBData,
    output logic [31:0] lastWBData,
    output logic [4:0]  rdIdxToID
);
logic [31:0]    memSignedResult, memUnsignedResult;
always_comb begin
    case (WBSel)
        `WBSelALU:
            WBData = aluResult;
        `WBSelPC:
            WBData = PC_4;
        `WBSelMemSigned:
            WBData = memSignedResult;
        `WBSelMemUnsigned:
            WBData = memUnsignedResult;
        `WBSelCSR:
            WBData = csr_fromMEM;
        default:
            WBData = aluResult;
    endcase
    rdIdxToID = rdIdxFromMEM;
end
always_comb begin
    case (MEMLength)
        `MEMByte: begin
            case (aluResult[1:0])
                2'd0: begin
                    memSignedResult = {{24{memReadData[7]}}, memReadData[7:0]};
                end
                2'd1: begin
                    memSignedResult = {{24{memReadData[15]}}, memReadData[15:8]};
                end
                2'd2: begin
                    memSignedResult = {{24{memReadData[23]}}, memReadData[23:16]};
                end
                2'd3: begin
                    memSignedResult = {{24{memReadData[31]}}, memReadData[31:24]};
                end
            endcase
        end
        `MEMHalf: begin
            case (aluResult[1:0])
                2'd0: begin
                    memSignedResult = {{16{memReadData[15]}}, memReadData[15:0]};
                end
                2'd1: begin
                    memSignedResult = {{16{memReadData[23]}}, memReadData[23:8]};
                end
                default: begin
                    memSignedResult = {{16{memReadData[31]}}, memReadData[31:16]};
                end
            endcase
        end
        `MEMWord:
            memSignedResult = memReadData;
        default:
            memSignedResult = 0;
    endcase
end
always_comb begin
    case (MEMLength)
        `MEMByte: begin
            case (aluResult[1:0])
                2'd0: begin
                    memUnsignedResult = {24'h0, memReadData[7:0]};
                end
                2'd1: begin
                    memUnsignedResult = {24'h0, memReadData[15:8]};
                end
                2'd2: begin
                    memUnsignedResult = {24'h0, memReadData[23:16]};
                end
                2'd3: begin
                    memUnsignedResult = {24'h0, memReadData[31:24]};
                end
            endcase
        end
        `MEMHalf: begin
            case (aluResult[1:0])
                2'd0: begin
                    memUnsignedResult = {16'h0, memReadData[15:0]};
                end
                2'd1: begin
                    memUnsignedResult = {16'h0, memReadData[23:8]};
                end
                2'd2: begin
                    memUnsignedResult = {16'h0, memReadData[31:16]};
                end
                2'd3: begin
                    memUnsignedResult = {16'h0, memReadData[15:0]};
                end
            endcase
        end
        `MEMWord:
            memUnsignedResult = memReadData;
        default:
            memUnsignedResult = 0;
    endcase
end
always_ff @(posedge clk) begin
    if (rst) begin
        lastWBData <= 32'd0;
    end
    else begin
        lastWBData <= WBData;
    end
end
endmodule