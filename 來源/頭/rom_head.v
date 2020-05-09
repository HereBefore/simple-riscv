`ifndef __ROM_HEADER__
	`define __ROM_HEADER__
	

	`define	ROM_SIZE				65536	//ROM的大小	
	`define	ROM_DEPTH				2048	//ROM的深度	  d'2048 = b'1000_0000_0000
	`define	ROM_ADDR_w				11		//地址宽度
	`define	RomAddrBus				10:0	//地址总线
	`define	RomAddrLoc				10:0	//地址的位置
	
	
`endif