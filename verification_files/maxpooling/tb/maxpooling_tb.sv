import "DPI-C" function void maxpooling_model(input int signed sig_layer[5][28][28], output int signed max_layer[5][14][14]);
`include "tb/maxpooling_input_tr.sv"
`include "tb/maxpooling_output_tr.sv"

module maxpooling_tb;

logic         clk;
logic         rst_n;


//logic signed [15:0]  model_max_layer[5][14][14];
int signed   model_max_layer[5][14][14];


int i1;
int j1;
int u1;

maxpooling_if mif (.clk(clk),.rst_n(rst_n));

maxpooling_input_tr  tr_i;
maxpooling_output_tr tr_o;

maxpooling dut(
	.clk            ( clk            ), 
	.rst_n          ( rst_n          ),
    .ena            ( mif.ena            ),  
	.frame_start_in ( mif.frame_start_in ),              
	.line_start_in  ( mif.line_start_in  ),            
	.frame_end_in   ( mif.frame_end_in   ),           
	.sig_layer      ( mif.sig_layer      ),        
	.max_layer      ( mif.max_layer      ),        
	.frame_start_out( mif.frame_start_out),             
	.line_start_out ( mif.line_start_out ),             
	.frame_end_out  ( mif.frame_end_out  ),            
	.valid          ( mif.valid          ) 
	);

task drive_one_tr_i(maxpooling_input_tr  tr_i);
    //initialization
    mif.ena <= 1'b0;
    mif.frame_start_in <= 1'b0;
    mif.frame_end_in   <= 1'b0;
    mif.line_start_in  <= 1'b0;
    @(mif.cb); 
    //frame start
    mif.frame_start_in <= 1'b1;
    mif.frame_end_in   <= 1'b0;
    mif.line_start_in  <= 1'b1;
    mif.ena <= 1'b0;
    @(mif.cb);
    for(int u=0; u<5;  u=u+1) begin
        for(int i=0; i<28; i=i+1) begin
            mif.frame_start_in <= 1'b0;
            mif.line_start_in  <= 1'b0;
            mif.frame_end_in   <= 1'b0;
            mif.ena <= 1'b1;
            for(int j=0; j<28; j=j+1) begin
                mif.ena <= 1'b1;
        	    mif.sig_layer <= tr_i.sig_layer_in[u][i][j];
        		if(j==27&&i==27&&u==4) 
        		    mif.frame_end_in <= 1'b1;
                else if(j==27)
                    mif.line_start_in <= 1'b1;
        		@(posedge clk);
        		mif.line_start_in <= 1'b0;
        		mif.frame_end_in <= 1'b0;
        	end
        end
    end
    mif.frame_end_in <=  1'b0;
    mif.ena <= 1'b0;
endtask

task monitor_one_tr_o();
    tr_o = new();
    while(!mif.frame_start_in);
        @(mif.cb);
    u1 = 0;
    i1 = 0;
    j1 = 0;

    while(1) begin
        if(mif.valid) begin 
            tr_o.max_layer_out[u1][i1][j1] = mif.max_layer;
            //$display("%d,%d,%d,%d",u1,i1,j1,mif.max_layer);
            if(j1 == 13) begin
                if(i1==13) begin
                    u1 = u1 + 1;
                    i1 = 0;
                end
                else
                    i1 = i1 + 1;
                j1 = 0;
            end
            else
                j1 = j1 + 1;
        end
        if(mif.frame_end_out)
            break;
        @(mif.cb);
    end
endtask

//clk
initial begin 
    clk = 1'b0;
	forever 
    #5 clk = !clk;
end

//rst_n
initial begin
    rst_n = 1'b0;
    #15
	rst_n = 1'b1;
end


initial begin 
    //randomize input transaction
    tr_i = new();
    tr_i.randomize();
    fork
        //driver
	    begin
            while(!rst_n) 
                @(mif.cb);
            drive_one_tr_i(tr_i);
        end
        //monitor
		begin
            while(!rst_n) 
                @(mif.cb);
            monitor_one_tr_o();
		end
	join
    //reference model
    maxpooling_model(.sig_layer(tr_i.sig_layer_in),.max_layer(model_max_layer));
    //scoreboard
    for(int u=0; u<5;  u=u+1) begin
        for(int i=0; i<14; i=i+1) begin
            for(int j=0; j<14; j=j+1) begin
                if(tr_o.max_layer_out[u][i][j]!=model_max_layer[u][i][j])
                    $error("Error: u=%d, i=%d, j=%d, max_layer output=%d, expected output=%d.\n",u,i,j,tr_o.max_layer_out[u][i][j],model_max_layer[u][i][j]);
                //else 
                //    $display("Correct: u=%d, i=%d, j=%d, max_layer output=%d, expected output=%d.\n",u,i,j,tr_o.max_layer_out[u][i][j],model_max_layer[u][i][j]);
            end
        end
    end
end

initial begin
   $fsdbDumpfile("maxpooling.fsdb");
   $fsdbDumpvars;
   $fsdbDumpMDA();
end		


initial begin
	#100000;
	$finish();
end

endmodule
		        
		

