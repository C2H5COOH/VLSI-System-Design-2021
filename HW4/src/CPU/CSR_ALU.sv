`include "../../include/Control.svh"
module CSR_ALU(
    input [31:0] csr, rs1,
    input [1:0] op,
    output logic [31:0] csr_result
);

always_comb begin
    case(op)
        `CSR_ASIGN : result = rs1;
        `CSR_OR : result = csr | rs1;
        `CSR_AND : result = csr & rs1;
        `CSR_NOP = result = 32'hzzzz_zzzz;
    endcase
end
    
endmodule