// memA and memB testbench

`include "systolic_array_tc.svh"

module memAB_tb();

   localparam BITS_AB=8;
   localparam DIM=8;
   localparam EN_CYCLES=(DIM*3 - 2);
   localparam AROWBITS=$clog2(DIM);
   
   localparam TESTS=10;
   
   // Clock
   logic clk;
   logic rst_n;
   logic en;
   logic WrEn;
   logic [$clog2(DIM)-1:0] Arow;
   logic signed [BITS_AB-1:0] Ain [DIM-1:0];
   logic signed [BITS_AB-1:0] Aout [DIM-1:0];
   logic signed [BITS_AB-1:0] Bin [DIM-1:0];
   logic signed [BITS_AB-1:0] Bout [DIM-1:0];
   
   int errors, mycycle;
   
   always #5 clk = ~clk;
   
	// Instantiate memoryA and memoryB
	memA #(	.BITS_AB(BITS_AB),
			.DIM(DIM)) DUT_A (.*);

	memB #(	.BITS_AB(BITS_AB),
			.DIM(DIM)) DUT_B (.*); 
   
	systolic_array_tc #(.BITS_AB(BITS_AB),
                       .DIM(DIM)
                       ) satc;
  
   
   initial begin
		clk = 1'b0;
		rst_n = 1'b1;
		en = 1'b0;
		WrEn = 1'b0;
		Arow = {AROWBITS{1'b0}};
		errors = 0;
		//initialize Ain and Bin as 0
		for(int rowcol=0;rowcol<DIM;++rowcol) begin
			Ain[rowcol] = {BITS_AB{1'b0}};
			Bin[rowcol] = {BITS_AB{1'b0}};
		end 
      
		// reset and check Aout and Bout
		@(posedge clk) begin end
		rst_n = 1'b0; // active low reset
		@(posedge clk) begin end
		rst_n = 1'b1; // reset finished
		en = 1'b1; // assert enable

		// check that A and B was properly reset
		for(int Row=0;Row<DIM*2-1;++Row) begin
			@(posedge clk) begin end
			for (int rowcol = 0; rowcol < DIM; ++rowcol) begin
				if(Aout[rowcol] !== 0 || Bout[rowcol] !== 0) begin
					errors++;
					$display("Error! Reset was not conducted properly. Expected: 0, Got: Aout = %p and Bout %p for Row %d", Aout,Bout,Row); 
				end
			end
		end
		
		// Randomly generates values for memA and memB and tests that they are passed through correctly
		// Repeats TESTS times
		for(int test=0;test<TESTS;++test) begin
			en = 1'b0;
			@(posedge clk) begin end
			rst_n = 1'b0; // active low reset
			@(posedge clk) begin end
			rst_n = 1'b1; // reset finished
        
			// instantiate test case
			satc = new();
         
			@(posedge clk) begin end
			en = 1'b1;   
			WrEn = 1'b1;
			// DIM cycles to fill memA and memB
			for(int cyc=0;cyc<DIM;++cyc) begin
				// set A, B values from the testcase
				Arow = cyc;
				for(int rowcol=0;rowcol<DIM;++rowcol) begin
				Ain[rowcol] = satc.A[cyc][rowcol];
				Bin[rowcol] = satc.B[cyc][rowcol];
				end
				@(posedge clk) begin end
			end
			// done filling memA and memB
			
			// Disable WrEn now that memA is full
			WrEn = 1'b0;
         
			// Shifts values out of memA/memB and checks they correspond with satc test case
			for(int cyc=0; cyc<DIM*2 -1; ++cyc) begin
				@(posedge clk) begin end
				for(int rowcol=0;rowcol<DIM;++rowcol) begin
					if (Aout[rowcol] !== satc.get_next_A(rowcol)) begin
					$display("Error found in memA: expected %d, result: %d", satc.get_next_A(rowcol), Aout[rowcol]);
					$display("Error found in memA: cyc %d, row: %d\n", cyc, rowcol);
					errors++;
					end 
					if (Bout[rowcol] !== satc.get_next_B(rowcol)) begin
					$display("Error found in memB: expected %d, result: %d", satc.get_next_B(rowcol), Bout[rowcol]);
					errors++;
					end
				end
				mycycle = satc.next_cycle();
			end
         
			if (errors > 0) begin
				$display("Errors found: %d, \n",errors);
			end
			else begin
				$display("No errors on test %d, testcase passed\n", test);
			end
			satc = null;  
		end // for (int test=0;test<TESTS;++test)
               
		$stop;
	end // initial begin
endmodule
