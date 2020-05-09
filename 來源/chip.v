`timescale 1ns / 1ps
`include "head/stddef.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/26 15:35:15
// Design Name: 
// Module Name: chip
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


/*************************************SOC顶层文件*******************************************/
module chip(input	wire			clk,
//			input	wire			clk_;
			input	wire			reset
			);
			
/****************************总线主控*********************************/
wire	[31:0]		m_rd_data;
wire				m_rdy_;
/*******************0号总线主控：IF阶段*********************/
wire				m0_req_;
wire	[31:0]		m0_addr;
wire				m0_as_;
wire				m0_rw;
wire	[31:0]		m0_wr_data;
wire				m0_grnt_;
wire				m0_busy;
/*******************1号总线主控：MEM阶段*********************/
wire				m1_req_;
wire	[31:0]		m1_addr;
wire				m1_as_;
wire				m1_rw;
wire	[31:0]		m1_wr_data;
wire				m1_grnt_;
wire				m1_busy;
wire	[2:0]		mem_wr_size;		//内存写入大小
/*******************空余总线主控*********************/
wire				m_req_;
wire	[31:0]		m_addr;
wire				m_as_;
wire				m_rw;
wire	[31:0]		m_wr_data;
wire				m_grnt_;
/****************************总线从属*********************************/
wire				s_as_;
wire				s_rw;
wire	[31:0]		s_addr;
wire	[31:0]		s_wr_data;
wire	[1:0]		htrans;
/*******************0号总线从属：ROM*********************/
wire	[31:0]		s0_rd_data;
wire				s0_rdy_;
wire				s0_cs_;
/*******************2号总线从属：RAM*********************/
wire	[31:0]		s2_rd_data;
wire				s2_rdy_;
wire				s2_cs_;
/*******************空余总线从属*********************/
wire	[31:0]		s_rd_data;
wire				s_rdy_;
wire				s_cs_;
/****************************中断*********************************/
wire	[7:0]		cpu_irq;


