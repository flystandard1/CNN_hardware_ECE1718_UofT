`include "tb/dense2_input_tr.sv"
`include "tb/dense2_output_tr.sv"

module dense2_top_tb;

import "DPI-C" function void dense_2_model(input int signed dense_w2[120][10], input int signed dense_sigmoid[120], input int signed dense_b2[10], output int signed dense_sum2[10]);

logic         clk;
logic         rst_n;
dense2_if      dif(.clk(clk),.rst_n(rst_n));

dense2_input_tr  tr_i;
dense2_output_tr tr_o;

int signed dense_w2[120][10];
int signed dense_b2[10];
int signed dense_sum2_ref[10];

reg [159:0] dense_w2_reg[119:0];
reg [15:0]  dense_b2_reg[9:0];

reg [159:0] rom_w2[255:0];

dense2_top dut(
	.clk            ( clk                ), 
	.rst_n          ( rst_n              ),
    .ena            ( dif.ena            ),  
	.frame_start_in ( dif.frame_start_in ),              
	.frame_end_in   ( dif.frame_end_in   ),           
    .dense_sigmoid  ( dif.dense_sigmoid  ),
    .dense_sum2_out ( dif.dense_sum2_out ),
	.valid          ( dif.valid          ) 
	);
    
    task driver_one_packet(dense2_input_tr tr_i);
		dif.ena <= 1'b0;
		dif.frame_start_in <= 1'b0;
		dif.frame_end_in   <= 1'b0;
        @(dif.cb);
        //generate a packet
	    dif.frame_start_in <= 1'b1;
		@(dif.cb);
	    dif.frame_start_in <= 1'b0;
        for(int i=0; i<120;  i=i+1) begin
            dif.ena = 1'b1;
		    dif.dense_sigmoid = tr_i.dense_sigmoid[i];
            fork
                begin
                    if(i==119) begin
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
        
    task monitor_one_packet();
        tr_o = new();
        while(!dif.frame_start_in);
            @(dif.cb);
        while(1) begin
            if(dif.valid) begin 
                int i;
                for(i=0;i<10;i=i+1) begin
                    tr_o.dense_sum2[i] = $signed(dif.dense_sum2_out[i*16 +: 15]);
                end
                break;
            end
        //    if(dif.frame_end_out)
        //        break;
            @(dif.cb);
        end
    endtask



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
                driver_one_packet(tr_i);
            end
            //monitor
			begin
        		while(!rst_n) 
        	        @(dif.cb);
                monitor_one_packet();       		         
			end
		join
        //reference model
        dense_2_model(
            .dense_w2 (dense_w2), 
            .dense_sigmoid(tr_i.dense_sigmoid), 
            .dense_b2 (dense_b2),  
            .dense_sum2(dense_sum2_ref)
        );

        //scoreboard
        for(int u=0;u<10;u=u+1) begin
            if(dense_sum2_ref[u] != tr_o.dense_sum2[u])
                $error("Error: index=%d, ref=%d, actual=%d\n",u, dense_sum2_ref[u], tr_o.dense_sum2[u]);
            else
                $display("Correct: index=%d, ref=%d, actual=%d\n",u, dense_sum2_ref[u], tr_o.dense_sum2[u]);
        end
	end

    initial begin
       $fsdbDumpfile("dense2.fsdb");
       $fsdbDumpvars;
       $fsdbDumpMDA();
    end		


    initial begin
    	#20000;
    	$finish();
    end

    initial begin
        $readmemh("dense_w2.txt", dense_w2_reg);
        for(int u=0;u<120;u=u+1) begin
            for(int v=0;v<10;v=v+1) begin
                dense_w2[u][v] = $signed(dense_w2_reg[u][v*16 +: 15]);
            end
        end
    end

    initial begin
        $readmemh("dense_b2.txt", dense_b2_reg);
        for(int v=0;v<10;v=v+1) begin
            dense_b2[v] = $signed(dense_b2_reg[v][15:0]);
            //$display("%d ",dense_b2[v]);
        end
    end

endmodule
		        
		

