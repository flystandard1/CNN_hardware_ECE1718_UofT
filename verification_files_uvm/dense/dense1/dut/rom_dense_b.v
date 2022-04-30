module rom_dense_b #
(
 parameter DATA_WIDTH = 8,
 parameter ADDR_WIDTH = 8
)
(
    input                        clk,
    input                        ena,
    input       [ADDR_WIDTH-1:0] addr,
    output reg  [DATA_WIDTH-1:0] q

    );
 
 reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];

 initial begin
     $readmemh("dense_b.txt", rom);
 end

 always @ (posedge clk)begin
     if(ena)
         q <= rom[addr];
     else
         q <= 'h0;
 end
 endmodule
