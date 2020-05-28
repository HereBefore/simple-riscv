`timescale 1ns / 1ps
`include "head/nettype.v"
`include "head/stddef.v"
`include "head/global_config.v"
`include "head/bus_head.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/07 09:15:30
// Design Name: 
// Module Name: bus_arbiter
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

/*************************总线仲裁器*****************************/
module bus_arbiter( input	wire	clk,
					input	wire	reset,
			/***************总线主控请求信号输入**************/
					input	wire	m0_req_,	
					input	wire	m1_req_,
					input	wire	m2_req_,
					input	wire	m3_req_,
			/***************总线赋予命令返回信号**************/
					output	reg 	m0_grnt_,
					output	reg 	m1_grnt_,
					output	reg 	m2_grnt_,
					output	reg 	m3_grnt_
					);

	reg	[0:1]	owner;
	
	/****************赋予总线使用权部分***************/
	always @ (posedge clk/* or negedge reset*/)
		begin
			/*********赋予总线使用权**************/
			case (owner)
				`BUS_OWNER_MASTER_0:
					begin
						m0_grnt_ = `ENABLE_;	//赋予0号总线主控
						m1_grnt_ = `DISABLE_;
						m2_grnt_ = `DISABLE_;
						m3_grnt_ = `DISABLE_;
					end
				`BUS_OWNER_MASTER_1:
					begin
						m1_grnt_ = `ENABLE_;	//赋予1号总线主控
						m0_grnt_ = `DISABLE_;
						m2_grnt_ = `DISABLE_;
						m3_grnt_ = `DISABLE_;
					end
				`BUS_OWNER_MASTER_2:
					begin
						m2_grnt_ = `ENABLE_;	//赋予2号总线主控
						m0_grnt_ = `DISABLE_;
						m1_grnt_ = `DISABLE_;
						m3_grnt_ = `DISABLE_;
					end
				`BUS_OWNER_MASTER_3:
					begin
						m3_grnt_ = `ENABLE_;	//赋予3号总线主控
						m0_grnt_ = `DISABLE_;
						m1_grnt_ = `DISABLE_;
						m2_grnt_ = `DISABLE_;
					end
				default:
					begin
						m0_grnt_ = `DISABLE_;
						m1_grnt_ = `DISABLE_;
						m2_grnt_ = `DISABLE_;
						m3_grnt_ = `DISABLE_;
					end
			endcase
		end
		
	/***************总线使用权的仲裁部分***************/
	always @ (posedge clk or posedge reset)
		begin
			if (reset == `RESET_ENABLE)
				begin
					/*****异步复位*****/
					owner <=   `BUS_OWNER_MASTER_0;	
				end
			else
				begin
					/******仲裁******/
				case(owner)
					`BUS_OWNER_MASTER_0:	//当前总线使用权所有者：0号主控
						begin
							/*下一个获得总线使用权的主控*/
							if (m0_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_0;
								end
							else if (m1_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_1;
								end
							else if (m2_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_2;
								end
							else if (m3_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_3;
								end
						end
						
					`BUS_OWNER_MASTER_1:	//当前总线使用权所有者：1号主控
						begin
							/*下一个获得总线使用权的主控*/
							if (m1_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_1;
								end
							else if (m2_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_2;
								end
							else if (m3_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_3;
								end
							else if (m0_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_0;
								end
						end
					
					`BUS_OWNER_MASTER_2:	//当前总线使用权所有者：2号主控
						begin
							/*下一个获得总线使用权的主控*/
							if (m2_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_2;
								end
							else if (m3_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_3;
								end
							else if (m0_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_0;
								end
							else if (m1_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_1;
								end
						end
					
					`BUS_OWNER_MASTER_3:	//当前总线使用权所有者：3号主控
						begin
							/*下一个获得总线使用权的主控*/
							if (m3_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_3;
								end
							else if (m0_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_0;
								end
							else if (m1_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_1;
								end
							else if (m2_req_ == `ENABLE_)
								begin
									owner <=   `BUS_OWNER_MASTER_2;
								end
						end
				endcase
			end
		end
	
endmodule
