// very broken, come back to this

module threshold_calibrator #(
  parameter CALIBRATION_FRAMES = 30
) (
  input wire clk_in,
  input wire rst_in,
  input wire dithered_pixel,
  input wire dithered_valid,

  output logic [7:0] threshold_out
  );

  // for first 30ish frames: new threshold each time, count number of transitions it creates
  // go through range of thresholds, determine which one has most frame transitions

  logic [7:0] best_threshold;
  logic [16:0] highest_transitions;
  logic [16:0] current_transitions;

  logic [16:0] pixel_counter;
  logic [7:0] num_frames;

  logic old_dithered;

  always_ff @(posedge clk_in) begin
    if (rst_in)begin
      highest_transitions <= 0;
      current_transitions <= 0;
      best_threshold <= 0;
      pixel_counter <= 0;
      num_frames <= 0;
    end else begin
        if (num_frames < CALIBRATION_FRAMES) begin
            // calibration phase
            if (dithered_valid) begin
              pixel_counter <= pixel_counter + 1;
              if (dithered_pixel == ~old_dithered) begin
                  current_transitions <= current_transitions + 1;
              end
              old_dithered <= dithered_pixel; 
            end

            if (pixel_counter == 320 * 240) begin
              if (current_transitions > highest_transitions) begin
                  highest_transitions <= current_transitions;
                  best_threshold <= threshold_out;
              end 
              threshold_out <= threshold_out + (256 / CALIBRATION_FRAMES);
              num_frames <= num_frames + 1;
              pixel_counter <= 0;
            end
        end else begin
            // constant phase
            threshold_out <= best_threshold;
        end
    end
  end
endmodule