module con(wei, bias, ima, out_reg, clk, rst_n,enable,valid);

parameter DATA = 16;//original wei width
parameter EXT = 17;//extension width
parameter NUM = 49;//how many multi
parameter IMA = 8;//image width

parameter MIN = 39'sb 111_1111_1111_1111_1100_0000_0000_0000_0000_0000;
parameter MAX = 39'sb 000_0000_0000_0000_0011_1111_1111_1111_1111_1111;

input enable;
input [DATA*NUM-1:0] wei;
input [IMA*NUM-1:0] ima;
input [DATA-1:0] bias;
input clk;
input rst_n;
output signed[15:0] out_reg;
output valid;

wire [EXT*NUM-1:0] ima_0;//image after extension
wire [EXT*NUM-1:0] wei_0;//weight after extension

reg en_r1;
reg en_r2;
reg en_r3;
reg en_r4;
reg en_r5;
reg en_r6;
reg en_r7;
reg en_r8;
reg en_r9;
reg en_r10;

always@(posedge clk or negedge rst_n)
  if(!rst_n)begin
    en_r1 <= 0;
    en_r2 <= 0;
    en_r3 <= 0;
    en_r4 <= 0;
    en_r5 <= 0;
    en_r6 <= 0;
    en_r7 <= 0;
    en_r8 <= 0;
    en_r9 <= 0;
    en_r10 <= 0;
  end
  else begin
    en_r1 <= enable;
    en_r2 <= en_r1;
    en_r3 <= en_r2;
    en_r4 <= en_r3;
    en_r5 <= en_r4;
    en_r6 <= en_r5;
    en_r7 <= en_r6;
    en_r8 <= en_r7;
    en_r9 <= en_r8;
    en_r10 <= en_r9;
  end

  assign valid = en_r10;  //changed by Guoxian delay 9 cycle

  //image extend
  genvar i;
  generate
  for(i = 1;i < 50;i = i + 1)
  begin: ima_extenstion
    assign ima_0[i*17-1:(i-1)*17] = {1'b0,ima[i*8-1:(i-1)*8],{8{1'b0}}};
  end
  endgenerate

  //wei extend
  genvar k;
  generate
  for(k = 1;k < 50;k = k + 1)
  begin: wei_extenstion
    assign wei_0[k*17-1:(k-1)*17] = {wei[k*16-1],wei[k*16-1:(k-1)*16]};  //change by Guoxian [k*16-1]
  end
  endgenerate

  //mul instantiate
  reg [(EXT*2-1)*NUM-1:0] out_r1;
  wire rou_r1;
  wire [(EXT*2-1)*NUM-1:0] out_r;

  genvar j;
  generate
  for(j = 1;j < 50;j = j + 1)
  begin:mul
    fix_ari_mul #(  //change fix_air_mul to fix_ari_mul by Guoxian
      .DATA(17),
      .EX_SI(16),
      .SIGN(1),
      .INTE(8),
      .POIN(8)
    )
    u_fix_ari_mul(                        
      .data_in1(wei_0[j*17-1:(j-1)*17]), //change i to j by Guoxian
      .data_in2(ima_0[j*17-1:(j-1)*17]),
      .data_out(out_r[j*33-1:(j-1)*33]),
      //change data_out to data_out_round by Guoxian
      .clk(clk),
        .rst_n(rst_n)
      );
    end
    endgenerate

    always@(posedge clk or negedge rst_n)
      if(!rst_n)
        out_r1 <= 0;
      else
        out_r1 <= out_r;

