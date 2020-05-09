`ifndef __NETTYPE_HEADER__
	`define __NETTYPE_HEADER__
	
	/*********************设置默认网络类型：两者选一*********************/
//	`default_nettype none		
//	`default_nettype wire		
	
`endif

/*
 module memory ( output reg [31:0] data_out, 
				input [7:0] address, 
				input [31:0] data_in, 
				input [3:0] write_enable, 
				input clk ); 

reg [31:0] memory [0:255];
reg [31:0] memory_in = 0; // wire reg 
always @* 
	begin : combinational_logic 
		memory_in = memory[address]; 
		if (write_enable[3]) 					// 1xxx
			memory_in[31:24] = data_in[31:24]; 
		if (write_enable[2]) 					// x1xx
			memory_in[23:16] = data_in[23:16]; 
		if (write_enable[1]) 					// xx1x
			memory_in[15:8] = data_in[15:8]; 
		if (write_enable[0]) 					// xxx1
			memory_in[7:0] = data_in[7:0]; 
	end 
always @(posedge clk) 
	begin : sequential_logic 
		if (|write_enable) 
			begin 
				memory[address] <= memory_in; 
			end 
		data_out <= memory[address]; 
	end
*/