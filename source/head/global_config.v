`ifndef __GLOBAL_CONFIG__HEADER__
	`define __GLOBAL_CONFIG__HEADER__
	
/**********************************************************************
****对整体文档的信号极性进行宏定义
***********************************************************************/

	/******************复位信号极性选择******************/
//	`define POSITIVE_RESET	posedge
//	`define	NEGATIVE_RESET	negedge
	
	/******************内存控制信号极性的选择************/
//	`define POSITIVE_MEMORY	posedge
//	`define	NEGATIVE_MEMORY	negedge
	
	/******************I/O的选择*************************/
//	`define	IMPLEMENT_TIMER	NaN		//需要实现计时器时定义
//	`define IMPLEMENT_UART	NaN		//需要实现UART时定义
//	`define	IMPLEMENT_GPIO	NaN		//需要实现通用I/O口时定义
	
	/******************复位信号边沿*********************/
//	`define	RESET_EDGE		posedge	//定义POSITIVE_RESET时
//	`define	RESET_EDGE		negedge	//定义NEGATIVE_RESET时

	/******************复位有效*************************/
	`define	RESET_ENABLE	1'b1	//定义POSITIVE_RESET时
//	`define	RESET_ENABLE	1'b0	//定义NEGATIVE_RESET时

	/******************复位无效*************************/
	`define	RESET_DISABLE	1'b0	//定义POSITIVE_RESET时
//	`define	RESET_DISABLE	1'b1	//定义NEGATIVE_RESET时

	/******************内存有效*************************/
	`define	MEM_ENABLE		1'b1	//定义POSITIVE_MEMORY时
//	`define	MEM_ENABLE		1'b0	//定义NEGATIVE_MEMORY时
	
	/******************内存无效*************************/
	`define	MEM_DISABLE		1'b0	//定义POSITIVE_MEMORY时
//	`define	MEM_DISABLE		1'b1	//定义NEGATIVE_MEMORY时


`endif