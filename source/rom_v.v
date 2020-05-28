`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/29 21:18:32
// Design Name: 
// Module Name: rom_v
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

/********** 共享头文件 **********/
`include "head/nettype.v"
`include "head/stddef.v"
`include "head/global_config.v"

/********** 特别头文件 **********/
`include "head/rom_head.v"

/*******************************************************/
module rom_v(input	wire					clka,	//时钟
			 input	wire	[`RomAddrBus]	addra,	//地址
			 output	reg		[`WordDataBus]	douta	//读出数据
			);
			
	/*******************寄存器******************/
	reg	[`WordDataBus] mem [0:`ROM_DEPTH-1];
	
	/*******************读取数据********************/
	always @ (posedge clka)
		begin
			douta <= #1 mem[addra];
		end
			
endmodule
