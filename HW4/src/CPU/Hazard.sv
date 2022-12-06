module Hazard (
    input [4:0]     rs1,rs2,EXE_rd,
    input           EXE_MemRead,
    output logic    stall,
    output          IDClear
);

always_comb begin
    if(EXE_MemRead == 1'b1) begin
        if( (EXE_rd == rs1) || (EXE_rd == rs2) ) begin
            stall = 1'b1;
        end
        else stall = 1'b0;
    end
    else stall = 1'b0;
end

assign IDClear = stall;
    
endmodule