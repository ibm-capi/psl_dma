
module afu (
  // Command interface
	ah_cvalid,      // Command valid
	ah_ctag,        // Command tag
	ah_ctagpar,     // Command tag parity
	ah_com,         // Command code
	ah_compar,      // Command code parity
	ah_cabt,        // Command ABT
	ah_cea,         // Command address
	ah_ceapar,      // Command address parity
	ah_cch,         // Command context handle
	ah_csize,       // Command size
	ha_croom,       // Command room
  // Buffer interface
	ha_brvalid,     // Buffer Read valid
	ha_brtag,       // Buffer Read tag
	ha_brtagpar,    // Buffer Read tag parity
	ha_brad,        // Buffer Read address
	ah_brlat,       // Buffer Read latency
	ah_brdata,      // Buffer Read data
	ah_brpar,       // Buffer Read parity
	ha_bwvalid,     // Buffer Write valid
	ha_bwtag,       // Buffer Write tag
	ha_bwtagpar,    // Buffer Write tag parity
	ha_bwad,        // Buffer Write address
	ha_bwdata,      // Buffer Write data
	ha_bwpar,       // Buffer Write parity
  // Response interface
	ha_rvalid,      // Response valid
	ha_rtag,        // Response tag
	ha_rtagpar,     // Response tag parity
	ha_response,    // Response
	ha_rcredits,    // Response credits
	ha_rcachestate, // Response cache state
	ha_rcachepos,   // Response cache pos
  // MMIO interface
	ha_mmval,       // A valid MMIO is present
	ha_mmcfg,       // MMIO is AFU descriptor space access
	ha_mmrnw,       // 1 = read, 0 = write
	ha_mmdw,        // 1 = doubleword, 0 = word
	ha_mmad,        // mmio address
	ha_mmadpar,     // mmio address parity
	ha_mmdata,      // Write data
	ha_mmdatapar,   // Write data parity
	ah_mmack,       // Write is complete or Read is valid
	ah_mmdata,      // Read data
	ah_mmdatapar,   // Read data parity
  // Control interface
	ha_jval,        // Job valid
	ha_jcom,        // Job command
	ha_jcompar,     // Job command parity
	ha_jea,         // Job address
	ha_jeapar,      // Job address parity
	ah_jrunning,    // Job running
	ah_jdone,       // Job done
	ah_jcack,       // Acknowledge completion of LLCMD
	ah_jerror,      // Job error
	ah_jyield,      // Job yield
	ah_tbreq,       // Timebase command request
	ah_paren,       // Parity enable
	ha_pclock       // clock
);


  // Command interface
  output         ah_cvalid;      // Command valid
  output [0:7]   ah_ctag;        // Command tag
  output         ah_ctagpar;     // Command tag parity
  output [0:12]  ah_com;         // Command code
  output         ah_compar;      // Command code parity
  output [0:2]   ah_cabt;        // Command ABT
  output [0:63]  ah_cea;         // Command address
  output         ah_ceapar;      // Command address parity
  output [0:15]  ah_cch;         // Command context handle
  output [0:11]  ah_csize;       // Command size
  input  [0:7]   ha_croom;       // Command room
  // Buffer interface
  input          ha_brvalid;     // Buffer Read valid
  input  [0:7]   ha_brtag;       // Buffer Read tag
  input          ha_brtagpar;    // Buffer Read tag parity
  input  [0:5]   ha_brad;        // Buffer Read address
  output [0:3]   ah_brlat;       // Buffer Read latency
  output [0:511] ah_brdata;      // Buffer Read data
  output [0:7]   ah_brpar;       // Buffer Read parity
  input          ha_bwvalid;     // Buffer Write valid
  input  [0:7]   ha_bwtag;       // Buffer Write tag
  input          ha_bwtagpar;    // Buffer Write tag parity
  input  [0:5]   ha_bwad;        // Buffer Write address
  input  [0:511] ha_bwdata;      // Buffer Write data
  input  [0:7]   ha_bwpar;       // Buffer Write parity
  // Response interface
  input          ha_rvalid;      // Response valid
  input  [0:7]   ha_rtag;        // Response tag
  input          ha_rtagpar;     // Response tag parity
  input  [0:7]   ha_response;    // Response
  input  [0:8]   ha_rcredits;    // Response credits
  input  [0:1]   ha_rcachestate; // Response cache state
  input  [0:12]  ha_rcachepos;   // Response cache pos
  // MMIO interface
  input          ha_mmval;       // A valid MMIO is present
  input          ha_mmcfg;       // MMIO is AFU descriptor space access
  input          ha_mmrnw;       // 1 = read; 0 = write
  input          ha_mmdw;        // 1 = doubleword; 0 = word
  input  [0:23]  ha_mmad;        // mmio address
  input          ha_mmadpar;     // mmio address parity
  input  [0:63]  ha_mmdata;      // Write data
  input          ha_mmdatapar;   // Write data parity
  output         ah_mmack;       // Write is complete or Read is valid
  output [0:63]  ah_mmdata;      // Read data
  output         ah_mmdatapar;   // Read data parity
  // Control interface
  input          ha_jval;        // Job valid
  input  [0:7]   ha_jcom;        // Job command
  input          ha_jcompar;     // Job command parity
  input  [0:63]  ha_jea;         // Job address
  input          ha_jeapar;      // Job address parity
  output         ah_jrunning;    // Job running
  output         ah_jdone;       // Job done
  output         ah_jcack;       // Acknowledge completion of LLCMD
  output [0:63]  ah_jerror;      // Job error
  output         ah_jyield;      // Job yield
  output         ah_tbreq;       // Timebase command request
  output         ah_paren;       // Parity enable
  input          ha_pclock;      // clock




  parameter jReset_cmd = 8'h80;
  parameter jStart_cmd = 8'h90;


