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
// Create Date: 2019/11/17 15:55:55
// Design Name: 
// Module Name: alu
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

/*************************************算术逻辑运算单元*********************************/
module alu(	input	wire	[31:0]	in_0,	//输入0
			input	wire	[31:0]	in_1,	//输入1
			input	wire	[3:0]	op,		//操作
			output	reg		[31:0]	out,	//输出
			output	reg				of		//溢出
			);
			
/***********************有符号输入输出信号*********************/
wire signed		[`WordDataBus]	s_in_0 = $signed(in_0);		//有符号输入0
wire signed		[`WordDataBus]	s_in_1 = $signed(in_1);		//有符号输入1
wire signed		[`WordDataBus]	s_out  = $signed(out);		//有符号输出

/***********************算术逻辑运算***************************/
always @ (*)
	begin
		case (op)
			`ALU_OP_AND:
				begin
					out	= in_0 & in_1;
				end
			`ALU_OP_OR:
				begin
					out	= in_0 | in_1;
				end
			`ALU_OP_XOR:
				begin
					out = in_0 ^ in_1;
				end
			`ALU_OP_ADDS:
				begin
					out = s_in_0 + s_in_1;
				end
			`ALU_OP_ADDU:
				begin
					out	= in_0 + in_1;
				end
			`ALU_OP_SUBS:
				begin
					out = s_in_0 - s_in_1;
				end
			`ALU_OP_SUBU:
				begin
					out	= in_0 - in_1;
				end
			`ALU_OP_SHRL:									//逻辑右移
				begin
					if (in_1[5] == 0)
						out = in_0 >> in_1[`ShAmountLoc];	//移位量为移位数的低五位
					else
						out = in_0;
				end
			`ALU_OP_SHRLA:									//算术右移
				begin
					if (in_1[5] == 0)
						out = in_0 >>> in_1[`ShAmountLoc];
					else
						out = in_0;
				end
			`ALU_OP_SHLL:
				begin
					if (in_1[5] == 0)
						out = in_0 << in_1[`ShAmountLoc];	
					else
						out = in_0;
				end
			`ALU_OP_STORE:
				begin
					out	= in_1;
				end
			default:
				begin
					out = in_0;
				end
		endcase
	end
	
/***********************溢出检测***************************/
always @ (*)												//溢出检测不实用，符号位检测不清楚
	begin
		case (op)
			`ALU_OP_ADDS:					//加法溢出
				begin
					if (((s_in_0 > 0) && (s_in_1 > 0) && (s_out < 0)) ||		
						((s_in_0 < 0) && (s_in_1 < 0) && (s_out > 0)))
						begin
							of = `ENABLE;
						end
					else
						begin
							of = `DISABLE;
						end
				end
			`ALU_OP_SUBS:					//减法溢出
				begin 
					if (((s_in_0 < 0) && (s_in_1 > 0) && (s_out > 0)) ||
						((s_in_0 > 0) && (s_in_1 > 0) && (s_out < 0)) ||
						((s_in_0 > 0) && (s_in_1 < 0) && (s_out < 0)))
						begin
							of = `ENABLE;
						end
					else
						begin
							of = `DISABLE;
						end
				end
			default:
				begin
					of = `DISABLE;
				end
		endcase
	end
			
endmodule




