`timescale 1ns / 1ps
/********** 共同头文件 **********/
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
// Module Name: bus_addr_dec
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

/*********************************地址解码器******************************/	//--AHBDCD
module bus_addr_dec(input	wire	[31:0]		s_addr,	//地址输入			//--HADDR
					
					output	reg					s0_cs_,	//0号总线从属		//--HSEL_S1
					output	reg					s1_cs_,	//1号总线从属
					output	reg					s2_cs_,	//2号总线从属
					output	reg					s3_cs_,	//3号总线从属
					output	reg					s4_cs_,	//4号总线从属
					output	reg					s5_cs_,	//5号总线从属
					output	reg					s6_cs_,	//6号总线从属
					output	reg					s7_cs_	//7号总线从属
					);

/***********************总线从属索引***********************/
wire	[`BusSlaveIndexBus]	s_index = s_addr[`BusSlaveIndexLoc];
//wire		[2:0]s_index = s_addr[29:27];

/***********************总线从属多路复用器*****************/
always @(*)
	begin
		/*****选择地址对应的从属*****/
		case (s_index)
			`BUS_SLAVE_0:				//访问0号总线从属
				begin
					s0_cs_ = `ENABLE_;
					s1_cs_ = `DISABLE_;
					s2_cs_ = `DISABLE_;
					s3_cs_ = `DISABLE_;
					s4_cs_ = `DISABLE_;
					s5_cs_ = `DISABLE_;
					s6_cs_ = `DISABLE_;
					s7_cs_ = `DISABLE_;
				end
			`BUS_SLAVE_1:				//访问1号总线从属
				begin
					s1_cs_ = `ENABLE_;
					s0_cs_ = `DISABLE_;
					s2_cs_ = `DISABLE_;
					s3_cs_ = `DISABLE_;
					s4_cs_ = `DISABLE_;
					s5_cs_ = `DISABLE_;
					s6_cs_ = `DISABLE_;
					s7_cs_ = `DISABLE_;
				end
			`BUS_SLAVE_2:				//访问2号总线从属
				begin
					s2_cs_ = `ENABLE_;
					s0_cs_ = `DISABLE_;
					s1_cs_ = `DISABLE_;
					s3_cs_ = `DISABLE_;
					s4_cs_ = `DISABLE_;
					s5_cs_ = `DISABLE_;
					s6_cs_ = `DISABLE_;
					s7_cs_ = `DISABLE_;
				end
			`BUS_SLAVE_3:				//访问3号总线从属
				begin
					s3_cs_ = `ENABLE_;
					s0_cs_ = `DISABLE_;
					s1_cs_ = `DISABLE_;
					s2_cs_ = `DISABLE_;
					s4_cs_ = `DISABLE_;
					s5_cs_ = `DISABLE_;
					s6_cs_ = `DISABLE_;
					s7_cs_ = `DISABLE_;
				end
			`BUS_SLAVE_4:				//访问4号总线从属
				begin
					s4_cs_ = `ENABLE_;
					s0_cs_ = `DISABLE_;
					s1_cs_ = `DISABLE_;
					s2_cs_ = `DISABLE_;
					s3_cs_ = `DISABLE_;
					s5_cs_ = `DISABLE_;
					s6_cs_ = `DISABLE_;
					s7_cs_ = `DISABLE_;
				end
			`BUS_SLAVE_5:				//访问5号总线从属
				begin
					s5_cs_ = `ENABLE_;
					s0_cs_ = `DISABLE_;
					s1_cs_ = `DISABLE_;
					s2_cs_ = `DISABLE_;
					s3_cs_ = `DISABLE_;
					s4_cs_ = `DISABLE_;
					s6_cs_ = `DISABLE_;
					s7_cs_ = `DISABLE_;
				end
			`BUS_SLAVE_6:				//访问6号总线从属
				begin	
					s6_cs_ = `ENABLE_;
					s0_cs_ = `DISABLE_;
					s1_cs_ = `DISABLE_;
					s2_cs_ = `DISABLE_;
					s3_cs_ = `DISABLE_;
					s4_cs_ = `DISABLE_;
					s5_cs_ = `DISABLE_;
					s7_cs_ = `DISABLE_;
				end
			`BUS_SLAVE_7:				//访问7号总线从属
				begin
					s7_cs_ = `ENABLE_;
					s0_cs_ = `DISABLE_;
					s1_cs_ = `DISABLE_;
					s2_cs_ = `DISABLE_;
					s3_cs_ = `DISABLE_;
					s4_cs_ = `DISABLE_;
					s5_cs_ = `DISABLE_;
					s6_cs_ = `DISABLE_;
				end
			default:
				begin
					s0_cs_ = `DISABLE_;
					s1_cs_ = `DISABLE_;
					s2_cs_ = `DISABLE_;
					s3_cs_ = `DISABLE_;
					s4_cs_ = `DISABLE_;
					s5_cs_ = `DISABLE_;
					s6_cs_ = `DISABLE_;
					s7_cs_ = `DISABLE_;
				end
		endcase
	end

endmodule