//////////////////////////////////////////////////////////////
//                                                          //
//                Generate reset singal                     //
//                                                          //
//////////////////////////////////////////////////////////////

	reg			ah_jrunning;		// Job running
	reg			reset;
	reg	[0:4]	reset_int_cnt;


	always @ (posedge ha_pclock)
	begin
		if (ha_jval & (ha_jcom == jReset_cmd))
		begin
			reset	<= 1;
			reset_int_cnt <= 8'h0;
		end
		else
		begin
			if (~&reset_int_cnt)
				reset_int_cnt	<= reset_int_cnt + 8'h1;
			if (&reset_int_cnt)
				reset	<= 0;
		end
	end


//////////////////////////////////////////////////////////////
//                                                          //
//                Generate Control Singal                   //
//                                                          //
//////////////////////////////////////////////////////////////

	reg					ah_jrunning_dly;    // Job running
	reg					ah_jdone;			// Job done
	reg					trigger_exit;		// Trigger to end the whole job

	assign ah_jerror = 64'h0;
	assign ah_paren = 1'b0;   // Enable parity
	assign ah_jcack = 1'b0;   // Dedicated mode AFU, LLCMD not supported
	assign ah_jyield = 1'b0;   // Job yield not used
	assign ah_tbreq = 1'b0;   // Timebase request not used

	always @ (posedge ha_pclock)
	begin
		ah_jdone	<= (reset & (&reset_int_cnt))
					|| (ah_jrunning_dly & (~ah_jrunning));
	end

	always @ (posedge ha_pclock)
	begin
		if (ha_jval & (ha_jcom == jReset_cmd))
			ah_jrunning <= 0;
		else if (ha_jval & (ha_jcom == jStart_cmd))
			ah_jrunning	<= 1;
		else if (trigger_exit)
			ah_jrunning	<= 0;

		ah_jrunning_dly	<= ah_jrunning;
	end



