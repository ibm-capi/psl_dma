
module tx_align
(
	clk,
	reset,

	write_ready_o,
	write_val_i,
	write_dat_i,
	write_eop_i,
	write_byte_i,

	avail_eop_o,			// all up-stream for the DAM is ready
	avail_byte_o,			// the available bytes for up-stream
	read_addr_offset_i,
	read_val_i,
	read_last_ack_i,
	read_size_i,
	read_dat_o,
	read_eop_o
);


///////////////////////////////////////////
//      Some rules for this module       //
//                                       //
//	write_val assert totally 2*N cycle   //
//	read_size is maximun 128             //
//	read_size is mininum 8               //
//	read_size is power of 2              //
///////////////////////////////////////////


input					clk;
input					reset;

output					write_ready_o;
input					write_val_i;
input	[0:511]			write_dat_i;
input					write_eop_i;
input	[0:6]			write_byte_i;

output					avail_eop_o;
output	[0:15]			avail_byte_o;
input	[0:6]			read_addr_offset_i;
input					read_val_i;
input					read_last_ack_i;
input	[0:7]			read_size_i;
output	[0:511]			read_dat_o;
output					read_eop_o;

reg						write_ready_o;
reg						avail_eop_o;
reg		[0:15]			avail_byte_o;
reg		[0:511]			read_dat_o;
reg						read_eop_o;



wire	[0:7]			align_fifo_wr;
wire	[0:7]			align_fifo_rd;
wire	[0:511]			align_fifo_dat;
wire	[0:7]			align_fifo_eop;
wire	[0:7]			align_fifo_afull;
wire	[0:7]			align_fifo_empty;
reg		[0:6]			write_byte_dly1;
reg		[0:6]			write_byte_dly2;
reg						write_eop_dly1;
reg						write_eop_dly2;

wire	[0:7]			fetch_data;
reg		[0:5]			read_offset;
wire	[0:7]			read_offset_next;
reg						double_line;

generate
	genvar i;

	for (i=0; i < 8; i=i+1) begin:gen_fifo_array
		SYNC_FIFO_WRAPPER # (4, 65, 8) align_fifo
		(
			.reset_i(reset),
			.clk_i(clk),

			.w_en_i(align_fifo_wr [i]),
			.w_din_i({write_dat_i[i*64:i*64+63], write_eop_i}),
			.w_num_used_o(),

			.r_en_i(align_fifo_rd[i]),
			.r_dout_o({align_fifo_dat[i*64:i*64+63], align_fifo_eop[i]}),
			.r_num_val_o(),

			.afull_o(align_fifo_afull[i]),
			.full_o(),
			.empty_o(align_fifo_empty[i])
		);

		assign	fetch_data [i]		= (read_val_i & (read_offset <= i*8) & (read_offset_next > i*8))
									| (read_val_i & (|read_size_i [0:1]))
									| (read_val_i & read_offset_next[1] & (read_offset_next [2:7] > i*8))
									| double_line;

		assign	align_fifo_wr [i]	= write_val_i & (write_byte_i > (i*8));
		assign	align_fifo_rd [i]	= fetch_data [i];

		always @ (posedge clk)
		begin
			if (align_fifo_rd[i] & align_fifo_empty[i])
				$stop;
		end
	end // gen_fifo_array
endgenerate

always @ (posedge clk)
	write_ready_o <= (~|align_fifo_afull);

always @ (posedge clk)
begin
	write_byte_dly1	<= write_val_i ? write_byte_i : 0;
	write_byte_dly2	<= {write_byte_dly1 [0:3] + (|write_byte_dly1 [4:6]), 3'h0};

	write_eop_dly1	<= write_val_i & write_eop_i;
	write_eop_dly2	<= write_eop_dly1;
end

always @ (posedge clk)
begin
	if (reset)
		avail_eop_o		<= 0;
	else if ( read_eop_o & (~|avail_byte_o [0:7])
			& (   (read_val_i & (read_size_i [0:7] == avail_byte_o [8:15]))
				| (double_line & (~|avail_byte_o [8:15])))
			)
		avail_eop_o		<= 0;
	else if (write_eop_dly2)
		avail_eop_o		<= 1;
end

always @ (posedge clk)
begin
	if (reset)
		avail_byte_o	<= 0;
	else
		avail_byte_o	<= avail_byte_o + write_byte_dly2
						-  (read_val_i ? read_size_i : 0);
end



always @ (posedge clk)
	double_line	<= read_val_i & read_size_i [0];

assign	read_offset_next	= {1'b0, read_offset} + (read_val_i ? read_size_i : 7'h0);

always @ (posedge clk)
begin
	if (reset)
		read_offset	<= 0;
	else if (read_last_ack_i)
		read_offset	<= 0;
	else
		read_offset	<= read_offset_next;
end

wire	[0:5]		out_in_offset;

assign	out_in_offset = read_addr_offset_i [1:6] - read_offset;

always @ (*)
begin
	case (out_in_offset [0:2])
		0 : read_dat_o <= align_fifo_dat [0:511];
		1 : read_dat_o <= {align_fifo_dat [448:511], align_fifo_dat [0:447]};
		2 : read_dat_o <= {align_fifo_dat [384:511], align_fifo_dat [0:383]};
		3 : read_dat_o <= {align_fifo_dat [320:511], align_fifo_dat [0:319]};
		4 : read_dat_o <= {align_fifo_dat [256:511], align_fifo_dat [0:255]};
		5 : read_dat_o <= {align_fifo_dat [192:511], align_fifo_dat [0:191]};
		6 : read_dat_o <= {align_fifo_dat [128:511], align_fifo_dat [0:127]};
		7 : read_dat_o <= {align_fifo_dat [64:511], align_fifo_dat [0:63]};
	endcase
end

always @ (*)
	read_eop_o	<= |((~align_fifo_empty) & align_fifo_eop);

endmodule
