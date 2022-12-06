`include "CPU_def.svh"

module MEM (
    input               clk,
    input               rst,
    input               stall,
    input [31:0]        PC_4FromEX,
    input [31:0]        aluResultFromEX,
    input [31:0]        rs2,
    input               LDSTSel,
    input [1:0]         MEMLengthFromEX,
    input [2:0]         WBSelFromEX,
    input [4:0]         rdIdxFromEX,
    input [31:0]        memDataFromSRAM,
    input [31:0]        csr_FromEX,
    input               instValidFromEX,
    output logic [31:0] memAddr,
    output logic [31:0] memDataToSRAM,
    output logic [3:0]  data_strobe,
    output logic        data_req,
    output logic        data_write,
    output logic [2:0]  data_type,
    output logic [1:0]  MEMLengthToWB,
    output logic [31:0] memResultToWB,
    output logic [31:0] aluResultToWB,
    output logic [31:0] PC_4ToWB,    
    output logic [2:0]  WBSelToWB,
    output logic [4:0]  rdIdxToWB,
    output logic        instValidToCSR,
    output logic [31:0] csr_toWB
);

assign data_req         = (MEMLengthFromEX != `NoMEM);
assign data_write       = LDSTSel;
assign data_type        = {1'b0, MEMLengthFromEX};

logic [3:0] byteMask;
/* byte mask and memory write data */
always_comb begin
    case (MEMLengthFromEX)
        `MEMByte: begin
            case (aluResultFromEX[1:0])
                2'd0: begin
                    byteMask = 4'b1110;
                    memDataToSRAM = {24'h0, rs2[7:0]};
                end
                2'd1: begin
                    byteMask = 4'b1101;
                    memDataToSRAM = {16'h0, rs2[7:0], 8'h0};
                end
                2'd2: begin
                    byteMask = 4'b1011;
                    memDataToSRAM = {8'h0, rs2[7:0], 16'h0};
                end
                2'd3: begin
                    byteMask = 4'b0111;
                    memDataToSRAM = {rs2[7:0], 24'h0};
                end
            endcase
        end
        `MEMHalf: begin
            case (aluResultFromEX[1:0])
                2'd0: begin
                    byteMask = 4'b1100;
                    memDataToSRAM = {16'h0, rs2[15:0]};
                end
                2'd1: begin
                    byteMask = 4'b1001;
                    memDataToSRAM = {8'h0, rs2[15:0], 8'h0};
                end
                2'd2: begin
                    byteMask = 4'b0011;
                    memDataToSRAM = {rs2[15:0], 16'h0};
                end
                default: begin
                    byteMask = 4'b1100;
                    memDataToSRAM = {16'h0, rs2[15:0]};
                end
            endcase
            
        end
        `MEMWord: begin
            byteMask = 4'b0000;
            memDataToSRAM = rs2;
        end
        default: begin
            byteMask = 4'b1111;
            memDataToSRAM = rs2;
        end
    endcase
end

/* address, write enable, read enable*/
always_comb begin
    memAddr = aluResultFromEX;
    if (LDSTSel == `MemRefST) begin
        data_strobe = byteMask;
    end
    else begin
        data_strobe = 4'b1111;
    end
end

/* read length */
always_ff @(posedge clk) begin
    if (rst) begin
        MEMLengthToWB <= 2'd0;
    end
    else if (!stall) begin
        MEMLengthToWB <= MEMLengthFromEX;
    end
end

/* alu result */
always_ff @(posedge clk) begin
    if (rst) begin
        aluResultToWB <= 32'd0;
        PC_4ToWB <= 32'd0;
    end
    else if (!stall) begin
        aluResultToWB <= aluResultFromEX;
        PC_4ToWB <= PC_4FromEX;
    end
end

/* write back select */
always_ff @(posedge clk) begin
    if (rst) begin
        WBSelToWB <= 3'd0;
        rdIdxToWB <= 5'd0;
        csr_toWB <= 32'd0;
    end
    else if (!stall) begin
        WBSelToWB <= WBSelFromEX;
        rdIdxToWB <= rdIdxFromEX;
        csr_toWB <= csr_FromEX;
    end
    // else begin
    //     WBSelToWB <= 2'd0;
    //     rdIdxToWB <= 5'd0;
    // end
end
/* bypassing memory read data */
always_comb begin
    memResultToWB = memDataFromSRAM;
end

/* Valid Inst */
always_ff @(posedge clk) begin
    if (rst) begin
        instValidToCSR <= 1'b0;
    end
    else if (!stall) begin
        instValidToCSR <= instValidFromEX;
    end
end
endmodule
