module tb_sram;
  parameter WIDTH = 32;
  parameter DEPTH = 8;
  parameter DEPTH_LOG = $clog2(DEPTH);
  
  logic clk;
  logic reset;
  logic chip_select;
  logic write_enable;
  logic [DEPTH_LOG-1:0] address;
  
  logic [WIDTH-1:0] data_in;
  logic [WIDTH-1:0] data_out;
  
  logic [WIDTH-1:0] data_out_buffer [0:DEPTH-1];
  logic [WIDTH-1:0] n;
  
  sram_model #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH),
    .DEPTH_LOG(DEPTH_LOG)
  ) dut (
    .clk(clk),
    .reset(reset),
    .chip_select(chip_select),
    .write_enable(write_enable),
    .data_in(data_in),
    .address(address),
    .data_out(data_out)
  );
  
  // Clock Generation
  initial begin
    $display("MSIM> Clock Started");
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  int error_count_1;
  int error_count_2;
  int error_count_3;
 
    
  // Test Cases
  initial begin
    
    // CASE 1: Reset signal check
    $display("MSIM> CASE 1 => Reset Signal Check; all elements in the SRAM must be initalized to 0");
    error_count_1 = 0;
    
    reset = 1;
    repeat (2) @(posedge clk);
    
    for (int i = 0; i < DEPTH; i++ ) begin
      if (dut.mem[i] != 0) begin
        $display("MSIM> ERROR: mem[%d] = %d (should be %d) at time %t", i, dut.mem[i], 0, $time);
        error_count_1++;
      end
    end
    
    if (error_count_1 == 0) $display("MSIM>  CASE 1 PASSED");
    else $display("MSIM> CASE 1 FAILED");
    
    // CASE 2: Write to SRAM
    $display("MSIM> CASE 2 => Write to SRAM");
    error_count_2 = 0;
    
    reset = 0;
    chip_select = 0;
    write_enable = 0;
    @(posedge clk);
    for (int i = 0; i < DEPTH; i++) begin
      chip_select <= 1;
      write_enable <= 1;
      address <= i;
      data_in <= 32'd10 + i;
      repeat (2) @(posedge clk);
    end
    
    for (int i = 0; i < DEPTH; i++ ) begin
      n = 32'd10 + i;
      if (dut.mem[i] != n) begin
        $display("MSIM> ERROR: mem[%d] = %d (should be %d) at time %t", i, dut.mem[i], n, $time);
        error_count_2++;
      end
    end
    
    if (error_count_2 == 0) $display("CASE 2 PASSED");
    else $display("CASE 2 FAILED");
    
    // CASE 3: Read from SRAM
    $display("MSIM> CASE 3 => Read from SRAM");
    error_count_3 = 0;
    
    chip_select = 0;
    write_enable = 0;
    @(posedge clk);
    for (int i = 0; i < DEPTH; i++) begin
      chip_select <= 1;
      write_enable <= 0;
      address <= i; 
      repeat (2) @(posedge clk);
      data_out_buffer[i] <= data_out;
    end
    
    for (int i = 0; i < DEPTH; i++ ) begin
      n = 32'd10 + i;
      if (data_out_buffer[i] != n) begin
        $display("MSIM> ERROR: data_out_buffer[%d] = %d (should be %d) at time %t", i, data_out_buffer[i], n, $time);
        error_count_3++;
      end
    end
    
    if (error_count_3 == 0) $display("CASE 3 PASSED");
    else $display("CASE 3 FAILED");
    
    if (error_count_1 == 0 && error_count_2 == 0 && error_count_3 == 0) $display("All TESTS PASSED!");
    else $display("At least one test FAILED");
    
    repeat (3) @(posedge clk);
    $finish();
  end
  
endmodule
