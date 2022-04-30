`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "uvc/dense1_if.sv"
`include "uvc/mem_if.sv"
`include "uvc/dense1_output_tr.sv"
`include "uvc/dense1_input_tr.sv"
`include "uvc/dense1_active_sequencer.sv"
`include "uvc/dense1_active_driver.sv"
`include "uvc/dense1_active_monitor.sv"
`include "uvc/dense1_passive_monitor.sv"
`include "uvc/dense1_active_agent.sv"
`include "uvc/dense1_passive_agent.sv"
`include "uvc/dense1_refm.sv"
`include "uvc/dense1_scbd.sv"
`include "uvc/dense1_env.sv"
`include "uvc/dense1_base_test.sv"
`include "uvc/dense1_rand.sv"
`include "uvc/dense1_smoke.sv"

module top_tb;

reg clk;
reg rst_n;

reg [1919:0] dense_w_reg[979:0];
reg [15:0]  dense_b_reg[120:0];

dense1_if dif(clk, rst_n);
mem_if memif(clk, rst_n);

dense1_top dut(
	.clk            ( clk            ), 
	.rst_n          ( rst_n          ),
    .ena            ( dif.ena            ),  
	.frame_start_in ( dif.frame_start_in ),              
	.frame_end_in   ( dif.frame_end_in   ),           
	.frame_start_out( dif.frame_start_out ),              
	.frame_end_out  ( dif.frame_end_out   ),           
    .dense_input    ( dif.dense_input    ),
    .dense_sigmoid_out  ( dif.dense_sigmoid_out  ),
	.valid          ( dif.valid          ) 
	);

initial begin
   clk = 0;
   forever begin
      #100 clk = ~clk;
   end
end

initial begin
   rst_n = 1'b0;
   #1000;
   rst_n = 1'b1;
end

initial begin
   run_test();
end

initial begin
   uvm_config_db#(virtual dense1_if)::set(null, "uvm_test_top.env.i_agt.drv", "dif", dif);
   uvm_config_db#(virtual dense1_if)::set(null, "uvm_test_top.env.i_agt.mon", "dif", dif);
   uvm_config_db#(virtual dense1_if)::set(null, "uvm_test_top.env.o_agt.mon", "dif", dif);
   uvm_config_db#(virtual mem_if)::set(null, "uvm_test_top.env.refm", "memif", memif);
end

initial begin
    $readmemh("dense_w.txt", dense_w_reg);
    for(int u=0;u<980;u=u+1) begin
        for(int v=0;v<120;v=v+1) begin
            memif.dense_w[u][v] = $signed(dense_w_reg[u][v*16 +: 15]);
        end
        //$display("w[0]:%d ",dense_w[0][v]);
    end
end

initial begin
    $readmemh("dense_b.txt", dense_b_reg);
    for(int v=0;v<120;v=v+1) begin
        memif.dense_b[v] = $signed(dense_b_reg[v][15:0]);
        //$display("b%d ",dense_b[v]);
    end
end

initial begin
   $fsdbDumpfile("dense_1.fsdb");
   $fsdbDumpvars;
   $fsdbDumpMDA();
end		

endmodule
