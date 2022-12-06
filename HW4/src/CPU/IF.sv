// `include "PC.sv"
`include "CPU/PC.sv"

module IF (
    input                   clk,rst,

    input [31:0]            EXE_jumpBranchAddr,
    input                   EXE_jumpBranch,
    input                   ID_hazardStall,

    output logic [31:0]     instruction_reg,
    output logic [31:0]     pc_reg,

    output logic [31:0]     IM_addr,
    output logic            IM_read,
    input  [31:0]           IM_instruction,

    input                   AXI_IF_stall,
    input                   AXI_MEM_stall,

    input                   ctrl_intr,
    output logic [31:0]     pc_store,
    input [31:0]            csr_pc,
    input                   wfi,mret
);

logic [31:0] pcOut;
logic [31:0] pcAdd4;
assign pcAdd4 = pcOut + 4;

// logic jumpBranch_reg;
// logic [31:0] jb_addr_reg;

// logic [31:0]    pc_jb_addr;
// logic           pc_jb;

//assign IF_pc = pcOut;
// always_comb begin
//     if(ctrl_intr) begin
//         if(pc_jb)   pc_store = pc_jb_addr;
//         else        pc_store = pcOut;
//     end
//     else begin
//         pc_store = 32'hffff_ffff;
//     end
// end
always_comb begin
    if(ctrl_intr) begin
        if(EXE_jumpBranch)begin
            pc_store = EXE_jumpBranchAddr;
        end
        else begin
            pc_store = pcOut;
        end
    end
    else begin
        pc_store = 32'hffff_ffff;
    end
end

// PC pc(
//     .clk(clk), 
//     .rst(rst),

//     .pcAdd4(pcAdd4),
//     .jumpBranchAddr(pc_jb_addr),

//     .pcOut(pcOut),

//     .hazard_stall(ID_hazardStall),
//     .AXI_IF_stall(AXI_IF_stall),
//     .jump_branch(pc_jb),
//     .AXI_MEM_stall(AXI_MEM_stall),

//     .ctrl_intr(ctrl_intr),
//     .csr_pc(csr_pc),
//     .wfi(wfi),
//     .mret(mret)

// );
PC pc(
    .clk(clk), 
    .rst(rst),

    .pcAdd4(pcAdd4),
    .jumpBranchAddr(EXE_jumpBranchAddr),

    .pcOut(pcOut),

    .hazard_stall(ID_hazardStall),
    .AXI_IF_stall(AXI_IF_stall),
    .jump_branch(EXE_jumpBranch),
    .AXI_MEM_stall(AXI_MEM_stall),

    .ctrl_intr(ctrl_intr),
    .csr_pc(csr_pc),
    .wfi(wfi),
    .mret(mret)
);

// always_comb begin
//     if(AXI_IF_stall) begin
//         pc_jb       = 1'b0;
//         pc_jb_addr  = 32'b0;
//     end
//     else begin
//         if(EXE_jumpBranch) begin
//             pc_jb       = EXE_jumpBranch;
//             pc_jb_addr  = EXE_jumpBranchAddr;
//         end
//         else if(jumpBranch_reg) begin
//             pc_jb       = jumpBranch_reg;
//             pc_jb_addr  = jb_addr_reg;
//         end
//         else begin
//             pc_jb       = 1'b0;
//             pc_jb_addr  = 32'b0;
//         end
//     end
// end

// always_ff @(posedge clk) begin
//     if(rst) begin
//         jumpBranch_reg  <= 1'b0;
//         jb_addr_reg     <= 32'b0;
//     end
//     else begin
//         if(AXI_IF_stall) begin
//             if(EXE_jumpBranch) begin
//                 jumpBranch_reg <= 1'b1;
//                 jb_addr_reg <= EXE_jumpBranchAddr;
//             end 
//             else begin
//                 jumpBranch_reg <= jumpBranch_reg;
//                 jb_addr_reg <= jb_addr_reg;
//             end
//         end
//         else begin
//             jumpBranch_reg <= 1'b0;
//             jb_addr_reg <= 32'b0;
//         end
//     end
// end

//register suppose to be flushed when hazard or jump or branch
//since pc needs extra cycle to load new address
//instruction goes directly through register, since IM already needs a cycle to load

logic init;
always_ff @(posedge clk) begin
    if(rst) init <= 1'b1;
    else init <= 1'b0 ;
end

//IM_addr
assign IM_addr = (EXE_jumpBranch)? EXE_jumpBranchAddr : pcOut;
// always_comb begin
//     if(EXE_jumpBranch) 
//         IM_addr = EXE_jumpBranchAddr;
//     else if (jumpBranch_reg)
//         IM_addr = jb_addr_reg;
//     else                
//         IM_addr = pcOut;
// end

always_ff @(posedge clk) begin
    if(rst || wfi) IM_read <= 1'b0;
    else IM_read <= 1'b1;
end


// always_ff @(posedge clk) begin
//     if(rst) begin
//         pc_reg          <= 32'b0;
//         instruction_reg <= 32'b0;
//     end
//     else begin
//         if(AXI_MEM_stall || ID_hazardStall)begin
//             pc_reg          <= pc_reg;
//             instruction_reg <= instruction_reg;
//         end
//         else if(AXI_IF_stall || init || jumpBranch_reg || EXE_jumpBranch || wfi)begin
//             pc_reg          <= 32'b0;
//             instruction_reg <= 32'b0;
//         end
//         else begin
//             pc_reg          <= pcOut;
//             instruction_reg <= IM_instruction;
//         end
//     end
// end
always_ff @(posedge clk) begin
    if(rst) begin
        pc_reg          <= 32'b0;
        instruction_reg <= 32'b0;
    end
    else begin
        if(AXI_MEM_stall || ID_hazardStall)begin
            pc_reg          <= pc_reg;
            instruction_reg <= instruction_reg;
        end
        else if(AXI_IF_stall || init || EXE_jumpBranch || wfi)begin
            pc_reg          <= 32'b0;
            instruction_reg <= 32'b0;
        end
        else begin
            pc_reg          <= pcOut;
            instruction_reg <= IM_instruction;
        end
    end
end
    
endmodule 
