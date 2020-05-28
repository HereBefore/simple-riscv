`timescale 1ns / 1ps
/********** 共享头文件 **********/
`include "head/nettype.v"
`include "head/global_config.v"
`include "head/stddef.v"

/********** 特别头文件 **********/
`include "head/cpu_head.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/13 11:24:03
// Design Name: 
// Module Name: gpr
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

/***************************通用寄存器*******************************/
module gpr(	input	wire			clk,
			input	wire			reset,
	/**********************读取端口0*************************/
			input	wire	[4:0]	rd_addr_0,		//读取的地址
			output	reg	[31:0]	rd_data_0,		//读取出的数据
	/**********************读取端口1*************************/
			input	wire	[4:0]	rd_addr_1,		
			output	reg	[31:0]	rd_data_1,
	/**********************写入端口**************************/
			input	wire			we_,			//写入有效信号
			input	wire	[4:0]	wr_addr,		//写入的地址
			input	wire	[31:0]	wr_data			//写入的数据
			);
			
	/******************************* 定义32个寄存器 *******************************/

	reg [31:0] gpr[0:31];


/******************************* 写操作 *******************************/
	always @(posedge clk)
		begin
			if (reset != 1)  //高电平复位
				if((we_ == `ENABLE_) && (wr_addr != 5'h0))
					begin
						gpr[wr_addr] <= wr_data;
					end		
		end


/******************************* 读端口0的读操作 *******************************/
//注意：读操作是组合逻辑、写操作是时序逻辑（？）
//这样可以保证在译码阶段取得想要读取的寄存器的值
	always @(*)
		begin
			if (reset == 1)
				begin
					rd_data_0 <= `WORD_DATA_W'h0;
				end
			else if(rd_addr_0 == 5'h0)
					begin
						rd_data_0 <= `WORD_DATA_W'h0;
					end
				 else if((rd_addr_0 == wr_addr) && (we_ == `ENABLE_))
						begin
							rd_data_0 <= wr_data;
						end
					  else
							begin
								rd_data_0 <= gpr[rd_addr_0];
							end
		end		


/******************************* 读端口1的读操作 *******************************/
//如果第1个读寄存器端口要读取的目标寄存器与要写入的目的寄存器是同一个寄存器，那么直接将要写入的值作为第2个读寄存器端口的输出（？）
	always @(*)
		begin
			if (reset == 1)
				begin
					rd_data_1 <= `WORD_DATA_W'h0;
				end
			else if(rd_addr_1 == 5'h0)
					begin
						rd_data_1 <= `WORD_DATA_W'h0;
					end
				 else if((rd_addr_1 == wr_addr) && (we_ == `ENABLE_))
						begin
							rd_data_1 <= wr_data;
						end
					  else
							begin
								rd_data_1 <= gpr[rd_addr_1];
							end
		end		

		
endmodule
