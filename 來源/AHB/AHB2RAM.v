////////////////////////////////////////////////////////////////////////////////
// AHB-Lite Memory Module
////////////////////////////////////////////////////////////////////////////////

/********** 共享头文件 **********/
`include "head/nettype.v"
`include "head/stddef.v"
`include "head/global_config.v"

/********** 特别头文件 **********/
`include "head/rom_head.v"


module AHB2RAM
   #(parameter MEMWIDTH = 15)               // Size = 32KB (1kb = 8192bit)
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

//   assign HREADYOUT = 1'b1; // Always ready
//	 assign HREADYOUT = ~(HSEL & HREADY);			//片选与地址选通使能时就绪

   // Memory Array
   reg  [31:0] memory[0:(2**(MEMWIDTH-2)-1)];

   // Registers to store Adress Phase Signals
   reg  [31:0] hwdata_mask;
   reg         we_write;
   reg		   we_read;
   reg  [31:0] buf_hwaddr;

   // Sample the Address Phase   
   always @(posedge HCLK or posedge HRESETn)
   begin
      if(HRESETn == 1)
      begin
         we_write <= 1'b0;
		 we_read  <= 1'b0;
         buf_hwaddr <= 32'h0;
      end
      else
         if(HREADY)
         begin
            we_write <= HSEL & HWRITE & HTRANS[1];
			we_read  <= HSEL & (~HWRITE) & HTRANS[1];
            buf_hwaddr <= HADDR;
   
            casez (HSIZE[1:0])
               2'b1?: hwdata_mask <=  32'hFFFFFFFF;                        // Word write
               2'b01: hwdata_mask <= (32'h0000FFFF << (16 * HADDR[1]));    // Halfword write
               2'b00: hwdata_mask <= (32'h000000FF << (8 * HADDR[1:0]));   // Byte write
            endcase
         end
   end
   
   // Read and Write Memory
   always @ (posedge HCLK)
   begin
      if(we_write)
		begin
			 memory[buf_hwaddr[MEMWIDTH:2]] <= (HWDATA & hwdata_mask) | (HRDATA & ~hwdata_mask);
			 we_write <= 1'b0;
		end
   end
   
   always @ (posedge HCLK)
   begin
      if(we_read)
		begin
			 HRDATA = memory[HADDR[MEMWIDTH:2]];
			 we_read <= 1'b0;
		end
   end
   
   
  always @(posedge HCLK)
	begin
		if(HWRITE == 1'b0)
			begin
				HREADYOUT <= ~(HSEL & we_read);
			end
		else
			begin
				HREADYOUT <= ~(HSEL & we_write);
			end
	end

endmodule