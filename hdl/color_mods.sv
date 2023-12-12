  // 000: RGB
  // 001: R
  // 010: G
  // 011: B
  // 100: Y
  // 101: Cr
  // 110: Cb

module color_mods (
  input wire clk_in,

  input wire [15:0] rec_pixel,
  input wire rec_valid,
  input wire [10:0] rec_hcount,
  input wire [9:0] rec_vcount,

  input wire [2:0] selector,

  output logic [7:0] result_pixel,
  output logic result_valid, 
  output logic [10:0] result_hcount,
  output logic [9:0] result_vcount
);

  logic [7:0] r;
  logic [7:0] g;
  logic [7:0] b;
  assign r = {rec_pixel[15:11], 3'b0};
  assign g = {rec_pixel[10:5], 2'b0};
  assign b = {rec_pixel[4:0], 3'b0};
  logic [9:0] rgb_sum;
  assign rgb_sum = r + g + b;

  // might have to change these to 9 bits
  logic [7:0] y;
  logic [7:0] cr;
  logic [7:0] cb;

  // y, cr, cb will be correct after 3 cycles: 
  // need to pipeline everything else 3 cycles
  rgb_to_ycrcb rgb_to_ycrcb_m (
    .clk_in(clk_in),
    .r_in(r),
    .g_in(g),
    .b_in(b),
    .y_out(y),
    .cr_out(cr),
    .cb_out(cb)
  );

  logic [7:0] pixel_pipe [2:0];
  logic valid_pipe [2:0];
  logic [10:0] hcount_pipe [2:0];
  logic [9:0] vcount_pipe [2:0];

  logic [7:0] rgb_result;
  logic [7:0] ycrcb_result;
  always_comb begin
    rgb_result = 100;
    ycrcb_result = 100;
    case(selector) 
      3'b000: rgb_result = (rgb_sum >> 2) + (rgb_sum >> 4) + (rgb_sum >> 6);
      3'b001: rgb_result = r;
      3'b010: rgb_result = g;
      3'b011: rgb_result = b;
      3'b100: ycrcb_result = y;
      3'b101: ycrcb_result = cr;
      default: ycrcb_result = cb;
    endcase
  end

  always_ff @(posedge clk_in) begin
    // pick which value is going to go into the pipeline
    pixel_pipe[0] <= rgb_result;
    valid_pipe[0] <= rec_valid;
    hcount_pipe[0] <= rec_hcount;
    vcount_pipe[0] <= rec_vcount;
    for (int i = 1; i < 3; i = i+1)begin
      pixel_pipe[i] <= pixel_pipe[i - 1];
      valid_pipe[i] <= valid_pipe[i - 1];
      hcount_pipe[i] <= hcount_pipe[i - 1];
      vcount_pipe[i] <= vcount_pipe[i - 1];
    end
  end

  always_comb begin
    if (selector[2] == 1'b0) begin
      result_pixel = pixel_pipe[2];
    end else begin
      result_pixel = ycrcb_result;
    end
    result_valid = valid_pipe[2];
    result_hcount = hcount_pipe[2];
    result_vcount = vcount_pipe[2];
  end

endmodule