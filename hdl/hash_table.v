`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dmitry Matyunin (https://github.com/mcjtag)
// 
// Create Date: 03.08.2020 13:37:21
// Design Name: 
// Module Name: hash_table
// Project Name: hash_table
// Target Devices:
// Tool Versions:
// Description: Hash Table
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

module hash_table #(
	parameter ADDR_WIDTH = 8,
	parameter DATA_WIDTH = 8,
	parameter KEY_WIDTH = 8,
	parameter HASH_POLY = 32'h1EDC6F41,
	parameter HASH_INIT = {ADDR_WIDTH{1'b1}},
	parameter MEMORY_TYPE = "block" // "block" or "distributed" 
)
(
	input wire clk,
	input wire rst,
	input wire [DATA_WIDTH-1:0]din,
	input wire [KEY_WIDTH-1:0]key,
	input wire [1:0]opcode,
	input wire req_valid,
	output wire req_ready,
	output wire [DATA_WIDTH-1:0]dout,
	output wire res_valid,
	output wire res_status
);

localparam INDEX_WIDTH = ADDR_WIDTH;

localparam [1:0]
	OPCODE_CLEAR = 0,
	OPCODE_INSERT = 1,
	OPCODE_DELETE = 2,
	OPCODE_SEARCH = 3;
	
wire [INDEX_WIDTH-1:0]index_addr;
wire [DATA_WIDTH-1:0]index_data;
	
hash_func #(
	.KEY_WIDTH(KEY_WIDTH),
	.INDEX_WIDTH(INDEX_WIDTH),
	.HASH_POLY(HASH_POLY),
	.HASH_INIT(HASH_INIT)
) hash_func_inst (
	.key(key),
    .index(index_addr)
);

hash_sdpram #(
	.MEMORY_TYPE(MEMORY_TYPE),
	.DATA_WIDTH(), // !
	.ADDR_WIDTH(ADDR_WIDTH),
	.INIT_VALUE(0),
	.INIT_FILE("")
) hash_sdpram_index (
	.clk(clk),
	.dina(),  // Control
	.addra(), // Control
	.wea(),   // Control
	.addrb(index_addr),
	.doutb(index_data)
);

	
endmodule  