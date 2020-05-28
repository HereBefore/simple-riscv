`ifndef __STDDEF_HEADER__
	`define __STDDEF_HEADER__
	
/**********************************************************
***对线路数据逻辑以及属性进行宏定义
***********************************************************/	

	/******************信号电平**************/
	`define	HIGH				1'b1
	`define	LOW					1'b0
	
	/******************逻辑单位**************/
	`define	DISABLE				1'b0	//无效（正逻辑）
	`define	ENABLE				1'b1	//有效（正逻辑）
	`define	DISABLE_			1'b1	//无效（负逻辑）
	`define	ENABLE_				1'b0	//有效（负逻辑）
	
	/******************读写操作**************/
	`define	READ				1'b0	//读取操作
	`define	WRITE				1'b1	//写入操作
	
	/******************数据属性**************/
	`define	LSB					0		//最低位
	`define	BYTE_DATA_W			8		//数据宽度（字节）
	`define	BYTE_MSB			7		//最高位（字节）
	`define	ByteDataBus			7:0		//数据总线（字节）
	`define	WORD_DATA_W			32		//数据宽度（字）
	`define	WORD_MSB			31		//最高位（字）
	`define	WordDataBus			31:0	//数据总线（字)
	`define	WORD_ADDR_W			32		//地址宽度
	`define	WORD_ADDR_MSB		31		//最高位
	`define	WordAddrBus			31:0	//地址总线
	`define	BYTE_OFFSET_W		2		//位移宽度
	`define	ByteOffsetBus		1:0		//位移总线
	`define	WordAddrLoc			31:2	//字地址位置
	`define	ByteOffsetLoc		1:0		//字节位移位置
	`define	BYTE_OFFSET_WORD	2'b00	//字边界
	`define	OFFSET_HALF_ONE		2'b00	//第一位半字
	`define	OFFSET_HALF_TWO		2'b10	//第二位半字
	`define	HalfDataLoc_one		15:0	//第一位半字数据地址
	`define	HalfDataLoc_two		31:16	//第二位半字数据地址
	`define	OFFSET_BYTE_ONE		2'b00	//第一位字节
	`define	OFFSET_BYTE_TWO		2'b01	//第二位字节
	`define	OFFSET_BYTE_THREE	2'b10	//第三位字节
	`define	OFFSET_BYTE_FOUR	2'b11	//第四位字节
	`define	ByteDataLoc_one		7:0		//第一位字节数据地址
	`define	ByteDataLoc_two		15:8	//第二位字节数据地址
	`define	ByteDataLoc_three	23:16	//第三位字节数据地址
	`define	ByteDataLoc_four	31:24	//第四位字节数据地址
	

`endif