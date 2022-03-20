interface conv_core_if(
    input  clk,
    input  rst_n
    );
logic         enable;
logic [49*16-1:0] wei;
logic [49*16-1:0] ima;
logic signed [15:0]  bias;
logic         valid ;
logic [15:0]  out_reg;

clocking cb @(posedge clk);
    input  rst_n;
    input  enable,wei,bias,ima;
    output valid, out_reg;
endclocking   
endinterface
