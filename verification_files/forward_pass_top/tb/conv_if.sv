interface conv_if(
    input  clk,
    input  rst_n
    );
logic         frame_start_in ;
logic         frame_start_dim_in ;
logic         frame_end_in   ;
logic         frame_end_dim_in ;
logic         line_start_in    ;
logic         frame_start_out ;
logic         frame_end_out   ;
logic         line_start_out   ;
logic         ena_in;
logic signed [7:0]   ima;
logic signed [15:0]  sig_layer;
logic signed [159:0]  forward_pass_out;

logic         valid          ;

clocking cb @(posedge clk);
    input  rst_n;
    input  frame_start_in,frame_end_in,ena_in,line_start_in,ima,frame_start_dim_in, frame_end_dim_in  ;
    output valid, forward_pass_out;
endclocking   
endinterface
