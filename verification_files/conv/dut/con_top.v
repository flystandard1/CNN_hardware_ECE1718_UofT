module con_top(ima, clk , rst_n, frame_start_dim_in, frame_end_dim_in, frame_start_in,line_start_in,frame_end_in,ena_in,frame_start_out,frame_end_out,line_start_out,out_valid,sig_layer_out,frame_start_dim_out,frame_end_dim_out);


parameter IMA = 8;

input [IMA-1:0] ima;
input frame_start_in,frame_end_in,line_start_in,ena_in, frame_start_dim_in,frame_end_dim_in;
output frame_start_out,frame_end_out,line_start_out,out_valid;
input clk,rst_n;
output [15:0] sig_layer_out;
output wire frame_start_dim_out;
output reg frame_end_dim_out;

parameter SENDING_IMAGE = 1'b1;
parameter IDLE          = 1'b0;

//enable conv core
reg enable;

//fsm signal
reg state;
reg[1:0] state_dly;
reg next_state;


reg [IMA-1:0]  pix_r [32*14-1:0];
reg [32*7-1:0] frame_start_r;
reg [49*8-1:0] ima_to_con;
reg [49*8-1:0] ima_to_con_dly;
reg [49*16-1:0] conv_w;
reg [15:0]     conv_b;


reg            frame_start_in_extend;
reg            frame_start_in_dly;
reg [8:0]      wri_cnt;

reg [2:0]      dim_cnt;

reg [49*16-1:0] rom_conv_w[4:0];
reg [15:0]   rom_conv_b[3919:0];

reg [9:0]      ena_cnt;

wire           valid_conv_core;
wire [15:0]    conv_layer_out;



//this fsm is used to determine when value sent to conv core is enabled
always@(posedge clk or negedge rst_n)
  if(!rst_n) begin
    state <= IDLE;
    state_dly <= 2'b0;
  end
  else begin 
    state <= next_state;
    state_dly <= {state_dly[0],state};
  end

always@(*)
  case(state)
    IDLE: 
    begin
      if(frame_start_in)
        next_state = SENDING_IMAGE;
      else
        next_state = IDLE;
    end
    SENDING_IMAGE:
    begin
      if(frame_end_in&(!frame_start_in))
        next_state = IDLE;
      else 
        next_state = SENDING_IMAGE;
    end
    default:
      next_state = IDLE;
    endcase

//conv core should not be enable when transfering the first 7 line
always@(posedge clk or negedge rst_n)
  if(!rst_n)
    frame_start_in_extend <= 1'b0;
  else if (frame_start_in_dly)
    frame_start_in_extend <= 1'b1;
  else if (wri_cnt == 32*7-1)
    frame_start_in_extend <= 1'b0;

always@(posedge clk or negedge rst_n)
  if(!rst_n)
    frame_start_in_dly    <= 1'b0;
  else
    frame_start_in_dly    <= frame_start_in;

always@(posedge clk or negedge rst_n)
  if(!rst_n)
    wri_cnt <= 0;
  else if(frame_start_in)
    wri_cnt <= 0;
  else if(ena_in&&wri_cnt==32*7-1)
    wri_cnt <= 0;
  else if(ena_in)
    wri_cnt <= wri_cnt + 1;

//write image sram
always@(posedge clk or negedge rst_n) begin
    pix_r[wri_cnt] <= ima;
    pix_r[wri_cnt+32*7] <= ima;
end

//read image sram
genvar i;
generate
    for(i=0; i<6; i=i+1) begin
      always@(posedge clk or negedge rst_n)
        if(!rst_n) begin
            ima_to_con[i*56+55:i*56   ] <= 56'h0;
        end
        else begin
            ima_to_con[i*56+7 :i*56   ] <= pix_r[wri_cnt+26+i*32];
            ima_to_con[i*56+15:i*56+ 8] <= pix_r[wri_cnt+27+i*32];
            ima_to_con[i*56+23:i*56+16] <= pix_r[wri_cnt+28+i*32];
            ima_to_con[i*56+31:i*56+24] <= pix_r[wri_cnt+29+i*32];
            ima_to_con[i*56+39:i*56+32] <= pix_r[wri_cnt+30+i*32];
            ima_to_con[i*56+47:i*56+40] <= pix_r[wri_cnt+31+i*32];
            ima_to_con[i*56+55:i*56+48] <= pix_r[wri_cnt+32+i*32];
        end
    end
endgenerate


