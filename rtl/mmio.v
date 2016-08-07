
module mmio (
  input          ha_mmval,
  input          ha_mmcfg,
  input          ha_mmrnw,
  input          ha_mmdw,
  input  [0:23]  ha_mmad,
  input          ha_mmadpar,
  input  [0:63]  ha_mmdata,
  input          ha_mmdatapar,
  output         ah_mmack,
  output [0:63]  ah_mmdata,
  output         ah_mmdatapar,
  output [0:1]   parity_error,
  input          odd_parity,
  input          reset,
  input          ha_pclock,
  input			wed_data_val,
  input			job_working,
  input			on_reading,
  input			on_writting,
  input	[0:15]	job_counter,
  input	[0:31]	write_size
);

  // Internal signals

  reg         cfg_read;
  reg         cfg_read_l;
  reg         cfg_write;
  reg         cfg_write_l;
  reg         mmio_read;
  reg         mmio_read_l;
  reg         mmio_write;
  reg         mmio_write_l;
  reg  [0:23] mmio_ad;
  reg         mmio_adpar;
  reg         mmio_dw;
  reg         mmio_dw_l;
  reg  [0:63] mmio_wr_data;
  reg         mmio_wr_datapar;
  reg  [0:63] mmio_rd_data;
  reg  [0:63] mmio_rd_data_l;
  reg         mmio_rd_datapar_l;
  reg         mmio_ack;
  reg         mmio_ack_l;
  reg  [0:63] cfg_data;

  wire        mmio_adpar_ul;
  wire        mmio_wr_datapar_ul;
  wire        mmio_rd_datapar;

  // Trace array signals
  reg          command_trace_val_l;
  reg  [0:7]   command_trace_wtag_l;
  reg  [0:119] command_trace_wdata_l;
  reg          response_trace_val_l;
  reg  [0:7]   response_trace_wtag_l;
  reg  [0:41]  response_trace_wdata_l;
  reg          jcontrol_trace_val_l;
  reg  [0:140] jcontrol_trace_wdata_l;
  reg          dma_trace_val_l;
  reg  [0:279] dma_trace_wdata_l;

  reg  [0:63]  trace_read_reg;

  reg         trace_rval_l;
  wire [0:23] trace_mmioad = 24'h FFFFFE;



  // Input latching

  always @ (posedge ha_pclock)
    cfg_read <= ha_mmval && ha_mmcfg && ha_mmrnw;

  always @ (posedge ha_pclock)
    cfg_read_l <= cfg_read;

  always @ (posedge ha_pclock)
    cfg_write <= ha_mmval && ha_mmcfg && !ha_mmrnw;

  always @ (posedge ha_pclock)
    cfg_write_l <= cfg_write;

  always @ (posedge ha_pclock)
    mmio_read <= ha_mmval && !ha_mmcfg && ha_mmrnw;

  always @ (posedge ha_pclock)
    mmio_read_l <= mmio_read;

  always @ (posedge ha_pclock)
    mmio_write <= ha_mmval && !ha_mmcfg && !ha_mmrnw;

  always @ (posedge ha_pclock)
    mmio_write_l <= mmio_write;

  always @ (posedge ha_pclock) begin
    if (ha_mmval)
      mmio_dw <= ha_mmdw;
  end

  always @ (posedge ha_pclock)
      mmio_dw_l <= mmio_dw;

  always @ (posedge ha_pclock) begin
    if (reset)
      mmio_ad <= 24'h0;
    if (ha_mmval)
      mmio_ad <= ha_mmad;
  end

  always @ (posedge ha_pclock) begin
    if (reset)
      mmio_adpar <= odd_parity;
    else if (ha_mmval)
      mmio_adpar <= ha_mmadpar;
  end

  always @ (posedge ha_pclock) begin
    if (reset)
      mmio_wr_data <= 64'h0;
    if (ha_mmval && !ha_mmrnw)
      mmio_wr_data <= ha_mmdata;
  end

  always @ (posedge ha_pclock) begin
    if (reset)
      mmio_wr_datapar <= odd_parity;
    if (ha_mmval && !ha_mmrnw)
      mmio_wr_datapar <= ha_mmdatapar;
  end

  // AFU descriptor
  // Offset 0x00(0), bit 31 -> AFU supports only 1 process at a time
  // Offset 0x00(0), bit 59 -> AFU supports dedicated process
  // Offset 0x30(6), bit 07 -> AFU Problem State Area Required

  always @ (posedge ha_pclock) begin
    if (mmio_ad[0:22]==0)
      cfg_data <= 64'h0000000100008010;
    else if (mmio_ad[0:22]==6)
      cfg_data <= 64'h0100000000000000;
    else
      cfg_data <= 64'h0000000000000000;
  end

  // Read data
	parameter	Version = 8'h11;

	reg	[0:63]	register_data;


	// Reading the lock_bit cause it become 1 right after the first reading
	// Writing the lock_bit cause it become 0
	// This bit can be used as mux lock
	reg			lock_bit;

	always	@ (posedge ha_pclock)
	begin
		if (reset)
			lock_bit	<= 0;
		else if (mmio_write & mmio_ad [20:23] == 4'h2)
			lock_bit	<= 0;
		else if (mmio_read & mmio_ad [20:23] == 4'h2)
			lock_bit	<= 1;
	end

	always	@ (posedge ha_pclock)
	begin
		if (mmio_ad [20:23] == 4'h2)
			register_data	<= {63'h0, lock_bit};
		else
			register_data	<= {write_size [0:31], job_counter [0:15], Version, 4'h0, on_writting, on_reading, job_working, wed_data_val};
	end


  always @ (posedge ha_pclock) begin
    if (cfg_read_l) begin
      if (mmio_dw_l)
        mmio_rd_data <= cfg_data;
      else if (mmio_ad[23])
        mmio_rd_data <= {cfg_data[0:31], cfg_data[0:31]};
      else
        mmio_rd_data <= {cfg_data[32:63], cfg_data[32:63]};
    end
    else
      mmio_rd_data <= register_data;
  end

  parity #(
    .BITS(64)
  ) rd_data_parity (
    .data(mmio_rd_data),
    .odd(odd_parity),
    .par(mmio_rd_datapar)
  );

  // MMIO acknowledge

  always @ (posedge ha_pclock)
    mmio_ack <= cfg_read_l || cfg_write_l || mmio_read_l || mmio_write_l;

  // Latched outputs

  always @ (posedge ha_pclock)
    mmio_rd_data_l <= mmio_rd_data;

  always @ (posedge ha_pclock)
    mmio_rd_datapar_l <= mmio_rd_datapar;

  always @ (posedge ha_pclock)
    mmio_ack_l <= mmio_ack;

  assign ah_mmack = mmio_ack_l;
  assign ah_mmdata = mmio_rd_data_l;
  assign ah_mmdatapar = mmio_rd_datapar_l;

  // Parity checking

  parity #(
    .BITS(24)
  ) ad_parity (
    .data(mmio_ad),
    .odd(odd_parity),
    .par(mmio_adpar_ul)
  );

  parity #(
    .BITS(64)
  ) wr_data_parity (
    .data(mmio_wr_data),
    .odd(odd_parity),
    .par(mmio_wr_datapar_ul)
  );

  assign parity_error[0] = 1'b0;//mmio_adpar ^ mmio_adpar_ul;
  assign parity_error[1] = 1'b0;//mmio_wr_datapar ^ mmio_wr_datapar_ul;

endmodule
