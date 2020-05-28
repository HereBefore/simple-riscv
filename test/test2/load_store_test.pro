//test1用于检测cpu的load和store指令是否正确,x1寄存器的初始值为0x40000000
@00
	00000000000000000000000000010011	//00000013	//nop				延时指令
	00000000010000001010000110000011	//0040a183	//LW	x3 x1 imm	x3 = [x1+imm]   //imm =  0x00000004
	00000100001100001010000000100011	//0430a023	//SW	x3 x1 imm	x3 -> [x1+imm]   //imm = 0x00000040  最终地址：0x40000040
	00000000000000000000000000010011	//00000013	//nop				延时指令
	00000000000000000000000000010011	//00000013	//nop				延时指令
	00000000000000000000000000010011	//00000013	//nop				延时指令
	00000000100000001001001000000011    //00809203  //LH   x4  x1  imm   x4=[x1+imm]    //imm=0x00000008
	00000100010000001001001000100011    //04409223  //SH   x4  x1  imm   x4 -> [x1+imm] //imm = 0x00000044 最终地址：0x40000044
	00000000110000001101001010000011    //00c0d283  //LHU  x5  x1  imm   x5=[x1+imm]    //imm=0x0000000c
	00000001000000001000001100000011    //01008303  //LB   x6  x1  imm   x6=[x1+imm]    //imm=0x00000010
	00000100011000001000011000100011    //04608623  //SB   x6  x1  imm   x6 -> [x1+imm] //imm = 0x0000004c 最终地址：0x4000004c
	00000001010000001100001110000011    //0140c383  //LBU  x7  x1  imm   x6=[x1+imm]    //imm=0x00000014
	00000000000000000000000000010011	//00000013	//nop				延时指令
	00000000000000000000000000010011	//00000013	//nop				延时指令
	00000000000000000000000000010011	//00000013	//nop				延时指令
