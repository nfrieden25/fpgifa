module dither (
  input wire clk_in,
  input wire rst_in,
  input wire a_valid,
  input wire [10:0] a_hcount,
  input wire [9:0] a_vcount,
  input wire [7:0] b,
  input wire [7:0] e,

  output logic dithered_pixel,
  output logic [10:0] dithered_hcount,
  output logic [9:0] dithered_vcount,
  output logic dithered_valid,

  output logic [7:0] updated_pixel
  );

  logic [7:0] a;
  logic [7:0] c;
  logic [7:0] d;

  logic [7:0] dithered_value = (a > 128) ? 255 : 0;
  logic signed [8:0] quant_error = a - dithered_value;
  logic signed [8:0] new_b = ($signed(b) + quant_error);
  logic signed [8:0] new_c = ($signed(c) + quant_error);
  logic signed [8:0] new_d = ($signed(d) + quant_error);
  logic signed [8:0] new_e = ($signed(e) + quant_error);

  always_ff @(posedge clk_in) begin
    if (rst_in)begin
        
    end else begin
        dithered_pixel <= dithered_value == 255 ? 1 : 0;
        a <= (new_b > 255) ? 255 : (new_b < 0) ? 0 : new_b;
        c <= (new_d > 255) ? 255 : (new_d < 0) ? 0 : new_d;
        d <= (new_e > 255) ? 255 : (new_e < 0) ? 0 : new_e;
        updated_pixel <= (new_c > 255) ? 255 : (new_c < 0) ? 0 : new_c;

        dithered_hcount <= a_hcount;
        dithered_vcount <= a_vcount;
        dithered_valid <= a_valid;
    end
  end
endmodule

// QUESTIONS
//   all the signed logic help