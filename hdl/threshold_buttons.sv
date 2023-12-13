module threshold_buttons (
  input wire clk_in,
  input wire sys_rst,
  input wire increment,
  input wire decrement,
  input wire [6:0] amount,
  input wire [7:0] threshold_in,
  output logic [7:0] threshold_out,
  output logic valid_threshold,
  output logic [3:0] ss0_an,
  output logic [3:0] ss1_an,
  output logic [6:0] ss0_c,
  output logic [6:0] ss1_c
  );

  // FOR INCREMENT BUTTON
  // debouncer
  logic debounce_output_inc;
  debouncer btn1_db_inc(.clk_in(clk_in),
                  .rst_in(sys_rst),
                  .dirty_in(increment),
                  .clean_out(debounce_output_inc));

  // btn pulse generator
  logic btn_pulse_inc;
  logic prev_debounce_inc;
  always_ff @(posedge clk_in) begin
    if (debounce_output_inc == 1 && prev_debounce_inc == 0) begin
      btn_pulse_inc <= 1;
    end else begin
      btn_pulse_inc <= 0;
    end
    prev_debounce_inc <= debounce_output_inc;
  end

  // FOR DECREMENT BUTTON
  logic debounce_output_dec;
  debouncer btn1_db_dec(.clk_in(clk_in),
                  .rst_in(sys_rst),
                  .dirty_in(decrement),
                  .clean_out(debounce_output_dec));

  // btn pulse generator
  logic btn_pulse_dec;
  logic prev_debounce_dec;
  always_ff @(posedge clk_in) begin
    if (debounce_output_dec == 1 && prev_debounce_dec == 0) begin
      btn_pulse_dec <= 1;
    end else begin
      btn_pulse_dec <= 0;
    end
    prev_debounce_dec <= debounce_output_dec;
  end

  // counter
  always_ff @(posedge clk_in) begin
    if (sys_rst) begin
      valid_threshold <= 0;
      threshold_out <= 128;
    end else begin
      if (btn_pulse_inc) begin
        threshold_out <= threshold_in + amount;
        valid_threshold <= 1;
      end else if (btn_pulse_dec) begin
        threshold_out <= threshold_in - amount;
        valid_threshold <= 1;
      end else if (valid_threshold) begin
        valid_threshold <= 0;
      end
    end
  end

  // seven segment display
  logic [6:0] ss_c;
  seven_segment_controller mssc(.clk_in(clk_in),
                                .rst_in(sys_rst),
                                .val_in(amount),
                                .cat_out(ss_c),
                                .an_out({ss0_an, ss1_an}));
  assign ss0_c = ss_c; //control upper four digit's cathodes!
  assign ss1_c = ss_c; //same as above but for lower four digits!
  
endmodule