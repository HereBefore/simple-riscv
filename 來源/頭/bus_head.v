`ifndef __BUS_HEADER__
	`define __BUS_HEADER__
	
	/*********************总线主控端属性*********************/
	`define BUS_MASTER_CH		4		//总线主控通道数
	`define	BUS_MASTER_INDEX_w	2		//总线主控索引宽度
	`define	BusOwnerBus			1:0		//总线所有权状态总线
	
	`define	BUS_OWNER_MASTER_0	2'h0	//0号总线主控使用总线
	`define	BUS_OWNER_MASTER_1	2'h1	//1号总线主控使用总线
	`define	BUS_OWNER_MASTER_2	2'h2	//2号总线主控使用总线
	`define	BUS_OWNER_MASTER_3	2'h3	//3号总线主控使用总线
	
	/*********************总线从属端属性**********************/
	`define	BUS_SLAVE_CH		8		//总线从属通道数
	`define	BUS_SLAVE_INDEX_W	3		//总线从属引索宽度
	`define	BusSlaveIndexBus	2:0		//总线从属索引总线
	`define	BusSlaveIndexLoc	31:29	//总线从属索引的位置
	
	`define	BUS_SLAVE_0			0		//0号总线从属	--ROM
	`define	BUS_SLAVE_1			1		//1号总线从属	--SPM
	`define	BUS_SLAVE_2			2		//2号总线从属	--RAM
	`define BUS_SLAVE_3			3		//3号总线从属
	`define	BUS_SLAVE_4			4		//4号总线从属
	`define	BUS_SLAVE_5			5		//5号总线从属
	`define BUS_SLAVE_6			6		//6号总线从属
	`define	BUS_SLAVE_7			7		//7号总线从属
	
`endif