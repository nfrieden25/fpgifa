`timescale 1ns / 1ps
`default_nettype none

module scale(
  input wire [1:0] scale_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  output logic [10:0] scaled_hcount_out,
  output logic [9:0] scaled_vcount_out,
  output logic valid_addr_out
);
  always_comb begin

    if (scale_in == 2'b00) begin
      scaled_hcount_out = hcount_in;
      scaled_vcount_out = vcount_in;
      valid_addr_out = hcount_in < 240 && vcount_in < 320;

    end else if (scale_in == 2'b10) begin
      scaled_hcount_out = hcount_in >> 2;
      scaled_vcount_out = vcount_in >> 1;
      valid_addr_out = hcount_in < 960 && vcount_in < 640;

    end else if (scale_in == 2'b11) begin
      scaled_hcount_out = hcount_in >> 1;
      scaled_vcount_out = vcount_in >> 1;
      valid_addr_out = hcount_in < 480 && vcount_in < 640;

    end else begin
      scaled_hcount_out = hcount_in;
      scaled_vcount_out = vcount_in;
      valid_addr_out = hcount_in < 240 && vcount_in < 320;
    end

  end
endmodule


`default_nettype wire

