`timescale 1ns / 1ps
/********** 共享头文件 **********/
`include "head/nettype.v"
`include "head/global_config.v"
`include "head/stddef.v"

/********** 特别头文件 **********/
`include "head/isa_head.v"
`include "head/cpu_head.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/14 20:16:25
// Design Name: 
// Module Name: decoder
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

/***************************指令解码器*******************************/
module decoder(	
	/********************IF/ID流水线寄存器*******************/
				input	wire			if_en,			//流水线if数据有效标志位
				input	wire	[31:0]	if_pc,			//程序计数器
				input	wire	[31:0]	if_insn,		//指令
	/********************通用寄存器接口**********************/
				input	wire	[31:0]	gpr_rd_data_0,	//读取数据0
				input	wire	[31:0]	gpr_rd_data_1,	//读取数据1
				output	wire	[4:0]	gpr_rd_addr_0,	//读取地址0
				output	wire	[4:0]	gpr_rd_addr_1,	//读取地址1
	/********************来自ID阶段的数据直通****************/
				input	wire			id_en,			//流水线id数据有效		0
				input	wire	[4:0]	id_dst_addr,	//写入地址				0
				input	wire			id_gpr_we_,		//写入有效				0
				input	wire	[3:0]	id_mem_op,		//内存操作				0
	/********************来自EX阶段的数据直通****************/
				input	wire			ex_en,			//流水线ex数据有效		0
				input	wire	[4:0]	ex_dst_addr,	//写入地址
				input	wire			ex_gpr_we_,		//写入有效
				input	wire	[31:0]	ex_fwd_data,	//数据直通
	/********************来自MEM阶段的数据直通***************/
				input	wire	[31:0]	mem_fwd_data,	//数据直通
	/********************控制寄存器接口**********************/
				input	wire			exe_mode,		//执行模式
				input	wire	[31:0]	creg_rd_data,	//读取的数据
				output	wire	[4:0]	creg_rd_addr,	//读取的地址
	/********************解码结果****************************/
				output	reg		[3:0]	alu_op,			//ALU操作
				output	reg		[31:0]	alu_in_0,		//ALU输入_0
				output	reg		[31:0]	alu_in_1,		//ALU输入_1
				output	reg		[31:0]	br_addr,		//分支地址
				output	reg				br_taken,		//分支成立
				output	reg				br_flag,		//分支标志位
				output	reg		[3:0]	mem_op,			//内存操作
				output	reg		[31:0]	mem_wr_data,	//内存写入操作
				output	reg		[1:0]	ctrl_op,		//控制操作
				output	reg		[4:0]	dst_addr,		//通用寄存器写入地址
				output	reg				gpr_we_,		//通用寄存器写入有效
				output	reg		[2:0]	exp_code,		//异常代码
				output	reg				ld_hazard		//Load冒险
				);
				

