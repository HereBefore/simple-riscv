`timescale 1ns / 1ps
/********** 共享头文件 **********/
`include "head/nettype.v"
`include "head/global_config.v"
`include "head/stddef.v"

/********** 特别头文件 **********/
`include "head/isa_head.v"
`include "head/cpu_head.v"
`include "head/bus_head.v"
`include "head/spm_head.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/19 17:27:39
// Design Name: 
// Module Name: CPU
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


module CPU(	input	wire			clk,
			input	wire			reset,
//			input	wire			clk_,
	/*****************************IF阶段总线接口******************************/
			input	wire	[31:0]	if_bus_rd_data,
			input	wire			if_bus_rdy_,
			input	wire			if_bus_grnt_,
			output	wire			if_bus_req_,
			output	wire	[31:0]	if_bus_addr,
			output	wire			if_bus_as_,
			output	wire			if_bus_rw,
			output	wire	[31:0]	if_bus_wr_data,
			output	wire			if_busy,
	/*****************************中断请求*************************************/
			input	wire	[7:0]	cpu_irq,
	/*****************************MEM阶段总线接口******************************/
			input	wire	[31:0]	mem_bus_rd_data,
			input	wire			mem_bus_rdy_,
			input	wire			mem_bus_grnt_,
			output	wire			mem_bus_req_,
			output	wire	[31:0]	mem_bus_addr,
			output	wire			mem_bus_as_,
			output	wire			mem_bus_rw,
			output	wire	[31:0]	mem_bus_wr_data,
			output	wire			mem_busy,
			output	wire	[2:0]	mem_wr_size		//内存写入大小
			);
		
		
//wire			if_busy;
wire			if_stall;
wire			if_flush;		
wire	[31:0]	new_pc;

wire			br_taken;
wire	[31:0]	br_addr;
wire	[31:0]	if_pc;
wire	[31:0]	if_insn;
wire			if_en;

wire	 		if_spm_as_;
wire	[31:0]	if_spm_addr;
wire			if_spm_rw;
wire	[31:0]	if_spm_wr_data;
wire	[31:0]	if_spm_rd_data;

wire	[4:0]	creg_rd_addr;
wire			ld_hazard;
wire			exe_mode;
wire	[31:0]	creg_rd_data;
wire			id_stall;
wire			id_flush;
wire	[31:0]	mem_fwd_data;

wire	[31:0]	ex_fwd_data;
wire	[31:0]	id_pc;
wire			id_en;
wire	[3:0]	id_alu_op;
wire	[31:0]	id_alu_in_0;
wire	[31:0]	id_alu_in_1;
wire			id_br_flag;
wire	[3:0]	id_mem_op;
wire	[31:0]	id_mem_wr_data;
wire	[1:0]	id_ctrl_op;
wire	[4:0]	id_dst_addr;
wire			id_gpr_we_;
wire	[2:0]	id_exp_code;

wire	[31:0]	gpr_rd_data_0;
wire	[31:0]	gpr_rd_data_1;
wire	[4:0]	gpr_rd_addr_0;
wire	[4:0]	gpr_rd_addr_1;

wire	[31:0]	spm_rd_data;
wire	[31:0]	spm_addr;
wire			spm_as_;
wire			spm_rw;
wire	[31:0]	spm_wr_data;

wire			int_detect;
wire			ex_stall;
wire			ex_flush;

wire	[31:0]	ex_pc;
wire			ex_en;
wire			ex_br_flag;
wire	[3:0]	ex_mem_op;
wire	[31:0]	ex_mem_wr_data;
wire	[1:0]	ex_ctrl_op;
wire	[4:0]	ex_dst_addr;
wire			ex_gpr_we_;
wire	[2:0]	ex_exp_code;
wire	[31:0]	ex_out;

wire			mem_gpr_we_;
wire	[4:0]	mem_dst_addr;
wire	[31:0]	mem_out;

//wire			mem_busy;
wire			mem_stall;
wire			mem_flush;
wire	[31:0]	mem_pc;
wire			mem_en;
wire			mem_br_flag;
wire	[1:0]	mem_ctrl_op;
wire	[2:0]	mem_exp_code;


wire			clk_ = ~clk; 


