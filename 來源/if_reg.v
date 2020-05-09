`timescale 1ns / 1ps
/********** 共享头文件 **********/
`include "head/nettype.v"
`include "head/global_config.v"
`include "head/stddef.v"

/********** 特别头文件 **********/
`include "head/isa_head.v"
`include "head/cpu_head.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/14 11:45:11
// Design Name: 
// Module Name: if_reg
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

/******************************IF阶段的流水线寄存器**********************************/
module if_reg(	input	wire			clk,
				input	wire			reset,
		/************************读取数据**************************/
				input	wire	[31:0]	insn,		//读取的指令
		/************************流水线控制信号********************/
				input	wire			stall,		//延迟
				input	wire			flush,		//刷新
				input	wire	[31:0]	new_pc,		//新程序计数器值
				input	wire			br_taken,	//分支成立
				input	wire	[31:0]	br_addr,	//分支目标地址
		/************************IF/ID流水线寄存器*****************/
				output	reg		[31:0]	if_pc,		//程序计数器
				output	reg		[31:0]	if_insn,	//指令
				output	reg				if_en		//流水线数据有效标志位
				);

/***********************流水线寄存器*************************/
always @ (posedge clk or posedge reset)
	begin
		if(reset == `ENABLE)
			begin
				/***异步复位***/
				if_pc	<= #1  `RESET_VECTOR;			//30'h0 复位向量
				if_insn	<= #1  `ISA_NOP;				//32'h0 无操作
				if_en	<= #1  `DISABLE;
			end
		else
			begin
				/***更新流水线寄存器***/
				if(stall == `DISABLE)			//非延迟状态
					begin
						if(flush == `ENABLE)	//刷新流水线并将PC值更新为新地址
							begin
								if_pc	<= #1  new_pc;
								if_insn	<= #1  `ISA_NOP;
								if_en	<= #1  `DISABLE;
							end
						else if(br_taken == `ENABLE)	//PC值更新为分支目标地址
							begin
								if_pc	<= #1  br_addr;
								if_insn	<= #1  insn;
								if_en	<= #1  `ENABLE;
							end
						else							//PC值更新为下一条地址
							begin 
								if_pc	<= #1  if_pc + 3'h4;
								if_insn	<= #1  insn;
								if_en	<= #1  `ENABLE;
							end
					end
			end
	end


endmodule