//////////////////////////////////////////////////////////////
//                                                          //
//                 Read WED from CPU side                   //
//                                                          //
//////////////////////////////////////////////////////////////

	parameter			TAG_wed = 8'hff;
	parameter			TAG_pre = 8'h80;
	parameter			Reorder_aw = 7;
	parameter			Reorder_size = 1 << Reorder_aw;

	//	8'hff			: used for WED read/write
	//	8'h00 - 8'h3f	: used for data read
	//	8'h40 - 8'h7f	: used for result write
	//	8'h80 - 8'h8f	: used for prefetch

	reg					updated_wed;
	reg		[0:63]		updated_wed_address;
	reg					new_wed;
	reg		[0:63]		wed_address;
	reg		[0:1023]	wed_data;
	reg					wed_data_val;
	reg					wed_data_val_plus;
	reg					job_working;
	wire				little_endian;

	wire	[0:31]		wed_source_size;
	wire	[0:31]		wed_result_size;
	wire	[0:63]		wed_source;			// 8 byte alignment
	wire	[0:63]		wed_result;			// 8 byte alignment
	wire	[0:31]		wed_param0;
	wire	[0:31]		wed_param1;


	always @ (posedge ha_pclock)
	begin
		if (reset)
			updated_wed	<= 0;
		else if (ha_mmval & (~ha_mmcfg) & (~ha_mmrnw) & (|ha_mmdata) & (~|ha_mmad [20:23]))
			updated_wed	<= 1;
		else if (~wed_data_val)
			updated_wed	<= 0;

		new_wed	<= (~wed_data_val) & updated_wed;
	end

	always @ (posedge ha_pclock)
	begin
		if (ha_mmval & (~ha_mmcfg) & (~ha_mmrnw) & (~|ha_mmad [20:23]))
			updated_wed_address	<= ha_mmdata;

		if ((~wed_data_val) & updated_wed)
			wed_address	<= updated_wed_address;
	end

	always @ (posedge ha_pclock)
	begin
		if (ha_bwvalid & (ha_bwtag == TAG_wed) & (~ha_bwad [5]))
			wed_data [0:511]	<= ha_bwdata;
		if (ha_bwvalid & (ha_bwtag == TAG_wed) & ha_bwad [5])
			wed_data [512:1023]	<= ha_bwdata;

		wed_data_val_plus	<= (~wed_data_val) & ha_rvalid & (ha_rtag == TAG_wed) & (ha_response == 8'h00);
	end

	always @ (posedge ha_pclock)
	begin
		if (reset)
			wed_data_val	<= 0;
		else if (wed_data_val_plus)
			wed_data_val	<= 1;
		else if (ha_rvalid & (ha_rtag == TAG_wed) & (ha_response == 8'h00))	// Writing wed succeed
			wed_data_val	<= 0;
	end


	assign little_endian = 1;

	endian_swap #(
		.BYTES(4)
	) endian_source_size (
		.data_in(wed_data[64:95]),
		.little_endian(little_endian),
		.data_out(wed_source_size)
	);

	endian_swap #(
		.BYTES(4)
	) endian_result_size (
		.data_in(wed_data[96:127]),
		.little_endian(little_endian),
		.data_out(wed_result_size)
	);

	endian_swap #(
		.BYTES(8)
	) endian_source (
		.data_in(wed_data[128:191]),
		.little_endian(little_endian),
		.data_out(wed_source)
	);

	endian_swap #(
		.BYTES(8)
	) endian_result (
		.data_in(wed_data[192:255]),
		.little_endian(little_endian),
		.data_out(wed_result)
	);

	endian_swap #(
		.BYTES(4)
	) endian_param0 (
		.data_in(wed_data[256:287]),
		.little_endian(little_endian),
		.data_out(wed_param0)
	);

	endian_swap #(
		.BYTES(4)
	) endian_param1 (
		.data_in(wed_data[288:319]),
		.little_endian(little_endian),
		.data_out(wed_param1)
	);



	reg					trigger_start;		// Trigger to start a sub-job
	reg					trigger_start_pre;	// One cycle before trigger_start

	always @ (posedge ha_pclock)
	begin
		trigger_start_pre	<= wed_data_val_plus;
		trigger_start		<= trigger_start_pre;
		trigger_exit		<= ha_mmval & (~ha_mmcfg) & (~ha_mmrnw) & (~|ha_mmdata) & (~|ha_mmad [20:23]);
											// Write 64 bit zero to trigger exit
	end

	always @ (posedge ha_pclock)
	begin
		if (reset)
			job_working	<= 0;
		else if (wed_data_val_plus)			// WED has been written
			job_working	<= 0;
		else if (trigger_start)
			job_working	<= 1;
	end


