`ifndef __ISA_HEADER__
	`define __ISA_HEADER__
	
	/**************************指令基本属性********************************/
	`define	ISA_NOP				32'h0				//No Operation
	`define	ISA_OP_W			7					//操作码宽
	`define	IsaOpBus			6:0					//操作码总线
	`define	IsaOpLoc			6:0					//操作码位置
	`define	IsaFun3Bus			2:0					//3位额外操作码总线
	`define	IsaFun3Loc			14:12				//3位额外操作码位置
	`define	IsaFun6Bus			5:0					//6位额外操作码总线
	`define	IsaFun6Loc			31:26				//6位额外操作码位置
	`define	IsaFun7Bus			6:0					//7位额外操作码总线
	`define	IsaFun7Loc			31:25				//7位额外操作码位置	
	`define	IsaFun12Bus			11:0				//12位额外操作码总线
	`define	IsaFun12Loc			31:20				//12位额外操作码位置
	
	/**************************基本操作码**********************************/
	`define	LOAD				7'b0000011			//内存提取指令
	`define	LOAD_FP				7'b0000111			//单精度内存提取指令
	`define	CUSTOM_0			7'b0001011			//用户拓展指令操作0
	`define	MISC_MEM			7'b0001111			//存储器模型
	`define	OP_IMM				7'b0010011			//寄存器-立即数运算
	`define	AUIPC				7'b0010111			//跳转地址转换
	`define	OP_IMM_32			7'b0011011			//64位寄存器-立即数运算
	`define	STORE				7'b0100011			//内存存储指令
	`define	STORE_FP			7'b0100111			//单精度内存存储指令
	`define	CUSTOM_1			7'b0101011			//用户拓展指令操作1
	`define	AMO					7'b0101111			//原子性存储器操作
	`define	OP					7'b0110011			//寄存器-寄存器运算
	`define	LUI					7'b0110111			//高位立即数加载
	`define	OP_32				7'b0111011			//64位寄存器-寄存器-寄存器运算
	`define	MADD				7'b1000011			//乘加计算
	`define	MSUB				7'b1000111			//乘减计算
	`define	NMSUB				7'b1001011			//乘取反减
	`define	NMADD				7'b1001111			//乘取反加
	`define	OP_FP				7'b1010011			//单精度寄存器-寄存器-寄存器运算
	`define	RESERVED_0			7'b1010111			//保留指令操作码
	`define	CUSTOM_2			7'b1011011			//用户拓展指令操作2
	`define	BRANCH				7'b1100011			//B型有条件跳转
	`define	JALR				7'b1100111			//I型无条件跳转
	`define	RESERVED_1			7'b1100111			//保留指令操作码
	`define	JAL					7'b1101111			//J型无条件跳转
	`define	SYSTEM				7'b1110011			//系统指令
	`define	RESERVED_2			7'b1110111			//保留指令操作码
	`define	CUSTOM_3			7'b1111011			//用户拓展指令操作3
	
	/**************************运算指令*************************************/
	`define	FUN3_ADDI			3'b000				//立即数间加法指令
	`define	FUN3_SLL			3'b001				//寄存器间逻辑左移
	`define	FUN3_SLLI			3'b001				//寄存器与立即数间左移
	`define	FUN3_SLT			3'b010				//寄存器间有符号之间的比较(<)，结果响应于目标寄存器
	`define	FUN3_SLTI			3'b010				//寄存器与立即数间有符号之间的比较(<)，结果响应于目标寄存器
	`define	FUN3_SLTU			3'b011				//寄存器间无符号之间的比较(<)，结果相应于目标寄存器
	`define	FUN3_SLTIU			3'b011				//寄存器与立即数间无符号之间的比较(<)，结果相应于目标寄存器
	`define	FUN3_XOR			3'b100				//寄存器间异或
	`define	FUN3_XORI			3'b100				//寄存器与立即数间异或
	`define	FUN3_OR				3'b110				//寄存器间逻辑或
	`define	FUN3_ORI			3'b110				//寄存器与立即数间逻辑或
	`define	FUN3_AND			3'b111				//寄存器间逻辑与
	`define	FUN3_ANDI			3'b111				//寄存器与立即数间逻辑与
	//---------------右移指令-------------
	`define	FUN3_SR				3'b101				//寄存器间右移
	`define	FUN3_SRI			3'b101				//寄存器与立即数间右移
	`define	FUN6_RL				7'b000000			//逻辑右移
	`define	FUN6_RA				7'b010000			//算术右移
	
//	`define	FUN3_SRLI			3'b101				//寄存器与立即数间右移
//	`define FUN3_SRAI			3'b101				//寄存器与立即数间的算术右移
//	`define	FUN3_SRL			3'b101				//寄存器间逻辑右移
//	`define	FUN3_SRA			3'b101				//寄存器间的算术右移
	//---------------计算指令------------
	`define	FUN3_CALCULATE		3'b000				//加减计算
	`define	FUN7_ADD			7'b0000000			//加法计算
	`define	FUN7_SUB			7'b0100000			//减法计算
	
//	`define	FUN3_ADD			3'b000				//寄存器间加法指令
//	`define	FUN3_SUB			3'b000				//减法指令
	/**************************条件跳转***********************************/
	`define	FUN3_BEQ			3'b000				//比较计算(==)
	`define	FUN3_BNE			3'b001				//比较计算(!=)
	`define	FUN3_BLT			3'b100				//有符号比较(<)
	`define	FUN3_BGE			3'b101				//有符号比较(>=)
	`define	FUN3_BLTU			3'b110				//无符号比较(<)
	`define	FUN3_BGEU			3'b111				//无符号比较(>=)
	
	/**************************内存存取指令*******************************/
	`define	FUN3_LB				3'b000				//有符号字节加载
	`define	FUN3_LBU			3'b100				//无符号字节加载
	`define	FUN3_LH				3'b001				//有符号半字加载
	`define	FUN3_LHU			3'b101				//无符号字节加载***
	`define	FUN3_LW				3'b010				//字加载
	`define	FUN3_SB				3'b000				//存8位数---bit
	`define	FUN3_SH				3'b001				//存16位数--半字
	`define	FUN3_SW				3'b010				//存32位数--字
	
	/***************************存储同步指令*******************************/
	`define	FUN3_FENCE			3'b000				//同步内存和IO
	`define	FUN3_FENCE_I		3'b001				//同步指令和数据流
	
	/***************************环境调用和断点****************************/
