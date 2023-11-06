module video_sig_gen
#(
  parameter ACTIVE_H_PIXELS = 1280,
  parameter H_FRONT_PORCH = 110,
  parameter H_SYNC_WIDTH = 40,
  parameter H_BACK_PORCH = 220,
  parameter ACTIVE_LINES = 720,
  parameter V_FRONT_PORCH = 5,
  parameter V_SYNC_WIDTH = 5,
  parameter V_BACK_PORCH = 20)
(
  input wire clk_pixel_in,
  input wire rst_in,
  output logic [$clog2(TOTAL_PIXELS)-1:0] hcount_out,
  output logic [$clog2(TOTAL_LINES)-1:0] vcount_out,
  output logic vs_out,
  output logic hs_out,
  output logic ad_out,
  output logic nf_out,
  output logic [5:0] fc_out);
 
  localparam TOTAL_H = ACTIVE_H_PIXELS + H_FRONT_PORCH + H_SYNC_WIDTH + H_BACK_PORCH;
  localparam TOTAL_LINES = ACTIVE_LINES + V_FRONT_PORCH + V_SYNC_WIDTH + V_BACK_PORCH;
  localparam TOTAL_PIXELS = TOTAL_H * TOTAL_LINES;

  logic one_cycle_delay;

  assign ad_out = (hcount_out < ACTIVE_H_PIXELS) && (vcount_out < ACTIVE_LINES) && !rst_in;
  assign vs_out = (vcount_out >= ACTIVE_LINES + V_FRONT_PORCH) && (vcount_out < ACTIVE_LINES + V_FRONT_PORCH + V_SYNC_WIDTH);
  assign hs_out = (hcount_out >= ACTIVE_H_PIXELS + H_FRONT_PORCH) && (hcount_out < ACTIVE_H_PIXELS + H_FRONT_PORCH + H_SYNC_WIDTH);

  always_ff @(posedge clk_pixel_in) begin
    if (rst_in) begin
        hcount_out <= 0;
        vcount_out <= 0;
        nf_out <= 0;
        fc_out <= 0;
        one_cycle_delay <= 0;
    end else begin
        // control next values of hcount and vcount 
        one_cycle_delay <= 1;

        if (one_cycle_delay) begin
            if (hcount_out == (TOTAL_H - 1) && vcount_out == TOTAL_LINES - 1) begin
                hcount_out <= 0;
                vcount_out <= 0;
            end else if (hcount_out == (TOTAL_H - 1)) begin
                hcount_out <= 0;
                vcount_out <= vcount_out + 1;
            end else begin
                hcount_out <= hcount_out + 1;
            end 
        end

        // control nf_out and fc_out
        if (hcount_out == ACTIVE_H_PIXELS - 1 && vcount_out == ACTIVE_LINES) begin
            nf_out <= 1;
            if (fc_out == 59) begin
                fc_out <= 0;
            end else begin
                fc_out <= fc_out + 1;
            end 
        end else if (nf_out == 1) begin
            nf_out <= 0;
        end
    end 
  end

endmodule