//////////////////////////////////////////////////////////////
//                                                          //
//             Read Source Data from CPU side               //
//                                                          //
//////////////////////////////////////////////////////////////


	reg					ah_cmd_ready;
	wire				read_start;				// Beigin to read data
	reg					on_reading;				// Data is being read from 8 buffers
	reg					read_done;				// All data has been read
	reg					read_first;				// the first read
	reg					read_last;				// the last read

	reg		[0:63]		read_addr;
	reg		[0:32]		read_size;				// Limited in 4GB
	reg		[0:7]		read_tag; 
	wire	[0:7]		read_bytes_max;
	wire	[0:7]		read_bytes;
	reg					read_req;
	wire				read_ack;

	reg		[0:7]						read_tag_used_num;
	reg		[0:(1<<(Reorder_aw-1))-1]	read_tag_val_list;
	wire	[0:Reorder_aw-2]			read_tag_head;

	wire								reorder_buf_rd;
	reg		[0:Reorder_aw-1]			reorder_buf_raddr;


	assign	read_start = trigger_start;

	always @ (posedge ha_pclock)
	begin
		if (reset)
			read_tag	<= 8'h0;
		else if (read_ack)
			read_tag [9-Reorder_aw:7]	<= read_tag [9-Reorder_aw:7] + 1;	// We use (Reorder_aw-1) bit counter becuase the rx buffer is (1<<Reorder_aw) depth
	end

	always @ (posedge ha_pclock)
	begin
		if (read_start)
		begin
			read_addr [0:56]	<= wed_source [0:56];
			read_addr [57:63]	<= 7'h0;		// 128 byte alignment
			read_size			<= {1'b0, wed_source_size} + wed_source [57:63];
		end
		else if (read_ack)
		begin
			read_addr	<= read_addr + read_bytes;
			read_size	<= read_size - read_bytes;
		end
	end

	always	@ (posedge ha_pclock)
	begin
		if (reset)
			read_tag_val_list	<= {(1<<(Reorder_aw-1)){1'b1}};
		else
		begin
			if (read_ack)
				read_tag_val_list [read_tag [9-Reorder_aw:7]]	<= 1'b0;
		
			if (reorder_buf_rd & reorder_buf_raddr [Reorder_aw-1])
				read_tag_val_list [reorder_buf_raddr[0:Reorder_aw-2]]	<= 1'b1;	
		end
	end

	always @ (posedge ha_pclock)
	begin
		if (reset)
			read_first	<= 0;
		else if (read_start)
			read_first	<= 1;
		else if (read_ack)
			read_first	<= 0;
	end

	always @ (posedge ha_pclock)
	begin
		if (reset)
			read_last	<= 0;
		else if (read_ack)
			read_last	<= 0;
		else
			read_last	<= (read_size <= 128);
	end

	always @ (posedge ha_pclock)
	begin
		read_done	<= read_ack & read_last;

		if (reset)
			on_reading	<= 0;
		else if (read_start)
			on_reading	<= 1;
		else if (read_ack & read_last)
			on_reading	<= 0;
	end

	assign	read_bytes = 128;

	always @ (posedge ha_pclock)
	begin
		if (reset)
			read_req	<= 0;
		else if (read_ack)
			read_req	<= 0;
		else
			read_req	<= ah_cmd_ready
						&  on_reading
						&  read_tag_val_list[read_tag_head]
						&  (read_tag_used_num < 34);
	end

	assign	read_tag_head [0:Reorder_aw-2] = read_tag [9-Reorder_aw:7] + read_req;

	always @ (posedge ha_pclock)
	begin
		if (reset)
			read_tag_used_num	<= 0;
		else if (read_ack & (~(reorder_buf_rd & reorder_buf_raddr [Reorder_aw-1])))
			read_tag_used_num	<= read_tag_used_num + 1;
		else if ((~read_ack) & (reorder_buf_rd & reorder_buf_raddr [Reorder_aw-1]))
			read_tag_used_num	<= read_tag_used_num - 1;
	end


	// To remember which read Tag is the last one for current job,
	// an end-of-job flag is pushed into the FIFO

	wire				read_route_fifo_rd;
	wire	[0:1]		read_route_ctl;
	wire				read_route_fifo_empty;


	SYNC_FIFO_WRAPPER # (Reorder_aw, 2, 8)	read_route_fifo
	(
		.reset_i(reset),
		.clk_i(ha_pclock),

		.w_en_i(read_ack),
		.w_din_i({read_first, read_last}),

		.r_en_i(read_route_fifo_rd),
		.r_dout_o(read_route_ctl),

		.full_o(),
		.empty_o(read_route_fifo_empty)
	);



//////////////////////////////////////////////////////////////
//                                                          //
//                 Write Result to CPU side                 //
//                                                          //
//////////////////////////////////////////////////////////////

	reg					job_done;
	wire				write_start;
	reg					on_writting;
	reg		[0:31]		write_left;
	reg					write_full;

	reg		[0:63]		write_addr;
	reg		[0:31]		write_size;				// Limited in 4GB
	reg		[0:7]		write_tag; 
	wire				write_last;
	reg					write_last_ack;
	reg		[0:7]		write_max;
	reg		[0:7]		write_bytes;
	reg					write_req;
	wire				write_ack;
	reg					write_comp_max;
	reg					write_comp_bytes;
	reg					write_allow;			// enough data to be upload

	wire				tx_align_done;
	wire	[0:15]		tx_align_byte;
	reg		[0:31]		write_tag_val_list;
	wire	[0:4]		write_tag_head;


	assign	write_start = trigger_start;

	always @ (posedge ha_pclock)
	begin
		if (reset)
			write_tag	<= 1<<(Reorder_aw-1);
		else if (write_ack)
			write_tag [3:7]	<= write_tag [3:7] + 5'h1;		// We use 5 bit counter because the tx buffer is 64 depth
	end

	always @ (posedge ha_pclock)
	begin
		if (write_start)
			write_addr	<= {wed_result [0:60], 3'h0};		// 8 byte alignment
		else if (write_ack)
			write_addr	<= write_addr + write_bytes;
	end

	always @ (posedge ha_pclock)
	begin
		if (write_addr [60])
			write_max	<= 8;
		else if (write_addr [59])
			write_max	<= 16;
		else if (write_addr [58])
			write_max	<= 32;
		else if (write_addr [57])
			write_max	<= 64;
		else
			write_max	<= 128;
	end

	always @ (posedge ha_pclock)
	begin
		if (|tx_align_byte [0:8])
			write_bytes <= write_max [0:7];
		else if ({1'b0, tx_align_byte [9:15]} >= write_max [0:7])
			write_bytes	<= write_max [1:7];
		else if (tx_align_byte [9:15] >= write_max [0:6])
			write_bytes	<= write_max [0:6];
		else if (tx_align_byte [9:15] >= write_max [0:5])
			write_bytes	<= write_max [0:5];
		else if (tx_align_byte [9:15] >= write_max [0:4])
			write_bytes <= write_max [0:4];
		else
			write_bytes <= 8;
	end

	always @ (posedge ha_pclock)
	begin
		if (write_ack & (write_bytes < 8))
			$stop;

		if ((!on_writting) & (|tx_align_byte))
			$stop;
	end

	always @ (posedge ha_pclock)
	begin
		write_comp_max		<= write_ack;
		write_comp_bytes	<= write_comp_max;
		write_allow			<= (|tx_align_byte [0:8]) | tx_align_done;
	end

	always	@ (posedge ha_pclock)
	begin
		if (reset)
			write_tag_val_list [0:31]	<= 32'hffffffff;
		else
		begin
			if (write_ack)
				write_tag_val_list [write_tag [3:7]]	<= 1'b0;
		
			if (ha_rvalid & ha_rtag [8-Reorder_aw] & (~ha_rtag[0]))
				write_tag_val_list [ha_rtag [3:7]]	<= 1'b1;	
		end
	end

	always @ (posedge ha_pclock)
	begin
		if (reset)
			write_last_ack	<= 0;
		else if (ah_cmd_ready & job_done)
			write_last_ack	<= 0;
		else if (write_last)
			write_last_ack	<= 1;
	end

	always @ (posedge ha_pclock)
	begin
		if (reset)
			on_writting	<= 0;
		else if (write_start)
			on_writting	<= 1;
		else if (write_last)
			on_writting	<= 0;
	end

	always @ (posedge ha_pclock)
	begin
		if (reset)
			write_req <= 0;
		else if (write_ack)
			write_req <= 0;
		else
			write_req <= ah_cmd_ready & on_writting & write_allow
						& write_tag_val_list [write_tag_head]
						& (~write_comp_max) & (~write_comp_bytes);
	end

	assign	write_tag_head [0:4] = write_tag [3:7] + write_req;

	always @ (posedge ha_pclock)
	begin
		if (trigger_start_pre)
			write_size	<= 0;
		else if (write_ack)
			write_size	<= write_size + write_bytes;
	end


	always @ (posedge ha_pclock)
	begin
		if (write_start)
			write_left	<= {wed_result_size [0:28] + (|wed_result_size [29:31]), 3'h0};
		else if (write_ack)
			write_left	<= write_left - write_bytes;
	end

	always @ (posedge ha_pclock)
	begin
		if (trigger_start)
			write_full	<= 0;
		else
			write_full	<= (~|write_left [0:23]) & (write_left [24:31] < write_bytes [0:7]);
	end


//////////////////////////////////////////////////////////////
//                                                          //
//                      Command Interface                   //
//                                                          //
//////////////////////////////////////////////////////////////


	reg	         ah_cvalid;      // Command valid
	reg	 [0:7]   ah_ctag;        // Command tag
	reg	 [0:12]  ah_com;         // Command code
	reg	 [0:63]  ah_cea;         // Command address
	reg	 [0:11]  ah_csize;       // Command size
	reg  [0:2]   ah_cabt;        // Command ABT

	reg	[0:7]			credits;
	reg					rw_priority;
	wire	[0:63]		rw_addr;
	wire	[0:7]		rw_ctag;
	wire	[0:12]		rw_com;
	wire	[0:63]		rw_size;


	assign ah_ctagpar = 1'b0;		// Command tag parity
	assign ah_compar = 1'b0;		// Command code parity
	assign ah_ceapar = 1'b0;		// Command address parity
	assign ah_cch = 16'h0;			// Command context handle

	always @ (posedge ha_pclock)
	begin
		if (on_writting)
		begin
			ah_cea		<= rw_addr;					// ACC read/write address
			ah_ctag		<= rw_ctag;
			ah_com		<= rw_com;
			ah_csize	<= rw_size;
			ah_cabt		<= 3'h0;
		end
		else if (new_wed)
		begin
			ah_cea		<= wed_address;				// Read Wed
			ah_ctag		<= TAG_wed;
			ah_com		<= 13'h0A00;
			ah_csize	<= 8'h80;
			ah_cabt		<= 3'h0;
		end
		else
		begin
			ah_cea		<= wed_address;				// Write Wed
			ah_ctag		<= TAG_wed;
			ah_com		<= 13'h0D00;
			ah_csize	<= 8'h80;
			ah_cabt		<= 3'h0;
		end
	end


	always @ (posedge ha_pclock)
	begin
		if (reset)
			credits	<= ha_croom;
		else
			credits	<= credits + (ha_rvalid ? ha_rcredits : 8'h0) - {7'h0, ah_cvalid};
	end

	always @ (posedge ha_pclock)
	begin
		ah_cmd_ready	<= (credits > 8'h4);
	end

	always @ (posedge ha_pclock)
	begin
		if (reset)
			job_done	<= 0;
		else if (job_done)
			job_done	<= 0;
		else if (write_last_ack & (&write_tag_val_list))
			job_done	<= 1;
		else if (ah_cmd_ready)
			job_done	<= 0;
	end

	always @ (posedge ha_pclock)
	begin
		ah_cvalid	<= new_wed							// Read Wed
					|| (ah_cmd_ready & job_done)		// Write Wed
					|| read_ack							// ACC Read
					|| write_ack;						// ACC Write
	end

	always @ (posedge ha_pclock)
	begin
		if (reset)
			rw_priority	<= 0;
		else if (read_ack | write_ack)
			rw_priority <= ~rw_priority;
	end


	assign read_ack		= read_req & ((~rw_priority) | (~write_req));
	assign write_ack	= write_req & (rw_priority | (~read_req));
	assign rw_addr		= write_ack ? write_addr : read_addr;
	assign rw_com		= write_ack ? 13'h0D00 : 13'h0A00;
	assign rw_size		= write_ack ? write_bytes : read_bytes;
	assign rw_ctag		= write_ack ? write_tag	: read_tag;


//////////////////////////////////////////////////////////////
//                                                          //
//     Convert the Source Data into an Isolated Stream      //
//                                                          //
//////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////
//              reorder the data for ACC              //
////////////////////////////////////////////////////////



	reg							reorder_buf_wr;
	reg		[0:Reorder_aw-1]	reorder_buf_waddr;
	reg							reorder_confirm_wr;
	reg		[0:Reorder_aw-2]	reorder_confirm_addr;
	wire	[0:Reorder_aw-1]	reorder_buf_raddr_w;
	wire	[0:511]				reorder_buf_out;

	reg		[0:(1<<(Reorder_aw-1))-1]	reorder_val_list;
	reg							reorder_buf_head_val;
	reg							reorder_error;

	always @ (*)
	begin
		reorder_buf_wr		<= ha_bwvalid & (ha_bwtag [0:8-Reorder_aw] == 0);
		reorder_buf_waddr	<= {ha_bwtag, ha_bwad [5]};
	end


//will write two cycle data into the reorder buffer, while
//response interface only confirm one cycle, so the
//reorder_val_list is only half length of the reorder buffer

	always @ (posedge ha_pclock)
	begin
		reorder_confirm_wr	<= ha_rvalid & (ha_rtag [0:8-Reorder_aw] == 0);
		reorder_confirm_addr<= ha_rtag;
	end

	always	@ (posedge ha_pclock)
	begin
		if (reset)
			reorder_val_list [0:(1<<(Reorder_aw-1))-1]	<= 0;
		else
		begin
			if (reorder_confirm_wr)
				reorder_val_list [reorder_confirm_addr]	<= 1'b1;
		
			if (reorder_buf_rd & reorder_buf_raddr [Reorder_aw-1])
				reorder_val_list [reorder_buf_raddr[0:Reorder_aw-2]]	<= 1'b0;	
		end
	end

	always	@ (posedge ha_pclock)
	begin
		if (reset)
			reorder_error	<= 0;
		else if (reorder_confirm_wr & reorder_val_list [reorder_confirm_addr])
			reorder_error	<= 1;
	end


	always	@ (posedge ha_pclock)
	begin
		if (reset)
			reorder_buf_raddr	<= 0;
		else
			reorder_buf_raddr	<= reorder_buf_raddr_w;
	end

	assign	reorder_buf_raddr_w = reorder_buf_raddr + {{(Reorder_aw-1){1'b0}}, reorder_buf_rd};


	always	@ (posedge ha_pclock)
	begin
		if (reset)
			reorder_buf_head_val	<= 0;
		else
			reorder_buf_head_val	<= (~reorder_error) & (reorder_val_list [reorder_buf_raddr_w[0:Reorder_aw-2]] | reorder_buf_raddr_w [Reorder_aw-1]);
	end


/////////////////////////  Block RAM  ///////////////////////

	BRAM_WRAPPER # (Reorder_aw, 512) reorder_buf
	(
		.clk(ha_pclock),
		.wren_i(reorder_buf_wr),
		.waddr_i(reorder_buf_waddr),
		.wdin_i(ha_bwdata),
		.raddr_i(reorder_buf_raddr_w),
		.rdout_o(reorder_buf_out)
	);

/////////////////////////////////////////////////////////////

	// 512 bit convert to 256 bit, stop one cycle
	wire				rx_data_ready;
	wire				rx_align_val;
	wire	[0:511]		rx_align_dat;
	wire	[0:6]		rx_align_byte;
	wire				rx_align_eop;

	rx_align rx_align
	(
		.clk(ha_pclock),
		.reset(reset),
		.offset_i(wed_source [57:63]),
		.rx_size_i (wed_source_size),

		.rx_val_i(reorder_buf_rd),
		.rx_dat_i(reorder_buf_out),
		.rx_ctl_i(read_route_ctl),

		.align_val_o(rx_align_val),
		.align_dat_o(rx_align_dat),
		.align_byte_o(rx_align_byte),
		.align_eop_o(rx_align_eop)
	);


	assign	reorder_buf_rd	= rx_data_ready & reorder_buf_head_val;
	assign	read_route_fifo_rd = reorder_buf_rd & reorder_buf_raddr [Reorder_aw-1];


//////////////////////////////////////////////////////////////
//                                                          //
//                      Loop back the data                  //
//                                                          //
//////////////////////////////////////////////////////////////



	wire				acc_result_ready;
	wire				acc_result_val;
	wire	[0:511]		acc_result_dat;
	wire				acc_result_eop;
	wire	[0:6]		acc_result_byte;


	loop_back loop_back
	(
		.clk(ha_pclock),
		.reset(reset),
		.acc_param0_i(wed_param0),
		.acc_param1_i(wed_param1),
	
		.acc_data_ready_o(rx_data_ready),
		.acc_data_val_i(rx_align_val),
		.acc_data_dat_i(rx_align_dat),
		.acc_data_eop_i(rx_align_eop),
		.acc_data_byte_i(rx_align_byte),
	
		.acc_result_ready_i(acc_result_ready),
		.acc_result_val_o(acc_result_val),
		.acc_result_dat_o(acc_result_dat),
		.acc_result_eop_o(acc_result_eop),
		.acc_result_byte_o(acc_result_byte)
	);



	wire	[0:511]				tx_align_dat;
	wire						tx_align_eop;


	tx_align tx_align
	(
		.clk(ha_pclock),
		.reset(reset),

		.write_ready_o(acc_result_ready),
		.write_val_i(acc_result_val),
		.write_dat_i(acc_result_dat),
		.write_eop_i(acc_result_eop),
		.write_byte_i(acc_result_byte),

		.avail_eop_o (tx_align_done),
		.avail_byte_o(tx_align_byte),
		.read_addr_offset_i (write_addr[57:63]),
		.read_val_i(write_ack),
		.read_last_ack_i(write_last),
		.read_size_i(write_bytes),
		.read_dat_o(tx_align_dat),
		.read_eop_o(tx_align_eop)
	);


//////////////////////////////////////////////////////////////
//                                                          //
//     Convert the Result Stream into Write Request         //
//                                                          //
//////////////////////////////////////////////////////////////


	wire				tx_buf_wr;
	reg					tx_buf_wr_double;
	reg		[0:5]		tx_buf_waddr;
	reg					tx_buf_rd;
	wire	[0:5]		tx_buf_raddr;
	wire	[0:511]		tx_buf_dout;

	assign	tx_buf_wr = write_ack | tx_buf_wr_double;

	always @ (posedge ha_pclock)
		tx_buf_wr_double <= write_ack & write_bytes [0];


////////////////////////////////////////////////////////
//              reorder the data for ACC              //
////////////////////////////////////////////////////////



	always @ (posedge ha_pclock)
	begin
		if (reset)
			tx_buf_waddr	<= 0;
		else if (write_ack)
			tx_buf_waddr	<= tx_buf_waddr + 1;
		else
			tx_buf_waddr	<= {write_tag [3:7], write_addr [57]};
	end


	assign	tx_buf_raddr = {ha_brtag, ha_brad [5]};
	always @ (posedge ha_pclock)
		tx_buf_rd <= ha_rvalid & ha_rtag [8-Reorder_aw] & (~ha_rtag[0]);

	assign	write_last	= (write_ack & tx_align_done & tx_align_eop & ({8'h0,write_bytes} == tx_align_byte))
						| (tx_buf_wr_double & tx_align_done & tx_align_eop & (~|tx_align_byte));


	reg					tx_buf_wr_reg;
	reg		[0:5]		tx_buf_waddr_reg;
	reg		[0:511]		tx_align_dat_reg;

	always @ (posedge ha_pclock)
	begin
		tx_buf_wr_reg		<= tx_buf_wr;
		tx_buf_waddr_reg	<= tx_buf_waddr;
		tx_align_dat_reg	<= tx_align_dat;
	end

/////////////////////////  Block RAM  ///////////////////////

	BRAM_WRAPPER # (6, 512) tx_buf
	(
		.clk(ha_pclock),
		.wren_i(tx_buf_wr_reg),
		.waddr_i(tx_buf_waddr_reg),
		.wdin_i(tx_align_dat_reg),
		.raddr_i(tx_buf_raddr),
		.rdout_o(tx_buf_dout)
	);

/////////////////////////////////////////////////////////////



	reg	[0:15]			job_counter;
	reg					tx_wed;
	reg					tx_wed_dly1;
	reg					tx_wed_dly2;
	reg					tx_wed_second;
	reg					tx_wed_second1;
	reg					tx_wed_second2;
	wire	[0:511]		tx_wed_data;
	reg		[0:511]		ah_brdata;
	reg		[0:511]		tx_buf_out_dly1;
	reg		[0:511]		tx_buf_out_dly2;



	assign	ah_brlat = 4'h3;
	assign	ah_brpar = 8'h0;

	always @ (posedge ha_pclock)
	begin
		if (reset)
			job_counter	<= 0;
		else if (trigger_start)
			job_counter	<= job_counter + 1;
	end

	assign	tx_wed_data [0:511] = {16'hffff, job_counter [8:15], job_counter [0:7],
									write_size [24:31], write_size [16:23], write_size [8:15], write_size [0:7],
									wed_data [64:511]};

	always @ (posedge ha_pclock)
	begin
		tx_wed			<= ha_brvalid & (ha_brtag == TAG_wed);
		tx_wed_dly1		<= tx_wed;
		tx_wed_dly2		<= tx_wed_dly1;		// Avoid compilor make the deday register into shift-RAM
		tx_wed_second	<= ha_brvalid & (ha_brtag == TAG_wed) & ha_brad [5];
		tx_wed_second1	<= tx_wed_second;
		tx_wed_second2	<= tx_wed_second1;
		tx_buf_out_dly1	<= tx_buf_dout;
		tx_buf_out_dly2	<= tx_buf_out_dly1;
		ah_brdata		<= tx_wed_dly2 ? (tx_wed_second2 ? wed_data [512:1023] : tx_wed_data [0:511]) : tx_buf_out_dly2;
	end


//////////////////////////////////////////////////////////////
//                                                          //
//            Accelerator with Stream Interface             //
//                                                          //
//////////////////////////////////////////////////////////////


 
  mmio m0 (
    .ha_mmval(ha_mmval),
    .ha_mmcfg(ha_mmcfg),
    .ha_mmrnw(ha_mmrnw),
    .ha_mmdw(ha_mmdw),
    .ha_mmad(ha_mmad),
    .ha_mmadpar(ha_mmadpar),
    .ha_mmdata(ha_mmdata),
    .ha_mmdatapar(ha_mmdatapar),
    .ah_mmack(ah_mmack),
    .ah_mmdata(ah_mmdata),
    .ah_mmdatapar(ah_mmdatapar),
    .parity_error(mmio_parity_err),
    .odd_parity(),
    .reset(reset),
    .ha_pclock(ha_pclock),
	.wed_data_val(wed_data_val),
	.job_working(job_working),
	.on_reading (on_reading),
	.on_writting(on_writting),
	.job_counter(job_counter),
	.write_size(write_size)
  );

endmodule

