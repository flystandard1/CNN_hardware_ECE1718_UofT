module fix_ari_mul_tb;
    parameter WIDTH = 16;
    logic                      clk;
	logic                      rst_n;
    logic   signed [WIDTH-1:0] data_in1;
    logic   signed [WIDTH-1:0] data_in2;

    logic   signed [2*WIDTH-2:0]   data_out;
	logic   signed [2*WIDTH-2:0]   data_out_ref;
	logic   signed [WIDTH-1:0]     data_out_round;
	logic   signed [WIDTH-1:0]     data_out_ref_round;

    logic   signed [WIDTH-1:0] data_in1_dly1;
    logic   signed [WIDTH-1:0] data_in1_dly2;
    logic   signed [WIDTH-1:0] data_in1_dly3;

    logic   signed [WIDTH-1:0] data_in2_dly1;
    logic   signed [WIDTH-1:0] data_in2_dly2;
    logic   signed [WIDTH-1:0] data_in2_dly3;

	always @ (posedge clk)
		if(!rst_n) begin
            data_in1_dly1 <= 'h0;
            data_in1_dly2 <= 'h0;
            data_in1_dly3 <= 'h0;
            data_in2_dly1 <= 'h0;
            data_in2_dly2 <= 'h0;
            data_in2_dly3 <= 'h0;
        end
		else begin
		    data_in1_dly1 <= data_in1;
		    data_in1_dly2 <= data_in1_dly1;
		    data_in1_dly3 <= data_in1_dly2;
		    data_in2_dly1 <= data_in2;
		    data_in2_dly2 <= data_in2_dly1;
		    data_in2_dly3 <= data_in2_dly2;
		end


	integer i;
	integer j;
	

    fix_ari_mul
	    dut(
	    .clk     (clk),
		.rst_n   (rst_n),
        .data_in1(data_in1[WIDTH-1:0]),
		.data_in2(data_in2[WIDTH-1:0]),
		.data_out(data_out),
		.data_out_round(data_out_round)

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
	    data_in1 = -200;
		data_in2 = -10;

		while(!rst_n)
		    @(posedge clk);

        fork 
		   begin
		      for(i=0;i<100;i=i+1) begin
		         @(posedge clk)
		         data_in1 = data_in1 + 10;
		         data_in2 = data_in2 + 2;
			  end
		   end
		   begin
		      @(posedge clk)
		      @(posedge clk)
		      for(j=0;j<100;j=j+1) begin
		         @(posedge clk)
		         data_out_ref = $signed(data_in1_dly3) * $signed(data_in2_dly3);
		         data_out_ref_round = {data_out_ref[2*WIDTH-2],data_out_ref[22:16],data_out_ref[15:8]};
		         if(data_out_ref == data_out)
		             $display("Correct: in1:%d, in2:%d, ref:%d, rounded ref:%d, output:%d, rounded output:%d", data_in1_dly3, data_in2_dly3, data_out_ref,data_out_ref_round,data_out,data_out_round);
		         else
		             $error  ("Error:   in1:%d, in2:%d, ref:%d, rounded ref:%d, output:%d, rounded output:%d", data_in1_dly3, data_in2_dly3, data_out_ref,data_out_ref_round,data_out,data_out_round);
			  end
		   end
		join

    end

    initial begin
       $fsdbDumpfile("fix_ari_mul.fsdb");
       $fsdbDumpvars;
       $fsdbDumpMDA();
    end		


    initial begin
    	#5000;
    	$finish();
    end

endmodule
