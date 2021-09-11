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
  reg [DEPTH-1:0] counter                               // counts how many queue entries are full
  
  assign q = queue[0]                                   // [0] is the head of the queue

  always_ff @(posedge clk, negedge rst_n) begin
  	if (en == 0);
    else begin
      if (!rst_n) begin
        for (int i = 0; i < DEPTH; i++) queue[i] <= 0;	// reset all fifo values to 0	
        counter <= 0;
      end else begin
        if (counter < DEPTH) begin
          queue[counter] <= d
          counter <= counter + 1;
        end else begin
          for (int i = 0; i < DEPTH -1; i = i+1)
            queue[i] <= queue[i+1];											// shifts values through fifo
  			  queue[DEPTH - 1] <= d;                        // shifts in d
        end
      end
    end
  end
  	
endmodule // fifo

