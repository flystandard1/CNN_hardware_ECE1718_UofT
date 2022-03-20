module forward_pass_top(
input clk,
input rst_n,
input [7:0] ima,
input frame_start_in,
input frame_end_in,
input line_start_in,
input ena_in, 
input frame_start_dim_in,
input frame_end_dim_in,
output valid,
output [159:0] forward_pass_out
);

wire [15:0] sig_layer_out;
wire frame_start_dim_out_conv;
wire frame_end_dim_out_conv;
wire line_start_out_conv;
wire out_valid_conv           ;

wire [15:0] max_layer_out;
wire frame_start_out_maxpooling;
wire frame_end_out_maxpooling;
wire line_start_out_maxpooling     ;
wire out_valid_maxpooling          ;

wire frame_start_out_dense1;
wire frame_end_out_dense1;
wire out_valid_dense1;
wire [15:0] dense1_out;

con_top u_con_top(
.clk                 (clk           ),    
.rst_n               (rst_n         ),       
.ima                 (ima           ),     
.frame_start_in      (frame_start_in),                
.frame_end_in        (frame_end_in  ),              
.line_start_in       (line_start_in ),               
.ena_in              (ena_in        ),         
.frame_start_dim_in  ( frame_start_dim_in), 
.frame_end_dim_in    ( frame_end_dim_in ),             
.sig_layer_out       (sig_layer_out),                 
.frame_start_dim_out (frame_start_dim_out_conv),                    
.line_start_out      (line_start_out_conv),                    
.frame_end_dim_out   (frame_end_dim_out_conv),                    
.out_valid           (out_valid_conv)
);

maxpooling u_maxpooling(
	.clk             (clk           ),              
	.rst_n           (rst_n         ),                 
    .ena             (out_valid_conv       ),
	.frame_start_in  (frame_start_dim_out_conv),                       
	.line_start_in   (line_start_out_conv),                            
	.frame_end_in    (frame_end_dim_out_conv),                        
	.sig_layer        (sig_layer_out),              
	.max_layer       (max_layer_out),                        
	.frame_start_out (frame_start_out_maxpooling),                     
	.frame_end_out   (frame_end_out_maxpooling),                     
	.line_start_out  (line_start_out_maxpooling     ),                    
	.valid           (out_valid_maxpooling          ) 
	);

dense1_top u_dense1_top(
    .clk             (clk           ),       
    .rst_n           (rst_n         ),    
    .ena              (out_valid_maxpooling          ),    
    .frame_start_in    (frame_start_out_maxpooling),          
    .frame_end_in       (frame_end_out_maxpooling),        
    .dense_input      (max_layer_out),        
    .frame_start_out     (frame_start_out_dense1),    
    .frame_end_out       (frame_end_out_dense1),    
    .valid               (out_valid_dense1),
    .dense_sigmoid_out   (dense1_out)
    
);

dense2_top u_dense2_top(
    .clk      (clk           ),         
    .rst_n    (rst_n         ),           
    .ena       (out_valid_dense1),      
    .frame_start_in    (frame_start_out_dense1),           
    .frame_end_in      (frame_end_out_dense1),        
    .dense_sigmoid     (dense1_out),        
    .valid     (valid), 
    .dense_sum2_out (forward_pass_out)
);
            
endmodule

