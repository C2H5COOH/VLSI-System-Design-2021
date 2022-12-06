`include "CPU/CPU.sv"
`include "cache/L1C_data.sv"
`include "cache/L1C_inst.sv"
`include "cache_def.svh"

module CPU_with_cache (
    input clk,
    input rst,

    input [`AXI_DATA_BITS-1:0] D_out,
    input D_wait,
    input D_valid,  // return data is valid
    output logic D_req,
    output logic D_write,
    output logic [`AXI_STRB_BITS-1:0]  D_strobe,
    output logic [`AXI_ADDR_BITS-1:0] D_addr,
    output logic [`AXI_DATA_BITS-1:0] D_in,
    output logic [`CACHE_TYPE_BITS-1:0] D_type,
    output logic                  D_burst,

    input [`AXI_DATA_BITS-1:0] I_out,
    input I_wait,
    input I_valid,  // return data is valid
    output logic I_req,  
    output logic [`DATA_BITS-1:0] I_addr,

    input  extern_interrupt
);

logic data_req;
logic data_write;
logic [3:0]   data_strobe;
logic [`DATA_BITS-1:0] MemAddr;
logic [`DATA_BITS-1:0] MemRD;
logic [`DATA_BITS-1:0] MemWD;
logic [`CACHE_TYPE_BITS-1:0] data_type;
logic m1Stall;

logic inst_req;
logic [`DATA_BITS-1:0] InstAddr;
logic [`DATA_BITS-1:0] InstRD;
logic m0Stall;

L1C_data L1C_data_1(
    .clk(clk),
    .rst(rst),
    .core_addr(MemAddr),
    .core_req(data_req),
    .core_write(data_write),
    .core_in(MemWD),
    .core_type(data_type),
    .core_strobe(data_strobe),
    .D_out(D_out),
    .D_wait(D_wait),
    .D_valid(D_valid), 
    .core_out(MemRD),
    .core_wait(m1Stall),
    .D_req(D_req),
    .D_addr(D_addr),
    .D_write(D_write),
    .D_in(D_in),
    .D_strobe(D_strobe),
    .D_type(D_type),
    .D_burst(D_burst)
);

L1C_inst L1C_inst_1(
    .clk(clk),
    .rst(rst),
    .core_addr(InstAddr),
    .core_req(inst_req),
    .I_out(I_out),
    .I_wait(I_wait),
    .I_valid(I_valid), 
    .core_out(InstRD),
    .core_wait(m0Stall),
    .I_req(I_req),
    .I_addr(I_addr)
);

CPU CPU1(
    .clk(clk),
    .rst(rst),
    .InstAddr(InstAddr),
    .inst_req(inst_req),
    .m0Stall(m0Stall),
    .InstData(InstRD),
    .MemAddr(MemAddr),
    .data_strobe(data_strobe),
    .data_req(data_req),
    .data_write(data_write),
    .data_type(data_type),
    .MemWData(MemWD),
    .m1Stall(m1Stall),
    .MemRData(MemRD),
    .extern_interrupt(extern_interrupt)
);
  
endmodule
