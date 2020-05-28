`ifndef __SPM_HEADER__
	`define __SPM_HEADER__
	
	/**************************SPM的属性*****************************/
	`define	SPM_SIZE				16384		//SPM的容量
	`define	SPM_DEPTH				4096		//SPM的深度
	`define	SPM_ADDR_w				12			//地址宽度
	`define	SpmAddrBus				11:0		//地址总线
	`define	SpmAddrLoc				11:0		//地址的位置
	
`endif