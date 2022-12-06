`timescale 1ns/10ps
`define CYCLE 10.0 // Cycle time
`define MAX 300000 // Max cycle number
`ifdef SYN
`include "top_syn.v"
`include "SRAM/SRAM.v"
`timescale 1ns/10ps
`include "/usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog/fsa0m_a_generic_core_21.lib"
`else
`include "top.sv"
`include "SRAM/SRAM_rtl.sv"
`endif
`timescale 1ns/10ps
`define mem_word(addr) \
  {TOP.DM1.i_SRAM.Memory_byte3[addr], \
  TOP.DM1.i_SRAM.Memory_byte2[addr], \
  TOP.DM1.i_SRAM.Memory_byte1[addr], \
  TOP.DM1.i_SRAM.Memory_byte0[addr]}
`define SIM_END 'h3fff
`define SIM_END_CODE -32'd1
`define TEST_START 'h0000
module top_tb;

  logic clk;
  logic rst;
  logic [31:0] GOLDEN[64];
  logic [7:0] Memory_byte0[32768];
  logic [7:0] Memory_byte1[32768];
  logic [7:0] Memory_byte2[32768];
  logic [7:0] Memory_byte3[32768];
  integer gf, i, num;
  integer err;
  string prog_path;
  always #(`CYCLE/2) clk = ~clk;

  top TOP(
    .clk(clk),
    .rst(rst)
  );

  initial
  begin
    $value$plusargs("prog_path=%s", prog_path);
    clk = 0; rst = 1;
    #(`CYCLE) rst = 0;
    $readmemh({prog_path, "/main0.hex"}, Memory_byte0);
    $readmemh({prog_path, "/main1.hex"}, Memory_byte1);
    $readmemh({prog_path, "/main2.hex"}, Memory_byte2);
    $readmemh({prog_path, "/main3.hex"}, Memory_byte3);
    for (i = 0; i < 16384; i++)
    begin
      TOP.IM1.i_SRAM.Memory_byte0[i] = Memory_byte0[i];
      TOP.DM1.i_SRAM.Memory_byte0[i] = Memory_byte0[i + 16384];
      TOP.IM1.i_SRAM.Memory_byte1[i] = Memory_byte1[i];
      TOP.DM1.i_SRAM.Memory_byte1[i] = Memory_byte1[i + 16384];
      TOP.IM1.i_SRAM.Memory_byte2[i] = Memory_byte2[i];
      TOP.DM1.i_SRAM.Memory_byte2[i] = Memory_byte2[i + 16384];
      TOP.IM1.i_SRAM.Memory_byte3[i] = Memory_byte3[i];
      TOP.DM1.i_SRAM.Memory_byte3[i] = Memory_byte3[i + 16384];
    end
    num = 0;
    gf = $fopen({prog_path, "/golden.hex"}, "r");
    while (!$feof(gf))
    begin
      $fscanf(gf, "%h\n", GOLDEN[num]);
      num++;
    end
    $fclose(gf);

    wait(`mem_word(`SIM_END) == `SIM_END_CODE);
    $display("\nDone\n");
    err = 0;

    for (i = 0; i < num; i++)
    begin
      if (`mem_word(`TEST_START + i) !== GOLDEN[i])
      begin
        $display("DM[%4d] = %h, expect = %h", `TEST_START + i, `mem_word(`TEST_START + i), GOLDEN[i]);
        err = err + 1;
      end
      else
      begin
        $display("DM[%4d] = %h, pass", `TEST_START + i, `mem_word(`TEST_START + i));
      end
    end
    result(err, num);
    $finish;
  end

  `ifdef SYN
  initial $sdf_annotate("top_syn.sdf", TOP);
  `endif

  initial
  begin
    `ifdef FSDB
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0, TOP);
    `elsif FSDB_ALL
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars("+struct", "+mda", TOP);
    `endif
    #(`CYCLE*`MAX)
    for (i = 0; i < num; i++)
    begin
      if (`mem_word(`TEST_START + i) !== GOLDEN[i])
      begin
        $display("DM[%4d] = %h, expect = %h", `TEST_START + i, `mem_word(`TEST_START + i), GOLDEN[i]);
        err=err+1;
      end
      else begin
        $display("DM[%4d] = %h, pass", `TEST_START + i, `mem_word(`TEST_START + i));
      end
    end
    $display("SIM_END(%5d) = %h, expect = %h", `SIM_END, `mem_word(`SIM_END), `SIM_END_CODE);
    result(num, num);
    $finish;
  end
  
  task result;
    input integer err;
    input integer num;
    integer rf;
    begin
      `ifdef SYN
			rf = $fopen({prog_path, "/result_syn.txt"}, "w");
      `else
			rf = $fopen({prog_path, "/result_rtl.txt"}, "w");
      `endif
      $fdisplay(rf, "%d,%d", num - err, num);
      if (err === 0)
      begin
        $display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  Congratulations !!    **      / O.O  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation PASS!!     **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("\n");
      end
      else
      begin
        $display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  OOPS!!                **      / X,X  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation Failed!!   **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("         Totally has %d errors                     ", err); 
        $display("\n");
      end
    end
  endtask

endmodule
