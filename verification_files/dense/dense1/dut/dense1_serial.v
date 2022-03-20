//serialize dense_sum and read out dense_b
module dense1_serial(
    input                clk,
    input                rst_n,
    input                ena,
    input  [1919:0]      dense_sum,
    output reg           frame_start,
    output reg           frame_end,
    output reg           valid,
    output reg signed [15:0]    dense_sum_serial,
    output reg signed [15:0]    dense_b,
    //read counter of dense_sigmoid_reg
    output reg [6:0]     reg_cnt
    );



//reg for storing dense_sum
reg [15:0] dense_sum_reg[119:0];

//enable signal for reading dense_sigmoid_reg
reg       ena_read_reg;


//serialize dense_sum
//--------------------------------------------------------
//generate frame_start signal
always @ (posedge clk or negedge rst_n)
    if (!rst_n)
        frame_start <= 1'b0;
    else if (ena)
        frame_start <= 1'b1;
    else
        frame_start <= 1'b0;

//generate frame_end signal
always @ (posedge clk or negedge rst_n)
    if (!rst_n)
        frame_end <= 1'b0;
    else if (reg_cnt==7'd119)
        frame_end <= 1'b1;
    else
        frame_end <= 1'b0;

//store dense_sum
genvar i;
generate 
    for(i=0;i<120;i=i+1) begin:gen
        always @ (posedge clk or negedge rst_n)
            if (!rst_n)
                dense_sum_reg[i] <= 16'h0;
            else if(ena)
                dense_sum_reg[i] <= dense_sum[i*16+15:i*16];
    end
endgenerate

//read counter of dense_sigmoid_reg
always @ (posedge clk or negedge rst_n)
    if (!rst_n)
        reg_cnt <= 7'h0;
    else if(ena)
        reg_cnt <= 7'h0;
    else if(reg_cnt==7'd119)
        reg_cnt <= 7'h0;
    else if(frame_start)
        reg_cnt <= 7'h1;
    else if(|reg_cnt)
        reg_cnt <= reg_cnt + 7'h1;

//enable signal of reading data from dense_sum_reg
always @ (posedge clk or negedge rst_n)
    if (!rst_n)
        ena_read_reg <= 1'b0;
    else if(ena)
        ena_read_reg <= 1'b1;
    else if(reg_cnt==7'd119)
        ena_read_reg <= 1'b0;

//output valid signal
always @ (posedge clk or negedge rst_n)
    if (!rst_n)
        valid <= 1'b0;
    else 
        valid <= ena_read_reg;

//load dense_sum_serial from the registers
always @ (posedge clk or negedge rst_n)
    if (!rst_n)
        dense_sum_serial <= 15'd0;
    else if(ena_read_reg)
        dense_sum_serial <= dense_sum_reg[reg_cnt];
    else
        dense_sum_serial <= 15'd0;
//--------------------------------------------------------

//read out dense_b 
rom_dense_b  
#(
    .DATA_WIDTH (16),
    .ADDR_WIDTH (8)
    )
rom_dense_b_inst
(
    .clk  (clk),
    .ena  (ena_read_reg),
    .addr ({1'b0,reg_cnt}),
    .q    (dense_b)
    );

endmodule
