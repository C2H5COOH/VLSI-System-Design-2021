`include "../../include/Control.svh"

module Control (
    input   [6:0]           opcode,
    input   [2:0]           funct3,
    input   [6:0]           funct7,

    output logic            JAL, JALR, Branch,
    output logic            MemRead, MemWrite, 
    output logic            ALUSrc1, ALUSrc2, 
    output logic            RegWrite,
    output logic  [2:0]     DataWidth,
    output logic  [4:0]     ALUOp,
    output logic  [2:0]     ImmOp   
);

assign JAL = (`JAL)?                            1'b1 : 1'b0;
assign JALR = (`JALR)?                          1'b1 : 1'b0;
assign Branch = (`BRANCH)?                      1'b1 : 1'b0;
assign MemRead = (`LOAD)?                       1'b1 : 1'b0;
assign MemWrite = (`STORE)?                     1'b1 : 1'b0;
assign ALUSrc1 = ( `AUIPC || `JAL || `JALR )?   1'b0 : 1'b1;
assign ALUSrc2 = ( (`R_TYPE) || (`BRANCH) )?    1'b0 : 1'b1;
assign RegWrite = ( (`STORE) || (`BRANCH) || (opcode == 7'b0))?    1'b0 : 1'b1;   


always_comb begin : data_width
    if( (`LOAD) || (`STORE) ) begin
        if(`BYTE)        begin
            DataWidth = `BYTE_WIDTH;
        end
        else if(`BYTEU)  begin
            DataWidth = `BYTEU_WIDTH; 
        end
        else if(`WORD)   begin
            DataWidth = `WORD_WIDTH;
        end
        else if(`HALF)   begin
            DataWidth = `HALF_WIDTH;
        end
        else if(`HALFU)  begin
            DataWidth = `HALFU_WIDTH;
        end
        else begin
            DataWidth = 3'b111;
        end
    end
    else DataWidth = 3'b111;
end

always_comb begin : alu_op
    unique if(`SUB)     begin
        ALUOp = `ALU_SUB;
    end
    else if(`SLL)   begin 
        ALUOp = `ALU_SLL;
    end
    else if(`SLT)   begin
        ALUOp = `ALU_SLT;
    end
    else if(`SLTU)  begin
        ALUOp = `ALU_SLTU;
    end
    else if(`XOR)   begin
        ALUOp = `ALU_XOR;
    end
    else if(`SRL)   begin
        ALUOp = `ALU_SRL;
    end 
    else if(`SRA)   begin
        ALUOp = `ALU_SRA;
    end 
    else if(`OR)    begin
        ALUOp = `ALU_OR;
    end 
    else if(`AND)   begin
        ALUOp = `ALU_AND;
    end 
    else if(`BEQ)   begin
        ALUOp = `ALU_BEQ;
    end 
    else if(`BNE)   begin 
        ALUOp = `ALU_BNE;
    end 
    else if(`BLT)   begin
        ALUOp = `ALU_BLT;
    end 
    else if(`BGE)   begin
        ALUOp = `ALU_BGE;
    end
    else if(`BLTU)  begin
        ALUOp = `ALU_BLTU;
    end
    else if(`BGEU)  begin
        ALUOp = `ALU_BGEU;
    end
    else if(`JAL || `JALR)   begin
        ALUOp = `ALU_JAL;
    end
    else if(`LUI)   begin
        ALUOp = `ALU_LUI;
    end
    else begin
        ALUOp = `ALU_ADD;
    end
end

always_comb begin : imm_op
    unique if(`I_TYPE_ARITH || `LOAD || `JALR)  begin 
        ImmOp = `IMM_I_TYPE;
    end
    else if(`STORE)         begin
        ImmOp = `IMM_S_TYPE;
    end                            
    else if(`BRANCH)        begin
        ImmOp = `IMM_B_TYPE;
    end                            
    else if(`AUIPC || `LUI) begin
        ImmOp = `IMM_U_TYPE;
    end                     
    else if(`JAL)           begin
        ImmOp = `IMM_J_TYPE;
    end                               
    else begin
        ImmOp = `IMM_ELSE;
    end
end

    
endmodule
