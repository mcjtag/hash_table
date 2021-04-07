`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dmitry Matyunin (https://github.com/mcjtag)
// 
// Create Date: 02.08.2020 15:33:45
// Design Name: 
// Module Name: hash_func
// Project Name: hash_table
// Target Devices:
// Tool Versions:
// Description: Hash Function (based on CRC)
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

module hash_func #(
	parameter KEY_WIDTH = 8,
	parameter INDEX_WIDTH = 32,
	parameter HASH_POLY = 32'h1EDC6F41,
	parameter HASH_INIT = {INDEX_WIDTH{1'b1}}
)
(
	input wire clk,
	input wire en,
    input wire [KEY_WIDTH-1:0]key,
    output wire [INDEX_WIDTH-1:0]index
);

reg [INDEX_WIDTH-1:0]mask_index[INDEX_WIDTH-1:0];
reg [KEY_WIDTH-1:0]mask_key[INDEX_WIDTH-1:0];
reg [INDEX_WIDTH-1:0]index_tmp = 0;
reg [KEY_WIDTH-1:0]key_tmp = 0;
reg [INDEX_WIDTH-1:0]index_out;
reg [INDEX_WIDTH-1:0]index_reg = 0;
integer i, j;

assign index = index_reg;

initial begin
	for (i = 0; i < INDEX_WIDTH; i = i + 1) begin
		mask_index[i] = {INDEX_WIDTH{1'b0}};
		mask_index[i][i] = 1'b1;
		mask_key[i] = {KEY_WIDTH{1'b0}};
	end

	for (i = KEY_WIDTH-1; i >= 0; i = i - 1) begin
		index_tmp = mask_index[INDEX_WIDTH-1];
		key_tmp = mask_key[INDEX_WIDTH-1];
		key_tmp = key_tmp ^ (1 << i);
		for (j = INDEX_WIDTH - 1; j > 0; j = j - 1) begin
			mask_index[j] = mask_index[j-1];
			mask_key[j] = mask_key[j-1];
		end
		mask_index[0] = index_tmp;
		mask_key[0] = key_tmp;
		for (j = 1; j < INDEX_WIDTH; j = j + 1) begin
			if (HASH_POLY & (1 << j)) begin
				mask_index[j] = mask_index[j] ^ index_tmp;
				mask_key[j] = mask_key[j] ^ key_tmp;
			end
		end
	end

	for (i = 0; i < INDEX_WIDTH / 2; i = i + 1) begin
		index_tmp = mask_index[i];
		key_tmp = mask_key[i];
		mask_index[i] = mask_index[INDEX_WIDTH - i - 1];
		mask_key[i] = mask_key[INDEX_WIDTH - i - 1];
		mask_index[INDEX_WIDTH - i - 1] = index_tmp;
		mask_key[INDEX_WIDTH - i - 1] = key_tmp;
	end

	for (i = 0; i < INDEX_WIDTH; i = i + 1) begin
		index_tmp = 0;
		for (j = 0; j < INDEX_WIDTH; j = j + 1) begin
			index_tmp[j] = mask_index[i][INDEX_WIDTH - j - 1];
		end
		mask_index[i] = index_tmp;
		key_tmp = 0;
		for (j = 0; j < KEY_WIDTH; j = j + 1) begin
			key_tmp[j] = mask_key[i][KEY_WIDTH - j - 1];
		end
		mask_key[i] = key_tmp;
	end
end

always @(*) begin
	for (i = 0; i < INDEX_WIDTH; i = i + 1) begin
		index_out[i] = 0;
		for (j = 0; j < INDEX_WIDTH; j = j + 1) begin
			if (mask_index[i][j]) begin
				index_out[i] = index_out[i] ^ HASH_INIT[j];
			end
		end
		for (j = 0; j < KEY_WIDTH; j = j + 1) begin
			if (mask_key[i][j]) begin
				index_out[i] = index_out[i] ^ key[j];
			end
		end
	end
end

always @(posedge clk) begin
	if (en == 1'b1) begin
		index_reg <= index_out;
	end
end

endmodule