/*****************************流水线IF阶段*******************************/
if_stage if_stage(.clk(clk),.reset(reset),
	/************************流水线控制信号*************************/
	.stall(if_stall),.flush(if_flush),.busy(if_busy),.new_pc(new_pc),.br_taken(br_taken),.br_addr(br_addr),
	/************************IF/ID流水线寄存器**********************/
	.if_pc(if_pc),.if_insn(if_insn),.if_en(if_en),
	/************************SPM接口********************************/
	.spm_rd_data(if_spm_rd_data),.spm_addr(if_spm_addr),.spm_as_(if_spm_as_),
	.spm_rw(if_spm_rw),.spm_wr_data(if_spm_wr_data),
	/************************总线接口*******************************/
	.bus_rd_data(if_bus_rd_data),.bus_rdy_(if_bus_rdy_),.bus_grnt_(if_bus_grnt_),.bus_req_(if_bus_req_),
	.bus_addr(if_bus_addr),.bus_as_(if_bus_as_),.bus_rw(if_bus_rw),.bus_wr_data(if_bus_wr_data));
	
/*****************************流水线ID阶段顶层文件*******************************/
id_stage id_stage(.clk(clk),.reset(reset),
	/***********************IF/ID流水线寄存器**************************/
	.if_en(if_en),.if_pc(if_pc),.if_insn(if_insn),
	/***********************通用寄存器访问*****************************/
	.gpr_rd_data_0(gpr_rd_data_0),.gpr_rd_data_1(gpr_rd_data_1),.gpr_rd_addr_0(gpr_rd_addr_0),.gpr_rd_addr_1(gpr_rd_addr_1),
	/***********************控制寄存器访问*****************************/
	.exe_mode(exe_mode),.creg_rd_data(creg_rd_data),.creg_rd_addr(creg_rd_addr),
	/***********************来自EX阶段的数据直通***********************/
	.ex_en(ex_en),.ex_dst_addr(ex_dst_addr),.ex_gpr_we_(ex_gpr_we_),.ex_fwd_data(ex_fwd_data),
	/***********************来自MEM阶段的数据直通**********************/
	.mem_fwd_data(mem_fwd_data),
	/***********************流水线控制信号*****************************/
	.br_addr(br_addr),.br_taken(br_taken),.ld_hazard(ld_hazard),.stall(id_stall),.flush(id_flush),
	/***********************ID/EX流水线寄存器**************************/
	.id_pc(id_pc),.id_en(id_en),.id_alu_in_0(id_alu_in_0),.id_alu_in_1(id_alu_in_1),.id_alu_op(id_alu_op),
	.id_br_flag(id_br_flag),.id_mem_op(id_mem_op),.id_mem_wr_data(id_mem_wr_data),.id_ctrl_op(id_ctrl_op),
	.id_dst_addr(id_dst_addr),.id_gpr_we_(id_gpr_we_),.id_exp_code(id_exp_code));

/***********************************EX阶段顶层模块*************************************/
ex_stage ex_stage(.clk(clk),.reset(reset),
	/*******************中断检测信号***********************/
	.int_detect(int_detect),
	/*******************流水线控制信号*********************/
	.stall(ex_stall),.flush(ex_flush),
	/*******************计算信号直通***********************/
	.fwd_data(ex_fwd_data),
	/*******************ID/EX阶段流水线寄存器**************/
	.id_pc(id_pc),.id_en(id_en),.id_alu_op(id_alu_op),.id_alu_in_0(id_alu_in_0),.id_alu_in_1(id_alu_in_1),
	.id_br_flag(id_br_flag),.id_mem_op(id_mem_op),.id_mem_wr_data(id_mem_wr_data),
	.id_ctrl_op(id_ctrl_op),.id_dst_addr(id_dst_addr),.id_gpr_we_(id_gpr_we_),.id_exp_code(id_exp_code),
	/*******************EX/MEM流水线寄存器******************/
	.ex_pc(ex_pc),.ex_en(ex_en),.ex_br_flag(ex_br_flag),.ex_mem_op(ex_mem_op),.ex_mem_wr_data(ex_mem_wr_data),
	.ex_ctrl_op(ex_ctrl_op),.ex_dst_addr(ex_dst_addr),.ex_gpr_we_(ex_gpr_we_),.ex_exp_code(ex_exp_code),.ex_out(ex_out));
	