/********************************指令字段的分解***********************************/
wire		[`IsaOpBus]		opcode 	= if_insn[`IsaOpLoc];										//基本操作码
wire		[`RegAddrBus]	rd		= if_insn[`IsaRdAddrLoc];									//目标地址
wire		[`RegAddrBus]	rs1		= if_insn[`IsaRs1AddrLoc];									//rs1地址
wire		[`RegAddrBus]	rs2		= if_insn[`IsaRs2AddrLoc];									//rs2地址
wire		[`IsaFun3Bus]	funct3	= if_insn[`IsaFun3Loc];										//3位操作码
wire		[`IsaFun6Bus]	funct6	= if_insn[`IsaFun6Loc];										//6位操作码
wire		[`IsaFun7Bus]	funct7	= if_insn[`IsaFun7Loc];										//7位操作码
wire		[`IsaFun12Bus]	funct12 = if_insn[`IsaFun12Loc];									//12位操作码
wire		[`ShamtBus]		shamt	= if_insn[`ShamtLoc];										//移位量
//立即数
wire		[11:0]			imm_i	= if_insn[31:20];											//I类立即数
wire		[11:0]			imm_s	= {if_insn[31:25],if_insn[11:7]};							//S类立即数
wire		[11:0]			imm_b	= {if_insn[31],if_insn[7],if_insn[30:25],if_insn[11:8]};	//B类立即数
wire		[19:0]			imm_u	= if_insn[31:12];											//U类立即数
wire		[20:1]			imm_j	= {if_insn[31],if_insn[19:12],if_insn[20],if_insn[30:21]};	//J类立即数
/********************************立即数字段的扩充*********************************/
wire		[`WordDataBus]	s_imm_i	= {{20{if_insn[31]}},imm_i};			//I类立即数符号扩充
wire		[`WordDataBus]	s_imm_s	= {{20{if_insn[31]}},imm_s};			//S类立即数符号扩充
wire		[`WordDataBus]	s_imm_b = {{19{if_insn[31]}},imm_b,{1'b0}};		//B类立即数符号扩充
wire		[`WordDataBus]	s_imm_u = {imm_u,{12{1'b0}}};					//U类立即数符号扩充
wire		[`WordDataBus]	s_imm_j = {{11{if_insn[31]}},imm_j,{1'b0}};		//J类立即数符号扩充
wire		[`WordDataBus]	u_imm_i	= {{20{1'b0}},imm_i};					//I类立即数无符号扩充
wire		[`WordDataBus]	u_imm_s	= {{20{1'b0}},imm_s};					//S类立即数无符号扩充
/********************************通用寄存器的读取数据*****************************/
reg			[`WordDataBus]	ra_data;							//无符号Ra
wire signed	[`WordDataBus]	s_ra_data = $signed(ra_data);		//有符号Ra
reg			[`WordDataBus]	rb_data;							//无符号Rb
wire signed	[`WordDataBus]	s_rb_data = $signed(rb_data);		//有符号Rb
//assign	mem_wr_data	  = rb_data;								//内存写入数据
/********************************地址的生成***************************************/
wire		[`WordAddrBus]	ret_addr  = if_pc + 1'b1;						//返回地址
wire		[`WordAddrBus]	br_target = if_pc + s_imm_b[`WORD_ADDR_MSB:0];	//分支目标地址	------------------------
wire		[`WordAddrBus]	jr_target = ra_data[`WordAddrLoc];				//跳转目标地址
/********************************寄存器读取地址***********************************/
assign	gpr_rd_addr_0 = rs1;	//通用寄存器读取地址0
assign	gpr_rd_addr_1 = rs2;	//通用寄存器读取地址1
assign	creg_rd_addr  = imm_i[4:0];	//控制寄存器读取地址


/********************************数据直通*****************************************/
//数据直通用于规避数据冲突和控制冲突产生的错误
always @ (*)
	begin
		/*****Ra寄存器*****/
		if((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) && (id_dst_addr == rs1))
			begin
				ra_data = ex_fwd_data;		//来自EX阶段的数据直通
			end
		else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) && (ex_dst_addr == rs1))
			begin
				ra_data = mem_fwd_data;		//来自MEM阶段的数据直通
			end
		else
			begin
				ra_data = gpr_rd_data_0;	//从寄存器堆读取
			end
		/*****Rb寄存器*****/
		if((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) && (id_dst_addr == rs2))
			begin
				rb_data = ex_fwd_data;		//来自EX阶段的数据直通
			end
		else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) && (ex_dst_addr == rs2))
			begin
				rb_data = mem_fwd_data;		//来自MEM阶段的数据直通
			end
		else
			begin
				rb_data = gpr_rd_data_1;	//从寄存器堆读取
			end
	end
	

/********************************load冒险检测****************************************/
always @ (*) 
	begin
		if ((id_en == `ENABLE) && ((id_mem_op == `MEM_OP_LDW) || (id_mem_op == `MEM_OP_LDB) ||(id_mem_op == `MEM_OP_LDH)) &&
			((id_dst_addr == rs1) || (id_dst_addr == rs2)))
			begin
				ld_hazard = `ENABLE;		//Load冒险
			end
		else
			begin
				ld_hazard = `DISABLE;		//冒险未发生
			end
	end


/********************************解码指令*********************************************/
always @ (*)
	begin
		/*****默认值*****/
		alu_op	 	= `ALU_OP_NOP;
		alu_in_0 	= ra_data;
		alu_in_1 	= rb_data;
		br_taken 	= `DISABLE;
		br_flag	 	= `DISABLE;
		br_addr  	= {`WORD_ADDR_W{1'b0}};
		mem_op	 	= `MEM_OP_NOP;
		ctrl_op  	= `CTRL_OP_NOP;
		dst_addr 	= rs2;
		gpr_we_  	= `DISABLE_;
		exp_code 	= `ISA_EXP_NO_EXP;
		mem_wr_data =  32'b0;
		
		if (if_en == `ENABLE)
			begin
				case(opcode)
					/*****高位立即数加载*****/
					`LUI:						//将s_imm_u存入rd
						begin
							alu_in_1 = s_imm_u;
							dst_addr = rd;	
							gpr_we_	 = `ENABLE_;
						end
					/*****跳转地址转换*****/
					`AUIPC:
						begin
							alu_op   = `ALU_OP_ADDU;
							alu_in_0 = if_pc;
							alu_in_1 = s_imm_u;
							gpr_we_	 = `ENABLE_;
						end
					/*****无条件跳转*****/
					`JAL:						//无条件跳转，相对路径跳转
						begin
							alu_op	 = `ALU_OP_STORE; 
							alu_in_1 <= #1 if_pc + 3'h4;			//跳转指令后面的指令 pc = pc+4
							br_addr	 = if_pc + s_imm_j;
							br_taken = `ENABLE;
							br_flag	 = `ENABLE;
							dst_addr = rd;
						end
					`JALR:						//无条件跳转，绝对路径跳转
						begin
							alu_op	 = `ALU_OP_STORE;
							alu_in_1 <= #1 if_pc + 3'h4;			//跳转指令后面的指令 pc = pc+4
//							br_addr	 = (ra_data + s_imm_i)&(~32'h0001);
							br_addr	 = ra_data + s_imm_i;
							br_taken = `ENABLE;
							br_flag	 = `ENABLE;
							dst_addr = rd;
						end
					/*****条件跳转*****/
					`BRANCH:
						begin
							case(funct3)
								`FUN3_BEQ:							//比较计算 (rs1 == rs2)
									begin
										br_addr  = br_target;
										br_taken = (ra_data == rb_data) ? `ENABLE : `DISABLE;
										br_flag	 = `ENABLE;
									end
								`FUN3_BNE:							//比较计算 (rs1 != rs2)
									begin
										br_addr	 = br_target;
										br_taken = (ra_data != rb_data) ? `ENABLE : `DISABLE;
										br_flag	 = `ENABLE;
									end
								`FUN3_BLT:							//有符号比较(rs1 < rs2)
									begin
										br_addr	 = br_target;
										br_taken = (s_ra_data < s_rb_data) ? `ENABLE : `DISABLE;
										br_flag	 = `ENABLE;
									end
								`FUN3_BGE:							//有符号比较(rs1 >= rs2)
									begin
										br_addr	 = br_target;
										br_taken = (s_ra_data >= s_rb_data) ? `ENABLE : `DISABLE;
										br_flag	 = `ENABLE;
									end
								`FUN3_BLTU:							//无符号比较(rs1 < rs2)
									begin
										br_addr	 = br_target;
										br_taken = (ra_data < rb_data) ? `ENABLE : `DISABLE;
										br_flag	 = `ENABLE;
									end
								`FUN3_BGEU:							//无符号比较(rs1 >= rs2)
									begin
										br_addr	 = br_target;
										br_taken = (ra_data >= rb_data) ? `ENABLE : `DISABLE;
										br_flag	 = `ENABLE;
									end	
								default:
									begin
										exp_code = `ISA_EXP_UNDEF_INSN;	//异常状态：使用未定义的指令
									end
							endcase
						end
					/*****内存访问指令*****/
					//-----内存读取------
					`LOAD:
						begin
							case(funct3)
								`FUN3_LB:							//有符号字节加载
									begin
										alu_op	 = `ALU_OP_ADDU;
										alu_in_1 = s_imm_i;
										dst_addr = rd;
										mem_op	 = `MEM_OP_LDB;
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_LH:							//有符号半字加载
									begin
										alu_op	 = `ALU_OP_ADDU;
										alu_in_1 = s_imm_i;
										dst_addr = rd;
										mem_op	 = `MEM_OP_LDH;
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_LW:							//字加载
									begin
										alu_op   = `ALU_OP_ADDU;
										alu_in_1 = s_imm_i;
										dst_addr = rd;
										mem_op	 = `MEM_OP_LDW;
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_LBU:							//无符号字节加载
									begin
										alu_op	 = `ALU_OP_ADDU;
										alu_in_1 = u_imm_i;//alu_in_1 = s_imm_i;
										dst_addr = rd;
										mem_op	 = `MEM_OP_LBU;
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_LHU:							//无符号半字加载
									begin
										alu_op	 = `ALU_OP_ADDU;
										alu_in_1 = u_imm_i;//alu_in_1 = s_imm_i;
										dst_addr = rd;
										mem_op	 = `MEM_OP_LHU;
										gpr_we_	 = `ENABLE_;
									end
								default:
									begin
										exp_code = `ISA_EXP_UNDEF_INSN;	//异常状态：使用未定义的指令
									end
							endcase
						end
					//-----内存写入-----
					`STORE:
						begin
							case(funct3)
								`FUN3_SB:							//写入8位数---字节
									begin
										alu_op	 = `ALU_OP_ADDU;
										alu_in_1 = s_imm_s;
										mem_op	 = `MEM_OP_STB;
										mem_wr_data	  = rb_data;     //（修改）
									end
								`FUN3_SH:							//写入16位数--半字
									begin
										alu_op	 = `ALU_OP_ADDU;
										alu_in_1 = s_imm_s;
										mem_op	 = `MEM_OP_STH;
										mem_wr_data	  = rb_data;    //（修改）
									end
								`FUN3_SW:							//写入32位数--字
									begin
										alu_op	 = `ALU_OP_ADDU;
										alu_in_1 = s_imm_s;
										mem_op	 = `MEM_OP_STW;
										mem_wr_data	  = rb_data;    //（修改）
									end
								default:
									begin
										exp_code = `ISA_EXP_UNDEF_INSN;	//异常状态：使用未定义的指令
									end
							endcase
						end
					/*****寄存器与立即数间的基本运算*****/
					`OP_IMM:
						begin
							case(funct3) 
								`FUN3_ADDI:							//寄存器与立即数的有符号加法
									begin
										alu_op	 = `ALU_OP_ADDS;
										alu_in_1 = s_imm_i;
										dst_addr = rd;
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_SLTI:							//寄存器rs1与立即数的有符号比较(<)
									begin
										alu_op	 = `ALU_OP_STORE;
										alu_in_1 = (s_ra_data < s_imm_i) ? `ENABLE : `DISABLE;
										dst_addr = rd;
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_SLTIU:						//寄存器rs1与立即数的无符号比较(<)
									begin
										alu_op	 = `ALU_OP_STORE;
										alu_in_1 = (ra_data < s_imm_i) ? `ENABLE : `DISABLE;
										dst_addr = rd;
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_XORI:							//寄存器与立即数的逻辑异或
									begin
										alu_op	 = `ALU_OP_XOR;
										alu_in_1 = s_imm_i;
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_ORI:							//寄存器与立即数间逻辑或
									begin
										alu_op	 = `ALU_OP_OR;
										alu_in_1 = s_imm_i;
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_ANDI:							//寄存器与立即数间逻辑与
									begin
										alu_op	 = `ALU_OP_AND;
										alu_in_1 = s_imm_i;
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_SLLI:							//寄存器与立即数间左移
									begin
										alu_op	 = `ALU_OP_SHLL;
										alu_in_1 = {{26{1'b0}},shamt};	//---imm_i[5]!=0时无效
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_SRI:							//寄存器与立即数间右移
									begin
										case(funct6)
											`FUN6_RL:				//逻辑右移
												begin
													alu_op	 = `ALU_OP_SHRL;
													dst_addr = rd;
													alu_in_1 = {{26{1'b0}},shamt};	//---imm_i[5]!=0时无效
													gpr_we_	 = `ENABLE_;
												end
											`FUN6_RA:				//算术右移
												begin
													alu_op	 = `ALU_OP_SHRLA;
													dst_addr = rd;
													alu_in_1 = {{26{1'b0}},shamt};	//---imm_i[5]!=0时无效
													gpr_we_	 = `ENABLE_;
												end
											default:
												begin
													exp_code = `ISA_EXP_UNDEF_INSN;	//异常状态：使用未定义的指令
												end
										endcase
									end
								default:
									begin
										exp_code = `ISA_EXP_UNDEF_INSN;	//异常状态：使用未定义的指令
									end
							endcase
						end
					/*****寄存器间的基本运算*****/
					`OP:
						begin
							case(funct3)
								`FUN3_CALCULATE:
									begin
										case(funct7)
											`FUN7_ADD:				//寄存器间加法指令
												begin
													alu_op	 = `ALU_OP_ADDS;
													dst_addr = rd;
													gpr_we_	 = `ENABLE_;
												end
											`FUN7_SUB:				//寄存器间减法指令
												begin
													alu_op	 = `ALU_OP_SUBS;
													dst_addr = rd;
													gpr_we_	 = `ENABLE_;
												end
											default:
												begin
													exp_code = `ISA_EXP_UNDEF_INSN;	//异常状态：使用未定义的指令
												end
										endcase
									end
								`FUN3_SLL:							//寄存器间逻辑左移
									begin
										alu_op	 = `ALU_OP_SHLL;
										dst_addr = rd;
										gpr_we_	 = `ENABLE_;
									end	
								`FUN3_SLT:							//寄存器间有符号之间的比较(<)
									begin
										alu_op	 = `ALU_OP_STORE;
										alu_in_1 = (s_ra_data < s_rb_data) ? `ENABLE : `DISABLE;
										dst_addr = rd;
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_SLTU:							//寄存器间无符号之间的比较(<)
									begin
										alu_op	 = `ALU_OP_STORE;
										alu_in_1 = (ra_data < rb_data) ? `ENABLE : `DISABLE;
										dst_addr = rd;
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_XOR:							//寄存器间异或
									begin
										alu_op	 = `ALU_OP_XOR;
										dst_addr = rd;
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_SR:							//寄存器间右移
									begin
										case(funct6)
											`FUN6_RL:				//逻辑右移
												begin
													alu_op	 = `ALU_OP_SHRL;
													dst_addr = rd;
													gpr_we_	 = `ENABLE_;
												end
											`FUN6_RA:				//算术右移
												begin
													alu_op	 = `ALU_OP_SHRLA;
													dst_addr = rd;
													gpr_we_	 = `ENABLE_;
												end
											default:
												begin
													exp_code = `ISA_EXP_UNDEF_INSN;	//异常状态：使用未定义的指令
												end
										endcase
									end									
								`FUN3_OR:							//寄存器间逻辑或
									begin
										alu_op	 = `ALU_OP_OR;
										dst_addr = rd;
										gpr_we_	 = `ENABLE_;
									end
								`FUN3_AND:							//寄存器间逻辑与
									begin
										alu_op	 = `ALU_OP_AND;
										dst_addr = rd;
										gpr_we_	 = `ENABLE_;
									end
								default:
									begin
										exp_code = `ISA_EXP_UNDEF_INSN;	//异常状态：使用未定义的指令
									end
							endcase
						end
					/*****存储器模型*****/
					`MISC_MEM:
						begin
							case(funct3)
								`FUN3_FENCE:						//同步内存和IO
									begin
										
									end
								`FUN3_FENCE_I:						//同步指令和数据流
									begin
										
									end
								default: 
									begin
										exp_code = `ISA_EXP_UNDEF_INSN;	//异常状态：使用未定义的指令
									end
							endcase
						end
					/*****系统指令*****/
					`SYSTEM:
						begin
							case(funct3)
								/*****环境调用和断点*****/
								`FUN3_PRIV:								//debug调试
									begin
										case(funct12)
											`FUN12_ECALL:				//环境调用
												begin
													
												end
											`FUN12_EBREAK:				//环境断点
												begin
													exp_code = `ISA_EXP_EXT_INT;	//-------
												end
											default: 
												begin
													exp_code = `ISA_EXP_UNDEF_INSN;	//异常状态：使用未定义的指令
												end
										endcase
									end
								/*****控制和状态寄存器指令*****/
								`FUN3_CSRRW:							//读后写
									begin
										if (exe_mode == `CPU_KERNEL_MODE)
											begin
												
												
											end
										else
											begin
												exp_code = `ISA_EXP_PRV_VIO;	//非内核模式下执行为违反权限
											end
									end
								`FUN3_CSRRS:							//读后置位
									begin
										if (exe_mode == `CPU_KERNEL_MODE)
											begin
												
												
											end
										else
											begin
												exp_code = `ISA_EXP_PRV_VIO;	//非内核模式下执行为违反权限
											end
									end
								`FUN3_CSRRC:							//读后清除
									begin
										if (exe_mode == `CPU_KERNEL_MODE)
											begin
												
												
											end
										else
											begin
												exp_code = `ISA_EXP_PRV_VIO;	//非内核模式下执行为违反权限
											end
									end
								`FUN3_CSRRWI:							//立即数读后写
									begin
										if (exe_mode == `CPU_KERNEL_MODE)
											begin
												
												
											end
										else
											begin
												exp_code = `ISA_EXP_PRV_VIO;	//非内核模式下执行为违反权限
											end
									end
								`FUN3_CSRRSI:							//立即数读后置位
									begin
										if (exe_mode == `CPU_KERNEL_MODE)
											begin
												
												
											end
										else
											begin
												exp_code = `ISA_EXP_PRV_VIO;	//非内核模式下执行为违反权限
											end
									end
								`FUN3_CSRRCI:							//立即数读后清除
									begin
										if (exe_mode == `CPU_KERNEL_MODE)
											begin
												
												
											end
										else
											begin
												exp_code = `ISA_EXP_PRV_VIO;	//非内核模式下执行为违反权限
											end
									end	
								default:
									begin
										exp_code = `ISA_EXP_UNDEF_INSN;	//异常状态：使用未定义的指令
									end
							endcase
						end
					/*****其他指令*****/
					default:
						begin						//未定义指令
							exp_code = `ISA_EXP_UNDEF_INSN;			//异常状态：使用未定义的指令
						end
						
				endcase
			end
	end


endmodule



