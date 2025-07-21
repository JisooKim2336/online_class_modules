`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jisoo Kim
// 
// Create Date: 07/21/2025 04:27:28 PM
// Design Name: 
// Module Name: sram_model
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sram_model #(
  parameter WIDTH = 32,
  parameter DEPTH = 8,
  parameter DEPTH_LOG = $clog2(DEPTH)
)(
  input clk, reset,
  input logic chip_select, // control signal that determines where the SRAM chip is active or IDLE
  input logic write_enable, 
  input logic [WIDTH-1:0] data_in,
  input logic [DEPTH_LOG-1:0] address,

  output logic [WIDTH-1:0] data_out

    );
    
  logic [WIDTH-1:0] mem [0:DEPTH-1];
  
  always_ff @(posedge clk) begin
    
    // initialize SRAM cells to 0
    if (reset) begin
      for (int i = 0; i < DEPTH; i++) begin
        mem[i] <= 32'd0;
      end
    end
    
    else begin
      // write
      if (chip_select & write_enable) begin
        mem[address] <= data_in;
      end
      // read
      else if (chip_select & !write_enable) begin
        data_out <= mem[address];  
      end
      
    end
  end
endmodule
