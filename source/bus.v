`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/07 09:15:30
// Design Name: 
// Module Name: bus
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

/*******************总线顶层文件*********************/
module bus(	input	wire				clk,
			input	wire				reset,
	/***************总线主控请求信号输入**************/
			input	wire				m0_req_,	
			input	wire				m1_req_,
			input	wire				m2_req_,
			input	wire				m3_req_,
	/***************目标地址**************************/
			input	wire	[31:0]		m0_addr,
			input	wire	[31:0]		m1_addr,
			input	wire	[31:0]		m2_addr,
			input	wire	[31:0]		m3_addr,	
	/***************地址选通**************************/
			input	wire				m0_as_,
			input	wire				m1_as_,
			input	wire				m2_as_,
			input	wire				m3_as_,
	/***************读写标志**************************/
			input	wire				m0_rw,
			input	wire				m1_rw,
			input	wire				m2_rw,
			input	wire				m3_rw,
	/****************ahb传输类型*********************/
			input	wire				m0_busy,
			input	wire				m1_busy,
			input	wire				m2_busy,
			input	wire				m3_busy,
	/****************写入的数据**********************/
			input	wire	[31:0]		m0_wr_data,
			input	wire	[31:0]		m1_wr_data,
			input	wire	[31:0]		m2_wr_data,
			input	wire	[31:0]		m3_wr_data,
	/***************从属的返回数据*******************/
			input	wire	[31:0]		s0_rd_data,
			input	wire	[31:0]		s1_rd_data,
			input	wire	[31:0]		s2_rd_data,
			input	wire	[31:0]		s3_rd_data,
			input	wire	[31:0]		s4_rd_data,
			input	wire	[31:0]		s5_rd_data,
			input	wire	[31:0]		s6_rd_data,
			input	wire	[31:0]		s7_rd_data,
	/***************从属的就绪信号*******************/
			input	wire				s0_rdy,
			input	wire				s1_rdy,
			input	wire				s2_rdy,
			input	wire				s3_rdy,
			input	wire				s4_rdy,
			input	wire				s5_rdy,
			input	wire				s6_rdy,
			input	wire				s7_rdy,
	/***************总线赋予命令返回信号**************/
			output	wire				m0_grnt_,
			output	wire				m1_grnt_,
			output	wire				m2_grnt_,
			output	wire				m3_grnt_,
	/***************总线使用端操作属性***************/
			output	wire	[31:0]		s_addr,
			output	wire				s_as_,
			output	wire				s_rw,
			output	wire	[31:0]		s_wr_data,
			output	wire	[1:0]		htrans,
	/***************片选信号*************************/
			output	wire				s0_cs_,
			output	wire				s1_cs_,
			output	wire				s2_cs_,
			output	wire				s3_cs_,
			output	wire				s4_cs_,
			output	wire				s5_cs_,
			output	wire				s6_cs_,
			output	wire				s7_cs_,
	/***************就绪信号*************************/
			output	wire				m_rdy,
	/***************选择读取的数据*******************/
			output	wire	[31:0]		m_rd_data
			);

/*****************************总线仲裁器*****************************/
bus_arbiter bus_arbiter(.clk(clk),.reset(reset),
	/***********总线主控请求信号输入**************/
	.m0_req_(m0_req_),.m1_req_(m1_req_),.m2_req_(m2_req_),.m3_req_(m3_req_),
	/***********总线赋予命令返回信号**************/
	.m0_grnt_(m0_grnt_),.m1_grnt_(m1_grnt_),.m2_grnt_(m2_grnt_),.m3_grnt_(m3_grnt_));

/**************************总线主控多路复用器************************/
bus_master_mux bus_master_mux(
	/***********目标地址**************************/
	.m0_addr(m0_addr),.m1_addr(m1_addr),.m2_addr(m2_addr),.m3_addr(m3_addr),
	/***********地址选通**************************/
	.m0_as_(m0_as_),.m1_as_(m1_as_),.m2_as_(m2_as_),.m3_as_(m3_as_),
	/***********读/写操作标志*********************/
	.m0_rw(m0_rw),.m1_rw(m1_rw),.m2_rw(m2_rw),.m3_rw(m3_rw),
	/***********写入的数据************************/
	.m0_wr_data(m0_wr_data),.m1_wr_data(m1_wr_data),.m2_wr_data(m2_wr_data),.m3_wr_data(m3_wr_data),
	/***********赋予总线**************************/
	.m0_grnt_(m0_grnt_),.m1_grnt_(m1_grnt_),.m2_grnt_(m2_grnt_),.m3_grnt_(m3_grnt_),
	/**************ahb传输类型********************/
	.m0_busy(m0_busy),.m1_busy(m1_busy),.m2_busy(m2_busy),.m3_busy(m3_busy),
	/***********从属信号输出**********************/
	.s_addr(s_addr),.s_as_(s_as_),.s_rw(s_rw),.s_wr_data(s_wr_data),.htrans(htrans));

/**************************地址解码器*********************************/
bus_addr_dec bus_addr_dec(
	/***********地址输入**************************/
	.s_addr(s_addr),
	/***********从属片选信号**********************/
	.s0_cs_(s0_cs_),.s1_cs_(s1_cs_),.s2_cs_(s2_cs_),.s3_cs_(s3_cs_),
	.s4_cs_(s4_cs_),.s5_cs_(s5_cs_),.s6_cs_(s6_cs_),.s7_cs_(s7_cs_));
	
/**************************总线从属多路复用器*************************/
bus_slave_mux bus_slave_mux(
	/***********片选信号*************************/
	.s0_cs_(s0_cs_),.s1_cs_(s1_cs_),.s2_cs_(s2_cs_),.s3_cs_(s3_cs_),
	.s4_cs_(s4_cs_),.s5_cs_(s5_cs_),.s6_cs_(s6_cs_),.s7_cs_(s7_cs_),
	/***********读出来的数据*********************/
	.s0_rd_data(s0_rd_data),.s1_rd_data(s1_rd_data),.s2_rd_data(s2_rd_data),.s3_rd_data(s3_rd_data),
	.s4_rd_data(s4_rd_data),.s5_rd_data(s5_rd_data),.s6_rd_data(s6_rd_data),.s7_rd_data(s7_rd_data),
	/***********就绪标志*************************/
	.s0_rdy(s0_rdy),.s1_rdy(s1_rdy),.s2_rdy(s2_rdy),.s3_rdy(s3_rdy),
	.s4_rdy(s4_rdy),.s5_rdy(s5_rdy),.s6_rdy(s6_rdy),.s7_rdy(s7_rdy),
	/***********总线主控共享信号输出*************/
	.m_rd_data(m_rd_data),.m_rdy(m_rdy));
	
endmodule



