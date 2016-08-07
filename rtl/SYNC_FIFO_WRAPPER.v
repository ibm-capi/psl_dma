/* ============================================================
*
* Author(s):    chenfei
*				chenfei@cn.ibm.com
*
* Create Date:  7.01.2015
* 
* Description:  show-ahead	synchronous fifo
* ===========================================================*/

//	show-ahead	synchronous fifo

`timescale 1ns/100ps

module SYNC_FIFO_WRAPPER
(
	reset_i,
	clk_i,

	w_en_i,
	w_din_i,
	w_num_used_o,			// how many line has been used

	r_en_i,
	r_dout_o,
	r_num_val_o,			// how many line can be read

	afull_o,
	full_o,
	empty_o
);

parameter aw = 3;
parameter dw = 8;
parameter afull_t = 6;

input					reset_i;
input					clk_i;
input					w_en_i;
input	[dw-1:0]		w_din_i;
output	[aw:0]			w_num_used_o;
input					r_en_i;
output	[dw-1:0] 		r_dout_o;
output	[aw:0]			r_num_val_o;
output					afull_o;
output					full_o;
output					empty_o;


reg		[aw:0]			w_num_used_o;
reg		[aw:0]			r_num_val_o;
wire					full_o;
reg						afull_o;
reg						empty_o;


reg						w_en_dly;
wire	[aw-1:0]		write_addr;
wire	[aw-1:0]		read_addr;


reg		[aw-1:0]		raddr;
wire	[aw-1:0]		raddr_next;
reg		[aw-1:0]		waddr;
wire	[aw-1:0]		waddr_next;


assign	write_addr [aw-1:0]	= waddr [aw-1:0];
assign	waddr_next [aw-1:0]	= waddr [aw-1:0] + 1;
assign	raddr_next [aw-1:0]	= raddr [aw-1:0] + 1;
assign	read_addr [aw-1:0]	= r_en_i ? raddr_next [aw-1:0] : raddr [aw-1:0];  


always	@ (posedge clk_i)
	w_en_dly	<= w_en_i;


always	@ (posedge clk_i or posedge reset_i)
begin
	if (reset_i)
		waddr	<= 0;
	else if (w_en_i)
    	waddr 	<= waddr_next;
end


always	@ (posedge clk_i or posedge reset_i)
begin
	if (reset_i)
		raddr	<= 0;
	else if (r_en_i)
    	raddr 	<= raddr_next;
end

assign	full_o = w_num_used_o [aw];

always	@ (posedge clk_i or posedge reset_i)
begin
	if (reset_i)
		empty_o	<= 1;
	else if (w_en_dly)
		empty_o	<= 0;
	else if (r_en_i & (raddr_next == waddr))
		empty_o <= 1;
end


always	@ (posedge clk_i or posedge reset_i)
begin
	if (reset_i)
		w_num_used_o	<= 0;
	else if (w_en_i & (~r_en_i) & (~w_num_used_o [aw]))
		w_num_used_o	<= w_num_used_o + 1'b1;
	else if (r_en_i & (~w_en_i) & (|w_num_used_o))
		w_num_used_o	<= w_num_used_o - 1'b1;
end


always	@ (posedge clk_i or posedge reset_i)
begin
	if (reset_i)
		r_num_val_o	<= 0;
	else if (w_en_dly & (~r_en_i) & (~r_num_val_o [aw]))
		r_num_val_o	<= r_num_val_o + 1'b1;
	else if (r_en_i & (~w_en_dly) & (|r_num_val_o))
		r_num_val_o	<= r_num_val_o - 1'b1;
end


always	@ (posedge clk_i or posedge reset_i)
begin
	if (reset_i)
		afull_o		<= 0;
	else if ((w_num_used_o == (afull_t - 1)) & w_en_i & (~r_en_i))
		afull_o		<= 1;
	else if ((w_num_used_o == afull_t) & r_en_i & (~w_en_i))
		afull_o		<= 0;
end


//----------------------------------------------------------------------------//
//-------------------------------    RAM    ----------------------------------//
//----------------------------------------------------------------------------//



reg		[dw-1:0]		mem [(1<<aw)-1:0]; 
reg 	[aw-1:0]		addr_reg;

always @(posedge clk_i)
if (w_en_i)
	mem[write_addr] <= w_din_i;



always @(posedge clk_i)
	addr_reg <= read_addr;	

assign	r_dout_o = mem[addr_reg];


endmodule
