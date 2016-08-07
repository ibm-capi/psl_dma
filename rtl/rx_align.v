
module rx_align
(
	clk,
	reset,
	offset_i,
	rx_size_i,

	rx_val_i,
	rx_dat_i,
	rx_ctl_i,

	align_val_o,
	align_dat_o,
	align_byte_o,
	align_eop_o
);


input					clk;
input					reset;
input	[0:6]			offset_i;
input	[0:31]			rx_size_i;

input					rx_val_i;
input	[0:1]			rx_ctl_i;
input	[0:511]			rx_dat_i;

output					align_val_o;
output	[0:511]			align_dat_o;
output	[0:6]			align_byte_o;
output					align_eop_o;

reg						align_val_o;
reg		[0:511]			align_dat_o;
reg		[0:6]			align_byte_o;
reg						align_eop_o;

reg						rx_phase;
reg						rx_on;
reg						first_rx;
reg		[0:31]			rx_size_left;
reg						skip_first;
reg						skip_second;
reg						align_val_dly;
wire	[0:6]			align_byte;

reg						delay_val;
reg		[0:511]			rx_dat_dly;
reg		[0:31]			align_bytes;
wire	[0:6]			align_bytes_w;
reg						align_begin;
reg						align_last;
wire					align_last_w;
wire					align_val;
wire					align_eop;

always	@ (posedge clk)
begin
	if (reset)
		rx_phase	<= 0;
	else if (rx_val_i)
		rx_phase	<= ~ rx_phase;
end

always	@ (posedge clk)
begin
	if (reset)
		rx_on	<= 0;
	else if (align_val & align_eop)
		rx_on	<= 0;
	else if (rx_val_i & (~rx_phase))
		rx_on	<= 1;
end


always	@ (posedge clk)
begin
	if (reset)
		first_rx	<= 1;
	else if (align_val & align_eop)
		first_rx	<= 1;
	else if (rx_val_i & rx_phase)
		first_rx	<= 0;
end

always	@ (posedge clk)
begin
	if (align_val)
		rx_size_left	<= rx_size_left - align_byte;
	else if (~rx_on)
		rx_size_left	<= rx_size_i;
end

assign	align_byte = (|rx_size_left[0:25]) ? 64 : rx_size_left [26:31];

assign	align_eop = (~|rx_size_left[0:24]) & (rx_size_left [25:31] <= 64);

always	@ (posedge clk)
begin
	skip_first	<= |offset_i [0:3];
	skip_second	<= offset_i [0] & (|offset_i [1:3]);
end

assign	align_val	= (rx_val_i & first_rx & (~rx_phase) & (~skip_first))
					| (rx_val_i & first_rx & rx_phase & (~skip_second) & rx_on)
					| (rx_val_i & (~first_rx) & rx_on)
					| (align_val_dly & rx_on & (|rx_size_left));

always	@ (posedge clk)
	align_val_dly	<= rx_val_i & rx_ctl_i [1] & rx_phase;


always	@ (posedge clk)
	align_byte_o	<= align_byte;

always	@ (posedge clk)
begin
	align_eop_o	<= align_val & align_eop;
	align_val_o	<= align_val;

	if (rx_val_i)
		rx_dat_dly	<= rx_dat_i;
end

always	@ (posedge clk)
begin
	if (align_val)
		case (offset_i [1:3])
			0 : align_dat_o	<= rx_dat_i [0:511];
			1 : align_dat_o <= {rx_dat_dly [64:511], rx_dat_i [0:63]};
			2 : align_dat_o <= {rx_dat_dly [128:511], rx_dat_i [0:127]};
			3 : align_dat_o <= {rx_dat_dly [192:511], rx_dat_i [0:191]};
			4 : align_dat_o <= {rx_dat_dly [256:511], rx_dat_i [0:255]};
			5 : align_dat_o <= {rx_dat_dly [320:511], rx_dat_i [0:319]};
			6 : align_dat_o <= {rx_dat_dly [384:511], rx_dat_i [0:383]};
			7 : align_dat_o <= {rx_dat_dly [448:511], rx_dat_i [0:447]};
		endcase
end

endmodule
