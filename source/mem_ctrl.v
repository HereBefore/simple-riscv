`timescale 1ns / 1ps
/********** 共享头文件 **********/
`include "head/nettype.v"
`include "head/global_config.v"
`include "head/stddef.v"

/********** 特别头文件 **********/
`include "head/isa_head.v"
`include "head/cpu_head.v"
`include "head/bus_head.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/17 19:50:26
// Design Name: 
// Module Name: mem_ctrl
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

/*********************************内存访问控制模块***************************************/
module mem_ctrl(
	/*******************EX/MEM流水线寄存器********************/
				input	wire			ex_en,			//流水线数据是否有效
				input	wire	[3:0]	ex_mem_op,		//内存操作
				input	wire	[31:0]	ex_mem_wr_data,	//内存写入数据
				input	wire	[31:0]	ex_out,			//处理结果
	/*******************内存访问接口**************************/
				input	wire	[31:0]	rd_data,		//读取的数据
				output	reg		[2:0]	wr_size,		//内存写入大小
				output	wire	[31:0]	addr,			//地址
				output	reg				as_,			//地址选通
				output	reg				rw,				//读/写
				output	reg 	[31:0]	wr_data,		//写入的数据
	/*******************内存访问结果***************************/
				output	reg		[31:0]	out,			//内存访问结果
				output	reg				miss_align		//未对齐标志
				);


wire  [1:0]	offset;
/*******************输出的赋值************************/
//assign wr_data	= ex_mem_wr_data;			//写入数据
assign addr		= {ex_out[`WordAddrLoc],2'b00};		//地址			[31:2]
assign offset	= ex_out[`ByteOffsetLoc];	//偏移			[1:0]

/*******************内存访问的控制*******************/
always @ (*)
	begin
		/*****默认值*****/
		miss_align  = `DISABLE;
		out		    = `WORD_DATA_W'h0;
		as_		    = `DISABLE_;
		rw		    = `READ;
		wr_size		= 3'b011;
		wr_data		= ex_mem_wr_data;							//写入数据
		/*****内存访问*****/
		if (ex_en == `ENABLE)
			begin
				case(ex_mem_op)
					`MEM_OP_LDW:								//字读取
						begin
							/*****字节偏移的检测*****/
							if (offset == `BYTE_OFFSET_WORD)	//对齐（字偏移量为0）
								begin
									out	= rd_data;
									as_	= `ENABLE_;
								end
							else								//未对齐
								begin
									miss_align = `ENABLE;
								end
						end
					`MEM_OP_STW:								//字写入
						begin
							/*****字偏移的检测*****/
							if(offset == `BYTE_OFFSET_WORD)		//对齐
								begin
									rw		= `WRITE;
									as_ 	= `ENABLE_;
									wr_size	= 3'b010;
								end
							else
								begin
									miss_align = `ENABLE;
								end
						end
					`MEM_OP_LDB:								//字节读取
						begin
							/*****字节偏移量检测*****/
							case (offset)
								`OFFSET_BYTE_ONE:
									begin
										out	= {{24{rd_data[7]}},rd_data[`ByteDataLoc_one]};
										as_	= `ENABLE_;
									end
								`OFFSET_BYTE_TWO:
									begin
										out	= {{24{rd_data[15]}},rd_data[`ByteDataLoc_two]};
										as_	= `ENABLE_;
									end
								`OFFSET_BYTE_THREE:
									begin
										out	= {{24{rd_data[23]}},rd_data[`ByteDataLoc_three]};
										as_	= `ENABLE_;
									end
								`OFFSET_BYTE_FOUR:
									begin
										out	= {{24{rd_data[31]}},rd_data[`ByteDataLoc_four]};
										as_	= `ENABLE_;
									end
								default:
									begin
										miss_align = `ENABLE;
									end
							endcase
						end
					`MEM_OP_STB:								//字节写入
						begin
							case (offset)
								`OFFSET_BYTE_ONE:
									begin
										rw			= `WRITE;
										as_ 		= `ENABLE_;
										wr_size		= 3'b000;
										wr_data		= {4{ex_mem_wr_data[`ByteDataLoc_one]}};	//字节1写入
									end
								`OFFSET_BYTE_TWO:
									begin
										rw			= `WRITE;
										as_ 		= `ENABLE_;
										wr_size		= 3'b000;
										wr_data		= {4{ex_mem_wr_data[`ByteDataLoc_two]}};	//字节2写入
									end
								`OFFSET_BYTE_THREE:
									begin
										rw			= `WRITE;
										as_	 		= `ENABLE_;	
										wr_size		= 3'b000;
										wr_data		= {4{ex_mem_wr_data[`ByteDataLoc_three]}};	//字节3写入
									end
								`OFFSET_BYTE_FOUR:
									begin
										rw			= `WRITE;
										as_ 		= `ENABLE_;
										wr_size		= 3'b000;
										wr_data		= {4{ex_mem_wr_data[`ByteDataLoc_four]}};	//字节4写入
									end
								default:
									begin
										miss_align = `ENABLE;
									end
							endcase
						end
					`MEM_OP_LDH:								//半字读取
						begin
							case (offset)
								`OFFSET_HALF_ONE:
									begin
										out	= {{16{rd_data[15]}},rd_data[`HalfDataLoc_one]};
										as_	= `ENABLE_;
									end
								`OFFSET_HALF_TWO:
									begin
										out	= {{16{rd_data[31]}},rd_data[`HalfDataLoc_two]};
										as_	= `ENABLE_;
									end
								default:
									begin
										miss_align = `ENABLE;
									end
							endcase
						end
					`MEM_OP_STH:								//半字写入
						begin
							case (offset)
								`OFFSET_HALF_ONE:
									begin
										rw			= `WRITE;
										as_ 		= `ENABLE_;
										wr_size		= 3'b001;
										wr_data		= {2{ex_mem_wr_data[`HalfDataLoc_one]}};	//半字1写入
									end
								`OFFSET_HALF_TWO:
									begin
										rw			= `WRITE;
										as_ 		= `ENABLE_;
										wr_size		= 3'b001;
										wr_data		= {2{ex_mem_wr_data[`HalfDataLoc_two]}};	//半字2写入
									end
								default:
									begin
										miss_align = `ENABLE;
									end
							endcase
						end
					`MEM_OP_LBU:								//无符号字节读取
						begin
							case (offset)
								`OFFSET_BYTE_ONE:
									begin
										out	= {{24{1'b0}},rd_data[`ByteDataLoc_one]};
										as_	= `ENABLE_;
									end
								`OFFSET_BYTE_TWO:
									begin
										out	= {{24{1'b0}},rd_data[`ByteDataLoc_two]};
										as_	= `ENABLE_;
									end
								`OFFSET_BYTE_THREE:
									begin
										out	= {{24{1'b0}},rd_data[`ByteDataLoc_three]};
										as_	= `ENABLE_;
									end
								`OFFSET_BYTE_FOUR:
									begin
										out	= {{24{1'b0}},rd_data[`ByteDataLoc_four]};
										as_	= `ENABLE_;
									end
								default:
									begin
										miss_align = `ENABLE;
									end
							endcase
						end
					`MEM_OP_LHU:								//无符号半字读取
						begin
							case (offset)
								`OFFSET_HALF_ONE:
									begin
										out	= {{16{1'b0}},rd_data[`HalfDataLoc_one]};
										as_	= `ENABLE_;
									end
								`OFFSET_HALF_TWO:
									begin
										out	= {{16{1'b0}},rd_data[`HalfDataLoc_two]};
										as_	= `ENABLE_;
									end
								default:
									begin
										miss_align = `ENABLE;
									end
							endcase
						end
					default:									//无内存访问
						begin
							out = ex_out;
						end
				endcase
			end
	end



endmodule
