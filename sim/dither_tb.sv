`timescale 1ns / 1ps
`default_nettype none

module dither_tb();

  logic clk_in;
  logic rst_in;
  logic a_valid;
  logic [10:0] a_hcount;
  logic [9:0] a_vcount;
  logic [7:0] b;
  logic [7:0] e;

  logic dithered_pixel;
  logic [10:0] dithered_hcount;
  logic [9:0] dithered_vcount;
  logic dithered_valid;

  logic [7:0] updated_pixel;
  logic [3:0] threshold;

  dither dither_m (
    .clk_in(clk_in),
    .rst_in(rst_in),

    .a_valid(a_valid),
    .a_hcount(a_hcount),
    .a_vcount(a_vcount),
    .b(b),
    .e(e),

    .dithered_pixel(dithered_pixel),
    .dithered_hcount(dithered_hcount),
    .dithered_vcount(dithered_vcount),
    .dithered_valid(dithered_valid),
    .updated_pixel(updated_pixel),
    .threshold_in(threshold)
  );

  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end
  
  //initial block...this is our test simulation
  initial begin
    $dumpfile("dither_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,dither_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    #10;
    rst_in = 1;
    #10;
    rst_in = 0;

    a_valid = 1;
    a_hcount = 1;
    a_vcount = 1;
    threshold = 8;
    
    for (int i = 0; i < 8; i++) begin
      b = 100;
      e = 100;
      #10;
      $display(dithered_pixel);
    end

    // for (int i = 0; i < 2; i++) begin
    //   b = 246;
    //   e = 75;
    //   #10;
    //   $display(dithered_pixel);
    //   b = 157;
    //   e = 120;
    //   #10;
    //   $display(dithered_pixel);
    //   b = 205;
    //   e = 176;
    //   #10;
    //   $display(dithered_pixel);
    // end
    
    $display("Simulation finished");
    $finish;
  end
endmodule
`default_nettype wire