/***********************空余信号线使能无效化***********************/
assign	m_req_ 		= `DISABLE_;
assign	m_addr 		= `WORD_ADDR_W'h0;
assign	m_as_  		= `DISABLE_;
assign	m_rw   		= `READ;
assign	m_wr_data	= `WORD_DATA_W'h0;
//assign	m_grnt		
assign	s_rd_data	= `WORD_DATA_W'h0;
assign	s_rdy_		= `DISABLE_;
//assign	s_cs
assign	cpu_irq		= 8'h0;



/************************************CPU******************************************/
CPU CPU(.clk(clk),.reset(reset),
	/*****************************IF阶段总线接口******************************/
	.if_bus_rd_data(m_rd_data),.if_bus_rdy_(m_rdy_),.if_bus_req_(m0_req_),.if_bus_addr(m0_addr),
	.if_bus_as_(m0_as_),.if_bus_rw(m0_rw),.if_bus_wr_data(m0_wr_data),.if_bus_grnt_(m0_grnt_),.if_busy(m0_busy),
	/*****************************中断请求*************************************/
	.cpu_irq(cpu_irq),
	/*****************************MEM阶段总线接口******************************/
	.mem_bus_rd_data(m_rd_data),.mem_bus_rdy_(m_rdy_),.mem_bus_req_(m1_req_),.mem_bus_addr(m1_addr),
	.mem_bus_as_(m1_as_),.mem_bus_rw(m1_rw),.mem_bus_wr_data(m1_wr_data),.mem_bus_grnt_(m1_grnt_),.mem_busy(m1_busy),.mem_wr_size(mem_wr_size));
	
	
/************************************总线******************************************/
bus bus_m(.clk(clk),.reset(reset),
	/***************总线主控请求信号输入**************/
	.m0_req_(m0_req_),.m1_req_(m1_req_),.m2_req_(m_req_),.m3_req_(m_req_),
	/***************目标地址**************************/
	.m0_addr(m0_addr),.m1_addr(m1_addr),.m2_addr(m_addr),.m3_addr(m_addr),
	/***************地址选通**************************/
	.m0_as_(m0_as_),.m1_as_(m1_as_),.m2_as_(m_as_),.m3_as_(m_as_),
	/***************读写标志**************************/
	.m0_rw(m0_rw),.m1_rw(m1_rw),.m2_rw(m_rw),.m3_rw(m_rw),
	/****************ahb传输类型*********************/
	.m0_busy(m0_busy),.m1_busy(m1_busy),.m2_busy(1'b0),.m3_busy(1'b0),
	/****************写入的数据**********************/
	.m0_wr_data(m0_wr_data),.m1_wr_data(m1_wr_data),.m2_wr_data(m_wr_data),.m3_wr_data(m_wr_data),
	/***************从属的返回数据*******************/
	.s0_rd_data(s0_rd_data),.s1_rd_data(s_rd_data),.s2_rd_data(s2_rd_data),.s3_rd_data(s_rd_data),
	.s4_rd_data(s_rd_data),.s5_rd_data(s_rd_data),.s6_rd_data(s_rd_data),.s7_rd_data(s_rd_data),
	/***************从属的就绪信号*******************/
	.s0_rdy(s0_rdy_),.s1_rdy(s_rdy_),.s2_rdy(s2_rdy_),.s3_rdy(s_rdy_),
	.s4_rdy(s_rdy_),.s5_rdy(s_rdy_),.s6_rdy(s_rdy_),.s7_rdy(s_rdy_),
	/***************总线赋予命令返回信号**************/
	.m0_grnt_(m0_grnt_),.m1_grnt_(m1_grnt_),.m2_grnt_(),.m3_grnt_(),
	/***************总线使用端操作属性***************/
	.s_addr(s_addr),.s_as_(s_as_),.s_rw(s_rw),.s_wr_data(s_wr_data),.htrans(htrans),
	/***************片选信号*************************/
	.s0_cs_(s0_cs_),.s1_cs_(),.s2_cs_(s2_cs_),.s3_cs_(),
	.s4_cs_(),.s5_cs_(),.s6_cs_(),.s7_cs_(),
	/***************就绪信号*************************/
	.m_rdy(m_rdy_), 
	/***************选择读取的数据*******************/
	.m_rd_data(m_rd_data));
	
/************************************ROM******************************************/
//rom rom(.clk(clk),.reset(reset),
//	/*******************总线接口*********************/
//	.cs_(s0_cs_),.as_(s_as_),.addr(s_addr),.rd_data(s0_rd_data),.rdy_(s0_rdy_));

   AHB2ROM AHB2ROM (
      .HSEL			(	~s0_cs_			),	//默认选用状态
      .HCLK			(	clk				), 
      .HRESETn		(	reset			), 
      .HREADY		(	~s_as_			),
      .HADDR		(	s_addr			),
      .HTRANS		(	htrans			), 	//传输类型
      .HWRITE		(	1'b0			),	//只读
      .HSIZE		(	3'b000			),	//传输大小(与全字、半字、字节有关;程序只读不考虑)
      .HWDATA		(	`WORD_DATA_W'h0	), 
      .HRDATA		(	s0_rd_data		), 
      .HREADYOUT	(	s0_rdy_			)
   );


/************************************RAM******************************************/
   // AHB-Lite RAM
   AHB2RAM AHB2RAM (
      .HSEL			(	~s2_cs_			),
      .HCLK			(	clk				), 
      .HRESETn		(	reset			), 
      .HREADY		(	~s_as_			), 
      .HADDR		(	s_addr			),
      .HTRANS		(	htrans			), 	//传输类型
      .HWRITE		(	s_rw			),
      .HSIZE		(	mem_wr_size		),	//传输大小
      .HWDATA		(	s_wr_data		), 
      .HRDATA		(	s2_rd_data		), 
      .HREADYOUT	(	s2_rdy_			)
   );

endmodule









