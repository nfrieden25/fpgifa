module line_buffers (
  input wire clk_in,
  input wire rst_in,

  input wire [7:0] bw_pixel,
  input wire [10:0] bw_hcount,
  input wire [9:0] bw_vcount,
  input wire bw_pixel_valid,

  input wire [7:0] updated_1,
  input wire [7:0] updated_2,
  input wire [2:0] dither_settings, 

  output logic [7:0] out_1,
  output logic [7:0] out_2,
  output logic [7:0] out_3,
  output logic [10:0] a_hcount,
  output logic [9:0] a_vcount,
  output logic a_valid
  );

  localparam FRAME_WIDTH = 320;
  logic [7:0] unused_0;
  logic [7:0] unused_1;
  logic [7:0] unused_2;
  logic [7:0] unused_3;

  logic [$clog2(FRAME_WIDTH-1)-1:0] write_ptr_0;
  logic [$clog2(FRAME_WIDTH-1)-1:0] write_ptr_1;
  logic [$clog2(FRAME_WIDTH-1)-1:0] write_ptr_2;
  logic [$clog2(FRAME_WIDTH-1)-1:0] write_ptr_3;
  logic [7:0] write_data_0;
  logic [7:0] write_data_1;
  logic [7:0] write_data_2;
  logic [7:0] write_data_3;
  logic write_enable_0;
  logic write_enable_1;
  logic write_enable_2;
  logic write_enable_3;
  logic [$clog2(FRAME_WIDTH-1)-1:0] read_ptr_0;
  logic [$clog2(FRAME_WIDTH-1)-1:0] read_ptr_1;
  logic [$clog2(FRAME_WIDTH-1)-1:0] read_ptr_2;
  logic [$clog2(FRAME_WIDTH-1)-1:0] read_ptr_3;
  logic [7:0] read_data_0;
  logic [7:0] read_data_1;
  logic [7:0] read_data_2;
  logic [7:0] read_data_3;

  logic [1:0] line_mux;

  // [14] = 0: real dithering
  // [14] = 1: fake dithering
  // [13] = 0: floyd steinberg
  // [13] = 1: atkinson
  // [12] = 1: freeze frame

  // MUX EVERYTHING INTO RIGHT ROLES
  always_comb begin
    if (dither_settings[2] == 0 && dither_settings[1] == 1) begin
      // atkinson dithering
      if (line_mux == 0) begin
        write_enable_0 = 1'b0;
        write_ptr_0 = 0;
        write_data_0 = 0;
        read_ptr_0 = bw_hcount;
        out_1 = read_data_0;

        write_ptr_1 = bw_hcount - 3;
        write_data_1 = updated_1;
        write_enable_1 = 1'b1;
        read_ptr_1 = bw_hcount - 1;
        out_2 = read_data_1;

        write_ptr_2 = bw_hcount - 2;
        write_data_2 = updated_2;
        write_enable_2 = 1'b1;
        read_ptr_2 = bw_hcount - 2;
        out_3 = read_data_2;

        write_ptr_3 = bw_hcount;
        write_data_3 = bw_pixel;
        write_enable_3 = bw_pixel_valid;
        read_ptr_3 = 0;

      end else if (line_mux == 1) begin
        write_enable_1 = 1'b0;
        write_ptr_1 = 0;
        write_data_1 = 0;
        read_ptr_1 = bw_hcount;
        out_1 = read_data_1;

        write_ptr_2 = bw_hcount - 3;
        write_data_2 = updated_1;
        write_enable_2 = 1'b1;
        read_ptr_2 = bw_hcount - 1;
        out_2 = read_data_2;
 
        write_ptr_3 = bw_hcount - 2;
        write_data_3 = updated_2;
        write_enable_3 = 1'b1;
        read_ptr_3 = bw_hcount - 2;
        out_3 = read_data_3;

        write_ptr_0 = bw_hcount;
        write_data_0 = bw_pixel;
        write_enable_0 = bw_pixel_valid;
        read_ptr_0 = 0;
        
      end else if (line_mux == 2) begin
        write_enable_2 = 1'b0;
        write_ptr_2 = 0;
        write_data_2 = 0;
        read_ptr_2 = bw_hcount;
        out_1 = read_data_2;

        write_ptr_3 = bw_hcount - 3; 
        write_data_3 = updated_1;
        write_enable_3 = 1'b1;
        read_ptr_3 = bw_hcount - 1;
        out_2 = read_data_3;
  
        write_ptr_0 = bw_hcount - 2;
        write_data_0 = updated_2;
        write_enable_0 = 1'b1;
        read_ptr_0 = bw_hcount - 2;
        out_3 = read_data_0;

        write_ptr_1 = bw_hcount;
        write_data_1 = bw_pixel;
        write_enable_1 = bw_pixel_valid;
        read_ptr_1 = 0;

      end else begin
        write_enable_3 = 1'b0;
        write_ptr_3 = 0;
        write_data_3 = 0;
        read_ptr_3 = bw_hcount;
        out_1 = read_data_3;

        write_ptr_0 = bw_hcount - 3;
        write_data_0 = updated_1; 
        write_enable_0 = 1'b1;
        read_ptr_0 = bw_hcount - 1;
        out_2 = read_data_0;
  
        write_ptr_1 = bw_hcount - 2;
        write_data_1 = updated_2;
        write_enable_1 = 1'b1;
        read_ptr_1 = bw_hcount - 2;
        out_3 = read_data_1;

        write_ptr_2 = bw_hcount;
        write_data_2 = bw_pixel;
        write_enable_2 = bw_pixel_valid;
        read_ptr_2 = bw_hcount;
      end
    end else begin
      // wrong dithering, floyd steinberg dithering
      write_ptr_3 = 0;
      write_data_3 = 0;
      write_enable_3 = 0;
      read_ptr_3 = 0;
      out_3 = 0;

      if (line_mux == 0) begin
          // 0 will be reading out the value of b
          write_enable_0 = 1'b0;
          write_ptr_0 = 0;
          write_data_0 = 0;
          read_ptr_0 = bw_hcount;
          out_1 = read_data_0;

          // 1 will be reading out the value of e & writing in updated value of c
          write_ptr_1 = bw_hcount - 2; // location of c
          write_data_1 = updated_1; // updated c
          write_enable_1 = 1'b1;
          read_ptr_1 = bw_hcount;
          out_2 = read_data_1;

          // 2 will be writing data into prep line from recover
          write_ptr_2 = bw_hcount;
          write_data_2 = bw_pixel;
          write_enable_2 = bw_pixel_valid;
          read_ptr_2 = 0;

      end else if (line_mux == 1) begin
          // 1 will be reading out the value of b
          write_enable_1 = 1'b0;
          write_ptr_1 = 0;
          write_data_1 = 0;
          read_ptr_1 = bw_hcount;
          out_1 = read_data_1;

          // 2 will be reading out the value of e & writing in updated value of c
          write_ptr_2 = bw_hcount - 2; // location of c
          write_data_2 = updated_1; // updated c
          write_enable_2 = 1'b1;
          read_ptr_2 = bw_hcount;
          out_2 = read_data_2;

          // 0 will be writing data into prep line from recover
          write_ptr_0 = bw_hcount;
          write_data_0 = bw_pixel;
          write_enable_0 = bw_pixel_valid;
          read_ptr_0 = 0;

      end else begin 
          // 2 will be reading out the value of b
          write_enable_2 = 1'b0;
          write_ptr_2 = 0;
          write_data_2 = 0;
          read_ptr_2 = bw_hcount;
          out_1 = read_data_2;

          // 0 will be reading out the value of e & writing in updated value of c
          write_ptr_0 = bw_hcount - 2; // location of c
          write_data_0 = updated_1; // updated c
          write_enable_0 = 1'b1;
          read_ptr_0 = bw_hcount;
          out_2 = read_data_0;

          // 1 will be writing data into prep line from recover
          write_ptr_1 = bw_hcount;
          write_data_1 = bw_pixel;
          write_enable_1 = bw_pixel_valid;
          read_ptr_1 = 0;
      end
    end
  end

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(8),             // Specify RAM data width
    .RAM_DEPTH(FRAME_WIDTH)   // Specify RAM depth (number of entries)
  ) line_buffer_0 (
    .addra(write_ptr_0),    // WRITE pointer
    .dina(write_data_0),    // Port A RAM input data
    .wea(write_enable_0),   // Port A write enable: whenever valid data
    .douta(unused_0),       // Port A RAM output data
    
    .addrb(read_ptr_0),     // READ pointer
    .dinb(8'b0000_0000),    // Port B RAM input data
    .web(1'b0),             // Port B write enable
    .doutb(read_data_0),     // Port B RAM output data
    
    .clka(clk_in),          // Port A clock
    .clkb(clk_in),          // Port B clock
    .ena(1'b1),             // Port A RAM Enable
    .enb(1'b1),             // Port B RAM Enable
    .rsta(rst_in),          // Port A output reset (does not affect memory contents)
    .rstb(rst_in),          // Port B output reset (does not affect memory contents)
    .regcea(1'b1),          // Port A output register enable
    .regceb(1'b1)           // Port B output register enable
  );

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(8),             // Specify RAM data width
    .RAM_DEPTH(FRAME_WIDTH)   // Specify RAM depth (number of entries)
  ) line_buffer_1 (
    .addra(write_ptr_1),    // WRITE pointer
    .dina(write_data_1),    // Port A RAM input data
    .wea(write_enable_1),   // Port A write enable: whenever valid data
    .douta(unused_1),         // Port A RAM output data
    
    .addrb(read_ptr_1),     // READ pointer
    .dinb(8'b0000_0000),    // Port B RAM input data
    .web(1'b0),             // Port B write enable
    .doutb(read_data_1),     // Port B RAM output data
    
    .clka(clk_in),          // Port A clock
    .clkb(clk_in),          // Port B clock
    .ena(1'b1),             // Port A RAM Enable
    .enb(1'b1),             // Port B RAM Enable
    .rsta(rst_in),          // Port A output reset (does not affect memory contents)
    .rstb(rst_in),          // Port B output reset (does not affect memory contents)
    .regcea(1'b1),          // Port A output register enable
    .regceb(1'b1)           // Port B output register enable
  );

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(8),             // Specify RAM data width
    .RAM_DEPTH(FRAME_WIDTH)   // Specify RAM depth (number of entries)
  ) line_buffer_2 (
    .addra(write_ptr_2),    // WRITE pointer
    .dina(write_data_2),    // Port A RAM input data
    .wea(write_enable_2),   // Port A write enable: whenever valid data
    .douta(unused_2),         // Port A RAM output data
    
    .addrb(read_ptr_2),     // READ pointer
    .dinb(8'b0000_0000),    // Port B RAM input data
    .web(1'b0),             // Port B write enable
    .doutb(read_data_2),     // Port B RAM output data
    
    .clka(clk_in),          // Port A clock
    .clkb(clk_in),          // Port B clock
    .ena(1'b1),             // Port A RAM Enable
    .enb(1'b1),             // Port B RAM Enable
    .rsta(rst_in),          // Port A output reset (does not affect memory contents)
    .rstb(rst_in),          // Port B output reset (does not affect memory contents)
    .regcea(1'b1),          // Port A output register enable
    .regceb(1'b1)           // Port B output register enable
  );

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(8),             // Specify RAM data width
    .RAM_DEPTH(FRAME_WIDTH)   // Specify RAM depth (number of entries)
  ) line_buffer_3 (
    .addra(write_ptr_3),    // WRITE pointer
    .dina(write_data_3),    // Port A RAM input data
    .wea(write_enable_3),   // Port A write enable: whenever valid data
    .douta(unused_3),         // Port A RAM output data
    
    .addrb(read_ptr_3),     // READ pointer
    .dinb(8'b0000_0000),    // Port B RAM input data
    .web(1'b0),             // Port B write enable
    .doutb(read_data_3),     // Port B RAM output data
    
    .clka(clk_in),          // Port A clock
    .clkb(clk_in),          // Port B clock
    .ena(1'b1),             // Port A RAM Enable
    .enb(1'b1),             // Port B RAM Enable
    .rsta(rst_in),          // Port A output reset (does not affect memory contents)
    .rstb(rst_in),          // Port B output reset (does not affect memory contents)
    .regcea(1'b1),          // Port A output register enable
    .regceb(1'b1)           // Port B output register enable
  );

  always_ff @(posedge clk_in) begin
    if (rst_in)begin
        line_mux <= 0;
    end else begin
      if (dither_settings[0]) begin

      end else if (dither_settings[2] == 0 && dither_settings[1] == 1) begin
        // atkinson
        if (bw_pixel_valid) begin
          if (bw_hcount == FRAME_WIDTH - 1) begin
              line_mux <= (line_mux < 3) ? (line_mux + 1) : 0; 
          end
          a_hcount <= (bw_hcount >= 1) ? bw_hcount - 1 : bw_hcount;
          a_vcount <= (bw_vcount >= 2) ? bw_vcount - 2 : bw_vcount;
        end
        a_valid <= bw_pixel_valid;

      end else if (dither_settings[2] == 0) begin
        // floyd steinberg
        if (bw_pixel_valid) begin
          if (bw_hcount == FRAME_WIDTH - 1) begin
              line_mux <= (line_mux < 2) ? (line_mux + 1) : 0; 
          end
          a_hcount <= (bw_hcount >= 1) ? bw_hcount - 1 : bw_hcount;
          a_vcount <= (bw_vcount >= 2) ? bw_vcount - 2 : bw_vcount;
        end
        a_valid <= bw_pixel_valid;

      end else begin
        // wrong dithering
        if (bw_hcount == FRAME_WIDTH - 1) begin
            line_mux <= (line_mux < 2) ? (line_mux + 1) : 0; 
        end
        a_hcount <= (bw_hcount >= 1) ? bw_hcount - 1 : bw_hcount;
        a_vcount <= (bw_vcount >= 2) ? bw_vcount - 2 : bw_vcount;
        a_valid <= bw_pixel_valid;
      end
    end
  end
endmodule