//	`define	FUN3_ECALL			3'b000				//环境调用
//	`define	FUN3_EBREAK			3'b000				//环境断点
	`define	FUN3_PRIV			3'b000				//环境调用和断点
	`define	FUN12_ECALL			12'b000000000000	//环境调用
	`define	FUN12_EBREAK		12'b000000000001	//环境断点
	
	/***************************控制和状态寄存器指令*********************/
	`define	FUN3_CSRRW			3'b001				//读后写
	`define	FUN3_CSRRS			3'b010				//读后置位
	`define	FUN3_CSRRC			3'b011				//读后清除
	`define	FUN3_CSRRWI			3'b101				//立即数读后写
	`define	FUN3_CSRRSI			3'b110				//立即数读后置位
	`define	FUN3_CSRRCI			3'b111				//立即数读后清除
	
	/************************寄存器属性*********************************/
	`define	ISA_REG_ADDR_W			5			//寄存器地址宽
	`define	IsaRegAddrBus			4:0			//寄存器地址总线
	`define	IsaRs1AddrLoc			19:15		//寄存器rs1的位置
	`define	IsaRs2AddrLoc			24:20		//寄存器rs2的位置
	`define	IsaRdAddrLoc			11:7		//目标寄存器rd的位置
	`define	ShamtBus				5:0			//移位操作数总线
	`define	ShamtLoc				25:20		//移位操作数位置
	
	/************************立即数属性*********************************/
//	`define	ISA_IMM_W				16			//立即宽
//	`define	ISA_EXT_W				16			//符号扩展后的立即数宽
//	`define	ISA_IMM_MSB				15			//立即数最高位
//	`define	IsaImmBus				15:0		//立即数总线
//	`define	IsaImmLoc				15:0		//立即数位置
	
	/************************异常处理属性*******************************/
	`define	ISA_EXP_W				3			//异常代码宽
	`define	IsaExpBus				2:0			//异常代码总线
	`define	ISA_EXP_NO_EXP			3'h0		//无异常
	`define ISA_EXP_EXT_INT			3'h1		//外部中断
	`define	ISA_EXP_UNDEF_INSN		3'h2		//未定义指令
	`define	ISA_EXP_OVERFLOW		3'h3		//溢出
	`define	ISA_EXP_MISS_ALIGN		3'h4		//地址未对齐
	`define	ISA_EXP_TRAP			3'h5		//陷阱
	`define	ISA_EXP_PRV_VIO			3'h6		//违反权限
	
	
	

`endif





