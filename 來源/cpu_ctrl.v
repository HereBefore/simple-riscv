`timescale 1ns / 1ps
/********** 共享头文件 **********/
`include "head/nettype.v"
`include "head/global_config.v"
`include "head/stddef.v"

/********** 特定头文件 **********/
`include "head/isa_head.v"
`include "head/cpu_head.v"
`include "head/rom_head.v"
`include "head/spm_head.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/19 09:08:13
// Design Name: 
// Module Name: cpu_ctrl
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

/*************************************CPU控制模块*******************************************/
module cpu_ctrl(input	wire			clk,
				input	wire			reset,
	/***********************控制寄存器接口************************/
				input	wire	[4:0]	creg_rd_addr,		//读取地址
				output	reg		[31:0]	creg_rd_data,		//读取数据
				output	reg				exe_mode,			//执行模式
	/***********************中断**********************************/
				input	wire	[7:0]	irq,				//中断请求
				output	reg				int_detect,			//中断检测
	/***********************ID/EX流水线寄存器**********************/
				input	wire	[31:0]	id_pc,				//ID阶段的程序计数器
	/***********************MEM/WB流水线寄存器*********************/
				input	wire	[31:0]	mem_pc,				//MEM阶段的程序计数器
				input	wire			mem_en,				//流水线数据是否有效
				input	wire			mem_br_flag,		//分支标志位
				input	wire	[1:0]	mem_ctrl_op,		//控制寄存器操作
				input	wire	[4:0]	mem_dst_addr,		//通用寄存器写入地址
				input	wire			mem_gpr_we_,		//通用寄存器写入有效
				input	wire	[2:0]	mem_exp_code,		//异常代码
				input	wire	[31:0]	mem_out,			//处理结果
	/***********************流水线的状态***************************/
				input	wire	 		if_busy,			//IF阶段忙信号
				input	wire			ld_hazard,			//Load冒险
				input	wire			mem_busy,			//MEM阶段忙信号
	/***********************延迟信号*******************************/
				output	wire			if_stall,			//IF阶段延迟
				output	wire			id_stall,			//ID阶段延迟
				output	wire			ex_stall,			//EX阶段延迟
				output	wire			mem_stall,			//MEM阶段延迟
	/***********************刷新信号*******************************/
				output	wire			if_flush,			//IF阶段刷新
				output	wire			id_flush,			//ID阶段刷新
				output	wire			ex_flush,			//EX阶段刷新
				output	wire			mem_flush,			//MEM阶段刷新
				output	reg		[31:0]	new_pc				//新程序计数器
				);
				
/*************************控制寄存器*****************************/
reg				int_en;			//0号控制寄存器：中断有效
reg				pre_exe_mode;	//1号控制寄存器：执行模式
reg				pre_int_en;		//1号控制寄存器：终端有效
reg		[31:0]	epc;			//3号控制寄存器：异常程序计数器
reg		[31:0]	exp_vector;		//4号控制寄存器：异常向量
reg		[2:0]	exp_code;		//5号控制寄存器：异常代码
reg				dly_flag;		//6号控制寄存器：延迟间隙标志位
reg		[7:0]	mask;			//7号控制寄存器：中断屏蔽
reg		[31:0]	pre_pc;			//前一个程序计数器
reg				br_flag;		//分支标志位


/*************************流水线控制信号***************************/
//延迟信号赋值
wire	stall	  = if_busy | mem_busy;
assign	if_stall  = stall | ld_hazard;
assign	id_stall  = stall;
assign	ex_stall  = stall;
assign	mem_stall = stall;
//刷新信号赋值
reg		flush;
assign	if_flush  = flush;
assign	id_flush  = flush | ld_hazard;
assign	ex_flush  = flush;
assign	mem_flush = flush;

