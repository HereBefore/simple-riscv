`timescale 1ns / 1ps
/********** 共享头文件 **********/
`include "head/nettype.v"
`include "head/stddef.v"
`include "head/global_config.v"

/********** 特别头文件 **********/
`include "head/bus_head.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/07 09:15:30
// Design Name: 
// Module Name: bus_slave_mux
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

/**************************总线从属多路复用器*******************/		//--AHBMUX
module bus_slave_mux(
			/***********************片选**************************/
					input	wire				s0_cs_,					//--MUX_SEL
					input	wire				s1_cs_,
					input	wire				s2_cs_,
					input	wire				s3_cs_,
					input	wire				s4_cs_,
					input	wire				s5_cs_,
					input	wire				s6_cs_,
					input	wire				s7_cs_,
			/***********************读出的数据*********************/	//--HRDATA_Sx
					input	wire	[31:0]		s0_rd_data,
					input	wire	[31:0]		s1_rd_data,
					input	wire	[31:0]		s2_rd_data,
					input	wire	[31:0]		s3_rd_data,
					input	wire	[31:0]		s4_rd_data,
					input	wire	[31:0]		s5_rd_data,
					input	wire	[31:0]		s6_rd_data,
					input	wire	[31:0]		s7_rd_data,
			/***********************就绪标志***********************/
					input	wire				s0_rdy,					//--HREADYOUT_Sx
					input	wire				s1_rdy,
					input	wire				s2_rdy,
					input	wire				s3_rdy,
					input	wire				s4_rdy,
					input	wire				s5_rdy,
					input	wire				s6_rdy,
					input	wire				s7_rdy,
			/******************总线主控共享信号输出*****************/
					output	reg		[31:0]		m_rd_data,				//--HRDATA
					output	reg					m_rdy					//--HRDATA
					);

always @(*)
	begin
		/******选择片选信号对应的从属*****/
		if (s0_cs_ == `ENABLE_)			//访问0号总线从属
			begin
				m_rd_data = s0_rd_data;
				m_rdy	  = s0_rdy;
			end
		else if (s1_cs_ == `ENABLE_)	//访问1号总线从属
			begin
				m_rd_data = s1_rd_data;
				m_rdy	  = s1_rdy;
			end
		else if (s2_cs_ == `ENABLE_)	//访问2号总线从属
			begin
				m_rd_data = s2_rd_data;
				m_rdy	  = s2_rdy;
			end
		else if (s3_cs_ == `ENABLE_)	//访问3号总线从属
			begin
				m_rd_data = s3_rd_data;
				m_rdy	  = s3_rdy;
			end	
		else if (s4_cs_ == `ENABLE_)	//访问4号总线从属
			begin
				m_rd_data = s4_rd_data;
				m_rdy	  = s4_rdy;
			end
		else if (s5_cs_ == `ENABLE_)	//访问5号总线从属
			begin
				m_rd_data = s5_rd_data;
				m_rdy	  = s5_rdy;
			end
		else if (s6_cs_ == `ENABLE_)	//访问6号总线从属
			begin
				m_rd_data = s6_rd_data;
				m_rdy	  = s6_rdy;
			end
		else if (s7_cs_ == `ENABLE_)	//访问7号总线从属
			begin
				m_rd_data = s7_rd_data;
				m_rdy	  = s7_rdy;
			end
		else
			begin
				m_rd_data = 0;
				m_rdy	  = 0;
			end
	end

endmodule
