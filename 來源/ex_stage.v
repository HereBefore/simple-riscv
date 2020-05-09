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
// Create Date: 2019/11/17 15:55:55
// Design Name: 
// Module Name: ex_stage
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

/***********************************EX阶段顶层模块*************************************/
module ex_stage(input	wire			clk,
				input	wire			reset,
		/*******************中断检测信号***********************/
				input	wire			int_detect,
		/*******************流水线控制信号*********************/
				input	wire			stall,
				input	wire			flush,
		/*******************计算信号直通***********************/
				output	wire	[31:0]	fwd_data,
		/*******************ID/EX阶段流水线寄存器**************/
				input	wire	[31:0]	id_pc,
				input	wire			id_en,
				input	wire	[3:0]	id_alu_op,
				input	wire	[31:0]	id_alu_in_0,
				input	wire	[31:0]	id_alu_in_1,
				input	wire			id_br_flag,
				input	wire	[3:0]	id_mem_op,
				input	wire	[31:0]	id_mem_wr_data,
				input	wire	[1:0]	id_ctrl_op,
				input	wire	[4:0]	id_dst_addr,
				input	wire			id_gpr_we_,
				input	wire	[2:0]	id_exp_code,
		/*******************EX/MEM流水线寄存器******************/
				output	wire	[31:0]	ex_pc,
				output	wire			ex_en,
				output	wire			ex_br_flag,
				output	wire	[3:0]	ex_mem_op,
				output	wire	[31:0]	ex_mem_wr_data,
				output	wire	[1:0]	ex_ctrl_op,
				output	wire	[4:0]	ex_dst_addr,
				output	wire			ex_gpr_we_,
				output	wire	[2:0]	ex_exp_code,
				output	wire	[31:0]	ex_out
				);

/******************运算结果******************/
wire	[31:0]	out;
wire			of;

assign	fwd_data = out;

/*************************************算术逻辑运算单元*********************************/
alu alu (.in_0(id_alu_in_0),.in_1(id_alu_in_1),.op(id_alu_op),
		 .out(out),.of(of));

/************************************EX阶段流水线寄存器*********************************/
ex_reg ex_reg (.clk(clk),.reset(reset),
	/***********************ALU的输出****************************/
	.alu_out(out),.alu_of(of),
	/***********************流水线控制信号***********************/
	.stall(stall),.flush(flush),.int_detect(int_detect),
	/***********************ID/EX阶段流水线寄存器****************/
	.id_pc(id_pc),.id_en(id_en),.id_br_flag(id_br_flag),.id_mem_op(id_mem_op),.id_mem_wr_data(id_mem_wr_data),
	.id_ctrl_op(id_ctrl_op),.id_dst_addr(id_dst_addr),.id_gpr_we_(id_gpr_we_),.id_exp_code(id_exp_code),
	/***********************EX/MEM流水线寄存器*******************/
	.ex_pc(ex_pc),.ex_en(ex_en),.ex_br_flag(ex_br_flag),.ex_mem_op(ex_mem_op),.ex_mem_wr_data(ex_mem_wr_data),
	.ex_ctrl_op(ex_ctrl_op),.ex_dst_addr(ex_dst_addr),.ex_gpr_we_(ex_gpr_we_),.ex_exp_code(ex_exp_code),.ex_out(ex_out));




endmodule






