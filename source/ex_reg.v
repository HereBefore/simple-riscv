`timescale 1ns / 1ps
/********** 共享头文件 **********/
`include "head/nettype.v"
`include "head/global_config.v"
`include "head/stddef.v"

/********** 特殊头文件 **********/
`include "head/isa_head.v"
`include "head/cpu_head.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/17 15:55:55
// Design Name: 
// Module Name: ex_reg
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

/************************************EX阶段流水线寄存器*********************************/
module ex_reg(	input	wire				clk,
				input	wire				reset,
	/************************ALU的输出*****************************/
				input	wire	[31:0]		alu_out,		//运算结果
				input	wire				alu_of,			//溢出
	/************************流水线控制信号************************/
				input	wire				stall,			//延迟
				input	wire				flush,			//刷新
				input	wire				int_detect,		//中断检测
	/************************ID/EX流水线寄存器*********************/
				input	wire	[31:0]		id_pc,			//程序计数器
				input	wire				id_en,			//流水线数据是否有效
				input	wire				id_br_flag,		//分支标志位
				input	wire	[3:0]		id_mem_op,		//内存操作
				input	wire	[31:0]		id_mem_wr_data,	//内存写入数据
				input	wire	[1:0]		id_ctrl_op,		//控制寄存器操作
				input	wire	[4:0]		id_dst_addr,	//通用寄存器写入地址
				input	wire				id_gpr_we_,		//通用寄存器写入有效
				input	wire	[2:0]		id_exp_code,	//异常代码
	/************************EX/MEM流水线寄存器*********************/
				output	reg		[31:0]		ex_pc,			//程序计数器
				output	reg					ex_en,			//流水线数据是否有效
				output	reg					ex_br_flag,		//分支标志位
				output	reg		[3:0]		ex_mem_op,		//内存操作
				output	reg		[31:0]		ex_mem_wr_data,	//内存写入数据
				output	reg		[1:0]		ex_ctrl_op,		//控制寄存器操作
				output	reg		[4:0]		ex_dst_addr,	//控制寄存器写入地址
				output	reg					ex_gpr_we_,		//通用寄存器写入有效
				output	reg		[2:0]		ex_exp_code,	//异常代码
				output	reg		[31:0]		ex_out			//处理结果
				);
				
/**********************流水线寄存器************************/
always @ (posedge clk or posedge reset)
	begin
		/*****异步复位*****/
		if (reset == 1)
			begin
				ex_pc			<= #1  `WORD_ADDR_W'h0;
				ex_en			<= #1  `DISABLE;
				ex_br_flag		<= #1  `DISABLE;
				ex_mem_op		<= #1  `MEM_OP_NOP;
				ex_mem_wr_data	<= #1  `WORD_ADDR_W'h0;
				ex_ctrl_op		<= #1  `CTRL_OP_NOP;
				ex_dst_addr		<= #1  `REG_ADDR_W'd0;
				ex_gpr_we_		<= #1  `DISABLE_;
				ex_exp_code		<= #1  `ISA_EXP_NO_EXP;
				ex_out			<= #1  `WORD_DATA_W'h0;
			end
		else
			begin
				/*****流水线寄存器更新*****/
				if(stall == `DISABLE)
					begin
						if(flush == `ENABLE)				//刷新流水线
							begin
								ex_pc			<= #1  `WORD_ADDR_W'h0;
								ex_en			<= #1  `DISABLE;
								ex_br_flag		<= #1  `DISABLE;
								ex_mem_op		<= #1  `MEM_OP_NOP;
								ex_mem_wr_data	<= #1  `WORD_ADDR_W'h0;
								ex_ctrl_op		<= #1  `CTRL_OP_NOP;
								ex_dst_addr		<= #1  `REG_ADDR_W'd0;
								ex_gpr_we_		<= #1  `DISABLE_;
								ex_exp_code		<= #1  `ISA_EXP_NO_EXP;
								ex_out			<= #1  `WORD_DATA_W'h0;
							end
						else if (int_detect == `ENABLE)		//中断检测
							begin
								ex_pc			<= #1  id_pc;
								ex_en			<= #1  id_en;
								ex_br_flag		<= #1  id_br_flag;
								ex_mem_op		<= #1  `MEM_OP_NOP;
								ex_mem_wr_data	<= #1  `WORD_ADDR_W'h0;
								ex_ctrl_op		<= #1  `CTRL_OP_NOP;
								ex_dst_addr		<= #1  `REG_ADDR_W'd0;
								ex_gpr_we_		<= #1  `DISABLE_;
								ex_exp_code		<= #1  `ISA_EXP_EXT_INT;		//中断异常
								ex_out			<= #1  `WORD_DATA_W'h0;
							end
						else if (alu_of == `ENABLE)			//算数溢出
							begin
								ex_pc			<= #1  id_pc;
								ex_en			<= #1  id_en;
								ex_br_flag		<= #1  id_br_flag;
								ex_mem_op		<= #1  `MEM_OP_NOP;
								ex_mem_wr_data	<= #1  `WORD_ADDR_W'h0;
								ex_ctrl_op		<= #1  `CTRL_OP_NOP;
								ex_dst_addr		<= #1  `REG_ADDR_W'd0;
								ex_gpr_we_		<= #1  `DISABLE_;
								ex_exp_code		<= #1  `ISA_EXP_OVERFLOW;	//溢出异常
								ex_out			<= #1  `WORD_DATA_W'h0;
							end
						else								//更新到下一个数据
							begin
								ex_pc			<= #1  id_pc;
								ex_en			<= #1  id_en;
								ex_br_flag		<= #1  id_br_flag;
								ex_mem_op		<= #1  id_mem_op;
								ex_mem_wr_data	<= #1  id_mem_wr_data;
								ex_ctrl_op		<= #1  id_ctrl_op;
								ex_dst_addr		<= #1  id_dst_addr;
								ex_gpr_we_		<= #1  id_gpr_we_;
								ex_exp_code		<= #1  id_exp_code;
								ex_out			<= #1  alu_out;
							end
					end
			end
	end

				
endmodule
