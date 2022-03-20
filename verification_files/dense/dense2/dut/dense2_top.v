module dense2_top(
    input                clk,
    input                rst_n,
    input                ena,
    input                frame_start_in,
    input                frame_end_in,
    input  signed [15:0] dense_sigmoid,
    output reg           valid,
    output reg   [159:0] dense_sum2_out
);

wire [9:0] valid_10;

wire [9:0]    rom0_addr[9:0];
wire [159:0]  rom0_data;

reg  [15:0]   dense_b2[9:0];

wire [159:0]  dense_sum2_mid;

genvar i;
generate 
    for(i=0;i<10;i=i+1) begin:gen
        dense_multiply_accumulator mul_acc_inst(
            .clk      (clk), 
            .rst_n    (rst_n),   
            .ena      (ena),
            .frame_start_in   (frame_start_in),    
            .frame_end_in     (frame_end_in),
            .dense_input      (dense_sigmoid ),   
            .valid            (valid_10[i]),
            .dense_sum_out    (dense_sum2_mid[i*16+15:i*16]),
            .rom0_addr        (rom0_addr[i]),
            .rom0_data        (rom0_data[i*16+15:i*16])
        );
        always @ (posedge clk or negedge rst_n)
            if(!rst_n) 
                dense_sum2_out[i*16+15:i*16] <= 16'h0;
            else
                dense_sum2_out[i*16+15:i*16] <= dense_sum2_mid[i*16+15:i*16] + dense_b2[i];

    end

endgenerate

rom_dense_w2
#(
    .DATA_WIDTH (160),
    .ADDR_WIDTH (8)
    )
dense_w2_rom_inst
(
    .clk  (clk),
    .ena  (ena),
    .addr (rom0_addr[0][7:0]),
    .q    (rom0_data)
    );

always @ (posedge clk or negedge rst_n)
    if(!rst_n) begin
        dense_b2[0] <= 16'h0;
        dense_b2[1] <= 16'h0;
        dense_b2[2] <= 16'h0;
        dense_b2[3] <= 16'h0;
        dense_b2[4] <= 16'h0;
        dense_b2[5] <= 16'h0;
        dense_b2[6] <= 16'h0;
        dense_b2[7] <= 16'h0;
        dense_b2[8] <= 16'h0;
        dense_b2[9] <= 16'h0;
    end
    else begin
        dense_b2[9] <= 16'hfd41;
        dense_b2[8] <= 16'hff89;
        dense_b2[7] <= 16'hfd84;
        dense_b2[6] <= 16'h00c4;
        dense_b2[5] <= 16'h01cc;
        dense_b2[4] <= 16'h0446;
        dense_b2[3] <= 16'h0116;
        dense_b2[2] <= 16'hfd11;
        dense_b2[1] <= 16'h0012;
        dense_b2[0] <= 16'h00a8;
    end

always @ (posedge clk or negedge rst_n)
    if(!rst_n)
        valid <= 1'b0;
    else
        valid <= valid_10[0];

endmodule


