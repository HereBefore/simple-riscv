`timescale 1ns / 1ps
/********** 共享头文件 **********/
`include "head/nettype.v"
`include "head/stddef.v"
`include "head/global_config.v"

/********** 特别头文件 **********/
`include "head/rom_head.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/11 10:49:30
// Design Name: 
// Module Name: rom
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


module rom( input	wire			clk,
			input	wire			reset,
	/**************总线接口*****************/
			input	wire			cs_,		//片选
			input	wire			as_,		//地址选通
			input	wire	[10:0]	addr,		//地址
			output	wire	[31:0]	rd_data,	//读取的数据
			output	reg				rdy_
			);

/*************实例化BROM_Single Port ROM****************/
rom_v rom_v(
	.clka(clk),
	.addra(addr),
	.douta(rd_data)
);

/*************生成就绪信号******************************/
always @ (posedge clk or posedge reset)
	begin
		if (reset == `RESET_ENABLE)
			begin
				rdy_ <=  #1 `DISABLE_;				//异步复位
			end
		else
			begin
				/*****生成就绪信号*****/
				if ((cs_ == `ENABLE_) && (as_ == `ENABLE_))
					begin
						rdy_ <=  #1 `ENABLE_;
					end
				else
					begin
						rdy_ <=  #1 `DISABLE_;
					end
			end
	end


endmodule
