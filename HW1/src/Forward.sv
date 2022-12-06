`include "../include/Control.svh"
module Forward (
    input [4:0]         MEM_Rd, WB_Rd, RFile_Rd, 
    input [4:0]         rs1, rs2,
    input               MEM_RegWrite, WB_RegWrite, RFile_RegWrite,
    //input               aluSrc1,aluSrc2,

    output logic [1:0]  rdataSrc1, rdataSrc2
);

always_comb begin
    //rs1
    if( (MEM_Rd == rs1) && (rs1!=0) && (MEM_RegWrite == 1'b1))begin
        rdataSrc1 = `FWD_MEM_DATA;
    end
    else if( (WB_Rd == rs1) && (rs1!=0) && (WB_RegWrite == 1'b1)) begin
        rdataSrc1 = `FWD_WB_DATA;
    end
    else if((RFile_Rd == rs1) && (rs1!=0) && (RFile_RegWrite == 1'b1)) begin
        rdataSrc1 = `FWD_RFILE_DATA;
    end
    else rdataSrc1 = `FWD_R_DATA;

    //rs2
    if( (MEM_Rd == rs2) && (rs2!=0) && (MEM_RegWrite == 1'b1)) begin
        rdataSrc2 = `FWD_MEM_DATA;
    end
    else if( (WB_Rd == rs2) && (rs2!=0) && (WB_RegWrite == 1'b1)) begin
        rdataSrc2 = `FWD_WB_DATA;
    end
    else if((RFile_Rd == rs2) && (rs2!=0) && (RFile_RegWrite == 1'b1)) begin
        rdataSrc2 = `FWD_RFILE_DATA;
    end
    else rdataSrc2 = `FWD_R_DATA;
    
end


    
endmodule
