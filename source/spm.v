`timescale 1ns / 1ps
/********** 共享头文件 **********/
`include "head/nettype.v"
`include "head/global_config.v"
`include "head/stddef.v"

/********** 特别头文件 **********/
`include "head/spm_head.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/13 13:00:51
// Design Name: 
// Module Name: spm
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

/**********************Scratch Pad Memory，便签存储器****************************/
module spm(	input	wire			clk,
	/**************************A端口IF阶段**************************/
			input	wire	[31:0]	if_spm_addr,		//地址			SPM深度 2^12 = 4096
			input	wire			if_spm_as_,			//地址选通
			input	wire			if_spm_rw,			//读写
			input	wire	[31:0]	if_spm_wr_data,		//写入的数据
			output	reg		[31:0]	if_spm_rd_data,		//读取的数据
	/**************************B端口MEM阶段*************************/
			input	wire	[31:0]	mem_spm_addr,		//地址
			input	wire			mem_spm_as_,		//地址选通
			input	wire			mem_spm_rw,			//读写
			input	wire	[31:0]	mem_spm_wr_data,	//写入的数据
			output	reg		[31:0]	mem_spm_rd_data		//读取的数据
			);
			
/***********写入有效标记位*******/
reg			wea;
reg			web;

reg [31:0]	mem [31:0];//memory array


/*****************写入有效信号的生成******************/
always @ (*)
	begin
		/******A端口*****/
		if((if_spm_as_ == `ENABLE_) && (if_spm_rw == `WRITE))
			begin
				wea = `MEM_ENABLE;				//写入有效
			end
		else
			begin
				wea = `MEM_DISABLE;				//写入无效
			end
		/*****B端口*****/
		if((mem_spm_as_ == `ENABLE_) && (mem_spm_rw == `WRITE))
			begin
				web = `MEM_ENABLE;			 	//写入有效
			end
		else
			begin
				web = `MEM_DISABLE;				//写入无效
			end
	end

always @ (posedge clk)
	begin
		/************A端口IF阶段**************/					
		if (wea == `MEM_ENABLE)
			begin
				mem[if_spm_addr] <= if_spm_wr_data;
			end
		if_spm_rd_data <= mem[if_spm_addr];
		/************B端口MEM阶段*************/	
		if (web == `MEM_ENABLE)
			begin
				mem[mem_spm_addr] <= mem_spm_wr_data;
			end
		mem_spm_rd_data <= mem[mem_spm_addr];
	end

/*****************实例化双端口RAM*********************/
//spm_ram your_instance_name (
	/************A端口IF阶段**************/						//仅读取
//	  .clka(clk),    // input wire clka
//	  .ena(if_spm_as_),      // input wire ena
//	  .wea(if_spm_rw),      // input wire [0 : 0] wea
//	  .addra(if_spm_addr),  // input wire [11 : 0] addra
//	  .dina(if_spm_wr_data),    // input wire [31 : 0] dina
//	  .douta(if_spm_rd_data),  // output wire [31 : 0] douta
	/************B端口MEM阶段*************/						//
//	  .clkb(clk),    // input wire clkb
//	  .enb(mem_spm_as_),      // input wire enb
//	  .web(mem_spm_rw),      // input wire [0 : 0] web
//	  .addrb(mem_spm_addr),  // input wire [11 : 0] addrb
//	  .dinb(mem_spm_wr_data),    // input wire [31 : 0] dinb
//	  .doutb(mem_spm_rd_data)  // output wire [31 : 0] doutb
//);



endmodule