reg signed [15:0]bias_r1;
reg signed [15:0]bias_r2;
reg signed [15:0]bias_r3;
reg signed [15:0]bias_r4;

      always@(posedge clk or negedge rst_n)
        if(!rst_n)begin
          bias_r1 <= 0;
          bias_r2 <= 0;
          bias_r3 <= 0;
          bias_r4 <= 0;
        end
        else begin
          bias_r1 <= bias;
          bias_r2 <= bias_r1;
          bias_r3 <= bias_r2;
          bias_r4 <= bias_r3;
        end

      //fisrt 25 add
      reg signed [34*25-1:0] out_r2;

      genvar a;
      generate
      for(a=1;a<25;a=a+1)
      begin:first_25
        always@(posedge clk or negedge rst_n)
          if(!rst_n)
            out_r2 <= 0;
          else
            out_r2[a*34-1:(a-1)*34] <= $signed(out_r1[33*a*2-1:33*(a*2-1)]) + $signed(out_r1[33*(a*2-1)-1:33*(a*2-2)]);
        end
        endgenerate

        always@(posedge clk or negedge rst_n)begin
          out_r2[34*25-1:34*24] <= $signed(out_r1[33*NUM-1:33*(NUM-1)]) + $signed({bias_r4,{8'h0}});//6'h0
        end

        //second 13 add
        reg signed [35*13-1:0] out_r3;
        genvar b;
        generate
        for(b=1;b<13;b=b+1)
        begin:second_13
          always@(posedge clk or negedge rst_n)
            if(!rst_n)
              out_r3 <= 0;
            else
              out_r3[35*b-1:35*(b-1)] <= $signed(out_r2[34*b*2-1:34*(b*2-1)]) + $signed(out_r2[34*(b*2-1)-1:34*(b*2-2)]);
          end
          endgenerate

          always@(posedge clk or negedge rst_n)begin
              out_r3[35*13-1:35*12] <= $signed(out_r2[34*25-1:34*24]);
          end

          //third 7 add
          reg signed [36*7-1:0] out_r4;

          genvar c;
          generate
          for(c=1;c<7;c=c+1)
          begin:third_7
            always@(posedge clk or negedge rst_n)
              if(!rst_n)
                out_r4 <= 0;
              else
                out_r4[36*c-1:36*(c-1)] <= $signed(out_r3[35*c*2-1:35*(c*2-1)]) + $signed(out_r3[35*(c*2-1)-1:35*(c*2-2)]);
            end
            endgenerate

            always@(posedge clk or negedge rst_n)begin
                out_r4[36*7-1:36*6] <= $signed(out_r3[35*13-1:35*12]);
            end

            //forth 4 add
            reg signed [37*4-1:0] out_r5;

            genvar d;
            generate
            for(d=1;d<4;d=d+1)
            begin:forth_4
              always@(posedge clk or negedge rst_n)
                if(!rst_n)
                  out_r5 <= 0;
                else
                  out_r5[37*d-1:37*(d-1)] <= $signed(out_r4[36*d*2-1:36*(d*2-1)]) + $signed(out_r4[36*(d*2-1)-1:36*(d*2-2)]);
              end
              endgenerate

              always@(posedge clk or negedge rst_n)begin
                  out_r5[37*4-1:37*3] <= $signed(out_r4[36*7-1:36*6]);
              end

              //fifth 2 add
              reg signed [38*2-1:0] out_r6;

              always@(posedge clk or negedge rst_n)
                if(!rst_n)
                  out_r6 <= 0;
                else begin
                  out_r6[37:0] <= $signed(out_r5[36:0]) + $signed(out_r5[73:37]);
                  out_r6[75:38] <= $signed(out_r5[110:74]) + $signed(out_r5[147:111]);
                end

                //final out
                reg signed [38:0] out_reg_0;

                always@(posedge clk or negedge rst_n)
                  if(!rst_n)
                    out_reg_0 <= 0;
                  else 
                    out_reg_0 <= $signed(out_r6[75:38]) + $signed(out_r6[37:0]);
                assign out_reg = (out_reg_0 > MAX) ? 16'sb0111_1111_1111_1111 :
                                 (out_reg_0 < MIN) ? 16'sb1000_0000_0000_0000 : {out_reg_0[38],out_reg_0[22:8]};
                  endmodule

