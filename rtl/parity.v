
module parity #(
  parameter BITS = 1
)(
  input  [0:BITS-1] data,
  input             odd,
  output            par
);

  assign par = ^{data, odd};

endmodule
