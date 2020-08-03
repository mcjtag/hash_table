`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dmitry Matyunin (https://github.com/mcjtag)
// 
// Create Date: 03.08.2020 13:33:27
// Design Name: 
// Module Name: hash_sdpram
// Project Name: hash_table
// Target Devices:
// Tool Versions:
// Description: Hash Simple Dual Port RAM
// Dependencies: 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// License: MIT
//  Copyright (c) 2020 Dmitry Matyunin
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// 
//////////////////////////////////////////////////////////////////////////////////

module hash_sdpram #(
	parameter MEMORY_TYPE = "block", // "block" or "distributed" 
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH = 5,
	parameter INIT_VALUE = 0,
	parameter INIT_FILE = ""
)
(
	input wire clk,
	input wire [DATA_WIDTH-1:0]dina,
	input wire [ADDR_WIDTH-1:0]addra,
	input wire wea,
	input wire [ADDR_WIDTH-1:0]addrb,
	output wire [DATA_WIDTH-1:0]doutb
);

(* ram_style = MEMORY_TYPE *)
reg [DATA_WIDTH-1:0]ram[2**ADDR_WIDTH-1:0];
reg [ADDR_WIDTH-1:0]rdoutb;
integer i;

assign doutb = rdoutb;

initial begin
	if (INIT_FILE == "") begin
		for (i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin
			ram[i] = INIT_VALUE;
		end
	end else begin
		$readmemh(INIT_FILE, ram); 
	end
end

always @(posedge clk) begin
	if (wea) begin
		ram[addra] <= dina;
	end
	rdoutb <= ram[addrb];
end
	
endmodule  