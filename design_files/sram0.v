module sram0 # (
			parameter DATA_WIDTH = 16,
			parameter ADDR_WIDTH = 5

)
(
    input  clk,
	input  en_n,
	input  wren_n,
	input  [ADDR_WIDTH-1:0] addr,
	input  [DATA_WIDTH-1:0] data_i,
	output reg [DATA_WIDTH-1:0] data_o
	);

reg     [DATA_WIDTH-1:0]   register[2**ADDR_WIDTH-1:0];

always @(posedge clk)begin
     if(!wren_n && !en_n)
         register[addr] <= data_i;
end
always @(posedge clk)begin
     if(wren_n && !en_n)
         data_o <= register[addr];
end
endmodule
