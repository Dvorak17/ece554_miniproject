// fifo.sv
// Implements delay buffer (fifo)
// On reset all entries are set to 0
// Shift causes fifo to shift out oldest entry to q, shift in d

module fifo
  #(
  parameter DEPTH=8,
  parameter BITS=64
  )
  (
  input clk,rst_n,en,
  input [BITS-1:0] d,
  output [BITS-1:0] q
  );
  reg [BITS-1:0] queue [0:DEPTH-1];
  
  always_ff @(posedge clk, negedge rst_n) begin
  	if (!rst_n)
  		for (int i = 0; i < DEPTH; i++) queue[i] <= 0;	// reset all fifo values to 0		
  	else begin
  		q <= queue[DEPTH-1];														// shift out last value
  		for (int i = DEPTH - 1; i > 0; i = i-1) 
  			queue[i] <= queue[i-1];												// shifts values through fifo
  		queue[0] <= d;																	// shifts in d
  	end
  end
  	
endmodule // fifo

