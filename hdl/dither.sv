module dither (
  input wire clk_in,
  input wire rst_in,
  input wire a_valid,
  input wire [10:0] a_hcount,
  input wire [9:0] a_vcount,
  input wire [7:0] in_1,
  input wire [7:0] in_2,
  input wire [7:0] in_3,

  input wire dither_type,

  output logic dithered_pixel,
  output logic [10:0] dithered_hcount,
  output logic [9:0] dithered_vcount,
  output logic dithered_valid,

  output logic [7:0] updated_1,
  output logic [7:0] updated_2,

  input wire [7:0] threshold_in
  );

  // for floyd steinberg
  logic [7:0] c;
  logic [7:0] d;
  logic signed [11:0] new_b;
  logic signed [11:0] new_c;
  logic signed [11:0] new_d;
  logic signed [11:0] new_e;

  // for atkinson
  logic [7:0] f;
  logic [7:0] h;
  logic [7:0] i;
  logic signed [11:0] new_f;
  logic signed [11:0] new_g;
  logic signed [11:0] new_h;
  logic signed [11:0] new_i;
  logic signed [11:0] new_j;
  logic signed [11:0] new_k;

  // for both
  logic [7:0] a;
  logic [7:0] dithered_value;
  logic signed [7:0] quant_error;
  assign dithered_value = (a > threshold_in) ? 255 : 0;
  assign quant_error = a - dithered_value;

  always_comb begin
    if (dither_type == 0) begin
      new_b = ($signed(in_1) + ($signed(quant_error * $signed(7)) >>> 4));
      new_c = ($signed(c) + ($signed(quant_error * $signed(3)) >>> 4));
      new_d = ($signed(d) + ($signed(quant_error * $signed(5)) >>> 4));
      new_e = ($signed(in_2) + (quant_error >>> 4));
      new_f = 0;
      new_g = 0;
      new_h = 0;
      new_i = 0;
      new_j = 0;
      new_k = 0;

    end else begin
      new_f = $signed(f) + ($signed(quant_error) >>> 3);
      new_g = $signed(in_1) + ($signed(quant_error) >>> 3);
      new_h = $signed(h) + ($signed(quant_error) >>> 3);
      new_i = $signed(i) + ($signed(quant_error) >>> 3);
      new_j = $signed(in_2) + ($signed(quant_error) >>> 3);
      new_k = $signed(in_3) + ($signed(quant_error) >>> 3);
      new_b = 0;
      new_c = 0;
      new_d = 0;
      new_e = 0;
    end
  end

  always_ff @(posedge clk_in) begin
    if (rst_in) begin

    end else if (dither_type == 0) begin
      if (a_valid) begin
        dithered_pixel <= (a > threshold_in) ? 1 : 0;
        a <= (new_b > 255) ? 255 : (new_b < 0) ? 0 : new_b;
        c <= (new_d > 255) ? 255 : (new_d < 0) ? 0 : new_d;
        d <= (new_e > 255) ? 255 : (new_e < 0) ? 0 : new_e;
        updated_1 <= (new_c > 255) ? 255 : (new_c < 0) ? 0 : new_c;
      end
    end else begin
      if (a_valid) begin
        dithered_pixel <= (a > threshold_in) ? 1 : 0;
        a <= (new_f > 255) ? 255 : (new_f < 0) ? 0 : new_f;
        f <= (new_g > 255) ? 255 : (new_g < 0) ? 0 : new_g;
        h <= (new_i > 255) ? 255 : (new_i < 0) ? 0 : new_i;
        i <= (new_j > 255) ? 255 : (new_j < 0) ? 0 : new_j;
        updated_1 <= (new_h > 255) ? 255 : (new_h < 0) ? 0 : new_h;
        updated_2 <= (new_k > 255) ? 255 : (new_k < 0) ? 0 : new_k;
      end
    end
    dithered_valid <= a_valid;
    dithered_hcount <= a_hcount;
    dithered_vcount <= a_vcount;
  end
endmodule