/*************************************MEM阶段顶层模块*******************************************/
mem_stage mem_stage(.clk(clk),.reset(reset),
	/***************************流水线控制信号*****************************/
	.stall(mem_stall),.flush(mem_flush),
	/***************************总线忙信号*********************************/
	.busy(mem_busy),
	/***************************SPM接口************************************/
	.spm_rd_data(spm_rd_data),.spm_addr(spm_addr),.spm_as_(spm_as_),.spm_rw(spm_rw),.spm_wr_data(spm_wr_data),
	/***************************总线接口***********************************/
	.bus_rd_data(mem_bus_rd_data),.bus_rdy_(mem_bus_rdy_),.bus_grnt_(mem_bus_grnt_),.bus_req_(mem_bus_req_),
	.bus_addr(mem_bus_addr),.bus_as_(mem_bus_as_),.bus_rw(mem_bus_rw),.bus_wr_data(mem_bus_wr_data),.wr_size(mem_wr_size),
	/***************************EX/MEM流水线寄存器**************************/
	.ex_en(ex_en),.ex_mem_op(ex_mem_op),.ex_mem_wr_data(ex_mem_wr_data),.ex_out(ex_out),.ex_pc(ex_pc),
	.ex_br_flag(ex_br_flag),.ex_ctrl_op(ex_ctrl_op),.ex_dst_addr(ex_dst_addr),.ex_gpr_we_(ex_gpr_we_),.ex_exp_code(ex_exp_code),
	/***************************数据直通************************************/
	.fwd_data(mem_fwd_data),
	/***************************MEM/WB流水线寄存器**************************/
	.mem_pc(mem_pc),.mem_en(mem_en),.mem_br_flag(mem_br_flag),.mem_ctrl_op(mem_ctrl_op),
	.mem_gpr_we_(mem_gpr_we_),.mem_exp_code(mem_exp_code),.mem_out(mem_out),.mem_dst_addr(mem_dst_addr));
	
/*************************************CPU控制模块*******************************************/
cpu_ctrl cpu_ctrl(.clk(clk),.reset(reset),
	/***********************控制寄存器接口************************/
	.creg_rd_addr(creg_rd_addr),.creg_rd_data(creg_rd_data),.exe_mode(exe_mode),
	/***********************中断**********************************/
	.irq(cpu_irq),.int_detect(int_detect),
	/***********************ID/EX流水线寄存器**********************/
	.id_pc(id_pc),
	/***********************MEM/WB流水线寄存器*********************/
	.mem_pc(mem_pc),.mem_en(mem_en),.mem_br_flag(mem_br_flag),.mem_ctrl_op(mem_ctrl_op),
	.mem_dst_addr(mem_dst_addr),.mem_gpr_we_(mem_gpr_we_),.mem_exp_code(mem_exp_code),.mem_out(mem_out),
	/***********************流水线的状态***************************/
	.if_busy(if_busy),.ld_hazard(ld_hazard),.mem_busy(mem_busy),
	/***********************延迟信号*******************************/
	.if_stall(if_stall),.id_stall(id_stall),.ex_stall(ex_stall),.mem_stall(mem_stall),
	/***********************刷新信号*******************************/
	.if_flush(if_flush),.id_flush(id_flush),.ex_flush(ex_flush),.mem_flush(mem_flush),.new_pc(new_pc));
	
	
/**********************Scratch Pad Memory，便签存储器****************************/
spm spm(.clk(clk_),
	/**************************A端口IF阶段**************************/
	.if_spm_addr(if_spm_addr),.if_spm_rd_data(if_spm_rd_data),.if_spm_as_(if_spm_as_),.if_spm_rw(if_spm_rw),.if_spm_wr_data(if_spm_wr_data),
	/**************************B端口MEM阶段*************************/
	.mem_spm_rd_data(spm_rd_data),.mem_spm_addr(spm_addr),.mem_spm_as_(spm_as_),.mem_spm_rw(spm_rw),.mem_spm_wr_data(spm_wr_data));
	

/*************************************通用寄存器*****************************************/
gpr gpr(.clk(clk),.reset(reset),
	/**********************读取端口0*************************/
	.rd_addr_0(gpr_rd_addr_0),.rd_data_0(gpr_rd_data_0),
	/**********************读取端口1*************************/
	.rd_addr_1(gpr_rd_addr_1),.rd_data_1(gpr_rd_data_1),
	/**********************写入端口**************************/
	.we_(mem_gpr_we_),.wr_addr(mem_dst_addr),.wr_data(mem_out));



endmodule