always@(posedge clk or negedge rst_n)
  if(!rst_n) begin
      ima_to_con[6*56+55:6*56   ] <= 56'h0;
  end
  else begin
      ima_to_con[6*56+7 :6*56   ] <= pix_r[wri_cnt+26+6*32];
      ima_to_con[6*56+15:6*56+ 8] <= pix_r[wri_cnt+27+6*32];
      ima_to_con[6*56+23:6*56+16] <= pix_r[wri_cnt+28+6*32];
      ima_to_con[6*56+31:6*56+24] <= pix_r[wri_cnt+29+6*32];
      ima_to_con[6*56+39:6*56+32] <= pix_r[wri_cnt+30+6*32];
      ima_to_con[6*56+47:6*56+40] <= pix_r[wri_cnt+31+6*32];
      ima_to_con[6*56+55:6*56+48] <= ima;  //not written to memory yet
  end

reg enable_dly;

always@(posedge clk or negedge rst_n)
  if(!rst_n)
      enable <= 1'b0;
  else begin
    if(wri_cnt[4:2]==7'd0)
      enable <= 1'b0;
    else if(frame_start_in_extend)
      enable <= 1'b0;
    else if(state)
      enable <= 1'b1;
  end

always@(posedge clk or negedge rst_n)
  if(!rst_n)
    enable_dly <= 1'b0;
  else
    enable_dly <= enable;

con  con_inst(
    .clk      (clk),
    .rst_n    (rst_n),
    .enable   (enable_dly),
    .valid    (valid_conv_core),
    .wei      (conv_w), 
    .bias     (conv_b), 
    .ima      (ima_to_con_dly),
    .out_reg  (conv_layer_out)
    );

//counter of filter_dim
 always@(posedge clk or negedge rst_n) begin
   if(!rst_n)
     dim_cnt <= 3'h0;
   else begin 
     if(frame_start_dim_in)
       dim_cnt <= 3'h0;
     else if(frame_start_in)
       dim_cnt <= dim_cnt + 3'h1;
     else if(frame_end_dim_in)
       dim_cnt <= 3'h0;
   end
 end

//counter of enable to conv core
 always@(posedge clk or negedge rst_n) begin
   if(!rst_n)
     ena_cnt <= 3'h0;
   else begin 
     if(frame_start_dim_in||frame_end_dim_in)
       ena_cnt <= 3'h0;
     else if(enable)
       ena_cnt <= ena_cnt + 3'h1;
   end
 end

 always@(posedge clk or negedge rst_n) begin
   if(!rst_n)
     ima_to_con_dly <= 'd0;
   else
     ima_to_con_dly <= ima_to_con;
 end

 initial begin
     $readmemh("conv_w.txt", rom_conv_w);
 end


 initial begin
     $readmemb("conv_b.txt", rom_conv_b);
 end

 //read conv_w
 always@(posedge clk or negedge rst_n) begin
   if(!rst_n)
     conv_w <= 'd0;
   else
     conv_w <= rom_conv_w[dim_cnt];
 end

 //read conv_b
 always@(posedge clk or negedge rst_n) begin
   if(!rst_n)
     conv_b <= 'd0;
   else
     conv_b <= rom_conv_b[ena_cnt];
 end


sigmoid u_sigmoid(
    .clk(clk),
    .rst_n(rst_n),
    .ena(valid_conv_core),
    .sigmoid_in(conv_layer_out),
    .valid(out_valid),
    .sigmoid_out(sig_layer_out)
    );

//generate frame_start_dim_mid
reg frame_start_dim_mid;
reg [3:0] frame_start_extend_dly;
 always@(posedge clk or negedge rst_n) begin
   if(!rst_n)
     frame_start_extend_dly <= 4'h0;
   else
     frame_start_extend_dly <= {frame_start_extend_dly[2:0],frame_start_in_extend};
 end
 always@(posedge clk or negedge rst_n) begin
   if(!rst_n)
     frame_start_dim_mid <= 1'b0;
   else
     frame_start_dim_mid <= (dim_cnt==0) ? (frame_start_extend_dly[3]&&!frame_start_extend_dly[2]) : 1'b0;
   end

 reg[20:0] frame_end_dim_in_dly;
 always@(posedge clk or negedge rst_n) begin
   if(!rst_n)
     frame_end_dim_in_dly <= 21'h0;
   else
     frame_end_dim_in_dly <= {frame_end_dim_in_dly[19:0],frame_end_dim_in};
  end

  assign frame_end_dim_out = frame_end_dim_in_dly[20];

 reg[19:0] frame_start_dim_mid_dly;
 always@(posedge clk or negedge rst_n) begin
   if(!rst_n)
     frame_start_dim_mid_dly <= 19'h0;
   else
     frame_start_dim_mid_dly <= {frame_start_dim_mid_dly[19:0],frame_start_dim_mid};
  end

  assign frame_start_dim_out = frame_start_dim_mid_dly[19];

 reg[19:0] enable_dly20;
 always@(posedge clk or negedge rst_n) begin
   if(!rst_n)
     enable_dly20 <= 20'h0;
   else
     enable_dly20 <= {enable_dly20[18:0],enable};
  end

  assign line_start_out = !enable_dly20[19]&&enable_dly20[18];
endmodule

