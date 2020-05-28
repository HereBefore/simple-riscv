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
// Create Date: 2019/11/17 19:50:26
// Design Name: 
// Module Name: mem_reg
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

/*********************************MEM阶段流水线寄存器************************************/
module mem_reg(	input	wire			clk,
				input	wire			reset,
	/***********************内存访问结果******************************/
				input	wire	[31:0]	out,				//结果
				input	wire			miss_align,			//未对齐
	/***********************流水线控制信号****************************/
				input	wire			stall,				//延迟
				input	wire			flush,				//刷新
	/***********************EX/MEM流水线寄存器************************/
				input	wire	[31:0]	ex_pc,				//程序计数器
				input	wire			ex_en,				//流水线数据是否有效
				input	wire			ex_br_flag,			//分支标志位
				input	wire	[1:0]	ex_ctrl_op,			//控制寄存器操作
				input	wire	[4:0]	ex_dst_addr,		//通用寄存器写入地址
				input	wire			ex_gpr_we_,			//通用寄存器写入有效
				input	wire	[2:0]	ex_exp_code,		//异常代码
	/***********************MEM/WB流水线寄存器************************/
				output	reg		[31:0]	mem_pc,				//程序计数器
				output	reg				mem_en,				//流水线数据是否有效
				output	reg				mem_br_flag,		//分支标志位
				output	reg		[1:0]	mem_ctrl_op,		//控制寄存器操作
				output	reg		[4:0]	mem_dst_addr,		//通用寄存器写入地址
				output	reg				mem_gpr_we_,		//通用寄存器写入有效
				output	reg		[2:0]	mem_exp_code,		//异常代码
				output	reg		[31:0]	mem_out				//处理结果
				);
				
/************************流水线寄存器************************/
always @ (posedge clk or posedge reset)
	begin
		if(reset == 1)
			begin
				/*****异步复位*****/
				mem_pc			<= #1  `WORD_ADDR_W'h0;
				mem_en			<= #1  `DISABLE;
				mem_br_flag		<= #1  `DISABLE;
				mem_ctrl_op 	<= #1  `CTRL_OP_NOP;
				mem_dst_addr	<= #1  `REG_ADDR_W'h0;
				mem_gpr_we_		<= #1  `DISABLE_;
				mem_exp_code	<= #1  `ISA_EXP_NO_EXP;
				mem_out			<= #1  `WORD_DATA_W'h0;
			end
		else
			begin
				if(stall == `DISABLE)
					begin
						/*****流水线寄存器的更新*****/
						if (flush == `ENABLE)					//刷新
							begin
								mem_pc			<= #1  `WORD_ADDR_W'h0;
								mem_en			<= #1  `DISABLE;
								mem_br_flag		<= #1  `DISABLE;
								mem_ctrl_op 	<= #1  `CTRL_OP_NOP;
								mem_dst_addr	<= #1  `REG_ADDR_W'h0;
								mem_gpr_we_		<= #1  `DISABLE_;
								mem_exp_code	<= #1  `ISA_EXP_NO_EXP;
								mem_out			<= #1  `WORD_DATA_W'h0;
							end
						else if (miss_align == `ENABLE)			//未对齐异常
							begin
								mem_pc			<= #1  ex_pc;
								mem_en			<= #1  ex_en;
								mem_br_flag		<= #1  ex_br_flag;
								mem_ctrl_op 	<= #1  `CTRL_OP_NOP;
								mem_dst_addr	<= #1  `REG_ADDR_W'h0;
								mem_gpr_we_		<= #1  `DISABLE_;
								mem_exp_code	<= #1  `ISA_EXP_MISS_ALIGN;
								mem_out			<= #1  `WORD_DATA_W'h0;
							end
						else									//下一个数据
							begin
								mem_pc			<= #1  ex_pc;
								mem_en			<= #1  ex_en;
								mem_br_flag		<= #1  ex_br_flag;
								mem_ctrl_op 	<= #1  ex_ctrl_op;
								mem_dst_addr	<= #1  ex_dst_addr;
								mem_gpr_we_		<= #1  ex_gpr_we_;
								mem_exp_code	<= #1  ex_exp_code;
								mem_out			<= #1  out;
							end
					end
			end
	end

				
endmodule
