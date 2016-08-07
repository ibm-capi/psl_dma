
module BRAM_WRAPPER
(
	clk,
	wren_i,
	waddr_i,
	wdin_i,
	raddr_i,
	rdout_o
);

parameter	aw = 3;
parameter	dw = 8;

input				clk;
input				wren_i;
input	[aw-1:0]	waddr_i;
input	[dw-1:0]	wdin_i;
input	[aw-1:0]	raddr_i;
output	[dw-1:0]	rdout_o;


reg		[dw-1:0]		mem [(1<<aw)-1:0]; 
reg 	[aw-1:0]		addr_reg;

always @(posedge clk)
if (wren_i)
	mem[waddr_i] <= wdin_i;

always @(posedge clk)
	addr_reg <= raddr_i;	

assign	rdout_o = mem[addr_reg];

endmodule
