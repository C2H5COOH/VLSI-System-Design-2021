`include "CPU_def.svh"

module IF (
    input               clk,
    input               rst,    
    input               branchTaken,
    /* m1Stall | loadUse | m0Stall */
    input               stall,
    input               stallPC,
    input [31:0]        instFromIMem,
    // branch
    input [1:0]         bra_src,
    input [31:0]        mepc,
    input [31:0]        mtvec,
    input [31:0]        EX_alu_res_reg,
    output logic [31:0] PCFromIF,
    output logic [31:0] PC_4FromIF,
    output logic [31:0] inst,
    output logic [31:0] addressToIMem,
    output logic        instValidToID
);

logic [31:0]    branch_pc;
logic [31:0]    pc;
logic [31:0]    pc_4;
logic [31:0]    instReg;
logic           lastBranchTaken;

always_comb begin
    case(bra_src)
        `BraFromALU:
            branch_pc = EX_alu_res_reg;
        `BraFromMepc:
            branch_pc = mepc;
        `BraFromMtvec:
            branch_pc = mtvec;
        default:
            branch_pc = 32'd0;
    endcase
end

assign pc_4 = pc + 4;

/* pc mux */
always_ff @(posedge clk) begin
    if (rst) begin
        pc <= 32'h0;
    end
    else if (branchTaken) begin
        pc <= branch_pc;
    end
    else if (!stall & !stallPC) begin
        pc <= pc_4;
    end
    else begin
        pc <= pc;
    end
end

/* pc output */
always_ff @(posedge clk) begin
    if (rst || branchTaken) begin
        PCFromIF <= 32'h0;
        PC_4FromIF <= 32'h0;
    end
    else if (!stall) begin
        PCFromIF <= pc;
        PC_4FromIF <= pc_4;
    end
    else begin
        PCFromIF <= PCFromIF;
        PC_4FromIF <= PC_4FromIF;
    end
end
    
/* inst addr, data*/
always_ff @(posedge clk) begin
    if (rst || branchTaken) begin
        instReg <= `NOP;
    end
    else if (!stallPC) begin
        instReg <= inst;
    end
end
always_comb begin
    addressToIMem = pc;
    inst = (stall/* || branchTaken || lastBranchTaken*/) ? instReg : instFromIMem;
end

always_ff @(posedge clk) begin
    lastBranchTaken <= branchTaken;
end

always_comb begin
    if (rst || stall || branchTaken || lastBranchTaken) begin
        instValidToID = 1'b0;
    end
    else begin
        instValidToID = 1'b1;
    end
end

endmodule
