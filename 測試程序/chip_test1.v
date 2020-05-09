`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/26 19:36:13
// Design Name: 
// Module Name: chip_test1
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


module chip_test1;

/*
reg	[8*10:1]	mnemonic;
integer			start;
wire	[5:0]	op;*/
//input
reg				clk;
reg				reset;
//output
/*
wire	[31:0]	if_insn;
wire			m0_req_;
wire	[31:0]	m0_addr;
wire			m0_as_;
wire			m0_rw;
wire	[31:0]	m0_wr_data;
wire			m0_grnt_;
wire	[31:0]	m_rd_data;
wire			m_rdy_;
wire	[2:0]	mem_exp_code;
wire	[31:0]	mem_out;
wire	[31:0]	ex_out;
wire			mem_gpr_we_;
wire	[4:0]	mem_dst_addr;
wire	[31:0]	gpr_rd_data_0;
wire	[31:0]	gpr_rd_data_1;
wire	[4:0]	gpr_rd_addr_0;
wire	[4:0]	gpr_rd_addr_1;
wire			s_as_;
wire			s0_cs_;
wire			s0_rdy_;
wire	[31:0]	s0_rd_data;
*/
//实例化chip
/*chip chip(.clk(clk),.reset(reset),.if_insn(if_insn),.m0_req_(m0_req_),.m0_addr(m0_addr),
		.m0_as_(m0_as_),.m0_rw(m0_rw),.m0_wr_data(m0_wr_data),.m0_grnt_(m0_grnt_),
		.m_rd_data(m_rd_data),.m_rdy_(m_rdy_),.mem_exp_code(mem_exp_code),
		.ex_out(ex_out),.mem_out(mem_out),.mem_gpr_we_(mem_gpr_we_),.mem_dst_addr(mem_dst_addr),
		.gpr_rd_addr_0(gpr_rd_addr_0),.gpr_rd_addr_1(gpr_rd_addr_1),.gpr_rd_data_0(gpr_rd_data_0),
		.gpr_rd_data_1(gpr_rd_data_1),.s_as_(s_as_),
		.s0_cs_(s0_cs_),.s0_rdy_(s0_rdy_),.s0_rd_data(s0_rd_data)
		);*/
		
chip chip(.clk(clk),.reset(reset));


//assign	op = if_insn[31:26];

always #1 clk = ~clk; 


initial
	begin
		clk = 0; 
		reset = 0;
//		start = 0;
		
		$readmemb ("E:/project/Modelsim_project/risc_v/rom_test1_pro.pro",chip.AHB2ROM.memory);
		$display("rom_test1_pro.pro loaded successfully!");
		
		#10 $readmemb ("E:/project/Modelsim_project/risc_v/ram.pro",chip.AHB2RAM.memory);
		$display("ram.pro loaded successfully!");
		
		#20 reset = 1;
		#2	reset = 0;
		
		#1 $readmemb ("E:/project/Modelsim_project/risc_v/test1.dat",chip.CPU.gpr.gpr);
		$display("test1.dat loaded successfully!");
		
//		#1 start = 1;
	end
/*
always @ (if_insn)
	begin
		case(op)
			6'b000011:
				mnemonic = "ORI";
			6'b000010:
				mnemonic = "ORR";
			6'b000100:
				mnemonic = "XORR";
			6'b001111:
				mnemonic = "SHLLI";
			6'b001011:
				mnemonic = "SUBUR";
			6'b010000:
				mnemonic = "BE";
			6'b011000:
				mnemonic = "TRAP";
			default:
				mnemonic = "stall_code";
		endcase
	end


always @ (start)
	begin
		$display("\n********************Runing CPU_test1-----Basic CPU Diagnostic Program***********************");
		$display("\t\t\t	TIME\t\t	PC\t\t	INSTR");
		$display("---------------------------------------------------------------------------------------");
		while(mem_exp_code == 0)
			begin
				wait(m0_addr != 0);
				$strobe("%t ps\t	%h	%s",$time,m0_addr,mnemonic);
				wait(m0_addr == 0);
			end
	end
*/


endmodule






