module dither (
  input wire clk_in,
  input wire rst_in,
  input wire a_valid,
  input wire [10:0] a_hcount,
  input wire [9:0] a_vcount,
  input wire [8:0] b,
  input wire [8:0] e,

  output logic dithered_pixel,
  output logic [10:0] dithered_hcount,
  output logic [9:0] dithered_vcount,
  output logic dithered_valid,

  output logic [7:0] updated_pixel,

  input wire [7:0] threshold_in,
  input wire [4:0] threshold_settings
  );

  logic [8:0] a;
  logic [8:0] c;
  logic [8:0] d;
  logic [8:0] dithered_value;
  logic signed [7:0] quant_error;
  logic signed [11:0] new_b;
  logic signed [11:0] new_c;
  logic signed [11:0] new_d;
  logic signed [11:0] new_e;

  logic [7:0] threshold;

  always_comb begin
    if (threshold_settings[0] == 1'b1) begin
      threshold = threshold_in;
    end else begin
      threshold = threshold_settings[4:1] * 16;
    end
  end

  assign dithered_value = (a > threshold) ? 255 : 0; // dithered_value is either 255 or 0
  assign quant_error = a - dithered_value; // quant_error is -127 to 127
  
  assign new_b = ($signed(b) + ($signed(quant_error * $signed(7)) >>> 4));
  assign new_c = ($signed(c) + ($signed(quant_error * $signed(3)) >>> 4));
  assign new_d = ($signed(d) + ($signed(quant_error * $signed(5)) >>> 4));
  assign new_e = ($signed(e) + (quant_error >>> 4));

  always_ff @(posedge clk_in) begin
    if (rst_in)begin
      a <= 0;
      c <= 0;
      d <= 0;
      dithered_pixel <= 0;
      dithered_hcount <= 0;
      dithered_vcount <= 0;
      dithered_valid <= 0;
      updated_pixel <= 0;
    end else begin
      if (a_valid) begin
        dithered_pixel <= (a > threshold) ? 1 : 0;
        a <= (new_b > 255) ? 255 : (new_b < 0) ? 0 : new_b;
        c <= (new_d > 255) ? 255 : (new_d < 0) ? 0 : new_d;
        d <= (new_e > 255) ? 255 : (new_e < 0) ? 0 : new_e;
        updated_pixel <= (new_c > 255) ? 255 : (new_c < 0) ? 0 : new_c;

        dithered_hcount <= a_hcount;
        dithered_vcount <= a_vcount;
      end
        dithered_valid <= a_valid;
    end
  end
endmodule