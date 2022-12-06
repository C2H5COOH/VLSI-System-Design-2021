module PC(
    input                clk,rst,
    input        [31:0]  pcAdd4,
    input        [31:0]  jumpBranchAddr,
    output logic [31:0]  pcOut,

    input                pcStall,pcSrc

);

//logic [31:0] pcOut;

always_ff @(posedge clk) begin
    if(rst) pcOut <= 0;
    else begin
        
        if(pcStall) pcOut <= pcOut;
        else pcOut <= (pcSrc)? jumpBranchAddr : pcAdd4;

    end
end

endmodule