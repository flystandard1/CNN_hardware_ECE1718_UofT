module dense_multiply_accumulator(
    input                clk,
    input                rst_n,
    input                ena,
    input                frame_start_in,
    input                frame_end_in,
    input  signed [15:0] dense_input,
    output reg              valid,
    output reg signed [15:0] dense_sum_out,
    output reg [9:0]         rom0_addr,
    input signed [15:0] rom0_data
);


wire signed [30:0] mul_data_out;
wire signed [15:0] mul_data_in1;
wire signed [15:0] mul_data_in2;

reg  signed [15:0] dense_input_dly;
reg  signed [30:0] dense_sum;

reg  [3:0]  ena_dly;
reg  [4:0]  frame_end_dly;

//ram0_addr also works as a counter
always @ (posedge clk or negedge rst_n)
    if (!rst_n)
        rom0_addr <= 10'h0;
    else if (frame_start_in)
        rom0_addr <= 10'h0;
    else if (ena)
        rom0_addr <= rom0_addr + 10'h1;

//ena delay 1 cycle -> enable multiplier
//ena delay 4 cycle -> enable adder
always @ (posedge clk or negedge rst_n)
    if (!rst_n)
        ena_dly <= 4'h0;
    else
        ena_dly <= {ena_dly[2:0],ena};

always @ (posedge clk or negedge rst_n)
    if (!rst_n)
        dense_input_dly <= 16'sh0;
    else
        dense_input_dly <= dense_input;

//frame_end delay5
always @ (posedge clk or negedge rst_n)
    if (!rst_n)
        frame_end_dly <= 5'h0;
    else
        frame_end_dly <= {frame_end_dly[3:0],frame_end_in};

//dense_sum
always @ (posedge clk or negedge rst_n)
    if (!rst_n)
        dense_sum <= 31'sh0;
    else if(frame_start_in)
        dense_sum <= 31'sh0;
    else if(ena_dly[3])
        dense_sum <= dense_sum + mul_data_out;

//output register
always @ (posedge clk or negedge rst_n)
    if (!rst_n) begin
        valid <= 1'b0;
        dense_sum_out <= 16'sb0;
    end
    else begin
        valid <= frame_end_dly[4];
        dense_sum_out <= {dense_sum[30],dense_sum[22:8]};
    end
    

//single_port_rom  
//#(
//    .DATA_WIDTH (16),
//    .ADDR_WIDTH (10)
//    )
//rom
//(
//    .clk  (clk),
//    .ena  (ena),
//    .addr (rom0_addr),
//    .q    (rom0_data)
//    );

fix_ari_mul mul0(
    .clk  (clk),
    .rst_n(rst_n),
    .data_in1(dense_input_dly),
    .data_in2(rom0_data),
    .data_out(mul_data_out)
    );
endmodule

