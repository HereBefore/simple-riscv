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
// Module Name: mem_stage
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

/*************************************MEM阶段顶层模块*******************************************/
module mem_stage(	input	wire			clk,
					input	wire			reset,
	/***************************流水线控制信号*****************************/
					input	wire			stall,
					input	wire			flush,
	/***************************总线忙信号*********************************/
					output	wire			busy,
	/***************************SPM接口************************************/
					input	wire	[31:0]	spm_rd_data,
					output	wire	[31:0]	spm_addr,
					output	wire			spm_as_,
					output	wire			spm_rw,
					output	wire	[31:0]	spm_wr_data,
	/***************************总线接口***********************************/
					input	wire	[31:0]	bus_rd_data,
					input	wire			bus_rdy_,
					input	wire			bus_grnt_,
					output	wire			bus_req_,
					output	wire	[31:0]	bus_addr,
					output	wire			bus_as_,
					output	wire			bus_rw,
					output	wire	[31:0]	bus_wr_data,
					output	wire	[2:0]	wr_size,		//内存写入大小
	/***************************EX/MEM流水线寄存器**************************/
					input	wire			ex_en,
					input	wire	[3:0]	ex_mem_op,
					input	wire	[31:0]	ex_mem_wr_data,
					input	wire	[31:0]	ex_out,
					input	wire	[31:0]	ex_pc,
					input	wire			ex_br_flag,
					input	wire	[1:0]	ex_ctrl_op,
					input	wire	[4:0]	ex_dst_addr,
					input	wire			ex_gpr_we_,
					input	wire	[2:0]	ex_exp_code,
	/***************************数据直通************************************/
					output	wire	[31:0]	fwd_data,
	/***************************MEM/WB流水线寄存器**************************/
					output	wire	[31:0]	mem_pc,
					output	wire			mem_en,
					output	wire			mem_br_flag,
					output	wire	[1:0]	mem_ctrl_op,
					output	wire	[4:0]	mem_dst_addr,
					output	wire			mem_gpr_we_,
					output	wire	[2:0]	mem_exp_code,
					output	wire	[31:0]	mem_out
					);
					
/*********************内存控制单元的总线接口***********************/
wire	[31:0]		addr;
wire				as_;
wire				rw;
wire	[31:0]		wr_data;
wire	[31:0]		rd_data;

/*********************内存控制单元输出*****************************/
wire	[31:0]		out;				//内存访问结果输出
wire				miss_align;			//未对齐标志

assign	fwd_data = out; 

/*********************************内存访问控制模块***************************************/
mem_ctrl mem_ctrl(
	/*******************EX/MEM流水线寄存器********************/
	.ex_en(ex_en),.ex_mem_op(ex_mem_op),.ex_mem_wr_data(ex_mem_wr_data),.ex_out(ex_out),
	/*******************内存访问接口**************************/
	.rd_data(rd_data),.addr(addr),.as_(as_),.rw(rw),.wr_data(wr_data),.wr_size(wr_size),
	/*******************内存访问结果***************************/
	.out(out),.miss_align(miss_align));
	
/*********************************MEM阶段流水线寄存器************************************/
mem_reg mem_reg(.clk(clk),.reset(reset),
	/***********************内存访问结果******************************/
	.out(out),.miss_align(miss_align),
	/***********************流水线控制信号****************************/
	.stall(stall),.flush(flush),
	/***********************EX/MEM流水线寄存器************************/
	.ex_pc(ex_pc),.ex_en(ex_en),.ex_br_flag(ex_br_flag),.ex_ctrl_op(ex_ctrl_op),
	.ex_dst_addr(ex_dst_addr),.ex_gpr_we_(ex_gpr_we_),.ex_exp_code(ex_exp_code),
	/***********************MEM/WB流水线寄存器************************/
	.mem_pc(mem_pc),.mem_en(mem_en),.mem_br_flag(mem_br_flag),.mem_ctrl_op(mem_ctrl_op),
	.mem_dst_addr(mem_dst_addr),.mem_gpr_we_(mem_gpr_we_),.mem_exp_code(mem_exp_code),.mem_out(mem_out));
	
AHB_if bus_if_2(.clk(clk),.reset(reset),
	/************************流水线控制信号************************/
	.stall(stall),.flush(flush),.busy(busy),
	/************************CPU接口*******************************/
	.addr(addr),.as_(as_),.rw(rw),.wr_data(wr_data),.rd_data(rd_data),
	/************************SPM接口*******************************/
	.spm_rd_data(spm_rd_data),.spm_addr(spm_addr),.spm_as_(spm_as_),.spm_rw(spm_rw),.spm_wr_data(spm_wr_data),
	/************************总线接口******************************/
	.bus_rd_data(bus_rd_data),.bus_rdy_(bus_rdy_),.bus_grnt_(bus_grnt_),.bus_req_(bus_req_),
	.bus_addr(bus_addr),.bus_as_(bus_as_),.bus_rw(bus_rw),.bus_wr_data(bus_wr_data));


endmodule




