`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dmitry Matyunin (https://github.com/mcjtag)
// 
// Create Date: 06.04.2021 23:27:53
// Design Name: 
// Module Name: hash_control
// Project Name: hash_table
// Target Devices:
// Tool Versions:
// Description: Hash Table Control
// Dependencies:
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// License: MIT
//  Copyright (c) 2021 Dmitry Matyunin
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

module hash_control #(
	parameter ADDR_WIDTH = 8,
	parameter DATA_WIDTH = 8,
	parameter KEY_WIDTH = 8,
	parameter TABLE_WIDTH = ADDR_WIDTH+DATA_WIDTH+KEY_WIDTH+1
)
(
	input wire clk,
	input wire rst,
	input wire [DATA_WIDTH-1:0]req_din,
	input wire [KEY_WIDTH-1:0]req_key,
	input wire [1:0]req_opcode,
	input wire req_valid,
	output wire req_ready,
	output wire [ADDR_WIDTH-1:0]index_din,
	output wire [ADDR_WIDTH-1:0]index_addr,
	output wire index_we,
	input wire [ADDR_WIDTH-1:0]index_dout,
	output wire [TABLE_WIDTH-1:0]table_din,
	input wire [TABLE_WIDTH-1:0]table_dout,
	output wire [ADDR_WIDTH-1:0]table_addr,
	output wire table_we,
	output wire [1:0]table_arb
);

localparam [1:0]
	OPCODE_CLEAR = 0,
	OPCODE_INSERT = 1,
	OPCODE_DELETE = 2,
	OPCODE_SEARCH = 3;

localparam [1:0]
	ARB_NONE = 0,
	ARB_INDEX = 1,
	ARB_CTRL = 2,
	ARB_LOOP = 3;

localparam [3:0]
	STATE_INIT = 0,
	STATE_IDLE = 1,
	STATE_CLEAR = 2;

reg [3:0]state;

reg [ADDR_WIDTH-1:0]ind_din = 0;
reg [ADDR_WIDTH-1:0]ind_addr = 0;
reg ind_we = 1'b0;

reg [TABLE_WIDTH-1:0]tbl_din = 0;
reg [ADDR_WIDTH-1:0]tbl_addr = 0;
reg tbl_we = 1'b0;
reg [1:0]tbl_arb = 0;

assign req_ready = (state == STATE_IDLE) ? 1'b1 : 1'b0;
assign index_din = ind_din;
assign index_addr = ind_addr;
assign index_we = ind_we;

assign table_din = tbl_din;
assign table_addr = tbl_addr;
assign table_we = tbl_we;
assign table_arb = tbl_arb;

always @(posedge clk) begin
	if (rst == 1'b1) begin
		state <= STATE_INIT;
		ind_din <= 0;
		ind_addr <= 0;
		ind_we <= 1'b0;
		tbl_din <= 0;
		tbl_addr <= 0;
		tbl_we <= 1'b0;
		tbl_arb <= ARB_NONE;
	end else begin
		case (state)
		STATE_INIT: begin
			state <= STATE_IDLE;
		end
		STATE_IDLE: begin
			if (req_valid == 1'b1) begin
				case (req_opcode)
				OPCODE_CLEAR: begin
					ind_we <= 1'b1;
					tbl_we <= 1'b1;
					ind_addr <= 0;
					tbl_addr <= 0;
					ind_din <= {ADDR_WIDTH{1'b0}};
					tbl_din <= {TABLE_WIDTH{1'b0}};
					state <= STATE_CLEAR;
				end
				OPCODE_INSERT: state <= STATE_IDLE;
				OPCODE_DELETE: state <= STATE_IDLE;
				OPCODE_SEARCH: state <= STATE_IDLE;
				endcase
			end
		end
		STATE_CLEAR: begin
			tbl_addr <= tbl_addr + 1;
			ind_addr <= ind_addr + 1;
			if (tbl_addr == {ADDR_WIDTH{1'b1}}) begin
				ind_we <= 1'b0;
				tbl_we <= 1'b0;
				state <= STATE_IDLE;
			end
		end
		endcase
	end
end

endmodule
