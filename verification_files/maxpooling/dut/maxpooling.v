module maxpooling(
	input wire        clk,
	input wire        rst_n,
    input wire        ena,
	input wire        frame_start_in,
	input wire        line_start_in,
	input wire        frame_end_in,
	input wire signed [15:0] sig_layer,
	output reg signed [15:0] max_layer,
	output reg        frame_start_out,
	output reg        line_start_out,
	output reg        frame_end_out,
	output reg        valid
	);

parameter IDLE      = 3'b001;
parameter WRITE_REG = 3'b010;
parameter READ_REG  = 3'b100;

//fsm state
reg [3:0]     state;
reg [3:0]     next_state;

//sram signals
reg           sram0_en   ;
reg           sram0_wen  ;
reg  signed [15:0]   sram0_wdata;
reg  [4:0]    sram0_addr ;
wire signed [15:0]   sram0_rdata;

//delayed signals
reg  signed [15:0]   sig_layer_dly1;
reg  signed [15:0]   sig_layer_dly2;
reg  signed [15:0]   sram0_rdata_dly1; 
wire signed [15:0]   max_value;
reg           sram0_addr_dly; //delay bit 0 of sram0_addr 
reg           state_read_dly;
reg           frame_end_in_dly;

reg           frame_start_reg;

// FSM for write/read 
always @(posedge clk or negedge rst_n)
	if(!rst_n)
		state <= IDLE;
	else 
	    state <= next_state;

always @(*)
	case(state)
	    IDLE:  
	    	next_state = frame_start_in ? WRITE_REG : IDLE;
        WRITE_REG:   // odd line: write SRAM
	    	next_state = line_start_in  ? READ_REG  : WRITE_REG;
        READ_REG:    // even line: read SRAM
	    	next_state = frame_end_in  ? IDLE : (line_start_in  ? WRITE_REG  : READ_REG);
        default:
	        next_state = IDLE;
	endcase
		

// sгam0 write enable (combiantional logic)
always @ (*) 
    if(state==WRITE_REG)
		sram0_wen   = 1'b1;
    else 
		sram0_wen   = 1'b0;

// sram0 enable (combinational logic)
always @ (*) 
    if(state==WRITE_REG||state==READ_REG)
		sram0_en   = ena;
    else 
		sram0_en   = 1'b0;

// sram0 write data (combinational logic)
assign sram0_wdata = sig_layer;  

// sram0 write address (used as a counter in a line)
always @ ( posedge clk or negedge rst_n)
    if (!rst_n)
        sram0_addr  <= 5'd0;
	else if(line_start_in)
        sram0_addr  <= 5'd0;
	else if (ena) begin
        sram0_addr <= sram0_addr + 5'd1;  
	end    



// sig_layer delay (values for max4)
always @ ( posedge clk or negedge rst_n)
    if (!rst_n) begin
        sig_layer_dly1 <= 16'h0;
        sig_layer_dly2 <= 16'h0;
	end
	else begin
	    sig_layer_dly1 <= sig_layer; 
        sig_layer_dly2 <= sig_layer_dly1; 
	end

// sram read data delay (values for max4)
always @ ( posedge clk or negedge rst_n)
    if (!rst_n)
	    sram0_rdata_dly1 <= 16'h0;
	else
	    sram0_rdata_dly1 <= sram0_rdata;

// sram read data delay (values for max4)
always @ ( posedge clk or negedge rst_n)
    if (!rst_n) begin
	    sram0_addr_dly <= 1'b0;
		state_read_dly <= 1'b0;
	end
	else begin
	    sram0_addr_dly <= sram0_addr[0];
		state_read_dly <= (state==READ_REG);
    end

//max_layer output
always @ ( posedge clk or negedge rst_n)
    if (!rst_n) begin
	    valid <= 1'b0;
		max_layer <= 'h0; 
	end
    else if (sram0_addr_dly && !sram0_addr[0] && state_read_dly)begin //sram_ddr[0] rising edge
	    valid <= 1'b1;
		max_layer <= max_value; 
    end
    else begin
        valid <= 1'b0;
		max_layer <= max_value; 
    end

//line_start_out
always @ ( posedge clk or negedge rst_n)
    if (!rst_n) 
	    line_start_out <= 1'b0;
    else if (sram0_addr == 5'h1 && !sram0_addr_dly   && state_read_dly)
	    line_start_out <= 1'b1;
    else
        line_start_out <= 1'b0;

//widen frame_start_in
always @ ( posedge clk or negedge rst_n)
    if (!rst_n) 
	    frame_start_reg <= 1'b0;
    else if (frame_start_in)
	    frame_start_reg <= frame_start_in;
	else if (sram0_addr == 5'h1 && state_read_dly)
	    frame_start_reg <= 1'b0;

//frame_start_out
always @ ( posedge clk or negedge rst_n)
    if (!rst_n) begin
	    frame_start_out <= 1'b0;
	end
    else begin
	    frame_start_out <= (sram0_addr == 5'h1 && state_read_dly && frame_start_reg);
	end

//frame_end_out
always @ ( posedge clk or negedge rst_n)
    if (!rst_n) begin
	    frame_end_out <= 1'b0;
	    frame_end_in_dly <= 1'b0;
	end
    else begin
	    frame_end_out <= frame_end_in_dly;
	    frame_end_in_dly <= frame_end_in;
	end

sram0 u_sram
(
    .clk    (clk         ),
	.en_n   (~sram0_en   ),
	.wren_n (~sram0_wen  ),
	.data_i (sram0_wdata ),
	.data_o (sram0_rdata ),
	.addr   (sram0_addr  )
);

max4 u_max4(
    .i_0 (sig_layer_dly1),
	.i_1 (sig_layer_dly2),
	.i_2 (sram0_rdata   ),
	.i_3 (sram0_rdata_dly1),
	.o_0 (max_value     )
	);
endmodule 
