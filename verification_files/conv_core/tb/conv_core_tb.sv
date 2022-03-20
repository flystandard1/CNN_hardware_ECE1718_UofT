`include "tb/conv_core_input_tr.sv"
`include "tb/conv_core_output_tr.sv"

import "DPI-C" function int conv_core_model(input int signed img[49], input int signed conv_w[49], input int signed conv_b);
module conv_core_tb;

logic clk;
logic rst_n;

int out_reg_ref;

conv_core_if cif(.clk(clk),.rst_n(rst_n));

conv_core_input_tr  tr_i;
conv_core_output_tr tr_o;

con dut(
    .clk (clk), 
    .rst_n(rst_n), 
    .ima(cif.ima),
    .wei(cif.wei),
    .bias(cif.bias),
    .out_reg(cif.out_reg),
    .enable(cif.enable),
    .valid(cif.valid)
);

	initial begin 
	    clk = 1'b0;
		forever 
        #5 clk = !clk;
	end

	initial begin
	    rst_n = 1'b0;
        #15
		rst_n = 1'b1;
    end

    initial begin
       $fsdbDumpfile("conv_core_tb.fsdb");
       $fsdbDumpvars;
       $fsdbDumpMDA();
    end		


    initial begin
    	#5000;
    	$finish();
    end


    task driver_one_pkt(conv_core_input_tr tr_i);
        cif.enable <= 1'b0;
        @(cif.cb);
        cif.enable = 1'b1;
        for(int i=0;i<49;i=i+1) begin
		    cif.ima[i* 8+: 8] = tr_i.ima[i];
		    cif.wei[i*16+:16] = tr_i.wei[i];
        end
		cif.bias = tr_i.bias;
        @(cif.cb);
        cif.enable = 1'b0;
    endtask

    task monitor_one_pkt();
		while(!cif.valid) 
            @(cif.cb);
		tr_o.out_reg = $signed(cif.out_reg);
        @(cif.cb);
    endtask
    

    initial begin
        cif.enable <= 1'b0;
		while(!rst_n) 
            @(cif.cb);
        tr_i=new();
        tr_i.randomize();
        tr_o=new();
        fork
            begin
                driver_one_pkt(tr_i);
            end
            begin
                monitor_one_pkt();
            end
        join
        //reference model
        out_reg_ref=conv_core_model(.img(tr_i.ima), .conv_w(tr_i.wei),.conv_b(tr_i.bias));
        //$display("img: %d, wei: %d, bias: %d",tr_i.ima[0], tr_i.wei[0], tr_i.bias);
        //scoreboard
        if(out_reg_ref != tr_o.out_reg)
            $error("Error: out_reg_ref: %d, out_reg: %d", out_reg_ref, tr_o.out_reg);
        else
            $display("Correct: out_reg_ref: %d, out_reg: %d", out_reg_ref, tr_o.out_reg);
    end


endmodule
