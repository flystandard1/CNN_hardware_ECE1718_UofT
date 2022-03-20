interface sigmoid_if(
    input  clk,
    input  rst_n
    );
logic         ena            ;
logic signed [15:0]  sigmoid_in ;
logic signed [15:0]  sigmoid_out  ;
logic         valid          ;

clocking cb @(posedge clk);
    input  rst_n;
    input  ena, sigmoid_in;
    output sigmoid_out, valid;
endclocking   
endinterface
