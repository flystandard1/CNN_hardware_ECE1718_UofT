interface maxpooling_if(
    input  clk,
    input  rst_n
    );
logic         ena            ;
logic         frame_start_in ;
logic         frame_end_in   ;
logic         line_start_in  ;
logic         frame_start_out;
logic         frame_end_out  ;
logic         line_start_out   ;

logic signed [15:0]  sig_layer;
logic signed [15:0]  max_layer;
logic         valid          ;

clocking cb @(posedge clk);
    input  rst_n;
    input  frame_start_in,frame_end_in,line_start_in,sig_layer;
    output max_layer, valid,frame_start_out, frame_end_out, line_start_out;
endclocking   
endinterface
