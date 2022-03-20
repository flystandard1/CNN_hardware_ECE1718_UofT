module conv_top_tb;

logic clk;
logic rst_n;
conv_if cif(.clk(clk),.rst_n(rst_n));

con_top dut(
    .clk (clk), 
    .rst_n(rst_n), 
    .ima(cif.ima),
    .ena_in(cif.ena_in),
    .frame_start_in(cif.frame_start_in),
    .frame_start_dim_in(cif.frame_start_dim_in),
    .line_start_in(cif.line_start_in),
    .frame_end_in(cif.frame_end_in),
    .frame_end_dim_in(cif.frame_end_dim_in),
    .frame_start_out(cif.frame_start_out),
    .frame_end_out(cif.frame_end_out),
    .line_start_out(cif.line_start_out),
    .out_valid(cif.valid)
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
       $fsdbDumpfile("conv_top_tb.fsdb");
       $fsdbDumpvars;
       $fsdbDumpMDA();
    end		


    initial begin
    	#200000;
    	$finish();
    end



    task driver_one_pkt();
        cif.line_start_in = 1'b0;
        cif.frame_start_in = 1'b0;
        cif.frame_start_dim_in = 1'b0;
        cif.frame_end_in   = 1'b0;
        cif.frame_end_dim_in   = 1'b0;
        @(cif.cb);
        //generate a packet
        for(int u=0;u<5;u=u+1) begin
            cif.line_start_in = 1'b1;
            cif.frame_start_in = 1'b1;
            if(u==0)
                cif.frame_start_dim_in = 1'b1;
		    @(cif.cb);
            cif.ena_in = 1'b1;
            cif.frame_start_in = 1'b0;
            cif.frame_start_dim_in = 1'b0;
            for(int i=0; i<35;  i=i+1) begin
                for(int j=0; j<32;  j=j+1) begin
                    cif.line_start_in = 1'b0;
		            cif.ima = i*32+j;
                    if(i<34 &&j==31)
                        cif.line_start_in = 1'b1;
                    if(i==34&&j==31) begin
                        cif.frame_end_in =  1'b1;
                        if(u==4)
                            cif.frame_end_dim_in =  1'b1;
                    end   
                       
                    @(cif.cb);
                end
            end
            cif.frame_end_in <=  1'b0;
            cif.frame_end_dim_in <=  1'b0;
            cif.ena_in <= 1'b0;
        end
    endtask

    initial begin
        fork
            begin
		        while(!rst_n) 
	                @(cif.cb);
                driver_one_pkt();
            end
            begin
                @(cif.cb);
            end
        join
    end
endmodule