/*************************流水线刷新控制****************************/
always @ (*) 
	begin
		/*****默认值*****/
		new_pc = `WORD_ADDR_W'h0;
		flush  = `DISABLE;
		/*****流水线刷新*****/
		if (mem_en == `ENABLE)			//流水线数据有效
			begin
				if (mem_exp_code != `ISA_EXP_NO_EXP)	//发生异常
					begin
						new_pc = exp_vector;
						flush  = `ENABLE;
					end
				else if (mem_ctrl_op == `CTRL_OP_EXRT)	//EXRT指令
					begin
						new_pc = epc;
						flush = `ENABLE;
					end
				else if (mem_ctrl_op == `CTRL_OP_WRCR)	//WRCR指令
					begin
						new_pc = mem_pc;
						flush  = `ENABLE;
					end
			end
	end

/**************************中断检测************************************/
always @ (*)
	begin
		if ((int_en == `ENABLE) && ((|((~mask) & irq)) == `ENABLE))
			begin
				int_detect = `ENABLE;
			end
		else
			begin
				int_detect = `DISABLE;
			end
	end

/**************************读取访问************************************/
//将控制寄存器得输出规范化
always @ (*)
	begin
		case (creg_rd_addr)								//读取控制寄存器
			`CREG_ADDR_STATUS:			//0号：状态
				begin
					creg_rd_data = {{`WORD_DATA_W-2{1'b0}},int_en,exe_mode};
				end
			`CREG_ADDR_PRE_STATUS:		//1号：异常发生前的状态
				begin
					creg_rd_data = {{`WORD_DATA_W-2{1'b0}},pre_int_en,pre_exe_mode};
				end
			`CREG_ADDR_PC:				//2号：程序计数器
				begin
					creg_rd_data = {id_pc,`BYTE_OFFSET_W'h0};
				end
			`CREG_ADDR_EPC:				//3号：异常程序计数器
				begin
					creg_rd_data = {epc,`BYTE_OFFSET_W'h0};
				end
			`CREG_ADDR_EXP_VECTOR:		//4号：异常向量
				begin
					creg_rd_data = {exp_vector,`BYTE_OFFSET_W'h0};
				end
			`CREG_ADDR_CAUSE:			//5号：异常原因
				begin
					creg_rd_data = {{`WORD_DATA_W-1-`ISA_EXP_W{1'b0}},dly_flag,exp_code};
				end	
			`CREG_ADDR_INT_MASK:		//6号：中断屏蔽
				begin
					creg_rd_data = {{`WORD_DATA_W-`CPU_IRQ_CH{1'b0}},mask};
				end
			`CREG_ADDR_IRQ:				//7号：中断原因
				begin
					creg_rd_data = {{`WORD_DATA_W-`CPU_IRQ_CH{1'b0}},irq};
				end
			`CREG_ADDR_ROM_SIZE:		//29号：ROM容量
				begin
					creg_rd_data = $unsigned(`ROM_SIZE);
				end
			`CREG_ADDR_SPM_SIZE:		//30号：SPM容量
				begin
					creg_rd_data = $unsigned(`SPM_SIZE);
				end	
			`CREG_ADDR_CPU_INFO:		//31号：CPU信息
				begin
					creg_rd_data = {`RELEASE_YEAR,`RELEASE_MONTH,`RELEASE_VERSION,`RELEASE_REVISION};
				end
			default:
				begin
					creg_rd_data = `WORD_DATA_W'h0;
				end
		endcase
	end
	
/**************************CPU的控制************************************/
always @ (posedge clk or posedge reset)
	begin
		if (reset == 1)
			/*****异步复位*****/
			begin
				exe_mode	 <= #1  `CPU_KERNEL_MODE;
				int_en		 <= #1  `DISABLE;
				pre_exe_mode <= #1  `CPU_KERNEL_MODE;
				pre_int_en	 <= #1  `DISABLE;
				exp_code	 <= #1  `ISA_EXP_NO_EXP;
				mask		 <= #1  {`CPU_IRQ_CH{`ENABLE}};
				dly_flag	 <= #1  `DISABLE;
				epc			 <= #1  `WORD_ADDR_W'h0;
				exp_vector	 <= #1  `WORD_ADDR_W'h0;
				pre_pc		 <= #1  `WORD_ADDR_W'h0;
				br_flag		 <= #1  `DISABLE;
			end
		else
			/*****更新CPU状态*****/
			begin
				if ((mem_en == `ENABLE) && (stall == `DISABLE))
					begin
						/*****PC和分支标志位的保存*****/
						pre_pc	<= #1  mem_pc;
						br_flag	<= #1  mem_br_flag;
						/*****CPU状态控制*****/
						if (mem_exp_code != `ISA_EXP_NO_EXP)		//发生异常
							begin
								exe_mode	 <= #1  `CPU_KERNEL_MODE;
								int_en		 <= #1  `DISABLE;
								pre_exe_mode <= #1  exe_mode;
								pre_int_en	 <= #1  int_en;
								exp_code	 <= #1  mem_exp_code;
								dly_flag	 <= #1  br_flag;
								epc			 <= #1  pre_pc;
							end
						else if (mem_ctrl_op == `CTRL_OP_EXRT)		//EXRT命令
							begin
								/*****读取控制寄存器，用以恢复*****/
								exe_mode	 <= #1  pre_exe_mode;
								int_en		 <= #1  pre_int_en;	
							end
						else if (mem_ctrl_op == `CTRL_OP_WRCR)		//WRCR命令
							begin
								/*****写入控制寄存器*****/
								case (mem_dst_addr)
									`CREG_ADDR_STATUS:				//0：状态
										begin
											exe_mode	 <=  #1 mem_out[`CregExeModeLoc];
											int_en		 <=  #1 mem_out[`CregIntEnableLoc];
										end
									`CREG_ADDR_PRE_STATUS:			//1：异常发生前的状态
										begin
											pre_exe_mode <= #1  mem_out[`CregExeModeLoc];
											pre_int_en	 <= #1  mem_out[`CregIntEnableLoc];
										end
									`CREG_ADDR_EPC:					//3：异常程序计数器
										begin
											epc			 <= #1  mem_out[`WordAddrLoc];
										end
									`CREG_ADDR_EXP_VECTOR:			//4：异常向量
										begin
											exp_vector	 <= #1  mem_out[`WordAddrLoc];
										end
									`CREG_ADDR_CAUSE:				//5：异常原因
										begin
											dly_flag	 <= #1  mem_out[`CregDlyFlagLoc];
											exp_code	 <= #1  mem_out[`CregExpCodeLoc];
										end
									`CREG_ADDR_INT_MASK:			//6：中断屏蔽
										begin
											mask		 <= #1  mem_out[`CPU_IRQ_CH-1:0];
										end
								endcase
							end
					end
			end
	end



endmodule






