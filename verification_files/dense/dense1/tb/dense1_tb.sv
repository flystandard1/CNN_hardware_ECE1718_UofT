`include "tb/dense1_input_tr.sv"
`include "tb/dense1_output_tr.sv"

module dense1_tb;

import "DPI-C" function void dense_1_model(input int signed dense_w[980][120], input int signed dense_input[980], input int signed dense_b[120], output int signed dense_sigmoid[120]);
    logic clk;
    logic rst_n;
    dense1_if      dif(.clk(clk),.rst_n(rst_n));

dense1_input_tr  tr_i;
dense1_output_tr tr_o;

int i1;
int signed dense_w[980][120];
int signed dense_b[120];
int signed dense_sigmoid_ref[120];

reg [1919:0] dense_w_reg[979:0];
reg [15:0]  dense_b_reg[120:0];

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

    task driver_one_pkt(dense1_input_tr tr_i);
	    dif.ena <= 1'b0;
        dif.frame_start_in <= 1'b0;
        dif.frame_end_in   <= 1'b0;
        @(dif.cb);
        //generate a packet
        dif.frame_start_in <= 1'b1;
		@(dif.cb);
        dif.frame_start_in <= 1'b0;
        for(int u=0; u<980;  u=u+1) begin
            dif.ena = 1'b1;
		    dif.dense_input = tr_i.dense_input[u];
            //$display("%d",tr_i.dense_input[u]);
            fork
                begin
                    if(u==979) begin
		                dif.frame_end_in <= 1'b1;
                        @(dif.cb);
		                dif.frame_end_in <= 1'b0;
                    end
                end
                begin
                    @(dif.cb);
                    dif.ena = 1'b0;
                    @(dif.cb);
                end
            join
        end
        dif.frame_end_in <=  1'b0;
        dif.ena <= 1'b0;
    endtask

    task monitor_one_pkt();
        while(!dif.frame_start_in);
            @(dif.cb);
        i1 = 0;
        while(1) begin
            if(dif.valid) begin 
                tr_o.dense_sigmoid[i1] = $signed(dif.dense_sigmoid_out);
                i1 = i1+1;
            end

            if(dif.frame_end_out)
            //if(i1==980)
                break;
            @(dif.cb);
        end
    endtask


    initial begin
       $fsdbDumpfile("dense_1.fsdb");
       $fsdbDumpvars;
       $fsdbDumpMDA();
    end		


    initial begin
    	#200000;
    	$finish();
    end

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
        tr_i = new();
        tr_i.randomize();
        tr_o = new();
	    fork
            //driver
		    begin
		        while(!rst_n) 
	                @(dif.cb);
                driver_one_pkt(tr_i);
            //monitor
            end
			begin
		        while(!dif.ena) 
	                @(dif.cb);
                monitor_one_pkt();
			end
		join
        //reference model
        dense_1_model(
            .dense_w (dense_w), 
            .dense_input(tr_i.dense_input), 
            .dense_b (dense_b),  
            .dense_sigmoid(dense_sigmoid_ref)
        );
        //scoreboard
        for(int u=0;u<120;u=u+1) begin
            if(dense_sigmoid_ref[u] != tr_o.dense_sigmoid[u])
                $error("Error: index=%d, ref=%d, actual=%d\n",u, dense_sigmoid_ref[u], tr_o.dense_sigmoid[u]);
            else
                $display("Correct: index=%d, ref=%d, actual=%d\n",u, dense_sigmoid_ref[u], tr_o.dense_sigmoid[u]);
        end
	end

    initial begin
        $readmemh("dense_w.txt", dense_w_reg);
        for(int u=0;u<980;u=u+1) begin
            for(int v=0;v<120;v=v+1) begin
                dense_w[u][v] = $signed(dense_w_reg[u][v*16 +: 15]);
            end
            //$display("w[0]:%d ",dense_w[0][v]);
        end
    end

    initial begin
        $readmemh("dense_b.txt", dense_b_reg);
        for(int v=0;v<120;v=v+1) begin
            dense_b[v] = $signed(dense_b_reg[v][15:0]);
            //$display("b%d ",dense_b[v]);
        end
    end

endmodule
