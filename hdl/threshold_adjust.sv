module threshold_adjust (
  input wire clk_in,
  input wire rst_in,
  input wire dithered_pixel,
  input wire dithered_valid,
  input wire [7:0] threshold_in,

  output logic [7:0] threshold_out
  );

  logic [16:0] pixel_address; // can hold up to the number of pixels in a frame

  logic [16:0] curr_frame_transitions;
  logic [16:0] old_frame_transitions;

  logic adjustment; // 0 = decreased threshold, 1 = increased threshold

  logic old_dithered;

  always_ff @(posedge clk_in) begin
    if (rst_in)begin
        threshold_out <= 60;
        adjustment <= 0;
    end else begin
        if (dithered_valid) begin
            pixel_address <= pixel_address + 1;
            if (dithered_pixel == ~old_dithered) begin
                curr_frame_transitions <= curr_frame_transitions + 1;
            end
            old_dithered <= dithered_pixel;
        end

        // frame almost done, do the analysis
        if (pixel_address == 320 * 240 - 1) begin
            // frame complete
            if (curr_frame_transitions < old_frame_transitions) begin
                // last adjustment made it worse! should be changed 
                adjustment <= ~adjustment;
            end 
            old_frame_transitions <= curr_frame_transitions;
            curr_frame_transitions <= 0;
        end

        // frame done, adjust threshold for next frame
        else if (pixel_address == 320 * 240) begin
            if (adjustment) begin
                threshold_out <= threshold_in > 5 ? threshold_in - 5 : threshold_in;
            end else begin
                threshold_out <= threshold_in < 250 ? threshold_in + 5 : threshold_in;
            end
            pixel_address <= 0;
        end
    end
  end
endmodule