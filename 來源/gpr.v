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
			output	wire	[31:0]	rd_data_0,		//读取出的数据
	/**********************读取端口1*************************/
			input	wire	[4:0]	rd_addr_1,		
			output	wire	[31:0]	rd_data_1,
	/**********************写入端口**************************/
			input	wire			we_,			//写入有效信号
			input	wire	[4:0]	wr_addr,		//写入的地址
			input	wire	[31:0]	wr_data			//写入的数据
			);

reg		[31:0]	gpr[0:31];

/*************************读取访问(Write After Read)**********************/
assign rd_data_0 = ((we_ == `ENABLE_) && (wr_addr == rd_addr_0)) ? wr_data : gpr[rd_addr_0];	//读取端口0
assign rd_data_1 = ((we_ == `ENABLE_) && (wr_addr == rd_addr_1)) ? wr_data : gpr[rd_addr_1];	//读取端口1

/*************************写入访问**********************/
generate
	genvar	i;
	for(i = 0;i < `REG_NUM;i = i+1)
		begin:gpr_rst
			always @ (posedge clk or posedge reset)
				begin
					if(reset == 1)
						begin
							gpr[i] <= #1`WORD_DATA_W'h0;	//异步清零，使用generate语句来避免直接综合for循环
						end
				end
		end
endgenerate

always @ (posedge clk)
	begin
		if (reset != 1)
			begin
				if(we_ == `ENABLE_)
					begin   
						gpr[wr_addr] <= #1 wr_data;			//写入访问
					end
			end
	end
	
			
endmodule
