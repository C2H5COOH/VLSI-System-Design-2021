`include "CPU_def.svh"

module Stall_ctrl (
    input [4:0]     rdIdxFromEX,
    input [4:0]     IDrs1Idx,
    input [4:0]     IDrs2Idx,
    input [2:0]     WBSelFromEX,
    input           branchTaken,
    input           m0Stall,
    input           m1Stall,
    input           wfi_stall,
    output logic    stallPC,
    output logic    clearID,
    output logic    stallIF,
    output logic    Global_Stall
);
logic loadUse;

always_comb begin
    // loadUse = (((rdIdxFromEX == IDrs1Idx || rdIdxFromEX == IDrs2Idx) && 
    //             WBSelFromEX[`WBSelMemBit]) && |rdIdxFromEX);
    // clearID = loadUse | branchTaken;
    stallPC = m0Stall || wfi_stall;
    stallIF = m1Stall || wfi_stall;
    clearID = branchTaken | m0Stall || wfi_stall;
    Global_Stall = m1Stall || wfi_stall;
end
endmodule
