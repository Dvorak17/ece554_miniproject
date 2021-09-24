
module tpumac_tb();

  reg clk, rst, en, wr_en;

  reg signed [7:0] Ain, Bin;
  reg signed [15:0] Cin;

  wire [7:0] Aout, Bout;
  wire [15:0] Cout;

  tpumac accum (
    .clk(clk),
    .rst_n(rst),
    .WrEn(wr_en),
    .en(en),
    .Ain(Ain),
    .Bin(Bin),
    .Cin(Cin),
    .Aout(Aout),
    .Bout(Bout),
    .Cout(Cout)
  );

    /*
   * Reset the module and set signals to default values
   */
  task reset();
    // Set signal defaults
    wr_en = 0;
    rst = 1;
    en = 0;

    // Trigger negedge reset
    #1 rst = 0;
    #1 rst = 1;
  endtask

  /*
   * Assure the module reset correctly
   */
  task assure_reset();
    if (accum.Aout !== 8'h00 || accum.Bout !== 8'h00 || accum.Cout !== 16'h0000) begin
      $display("Failure, module did not reset correctly");
      $stop();
    end
  endtask

  /*
   * Assure the module does nothing when enable is not set
   */
  task assure_enable();
    Ain = 8'h08;
    Bin = 8'h08;
    Cin = 16'h0008;

    @(posedge clk);

    if (accum.Aout !== 8'h00 || accum.Bout !== 8'h00 || accum.Cout !== 16'h0000) begin
      $display("Failure, module updated registers when enable was not set");
      $stop();
    end else begin
      Ain = 8'h00;
      Bin = 8'h00;
      Cin = 16'h0000;
    end
  endtask

  /*
   * Test that Ain and Bin update Aout and Bout registers correctly
   */
  task test_ain_bin();

    reset();

    @(posedge clk);

    en = 1;
	
    @(posedge clk);

    for (int i = 0; i < 100; i = i + 1) begin
	
      Ain = i;
      Bin = i;
	  
      @(posedge clk);
      @(posedge clk);
	  
      if (Aout !== i || Bout !== i) begin
        $display("Failure, expected Aout = %d, Bout = %d. Found Aout=%d, Bout=%d",i, i, Aout, Bout);
        $stop();
      end
    end
    
    en = 0;
    Ain = 0;
    Bin = 0;
    
  endtask
  
  /*
   * Test to assure Cout correctly updates to Cin when wr_en is set
   */
  task test_wr_en();
  
    reset();
    
    @(posedge clk);
    
    en = 1;
    wr_en = 1;
    
    @(posedge clk);
    
    for (int i = 0; i < 100; i = i + 1) begin
    
      Cin = i;
      
      @(posedge clk);
      @(posedge clk);
      
      if (Cout !== i) begin
        $display("Failure, expect Cout = %d. Found Cout = %d", i, Cout);
        $stop();
      end
    end
    
    en = 0;
    Cin = 0;
    wr_en = 0;
    
  endtask
  
  /*
   * Test that the modules main functionality, multiply accumulate, operates as expected
   */
  task test_mac();
  
    integer expected_cout;
  
    reset();
    
    @(posedge clk);
    
    en = 1;
    wr_en = 0;
    expected_cout = 0;
    
    @(posedge clk);
    
    for (int i = 0; i < 5; i = i + 1) begin
    
      Ain = i;
      Bin = i;
      Cin = Cout;
      
      @(posedge clk);
      @(posedge clk);
      
      expected_cout += (i * i);
      
      if (Cout != expected_cout) begin
        $display("Failure, expected Cout = %d. Found Cout = %d", expected_cout, Cout);
        $stop();
      end
    end
    
    en = 0;
    Ain = 0;
    Bin = 0;
    
  endtask

  initial begin

    clk = 0;

    // Reset module
    reset();

    // Assure it reset correctly
    assure_reset();

    // Assure the module does nothing when enable is not set
    assure_enable();

    // Test the Aout and Bout registers work correctly
    test_ain_bin();
    
    // Test that the Cout register correctly takes on the Cin value when wr_en is set
    test_wr_en();
    
    // Assure multiply accumulate operates as expected
    test_mac();

    $display("All tests passed!");
    $stop();
  end

  always
    #5 clk = !clk;

endmodule