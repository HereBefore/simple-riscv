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
// Create Date: 2019/11/14 20:16:25
// Design Name: 
// Module Name: id_stage
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

/*****************************流水线ID阶段顶层文件*******************************/
module id_stage(input	wire			clk,
				input	wire			reset,
	/***********************IF/ID流水线寄存器**************************/
				input	wire			if_en,			//流水线if数据有效标志位
				input	wire	[31:0]	if_pc,			//程序计数器
				input	wire	[31:0]	if_insn,		//指令
	/***********************通用寄存器访问*****************************/
				input	wire	[31:0]	gpr_rd_data_0,	//读取数据0
				input	wire	[31:0]	gpr_rd_data_1,	//读取数据1
				output	wire	[4:0]	gpr_rd_addr_0,	//读取地址0
				output	wire	[4:0]	gpr_rd_addr_1,	//读取地址1
	/***********************控制寄存器访问*****************************/
				input	wire			exe_mode,		//执行模式
				input	wire	[31:0]	creg_rd_data,	//读取的数据
				output	wire	[4:0]	creg_rd_addr,	//读取的地址
	/***********************来自EX阶段的数据直通***********************/
				input	wire			ex_en,			//流水线ex数据有效		
				input	wire	[4:0]	ex_dst_addr,	//写入地址
				input	wire			ex_gpr_we_,		//写入有效
				input	wire	[31:0]	ex_fwd_data,	//数据直通
	/***********************来自MEM阶段的数据直通**********************/
				input	wire	[31:0]	mem_fwd_data,	//数据直通
	/***********************流水线控制信号*****************************/
				output	wire	[31:0]	br_addr,		//分支地址
				output	wire			br_taken,		//分支成立
				output	wire			ld_hazard,		//Load冒险
				input	wire			stall,			//延迟
				input	wire			flush,			//刷新
	/***********************ID/EX流水线寄存器**************************/
				output	wire	[31:0]	id_pc,			//程序计数器
				output	wire			id_en,			//流水线数据是否有效
				output	wire	[31:0]	id_alu_in_0,	//ALU输入0
				output	wire	[31:0]	id_alu_in_1,	//ALU输入1
				output	wire	[3:0]	id_alu_op,		//ALU操作
				output	wire			id_br_flag,		//分支符号位
				output	wire	[3:0]	id_mem_op,		//内存操作
				output	wire	[31:0]	id_mem_wr_data,	//内存写入数据
				output	wire	[1:0]	id_ctrl_op,		//控制操作
				output	wire	[4:0]	id_dst_addr,	//通用寄存器写入地址
				output	wire			id_gpr_we_,		//通用寄存器写入有效
				output	wire	[2:0]	id_exp_code		//异常代码
				);
				
/********************解码结果***********************/
wire	[3:0]	alu_op;			//ALU操作
wire	[31:0]	alu_in_0;		//ALU输入0
wire	[31:0]	alu_in_1;		//ALU输入1
wire			br_flag;		//分支符号位
wire	[3:0]	mem_op;			//内存操作
wire	[31:0]	mem_wr_data;	//内存写入数据
wire	[1:0]	ctrl_op;		//控制操作
wire	[4:0]	dst_addr;		//通用寄存器写入地址
wire			gpr_we_;		//通用寄存器写入有效
wire	[2:0]	exp_code;		//异常代码

/***********************************指令解码器*************************************/
decoder decoder(
	/*******************IF/ID流水线寄存器*************************/
	.if_en(if_en),.if_pc(if_pc),.if_insn(if_insn),
	/*******************通用寄存器接口****************************/
	.gpr_rd_addr_0(gpr_rd_addr_0),.gpr_rd_addr_1(gpr_rd_addr_1),.gpr_rd_data_0(gpr_rd_data_0),.gpr_rd_data_1(gpr_rd_data_1),
	/*******************控制寄存器访问****************************/
	.exe_mode(exe_mode),.creg_rd_data(creg_rd_data),.creg_rd_addr(creg_rd_addr),
	/*******************来自ID阶段的数据直通**********************/
	.id_en(id_en),.id_dst_addr(id_dst_addr),.id_gpr_we_(id_gpr_we_),.id_mem_op(id_mem_op),
	/*******************来自EX阶段的数据直通**********************/
	.ex_en(ex_en),.ex_dst_addr(ex_dst_addr),.ex_gpr_we_(ex_gpr_we_),.ex_fwd_data(ex_fwd_data),
	/*******************来自MEM阶段的数据直通*********************/
	.mem_fwd_data(mem_fwd_data),
	/*******************流水线控制信号****************************/
	.br_addr(br_addr),.br_taken(br_taken),.ld_hazard(ld_hazard),
	/*******************解码结果*********************************/
	.alu_op(alu_op),.alu_in_0(alu_in_0),.alu_in_1(alu_in_1),.br_flag(br_flag),.mem_op(mem_op),
	.mem_wr_data(mem_wr_data),.ctrl_op(ctrl_op),.dst_addr(dst_addr),.gpr_we_(gpr_we_),.exp_code(exp_code));
	

/*******************************ID阶段流水线寄存器*********************************/
id_reg id_reg(.clk(clk),.reset(reset),
	/***************************解码结果****************************/
	.alu_op(alu_op),.alu_in_0(alu_in_0),.alu_in_1(alu_in_1),.br_flag(br_flag),.mem_op(mem_op),
	.mem_wr_data(mem_wr_data),.ctrl_op(ctrl_op),.dst_addr(dst_addr),.gpr_we_(gpr_we_),.exp_code(exp_code),
	/***************************流水线控制信号**********************/
	.stall(stall),.flush(flush),
	/***************************IF/ID流水线寄存器*******************/
	.if_pc(if_pc),.if_en(if_en),
	/***************************ID/EX流水线寄存器*******************/
	.id_pc(id_pc),.id_en(id_en),.id_alu_in_0(id_alu_in_0),.id_alu_in_1(id_alu_in_1),.id_alu_op(id_alu_op),
	.id_br_flag(id_br_flag),.id_mem_op(id_mem_op),.id_mem_wr_data(id_mem_wr_data),.id_ctrl_op(id_ctrl_op),
	.id_dst_addr(id_dst_addr),.id_gpr_we_(id_gpr_we_),.id_exp_code(id_exp_code));
				
endmodule





