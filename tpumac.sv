// Spec v1.1
module tpumac
 #(parameter BITS_AB=8,
   parameter BITS_C=16)
  (
   input clk, rst_n, WrEn, en,
   input signed [BITS_AB-1:0] Ain,
   input signed [BITS_AB-1:0] Bin,
   input signed [BITS_C-1:0] Cin,
   output reg signed [BITS_AB-1:0] Aout,
   output reg signed [BITS_AB-1:0] Bout,
   output reg signed [BITS_C-1:0] Cout
  );

  wire [BITS_C-1:0] matrx_mul_result, C_mux;

  assign matrx_mul_result = (Ain * Bin) + Cout;
  assign C_mux = WrEn ? Cin : matrx_mul_result;

  always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) Aout <=0; Bout <= 0; Cout <= 0;
      else
        if (en) begin
            Aout <= Ain;
            Bout <= Bin;
            Cout <= C_mux;
        end
  end

// Modelsim prefers "reg signed" over "signed reg"