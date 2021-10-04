module systolic_array
	#(
	parameter BITS_AB=8,
	parameter BITS_C=16,
	parameter DIM=8
	)
	(
	input	clk, rst_n, WrEn, en,
	input signed [BITS_AB-1:0] A [DIM-1:0],
	input signed [BITS_AB-1:0] B [DIM-1:0],
	input signed [BITS_C-1:0] Cin [DIM-1:0],
	input [$clog2(DIM)-1:0]	Crow,
	output signed [BITS_C-1:0] Cout [DIM-1:0]
	);
	
	wire signed [BITS_AB-1:0] Ain_grid [DIM-1:0][DIM-1:0];
	wire signed [BITS_AB-1:0] Bin_grid [DIM-1:0][DIM-1:0];
	wire signed [BITS_AB-1:0] Aout_grid [DIM-1:0][DIM-1:0];
	wire signed [BITS_AB-1:0] Bout_grid [DIM-1:0][DIM-1:0];
	wire signed [BITS_C-1:0] Cin_grid [DIM-1:0][DIM-1:0];
	wire signed [BITS_C-1:0] Cout_grid [DIM-1:0][DIM-1:0];
	wire Wren_grid [DIM-1:0][DIM-1:0];
	
	assign Cout = Cout_grid[Crow];
	
	genvar i, j, k, row, col;
	generate
		for (k = 0; k < DIM; k = k + 1) begin
			assign Ain_grid[k][0] = A[k];
			assign Bin_grid[0][k] = B[k];
		end	
		for (i = 0; i < DIM; i = i + 1) begin
			for (j = 1; j < DIM; j = j + 1) begin
				assign Ain_grid[i][j] = Aout_grid[i][j-1];
				assign Bin_grid[j][i] = Bout_grid[j-1][i];
				assign Cin_grid[i][j] = Cin[j];
				assign Wren_grid[i][j] = (Crow == i) ? WrEn : 1'b0; 
			end
		end
		for (i = 0; i < DIM; i = i + 1) begin
			for (j = 0; j < DIM; j = j + 1) begin
				assign Cin_grid[i][j] = Cin[j];
				assign Wren_grid[i][j] = (Crow == i) ? WrEn : 1'b0; 
			end
		end
		for (row = 0; row < DIM; row = row + 1) begin
			for (col = 0; col < DIM; col = col + 1) begin
				tpumac #(BITS_AB, BITS_C) tpumac_array( 
					.clk(clk),
					.rst_n(rst_n), 
					.WrEn(Wren_grid[row][col]), 
					.en(en),
					.Ain(Ain_grid[row][col]), 
					.Bin(Bin_grid[row][col]), 
					.Cin(Cin_grid[row][col]), 
					.Aout(Aout_grid[row][col]), 
					.Bout(Bout_grid[row][col]), 
					.Cout(Cout_grid[row][col]));
			end
		end
	endgenerate
endmodule
	
	