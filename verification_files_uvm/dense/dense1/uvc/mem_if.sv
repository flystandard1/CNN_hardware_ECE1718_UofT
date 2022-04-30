interface mem_if(
    input  clk,
    input  rst_n
    );

int signed dense_w[980][120];
int signed dense_b[120];

clocking cb @(posedge clk);
    input  rst_n;
    output dense_w,dense_b;
endclocking   
endinterface
