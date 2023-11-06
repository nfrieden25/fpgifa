module tm_choice (
  input wire [7:0] data_in,
  output logic [8:0] qm_out
  );
  
  logic [3:0] num_ones;

  always_comb begin
    // calculate number of ones in input
    num_ones = 0;
    for (integer i = 0; i < 8; i = i + 1) begin
        num_ones = num_ones + data_in[i];
    end 

    if ((num_ones > 4'd4) || (num_ones == 4'd4 && data_in[0] == 0)) begin
        // option 2
        qm_out[0] = data_in[0];
        for (integer n = 1; n < 8; n = n + 1) begin
            qm_out[n] = ~(data_in[n] ^ qm_out[n - 1]);
        end
        qm_out[8] = 0;
    end else begin
        // option 1
        qm_out[0] = data_in[0];
        for (integer n = 1; n < 8; n = n + 1) begin
            qm_out[n] = data_in[n] ^ qm_out[n - 1];
        end
        qm_out[8] = 1;
    end 
  end
endmodule