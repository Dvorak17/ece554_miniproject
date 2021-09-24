module tpumac
 #(
    parameter BITS_AB=8,
    parameter BITS_C=16
  )
  (
    input clk, rst_n, WrEn, en,
    input signed [BITS_AB-1:0] Ain,
    input signed [BITS_AB-1:0] Bin,
    input signed [BITS_C-1:0] Cin,
    output reg signed [BITS_AB-1:0] Aout,
    output reg signed [BITS_AB-1:0] Bout,
    output reg signed [BITS_C-1:0] Cout
  );

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      Aout <= '0;
      Bout <= '0;
      Cout <= '0;
    end else begin
      if (en) begin
        Aout <= Ain;
        Bout <= Bin;
        if (WrEn) begin
          Cout <= Cin;
        end else begin
          Cout <= (Ain * Bin) + Cin;
        end
      end
    end
  end
endmodule