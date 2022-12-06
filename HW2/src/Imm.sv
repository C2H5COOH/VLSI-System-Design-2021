`include "../include/Control.svh"

module Imm (
    input [2:0]             immOp,
    input [31:0]            inst,
    output logic [31:0]     immOut
);

always_comb begin
    case(immOp) 
        `IMM_I_TYPE : begin //I
            immOut = { { 20{inst[31]} }, inst[31:20] };
        end

        `IMM_S_TYPE : begin //S
            immOut = { { 20{inst[31]} }, inst[31:25], inst[11:7] };
        end

        `IMM_B_TYPE : begin //B
            immOut = { { 19{inst[31]} }, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
        end

        `IMM_U_TYPE : begin //U
            immOut = { inst[31:12], 12'd0};
        end

        `IMM_J_TYPE : begin //J
            immOut = { { 11{inst[31]} }, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
        end

        default : immOut = 32'd0;
    endcase
end
    
endmodule
