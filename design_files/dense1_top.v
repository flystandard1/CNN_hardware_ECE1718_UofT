module dense1_top(
    input                clk,
    input                rst_n,
    input                ena,
    input                frame_start_in,
    input                frame_end_in,
    input  signed [15:0] dense_input,
    output               frame_start_out,
    output               frame_end_out,
    output               valid,
    output signed [15:0] dense_sigmoid_out
    
);

//output from dense_multiply_accumulator
wire          valid_mul_acc1;
wire [1919:0] dense_sum_out;

//valid signal from all 120 mul_acc_inst
wire [119:0] valid_120;

//for serializing dense_1 output
//enable signal before adding dense_b
wire       frame_start_mid1;
wire       frame_end_mid1;
wire       valid1;

//enable signal after adding dense_b, before sigmoid
reg       frame_start_mid2;
reg       frame_end_mid2;
reg       valid2;

//dense_w stored in rom
wire [9:0]    rom0_addr[119:0];
wire [1919:0] rom0_data;


//serialized dense_sum
wire signed [15:0] dense_sum_serial;
wire signed [15:0]    dense_b;

//dense_sum after executing "dense_sum[i] += dense_b[i]"
reg signed [15:0] dense_sum_serial_plus;

reg [8:0] frame_end_mid2_dly;
reg [8:0] frame_start_mid2_dly;

//assign valid_mul_acc1 = &valid_120;
assign valid_mul_acc1 = valid_120[0];

genvar i;
generate 
    for(i=0;i<120;i=i+1) begin:gen
        dense_multiply_accumulator mul_acc_inst(
            .clk      (clk), 
            .rst_n    (rst_n),   
            .ena      (ena),
            .frame_start_in   (frame_start_in),    
            .frame_end_in     (frame_end_in),
            .dense_input      (dense_input ),   
            .valid            (valid_120[i]),
            .dense_sum_out    (dense_sum_out[i*16+15:i*16]),
            .rom0_addr        (rom0_addr[i]),
            .rom0_data        (rom0_data[i*16+15:i*16])
        );
    end
endgenerate

rom_dense_w  
#(
    .DATA_WIDTH (1920),
    .ADDR_WIDTH (10)
    )
rom_dense_w_inst
(
    .clk  (clk),
    .ena  (ena),
    .addr (rom0_addr[0]),
    .q    (rom0_data)
    );

//serialize dense_sum_out
dense1_serial u_dense_serial(
    .clk          (clk),
    .rst_n        (rst_n),       
    .ena          (valid_mul_acc1),
    .dense_sum    (dense_sum_out),   
    .frame_start  (frame_start_mid1),
    .frame_end    (frame_end_mid1),
    .valid        (valid1),
    .dense_sum_serial(dense_sum_serial),
    .dense_b      (dense_b)
    );

//adding dense_b
always @ (posedge clk or negedge rst_n)
    if (!rst_n) begin
        frame_start_mid2 <= 1'b0;    
        frame_end_mid2   <= 1'b0; 
        valid2           <= 1'b0;
        dense_sum_serial_plus <= 16'h0;
    end
    else begin
        frame_start_mid2 <= frame_start_mid1;    
        frame_end_mid2   <= frame_end_mid1  ; 
        valid2           <= valid1          ;
        dense_sum_serial_plus <= dense_sum_serial + dense_b;
    end

sigmoid u_sigmoid(
    .clk(clk),
    .rst_n(rst_n),
    .ena(valid2),
    .sigmoid_in(dense_sum_serial_plus),
    .valid(valid),
    .sigmoid_out(dense_sigmoid_out)
    );

//generate output frame_start frame_end
always @ (posedge clk or negedge rst_n)
    if (!rst_n) begin
        frame_end_mid2_dly   <= 9'h0;
        frame_start_mid2_dly <= 9'h0;
    end
    else begin
        frame_end_mid2_dly   <= {frame_end_mid2_dly[7:0],frame_end_mid2};
        frame_start_mid2_dly <= {frame_start_mid2_dly[7:0],frame_start_mid2};
    end

assign frame_end_out    = frame_end_mid2_dly[8];
assign frame_start_out  = frame_start_mid2_dly[8];
endmodule


