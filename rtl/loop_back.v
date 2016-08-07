
module loop_back
(
	clk,
	reset,
	acc_param0_i,				// 32 bit user defined parameter
	acc_param1_i,				// 32 bit user defined parameter

	acc_data_ready_o,			// ready to received data, 2 cycle tolerance for val_i
	acc_data_val_i,				// current cycle is valid
	acc_data_dat_i,				// data from DMA source buffer
	acc_data_eop_i,				// last cycle of the DMA downstrem
	acc_data_byte_i,			// how many byte available in current cycle

	acc_result_ready_i,			// ready to received data, 2 cycle tolerance for val_o
	acc_result_val_o,			// current cycle is valid
	acc_result_dat_o,			// data to DMA result buffer
	acc_result_eop_o,			// last cycle of DMA upstream
	acc_result_byte_o			// how many byte available in current cycle
);

parameter	bus_width = 512;

input					clk;
input					reset;
input	[31:0]			acc_param0_i;
input	[31:0]			acc_param1_i;

output					acc_data_ready_o;
input					acc_data_val_i;
input	[bus_width-1:0]	acc_data_dat_i;
input					acc_data_eop_i;
input	[0:6]			acc_data_byte_i;

input					acc_result_ready_i;
output					acc_result_val_o;
output	[bus_width-1:0]	acc_result_dat_o;
output					acc_result_eop_o;
output	[0:6]			acc_result_byte_o;


reg						acc_data_ready_o;
reg						acc_result_val_o;
reg		[bus_width-1:0]	acc_result_dat_o;
reg						acc_result_eop_o;
reg		[0:6]			acc_result_byte_o;


always	@ (posedge clk)
begin
	acc_data_ready_o	<= acc_result_ready_i;
	acc_result_val_o	<= acc_data_val_i;
	acc_result_dat_o	<= acc_data_dat_i;
	acc_result_eop_o	<= acc_data_eop_i;
	acc_result_byte_o	<= acc_data_byte_i;
end

endmodule
