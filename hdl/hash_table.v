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
	input wire [DATA_WIDTH-1:0]req_din,
	input wire [KEY_WIDTH-1:0]req_key,
	input wire [1:0]req_opcode,
	input wire req_valid,
	output wire req_ready,
	output wire [DATA_WIDTH-1:0]dout,
	output wire res_valid,
	output wire res_status
);

localparam TABLE_WIDTH = KEY_WIDTH+DATA_WIDTH+ADDR_WIDTH+1;

wire [ADDR_WIDTH-1:0]index_addr;
wire [DATA_WIDTH-1:0]index_data;
wire [ADDR_WIDTH-1:0]ctl_index_din;
wire [ADDR_WIDTH-1:0]ctl_index_addr;
wire ctl_index_we;
	
hash_func #(
	.KEY_WIDTH(KEY_WIDTH),
	.INDEX_WIDTH(ADDR_WIDTH),
	.HASH_POLY(HASH_POLY),
	.HASH_INIT(HASH_INIT)
) hash_func_inst (
	.clk(clk),
	.en(req_ready & req_valid),
	.key(key),
    .index(index_addr)
);

hash_sdpram #(
	.MEMORY_TYPE(MEMORY_TYPE),
	.DATA_WIDTH(ADDR_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.INIT_VALUE(0)
) hash_sdpram_index (
	.clk(clk),
	.dina(ctl_index_din),
	.addra(ctl_index_addr),
	.wea(ctl_index_we),
	.addrb(index_addr),
	.doutb(index_data)
);

wire [TABLE_WIDTH-1:0]ctl_table_din;
wire [TABLE_WIDTH-1:0]ctl_table_dout;
wire [ADDR_WIDTH-1:0]ctl_table_addr;
wire ctl_table_we;
wire [1:0]ctl_table_arb;
reg [ADDR_WIDTH-1:0]table_addr;

hash_sdpram #(
	.MEMORY_TYPE(MEMORY_TYPE),
	.DATA_WIDTH(TABLE_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.INIT_VALUE(0),
	.INIT_FILE("")
) hash_sdpram_table (
	.clk(clk),
	.dina(ctl_table_din),
	.addra(ctl_table_addr),
	.wea(ctl_table_we),
	.addrb(table_addr),
	.doutb(ctl_table_dout)
);

hash_control #(
	.ADDR_WIDTH(ADDR_WIDTH)
) hash_control_inst (
	.clk(clk),
	.rst(rst),
	.req_din(req_din),
	.req_key(req_key),
	.req_opcode(req_opcode),
	.req_valid(req_valid),
	.req_ready(req_ready),
	.index_din(ctl_index_din),
	.index_addr(ctl_index_addr),
	.index_we(ctl_index_we),
	.index_dout(index_data),
	.table_din(ctl_table_din),
	.table_dout(ctl_table_dout),
	.table_addr(ctl_table_addr),
	.table_we(ctl_table_we),
	.table_arb(ctl_table_arb)
);

always @(*) begin
	case (ctl_table_arb)
	2'b00: table_addr = 0;
	2'b01: table_addr = index_data;
	2'b10: table_addr = ctl_table_addr;
	2'b11: table_addr = ctl_table_dout[ADDR_WIDTH-:ADDR_WIDTH];
	endcase
end

endmodule  