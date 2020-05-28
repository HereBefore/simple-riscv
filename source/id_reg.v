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
// Create Date: 2019/11/14 20:16:25
// Design Name: 
// Module Name: id_reg
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


/*******************************ID阶段流水线寄存器*********************************/
module id_reg(	input	wire			clk,
				input	wire			reset,
		/***************************解码结果****************************/
				input	wire	[3:0]	alu_op,			//ALU操作
				input	wire	[31:0]	alu_in_0,		//ALU输入0
				input	wire	[31:0]	alu_in_1,		//ALU输入1
				input	wire			br_flag,		//分支符号位
				input	wire	[3:0]	mem_op,			//内存操作
				input	wire	[31:0]	mem_wr_data,	//内存写入数据
				input	wire	[1:0]	ctrl_op,		//控制操作
				input	wire	[4:0]	dst_addr,		//通用寄存器写入地址
				input	wire			gpr_we_,		//通用寄存器写入有效
				input	wire	[2:0]	exp_code,		//异常代码
		/***************************流水线控制信号*********************/
				input	wire			stall,			//延迟
				input	wire			flush,			//刷新
		/***************************IF/ID流水线寄存器******************/
				input	wire	[31:0]	if_pc,			//程序计数器
				input	wire			if_en,			//流水线数据是否有效
		/***************************ID/EX流水线寄存器******************/
				output	reg		[31:0]	id_pc,			//程序计数器
				output	reg				id_en,			//流水线数据是否有效
				output	reg		[31:0]	id_alu_in_0,	//ALU输入0
				output	reg		[31:0]	id_alu_in_1,	//ALU输入1
				output	reg		[3:0]	id_alu_op,		//ALU操作
				output	reg				id_br_flag,		//分支符号位
				output	reg		[3:0]	id_mem_op,		//内存操作
				output	reg		[31:0]	id_mem_wr_data,	//内存写入数据
				output	reg		[1:0]	id_ctrl_op,		//控制操作
				output	reg		[4:0]	id_dst_addr,	//通用寄存器写入地址
				output	reg				id_gpr_we_,		//通用寄存器写入有效
				output	reg		[2:0]	id_exp_code
				);
				
/**********************流水线寄存器*************************/
always @ (posedge clk or posedge reset)
	begin
		if (reset == `ENABLE)
			begin
				/*****异步复位*****/
				id_pc			<= #1  `WORD_ADDR_W'h0;
				id_en			<= #1  `DISABLE;
				id_alu_op 		<= #1  `ALU_OP_NOP;
				id_alu_in_0		<= #1  `WORD_DATA_W'h0;
				id_alu_in_1		<= #1  `WORD_ADDR_W'h0;
				id_br_flag		<= #1  `DISABLE;
				id_mem_op		<= #1  `MEM_OP_NOP;
				id_mem_wr_data	<= #1  `WORD_ADDR_W'h0;
				id_ctrl_op		<= #1  `CTRL_OP_NOP;
				id_dst_addr		<= #1  `REG_ADDR_W'd0;
				id_gpr_we_		<= #1  `DISABLE_;
				id_exp_code		<= #1  `ISA_EXP_NO_EXP;
			end
		else
			begin
				/*****流水线寄存器的更新*****/
				if(stall == `DISABLE)
					begin
						if(flush == `ENABLE)		//刷新
							begin
								id_pc			<= #1  `WORD_ADDR_W'h0;
								id_en			<= #1  `DISABLE;
								id_alu_op 		<= #1  `ALU_OP_NOP;
								id_alu_in_0		<= #1  `WORD_DATA_W'h0;
								id_alu_in_1		<= #1  `WORD_ADDR_W'h0;
								id_br_flag		<= #1  `DISABLE;
								id_mem_op		<= #1  `MEM_OP_NOP;
								id_mem_wr_data	<= #1  `WORD_ADDR_W'h0;
								id_ctrl_op		<= #1  `CTRL_OP_NOP;
								id_dst_addr		<= #1  `REG_ADDR_W'd0;
								id_gpr_we_		<= #1  `DISABLE_;
								id_exp_code		<= #1  `ISA_EXP_NO_EXP;
							end
						else						//流水线的下一个数据
							begin
								id_pc			<= #1  if_pc;
								id_en			<= #1  if_en;
								id_alu_op 		<= #1  alu_op;
								id_alu_in_0		<= #1  alu_in_0;
								id_alu_in_1		<= #1  alu_in_1;
								id_br_flag		<= #1  br_flag;
								id_mem_op		<= #1  mem_op;
								id_mem_wr_data	<= #1  mem_wr_data;
								id_ctrl_op		<= #1  ctrl_op;
								id_dst_addr		<= #1  dst_addr;
								id_gpr_we_		<= #1  gpr_we_;
								id_exp_code		<= #1  exp_code;
							end
					end
			end
	end

				
endmodule




