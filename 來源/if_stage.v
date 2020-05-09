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
// Create Date: 2019/11/14 16:42:24
// Design Name: 
// Module Name: if_stage
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

/*****************************流水线IF阶段顶层文件*******************************/
module if_stage(input	wire			clk,
				input	wire			reset,
	/**********************流水线控制信号***********************/
				input	wire			stall,
				input	wire			flush,
				output	wire			busy,
				input	wire	[31:0]	new_pc,
				input	wire			br_taken,
				input	wire	[31:0]	br_addr,
	/**********************IF/ID流水线寄存器********************/
				output	wire	[31:0]	if_pc,		
				output	wire	[31:0]	if_insn,	
				output	wire			if_en,
	/**********************SPM接口*****************************/
				input	wire	[31:0]	spm_rd_data,
				output	wire	[31:0]	spm_addr,	
				output	wire			spm_as_,	
				output	wire			spm_rw,		
				output	wire	[31:0]	spm_wr_data,
	/************************总线接口******************************/
				input	wire	[31:0]	bus_rd_data,
				input	wire			bus_rdy_,	
				input	wire			bus_grnt_,	
				output	wire			bus_req_,	
				output	wire	[31:0]	bus_addr,	
				output	wire			bus_as_,	
				output	wire			bus_rw,		
				output	wire	[31:0]	bus_wr_data
				);

wire			as_;
wire			rw;
wire	[31:0]	wr_data;
wire	[31:0]	rd_inData;

assign	as_		= `ENABLE_;
assign	rw		= `READ;			//assign spm_rw = bus_rw = rw = `READ;
assign	wr_data	= `WORD_DATA_W'h0;



/************************************总线接口*****************************************/
AHB_if bus_if_1(.clk(clk),.reset(reset),
	/************************流水线控制信号************************/
	.stall(stall),.flush(flush),.busy(busy),
	/************************CPU接口*******************************/
	.addr(if_pc),.as_(as_),.rw(rw),.wr_data(wr_data),.rd_data(rd_inData),
	/************************SPM接口*******************************/
	.spm_rd_data(spm_rd_data),.spm_addr(spm_addr),.spm_as_(spm_as_),.spm_rw(spm_rw),.spm_wr_data(spm_wr_data),
	/************************总线接口******************************/
	.bus_rd_data(bus_rd_data),.bus_rdy_(bus_rdy_),.bus_grnt_(bus_grnt_),.bus_req_(bus_req_),
	.bus_addr(bus_addr),.bus_as_(bus_as_),.bus_rw(bus_rw),.bus_wr_data(bus_wr_data));
	
	
/******************************IF阶段的流水线寄存器**********************************/
if_reg if_reg(.clk(clk),.reset(reset),
	/*************************读取数据****************************/
	.insn(rd_inData),
	/*************************流水线控制信号**********************/
	.stall(stall),.flush(flush),.new_pc(new_pc),.br_taken(br_taken),.br_addr(br_addr),
	/************************IF/ID流水线寄存器*****************/
	.if_pc(if_pc),.if_insn(if_insn),.if_en(if_en));
	
	

endmodule





