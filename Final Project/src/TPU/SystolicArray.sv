`include "TPU_def.svh"
`include "MAC.sv"
module systolic_arr(
    input                           clk,
    input                           rst,
    input                           isW,
    input   [`MAC_IN_BIT-1:0]       IFM_FromSRAM[0:`SYS_HEIGHT-1],
    input   [`IFM_PER_BYTE_BIT-1:0] W_FromSRAM[0:`SYS_WIDTH-1],
    output  [`MAC_OUT_BIT-1:0]      OFM_ToSRAM[0:`SYS_WIDTH-1]
);
logic [`MAC_IN_BIT-1:0]     IFM_ToMAC   [0:`SYS_HEIGHT-1][0:`SYS_WIDTH];
logic [`MAC_OUT_BIT-1:0]    OFM_ToMAC [0:`SYS_HEIGHT][0:`SYS_WIDTH-1];

genvar idxW0, idxH0;
generate
    for (idxW0=0; idxW0<`SYS_WIDTH; idxW0=idxW0+1) begin
        for (idxH0=0; idxH0<`SYS_HEIGHT; idxH0=idxH0+1) begin
            MAC mac(
                .clk(clk),
                .reset(rst),
                .W_OFM_In(OFM_ToMAC[idxH0][idxW0]),
                .IFM_In(IFM_ToMAC[idxH0][idxW0]),
                .IsW(isW),
                .IFM_Out(IFM_ToMAC[idxH0][idxW0+1]),
                .W_OFM_Out(OFM_ToMAC[idxH0+1][idxW0])
            );
        end
    end
endgenerate

genvar idxH1;
generate
    for (idxH1=0; idxH1 < `SYS_HEIGHT; idxH1=idxH1+1) begin
        assign IFM_ToMAC[idxH1][0] = IFM_FromSRAM[idxH1];
    end
endgenerate

genvar idxW1;
generate
    for (idxW1=0; idxW1 < `SYS_WIDTH; idxW1=idxW1+1) begin
        assign OFM_ToMAC[0][idxW1] = {16'd0, W_FromSRAM[idxW1]};
        assign OFM_ToSRAM[idxW1] = OFM_ToMAC[`SYS_HEIGHT][idxW1];
    end
endgenerate
endmodule