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
// Module Name: bus_master_mux
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

/************************总线主控多路复用器********************/
module bus_master_mux(	
				/***********************目标地址**********************/
						input	wire	[31:0]		m0_addr,
						input	wire	[31:0]		m1_addr,
						input	wire	[31:0]		m2_addr,
						input	wire	[31:0]		m3_addr,
				/***********************地址选通**********************/
						input	wire				m0_as_,
						input	wire				m1_as_,
						input	wire				m2_as_,
						input	wire				m3_as_,
				/***********************读/写操作标志*****************/
						input	wire				m0_rw,
						input	wire				m1_rw,
						input	wire				m2_rw,
						input	wire				m3_rw,
				/***********************写入的数据********************/
						input	wire	[31:0]		m0_wr_data,
						input	wire	[31:0]		m1_wr_data,
						input	wire	[31:0]		m2_wr_data,
						input	wire	[31:0]		m3_wr_data,
				/***********************赋予总线**********************/
						input	wire				m0_grnt_,
						input	wire				m1_grnt_,
						input	wire				m2_grnt_,
						input	wire				m3_grnt_,
				/**********************ahb传输类型********************/
						input	wire				m0_busy,
						input	wire				m1_busy,
						input	wire				m2_busy,
						input	wire				m3_busy,
				/**********************从属信号输出*******************/
						output	reg		[31:0]		s_addr,
						output	reg					s_as_,
						output	reg					s_rw,
						output	reg		[31:0]		s_wr_data,
						output	reg		[1:0]		htrans
						);
						

	always @ (*) 
		begin
			/*选择持有总线使用权的主控*/
			if (m0_grnt_ == `ENABLE_)		//0号主控
				begin
					s_addr	  = m0_addr;
					s_as_	  = m0_as_;
					s_rw	  = m0_rw;
					s_wr_data = m0_wr_data;
					htrans	  = {m0_busy,1'b0};
				end
			else if (m1_grnt_ == `ENABLE_)	//1号主控
				begin
					s_addr	  = m1_addr;
					s_as_	  = m1_as_;
					s_rw	  = m1_rw;
					s_wr_data = m1_wr_data;
					htrans	  = {m1_busy,1'b0};
				end
			else if (m2_grnt_ == `ENABLE_)	//2号主控
				begin
					s_addr	  = m2_addr;
					s_as_	  = m2_as_;
					s_rw	  = m2_rw;
					s_wr_data = m2_wr_data;
					htrans	  = {m2_busy,1'b0};
				end
			else if (m3_grnt_ == `ENABLE_)	//3号主控
				begin
					s_addr	  = m3_addr;
					s_as_	  = m3_as_;
					s_rw	  = m3_rw;
					s_wr_data = m3_wr_data;
					htrans	  = {m3_busy,1'b0};
				end
			else 							//默认值
				begin
					s_addr	  = `WORD_ADDR_W'h0;
					s_as_	  = `DISABLE_;
					s_rw	  = `READ;
					s_wr_data = `WORD_DATA_W'h0;
					htrans	  = 2'b00;
				end
		end
						
endmodule
