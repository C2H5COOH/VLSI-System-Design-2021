module PC(
    input           clk,rst,
    input [31:0]    pcAdd4,
    input [31:0]    jumpBranchAddr,
    output logic [31:0]  pcOut,

    input           hazard_stall, AXI_IF_stall, 
    input           jump_branch,
    input           AXI_MEM_stall,

    input           ctrl_intr,
    input [31:0]    csr_pc,

    input           wfi, mret
);

//logic [31:0] pcOut;

logic init;
always_ff @(posedge clk) begin
    if(rst) init <= 1'b1;
    else    init <= 1'b0;
end

always_ff @(posedge clk) begin
    if(rst || init) pcOut <= 0;
    else begin

        // if(AXI_IF_stall || hazard_stall || AXI_MEM_stall || wfi) begin 
        //     pcOut <= pcOut;
        // end
        // else begin
        //     unique if(ctrl_intr || mret)begin
        //         pcOut <= csr_pc;
        //     end
        //     else if(jump_branch)begin
        //         pcOut <= jumpBranchAddr;
        //     end
        //     else begin
        //         pcOut <= pcAdd4;
        //     end
        // end
        if(jump_branch) begin
            pcOut <= jumpBranchAddr; // Interrupt should have higher priority than branch
        end
        else if(AXI_IF_stall || hazard_stall || AXI_MEM_stall || wfi) begin //ctrl_intr should have higher priority than wfi, needs to fix.
            pcOut <= pcOut;
        end
        else begin
            // pcOut <= pcAdd4;
            if(ctrl_intr || mret)begin
                pcOut <= csr_pc;
            end
            else begin
                pcOut <= pcAdd4;
            end
        end

    end
end

endmodule