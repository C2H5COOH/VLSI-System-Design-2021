module PC(
    input           clk,rst,
    input [31:0]    pcAdd4,
    input [31:0]    jumpBranchAddr,
    output logic [31:0]  pcOut,

    input           hazard_stall, AXI_IF_stall, 
    input           jump_branch,
    input           AXI_MEM_stall
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

        if(AXI_IF_stall || hazard_stall || AXI_MEM_stall) begin 
            pcOut <= pcOut;
        end
        else begin
            if(jump_branch) pcOut <= jumpBranchAddr;
            else            pcOut <= pcAdd4;
        end
        /*if(~cache_allow || hazard_stall || AXI_MEM_stall) begin 
            pcOut <= pcOut;
        end
        else begin
            if(jump_branch) pcOut <= jumpBranchAddr;
            else if(~AXI_IF_stall)  
                pcOut <= pcAdd4;
            else pcOut <= pcOut;
        end*/

    end
end

endmodule