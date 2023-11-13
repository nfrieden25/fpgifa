// INPUTS
// clk_in
// valid signal (data_valid_rec from recover)
// pixel from that (bw, the modified version of pixel_data_rec)
// pixel written back every clock cycle from dither
//   hcount & vcount for that pixel

// OUTPUTS
// outputs B and E every cycle (8 bit values)
// signal for whether B and E are valid
// hcount 
// vcount

// need to pass to dither:
// input wire a_valid, 
// input wire [10:0] a_hcount,
// input wire [9:0] a_vcount,
// input wire [7:0] b,
// input wire [7:0] e,

module line_buffers (
  input wire clk_in,
  input wire rst_in,

  input wire [7:0] bw_pixel,
  input wire [10:0] bw_hcount,
  input wire [9:0] bw_vcount,
  input wire bw_pixel_valid,

  input wire [7:0] updated_pixel,

  output logic [7:0] new_b,
  output logic [7:0] new_e,
  output logic [10:0] a_hcount,
  output logic [9:0] a_vcount,
  output logic a_valid
  );

  localparam FRAME_WIDTH = 240;
  logic [7:0] unused_0;
  logic [7:0] unused_1;
  logic [7:0] unused_2;

  logic [$clog2(FRAME_WIDTH-1)-1:0] write_ptr_0;
  logic [$clog2(FRAME_WIDTH-1)-1:0] write_ptr_1;
  logic [$clog2(FRAME_WIDTH-1)-1:0] write_ptr_2;
  logic [7:0] write_data_0;
  logic [7:0] write_data_1;
  logic [7:0] write_data_2;
  logic write_enable_0;
  logic write_enable_1;
  logic write_enable_2;
  logic [$clog2(FRAME_WIDTH-1)-1:0] read_ptr_0;
  logic [$clog2(FRAME_WIDTH-1)-1:0] read_ptr_1;
  logic [$clog2(FRAME_WIDTH-1)-1:0] read_ptr_2;
  logic [7:0] read_data_0;
  logic [7:0] read_data_1;
  logic [7:0] read_data_2;

  logic [1:0] line_mux;

  // MUX EVERYTHING INTO RIGHT ROLES
  always_comb begin
    if (line_mux == 0) begin
        // write_ptr_0 = X
        // write_data_0 = X
        write_enable_0 = 1'b0;
        read_ptr_0 = bw_hcount; // 0 - 239 
        new_b = read_data_0;

        write_ptr_1 = bw_hcount - 3; // location of c
        write_data_1 = updated_pixel; // updated c
        write_enable_1 = 1'b1; // TODO: might want to make this an enable from dither
        read_ptr_1 = bw_hcount; // 0 - 239 
        new_e = read_data_1;

        write_ptr_2 = bw_hcount;
        write_data_2 = bw_pixel;
        write_enable_2 = bw_pixel_valid;
        // read_ptr_2 = X
        // read_data_2 = X

    end else if (line_mux == 1) begin
        // write_ptr_1 = X
        // write_data_1 = X
        write_enable_1 = 1'b0;
        read_ptr_1 = bw_hcount; // 0 - 239 
        new_b = read_data_1;

        write_ptr_2 = bw_hcount - 3; // location of c
        write_data_2 = updated_pixel; // updated c
        write_enable_2 = 1'b1; // TODO: might want to make this an enable from dither
        read_ptr_2 = bw_hcount; // 0 - 239 
        new_e = read_data_2;

        write_ptr_0 = bw_hcount;
        write_data_0 = bw_pixel;
        write_enable_0 = bw_pixel_valid;
        // read_ptr_0 = X
        // read_data_0 = X
        
    end else begin
        // write_ptr_2 = X
        // write_data_2 = X
        write_enable_2 = 1'b0;
        read_ptr_2 = bw_hcount; // 0 - 239 
        new_b = read_data_2;

        write_ptr_0 = bw_hcount - 3; // location of c
        write_data_0 = updated_pixel; // updated c
        write_enable_0 = 1'b1; // TODO: might want to make this an enable from dither
        read_ptr_0 = bw_hcount; // 0 - 239 
        new_e = read_data_0;

        write_ptr_1 = bw_hcount;
        write_data_1 = bw_pixel;
        write_enable_1 = bw_pixel_valid;
        // read_ptr_1 = X
        // read_data_1 = X
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

  always_ff @(posedge clk_in) begin
    if (rst_in)begin
        line_mux <= 0;
    end else begin
        if (bw_hcount == FRAME_WIDTH - 1) begin
            line_mux <= (line_mux < 2) ? (line_mux + 1) : 0; 
        end

        // a_hcount = hcount @ b & e - 2
        // BUT there is also a two cycle delay until new_b and new_e get those values
        a_hcount <= (bw_hcount >= 4) ? bw_hcount - 4 : bw_hcount;
        // a_hcount <= bw_hcount;

        // a is always two lines behind where you're writing
        a_vcount <= (bw_vcount >= 2) ? bw_vcount - 2 : bw_vcount;
        // a_vcount <= bw_vcount;

        // a is valid if the pixel being read in is valid (for now)
        a_valid <= bw_pixel_valid;

    end
  end
endmodule

// QUESTIONS
// if we're running this on the faster clock, does it still take 2 cycles?