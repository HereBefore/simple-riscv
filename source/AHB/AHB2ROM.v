////////////////////////////////////////////////////////////////////////////////
// AHB-Lite Memory Module
////////////////////////////////////////////////////////////////////////////////

/********** 共享头文件 **********/
`include "head/nettype.v"
`include "head/stddef.v"
`include "head/global_config.v"

/********** 特别头文件 **********/
`include "head/rom_head.v"


module AHB2ROM
	#(parameter MEMWIDTH = 13)               // Size = 8KB (1kb = 8192bit)
   (
   input wire           HSEL,				//slave片选信号
   input wire           HCLK,				//时钟
   input wire           HRESETn,			//复位
   input wire           HREADY,				//选通信号
   input wire    [31:0] HADDR,				//地址总线
   input wire     [1:0] HTRANS,				//当前传输类型：IDLE(00),BUSY(01),NONSEQ(10),SEQ(11)
   input wire           HWRITE,				//读写标志：1写；0读
   input wire     [2:0] HSIZE,				//当前传输大小：000(8bit),001(16bit),010(32bit),011(64bit)...
   input wire    [31:0] HWDATA,				//写数据总线
   output reg          HREADYOUT,			//传输结束标志
   output reg    [31:0] HRDATA				//读数据总线
   );
   
//the register HRDATA_reg is a constant and will be removed


//   assign HREADYOUT = 1'b1; // Always ready	
//   assign HREADYOUT = ~(HSEL & HREADY);			//片选与地址选通使能时就绪

   // Memory Array
   reg  [`WordDataBus] memory[0:(2**(MEMWIDTH-2)-1)];		//[0:(2^(MEMWIDTH-2)-1)]



   // Registers to store Adress Phase Signals
   reg		   we_read;
   reg		   we_buf;

   // Sample the Address Phase   
   always @(posedge HCLK or posedge HRESETn)
   begin
      if(HRESETn == 1)
      begin
		 we_read  <= 1'b0;
      end
      else
         if(HREADY)
         begin
			

			we_read <= HSEL & (~HWRITE) & HTRANS[1];
         end
   end
   
   // Read Memory   
   always @ (posedge HCLK or posedge HRESETn)
   begin
	  if (HRESETn == 1)
	  begin
		we_buf <= 1'b1;
	  end
      else 	begin
		  if(we_read)
			begin
				 HRDATA <= memory[HADDR[MEMWIDTH:2]];
				 if (we_buf == 1'b0)
					we_buf <= 1'b1;
				 else 
					we_buf <= 1'b0;
			end
	  end
   end
   
  always @(posedge HCLK)
	begin
		if(HWRITE == 1'b0)
			begin
				HREADYOUT <= ~(HSEL & we_read & we_buf);
			end
	end

endmodule
