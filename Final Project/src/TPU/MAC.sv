`include "TPU_def.svh"
module MAC(
    input                           clk,
    input                           reset,
    input signed [`MAC_OUT_BIT-1:0] W_OFM_In,
    input signed [`MAC_IN_BIT-1:0]  IFM_In,
    input                           IsW,
    output logic [`MAC_IN_BIT-1:0]  IFM_Out,
    output logic [`MAC_OUT_BIT-1:0] W_OFM_Out
);
/* Weight register */
logic signed [`IFM_PER_BYTE_BIT-1:0]  weightReg;
/* Output of multiplier and adder*/
logic signed [`MAC_OUT_BIT-1:0] multOut;
logic signed [`MAC_OUT_BIT:0]   adderOut;

always_ff @(posedge clk) begin
    if (reset) begin
        IFM_Out <= `MAC_IN_BIT'd0;
        W_OFM_Out <= `MAC_OUT_BIT'd0;
        weightReg <= `IFM_PER_BYTE_BIT'd0;
    end
    else begin
        if (IsW) begin
            weightReg <= W_OFM_In[`IFM_PER_BYTE_BIT-1:0];
            W_OFM_Out <= W_OFM_In;
        end
        else begin
            unique case (adderOut[`MAC_OUT_BIT:`MAC_OUT_BIT-1])
            2'b00:
                W_OFM_Out <= adderOut[`MAC_OUT_BIT-1:0];
            2'b11:
                W_OFM_Out <= adderOut[`MAC_OUT_BIT-1:0];
            2'b01:
                W_OFM_Out <= `MAC_MAX;
            2'b10:
                W_OFM_Out <= `MAC_MIN;
            endcase
        end
        IFM_Out <= IFM_In;
    end
end

/* Multiplier sign bit */
always_comb begin
    multOut = weightReg * IFM_In;
    adderOut = {multOut[`MAC_OUT_BIT-1], multOut} + {W_OFM_In[`MAC_OUT_BIT-1], W_OFM_In};
end
endmodule