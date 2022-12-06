//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "Cache_define.svh"

`ifndef CACHE_ARRAY
`define CACHE_ARRAY
`include "CPU/Cache/data_array_wrapper.sv"
`include "CPU/Cache/tag_array_wrapper.sv"
`endif

`define CPU_READ    1'b0
`define CPU_WRITE   1'b1

module L1C_inst(
	input clk,
	input rst,
	// Core to CPU wrapper
	input [`DATA_BITS-1:0] 			core_addr,
	input 							core_req,
	input							core_jb,
	// CPU wrapper to core
	output logic [`DATA_BITS-1:0] 	core_out,
	output logic 					core_wait,
	// Mem to CPU wrapper
	input [`DATA_BITS-1:0] 			I_out,
	input 							I_wait,
	// CPU wrapper to Mem
	output logic 					I_req,
	output logic [`DATA_BITS-1:0] 	I_addr
);

	logic [`CACHE_INDEX_BITS-1:0] 	index;
	logic [`CACHE_DATA_BITS-1:0] 	DA_out;
	logic [`CACHE_DATA_BITS-1:0] 	DA_in;
	logic [`CACHE_WRITE_BITS-1:0] 	DA_write;
	logic 							DA_read;
	logic [`CACHE_TAG_BITS-1:0] 	TA_out;
	logic [`CACHE_TAG_BITS-1:0] 	TA_in;
	logic 							TA_write;
	logic 							TA_read;
	logic [`CACHE_LINES-1:0] 		valid;

	logic valid_reg;
	logic tag_comp;
	logic hit;

	typedef enum logic[`CACHE_STATE_BITS-1:0] { 
		IDLE, READ, READ_MISS, READ_WAIT, READ_BURST, READ_END, DEFAULT
	} FSM;
	FSM state, nstate;

	logic [1:0] burst_counter;
	logic branch_during_send;

	logic [`DATA_BITS-1:0] I_addr_reg;

  //--------------- complete this part by yourself -----------------//
  
	data_array_wrapper DA(
		.A(index),
		.DO(DA_out),
		.DI(DA_in),
		.CK(clk),
		.WEB(DA_write),
		.OE(DA_read),
		.CS(1'b1)
	);
	
	tag_array_wrapper  TA(
		.A(index),
		.DO(TA_out),
		.DI(TA_in),
		.CK(clk),
		.WEB(~TA_write),
		.OE(TA_read),
		.CS(1'b1)
	);

	always_comb begin
		case(state)
			IDLE, READ : begin
				index = core_addr[9:4];
			end
			READ_END : begin
				//index = (branch_during_send)? core_addr[9:4] : I_addr_reg[9:4];
				index = core_addr[9:4];
				// core_addr : check whether hit or not
				// I_addr_reg : write to tag and valid array
			end
			default : index = I_addr_reg[9:4];
		endcase
	end

	//assign index = core_addr[9:4];
	assign tag_comp = (TA_out == core_addr[31:10])? 1'b1 : 1'b0;

	// valid bit registers
	// Since there is a cycle delay in tag
	always_ff @(posedge clk) begin
		valid_reg <= valid[index];
	end

	//assign hit = valid_reg & tag_comp;
	always_comb begin
		case(state)
			READ : begin
				if(!core_jb) 
					hit = valid_reg & tag_comp; // if not branch
				else
					hit = 1'b0;
			end
			default : hit = 1'b0;
		endcase
	end


	// counter for read burst
	always_ff @(posedge clk) begin
		//since there will be a cycle delay
		if(rst) burst_counter <= 2'b00;
		else begin
			case(state)
				READ_WAIT, READ_BURST : begin
					if(~I_wait) burst_counter <= burst_counter+1;
					else ;
				end
				default : burst_counter <= 2'b00;
			endcase
		end
	end

	always_comb begin
		if( (state == READ_END) && (core_addr[31:4]!= I_addr_reg[31:4]) ) begin
			branch_during_send = 1'b1;
		end
		else begin
			branch_during_send = 1'b0;
		end
	end

	// controller FSM
	// next state logic
	always_comb begin
		case(state)
			// read FSM
			IDLE : begin
				nstate = (core_req)? READ : IDLE;
			end

			READ : begin
				if(hit) begin
					nstate = IDLE;
				end
				else begin
					nstate = (core_jb)? READ : READ_MISS;
				end
			end

			READ_MISS : begin
				// nstate = (~I_wait)? READ_BURST : READ_MISS;
				nstate = READ_WAIT;
			end

			READ_WAIT : begin
				nstate = (~I_wait)? READ_BURST : READ_WAIT;
			end

			READ_BURST : begin
				if( (burst_counter == 2'd3) && (~I_wait)) begin
					nstate = READ_END;
				end
				else begin
					nstate = READ_BURST;
				end
			end

			READ_END : begin
				//nstate = IDLE;
				nstate = (branch_during_send)? READ : IDLE;
			end

			default : nstate = DEFAULT;
		endcase
	end

	// state transition
	always_ff @(posedge clk) begin
		if(rst) state <= IDLE;
		else 	state <= nstate;
	end

	// combinational output
	// core
	always_comb begin
		case(state)
			// stall CPU immediately
			IDLE : begin
				core_wait 	= (core_req)? 1'b1 : 1'b0;
				DA_read 	= 1'b0;
				core_out 	= 32'b0;
			end

			READ : begin	
				if(hit) begin 
					// hit, let DA output to CPU, drop stall
					core_wait 	= 1'b0;
					DA_read 	= 1'b1;
					case(core_addr[3:2])
						2'b00 : core_out = DA_out[31:0];
						2'b01 : core_out = DA_out[63:32];
						2'b10 : core_out = DA_out[95:64];
						2'b11 : core_out = DA_out[127:96];
					endcase
				end
				else begin
					//miss, keep stalling
					core_wait 	= 1'b1;
					DA_read		= 1'b0;
					core_out 	= 32'b0;
				end
			end

			READ_MISS, READ_WAIT, READ_BURST : begin
				core_wait 	= 1'b1;
				DA_read 	= 1'b0;
				core_out 	= 32'b0;
			end

			READ_END : begin
				// return data back to CPU	
				core_wait 	= (branch_during_send)? 1'b1 : 1'b0;
				DA_read 	= (branch_during_send)? 1'b0 : 1'b1;
				case(core_addr[3:2])
					2'b00 : core_out = DA_out[31:0];
					2'b01 : core_out = DA_out[63:32];
					2'b10 : core_out = DA_out[95:64];
					2'b11 : core_out = DA_out[127:96];
				endcase
			end

			default : begin
				core_wait 	= 1'b0;
				DA_read 	= 1'b0;
				core_out 	= 32'b0;
			end
		endcase
	end

	// I
	always_ff @(posedge clk) begin
		if(rst) I_addr_reg <= 32'b0;
		else begin
			case(state)
				IDLE : begin
					I_addr_reg <= 32'b0;
				end

				// READ_MISS : begin
				// 	I_addr_reg <= I_addr; 
				// end
				READ : begin
					I_addr_reg <= { core_addr[31:4], 4'b00 };
				end
				
				default : I_addr_reg <= I_addr_reg;
			endcase
		end
	end

	always_comb begin
		case(state)
			IDLE, READ : begin
				I_req	= 1'b0;
				I_addr  = 32'b0;
			end

			READ_MISS : begin
				I_req	= 1'b1;
				// I_addr	= { core_addr[31:4], 4'b00 };
				I_addr = I_addr_reg;
			end

			READ_WAIT, READ_BURST : begin
				I_req	= 1'b1;
				I_addr	= I_addr_reg;
			end

			// last data
			default : begin	
				// drop request
				I_req   = 1'b0;
				I_addr	= 32'b0;
			end
		endcase
	end

	//DA, write
	always_comb begin
		case(state)
			READ_WAIT : begin
				//first data
				if(~I_wait) begin
					DA_write = 16'hfff0;
					DA_in = { 96'b0, I_out };
				end
				else begin
					DA_write = 16'hffff;
					DA_in = 128'b0;
				end
			end

			READ_BURST : begin
				if(~I_wait) begin
					case(burst_counter)
						2'b01 : begin
							DA_write = 16'hff0f;
							DA_in = { 64'b0, I_out, 32'b0 };
						end
						2'b10 : begin
							DA_write = 16'hf0ff;
							DA_in = { 32'b0, I_out, 64'b0 };
						end
						2'b11 : begin
							DA_write = 16'h0fff;
							DA_in = { I_out, 96'b0 };
						end
						default : begin
							DA_write = 16'hffff;
							DA_in = 128'b0;
						end
					endcase
				end
				else begin
					DA_write = 16'hffff;
					DA_in = 128'b0;
				end
			end
			
			default : begin
				DA_write = 16'hffff;
				DA_in = 128'b0;
			end
		endcase
	end

	//TAG
	always_comb begin
		case(state)
			READ : begin
				TA_in 		= 22'b0;
				TA_write 	= 1'b0;
				TA_read 	= 1'b1;
			end
			READ_BURST : begin
				//update TAG
				TA_in 		= I_addr_reg[31:10];
				TA_write 	= 1'b1;
				TA_read 	= 1'b0;
			end 
			default : begin
				TA_in 		= 22'b0;
				TA_write 	= 1'b0;
				TA_read 	= 1'b0;
			end
		endcase
	end

	//update valid bits
	integer i;
	always_ff @(posedge clk) begin
		if(rst) begin
			for(i = 0; i < `CACHE_LINES ; i = i+1) begin
				valid[i] <= 1'b0;
			end
		end
		else begin
			if(state == READ_BURST) begin
				valid[index] <= 1'b1;
			end 
			else;
		end
	end

endmodule