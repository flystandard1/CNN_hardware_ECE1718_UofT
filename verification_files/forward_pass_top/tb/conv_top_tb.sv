`timescale 1ns / 1ps
module conv_top_tb;

logic clk;
logic rst_n;
conv_if cif(.clk(clk),.rst_n(rst_n));

reg[63:0] img[84399:0];
reg[159:0] res[599:0];
 

int m,n;
int i0;

//integer handle;

parameter handle = "./res.txt";

//initial begin
//    handle=$fopen("~/Documents/cnn_mnist_1718/1718a1/forward_pass_top/res.txt","w");
//end

forward_pass_top dut(
    .clk (clk), 
    .rst_n(rst_n), 
    .ima(cif.ima),
    .ena_in(cif.ena_in),
    .frame_start_in(cif.frame_start_in),
    .frame_start_dim_in(cif.frame_start_dim_in),
    .line_start_in(cif.line_start_in),
    .frame_end_in(cif.frame_end_in),
    .frame_end_dim_in(cif.frame_end_dim_in),
    .valid(cif.valid),
    .forward_pass_out(cif.forward_pass_out)
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
    	#50000000;
    	$finish();
    end


    task driver_one_pkt();
        //generate a packet
        for(int d=0;d<600;d=d+1) begin
        cif.line_start_in = 1'b0;
        cif.frame_start_in = 1'b0;
        cif.frame_start_dim_in = 1'b0;
        cif.frame_end_in   = 1'b0;
        cif.frame_end_dim_in   = 1'b0;
        @(cif.cb);

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
                        m = j/8;
                        n = j%8;
                        cif.line_start_in = 1'b0;
		                cif.ima = img[140*d+i*4+m][n*8+:8];
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
            repeat(200) @(cif.cb);
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
                i0 = 0;
                while(1) begin
                    @(cif.cb);
                    while(!cif.valid)
                        @(cif.cb);
                    res[i0] = cif.forward_pass_out;
                    $writememb(handle, res, 0);
                    i0 = i0 + 1;
                end
 
            end
        join_any
    end

    initial begin
        $readmemh("img_in_bus.txt", img);
    end
        
        
endmodule
