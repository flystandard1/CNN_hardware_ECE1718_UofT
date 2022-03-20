import "DPI-C" function int sigmoid_model(input int x);
module sigmoid_tb;

logic clk;
logic rst_n;

int signed in_tr;
int signed in_tr_ref;
int signed out_tr;
int signed out_tr_ref;

sigmoid_if sif(.clk(clk),.rst_n(rst_n));

sigmoid dut(
    .clk  (clk),
    .rst_n(rst_n),
    .ena  (sif.ena),
    .sigmoid_in(sif.sigmoid_in),
    .valid (sif.valid),
    .sigmoid_out (sif.sigmoid_out)
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
    fork
        //driver
        begin
            while(!rst_n) 
                @(sif.cb);
            sif.ena = 1'b0;
            sif.sigmoid_in = 'd0;
            in_tr = -1972;
            @(sif.cb);
            for(int i=0;i<3584;i=i+1) begin //3584
                sif.ena = 1'b1;
                sif.sigmoid_in = in_tr;
                in_tr = in_tr + 'sb1;
                @(sif.cb);
                sif.ena = 1'b0;
                @(sif.cb);
            end
            repeat(10)
                @(sif.cb);
        end
        //monitor + reference model + scoreboard
        begin
            in_tr_ref = -1972;
            while(!rst_n) 
                @(sif.cb);
            while(1) begin
                if(sif.valid) begin 
                    out_tr = sif.sigmoid_out;
                    out_tr_ref=sigmoid_model(in_tr_ref);
                    in_tr_ref = in_tr_ref + 1;
                    if(out_tr != out_tr_ref)
                        $error("input:%d, expected: %d, actuall: %d\n",in_tr_ref, out_tr_ref, out_tr);
                end
                @(sif.cb);
            end
        end
    join_any
end



initial begin
   $fsdbDumpfile("sigmoid.fsdb");
   $fsdbDumpvars;
   $fsdbDumpMDA();
end		


initial begin
	#400000;
	$finish();
end


endmodule
