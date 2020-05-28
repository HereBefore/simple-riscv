`timescale 1ns / 1ps
/********** 共享头文件 **********/
`include "head/nettype.v"
`include "head/global_config.v"
`include "head/stddef.v"

/********** 特别头文件 **********/
`include "head/cpu_head.v"
`include "head/bus_head.v"


/*********************************总线接口*************************************/
module AHB_if(	input	wire			clk,
				input	wire			reset,
	/************************流水线控制信号************************/
				input	wire			stall,		//延迟信号
				input	wire			flush,		//刷新信号
				output	reg				busy,		//总线忙信号
	/************************CPU接口*******************************/
				input	wire	[31:0]	addr,		//地址
				input	wire			as_,		//地址有效
				input	wire			rw,			//读写
				input	wire	[31:0]	wr_data,	//写入的数据
				output	reg		[31:0]	rd_data,	//读取的数据
	/************************SPM接口*******************************/
				input	wire	[31:0]	spm_rd_data,//读取的数据
				output	wire	[31:0]	spm_addr,	//地址
				output	reg				spm_as_,	//地址选通
				output	wire			spm_rw,		//读/写
				output	wire	[31:0]	spm_wr_data,//写入的数据
	/************************总线接口******************************/
				input	wire	[31:0]	bus_rd_data,//读取的数据
				input	wire			bus_rdy_,	//就绪
				input	wire			bus_grnt_,	//许可
				output	reg				bus_req_,	//请求
				output	reg		[31:0]	bus_addr,	//地址
				output	reg				bus_as_,	//地址选通
				output	reg				bus_rw,		//读写
				output	reg		[31:0]	bus_wr_data	//写入的数据
				);


reg		[1:0]	state;		//总线接口状态
reg		[31:0]	rd_buf;		//读取缓冲
wire	[2:0]	s_index;	//总线从属引索


assign	s_index	 = addr[`BusSlaveIndexLoc];		//生成总线从属索引 [29:27]

/********************输出的赋值******************/
assign	spm_addr 	= addr;
assign	spm_rw	 	= rw;
assign	spm_wr_data = wr_data;

/*****************内存访问的控制*****************/
always @ (*)
	begin
		/*****默认值*****/
		rd_data	 = `WORD_DATA_W'h0;
		spm_as_	 = `DISABLE_;
		busy	 = `DISABLE;
		/*****总线接口的状态*****/
		case (state)
			`BUS_IF_STATE_IDLE:			//空闲状态
				begin
					/***内存访问***/
					if((flush == `DISABLE) && (as_ == `ENABLE_))
						begin
							/***选择访问的目标***/
							if (s_index == `BUS_SLAVE_1)	//访问SPM
								begin
									if (stall == `DISABLE)	//检测延迟的发生
										begin
											spm_as_ = `ENABLE_;
											if(rw == `READ)	//读取访问
												begin
													rd_data = spm_rd_data;
												end
										end
								end
							else
								begin
									busy = `ENABLE;		//访问总线
								end
						end
				end

			`BUS_IF_STATE_REQ:			//请求总线
				begin
					busy = `ENABLE;
				end
				
			`BUS_IF_STATE_ACCESS:		//访问总线
				begin
					/***等待就绪信号***/
					if (bus_rdy_ == `ENABLE_)				//就绪信号到达
						begin
							if (rw == `READ)				//读取访问
								begin
									rd_data = bus_rd_data;
								end
		//					busy = `ENABLE;          //（修改）
						end
					else									//就绪信号未到达
						begin
							busy = `ENABLE;
						end
				end

			`BUS_IF_STATE_STALL:		//延迟
				begin
					if(rw == `READ)							//读取访问
						begin
							rd_data = rd_buf;
						end
				end
				
		endcase
	end

/*****************总线接口的状态控制*****************/
always @(posedge clk or posedge reset)
	begin
		if (reset == `RESET_ENABLE)
			/***异步复位***/
			begin
				state		<= #1  `BUS_IF_STATE_IDLE;
				bus_req_	<= #1  `DISABLE_;
				bus_addr	<= #1  `WORD_DATA_W'h0;
				bus_as_		<= #1  `DISABLE_;
				bus_rw		<= #1  `READ;
				bus_wr_data <= #1  `WORD_DATA_W'h0;
				rd_buf		<= #1  `WORD_DATA_W'h0;
			end
		else
			/***总线接口状态***/
			begin
				case(state)
					`BUS_IF_STATE_IDLE:				//空闲状态
						/***内存访问***/
						begin
							if ((flush == `DISABLE) && (as_ == `ENABLE_))
								/***选择访问目标***/
								begin
									if (s_index != `BUS_SLAVE_1)	//访问总线
										begin
											state		<= #1  `BUS_IF_STATE_REQ;
											bus_req_	<= #1  `ENABLE_;
											bus_addr	<= #1  addr;
											bus_rw		<= #1  rw;
											bus_wr_data <= #1  wr_data;
										end
								end
						end
					
					`BUS_IF_STATE_REQ:				//请求总线
						/***等待总线许可***/
						begin
							if (bus_grnt_ == `ENABLE_)	//获得总线使用权
								begin
									state	<= #1  `BUS_IF_STATE_ACCESS;
									bus_as_	<= #1  `ENABLE_;
								end
						end

					`BUS_IF_STATE_ACCESS:			//访问总线
						/***地址选通无效化***/
						begin
							//bus_as_		<= #1  `DISABLE_;
							/***等待就绪信号***/
							if(bus_rdy_ == `ENABLE_)	//就绪信号到位，表示当前总线访问已结束
								begin
									bus_as_			<= #1  `DISABLE_;
									bus_req_		<= #1  `DISABLE_;
									bus_addr		<= #1  `WORD_DATA_W'h0;
									bus_rw			<= #1  `READ;
									bus_wr_data		<= #1  `WORD_DATA_W'h0;
									/***保存读取到的数据***/
									if(bus_rw == `READ)	//读取访问
										begin
											rd_buf	<= #1  bus_rd_data;
										end
									/***检测是否发生延迟***/
									if(stall == `ENABLE)	//发生延迟
										begin
											state	<= #1  `BUS_IF_STATE_STALL;
										end
									else
										begin				//未发生延迟
											state	<= #1  `BUS_IF_STATE_IDLE;
										end
								end
						end
					
					`BUS_IF_STATE_STALL:			//延迟
						begin
							/***检测是否发生延迟***/
							if(stall == `DISABLE)	//接触延迟
								begin
									state	<= #1  `BUS_IF_STATE_IDLE;
								end
						end
						
				endcase
			end
	end

				
endmodule







