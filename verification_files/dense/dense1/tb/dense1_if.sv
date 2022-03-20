interface dense1_if(
    input  clk,
    input  rst_n
    );
logic         ena            ;
logic         frame_start_in ;
logic         frame_end_in   ;
logic         frame_start_out ;
logic         frame_end_out   ;
logic signed [15:0]  dense_input    ;
logic signed [15:0]  dense_sigmoid_out  ;
logic         valid          ;

clocking cb @(posedge clk);
    input  rst_n;
    input  frame_start_in,frame_end_in,dense_input;
    output dense_sigmoid_out, valid, frame_start_out, frame_end_out;
endclocking   
endinterface
