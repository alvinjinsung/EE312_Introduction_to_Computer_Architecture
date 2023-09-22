module CACHE (
	input wire CLK,
	input wire RSTn,
	input wire [31:0] MEM_Inst,
	input wire [11:0] CACHE_ADDR_IN,
	input wire [31:0] CACHE_MEM_RD2,
	input wire [127:0] DMEM_CACHE_data,
	input wire MEM_isBubble,
	output reg [9:0] CACHE_ADDR_OUT,
	output reg [31:0] CACHE_DOUT,
	output reg [127:0] CACHE_DMEM_data,
	output reg CACHE_DMEM_WEN,
	output reg CACHE_stall,
	output reg CACHE_csn
	);

	reg [135:0] CACHE_struct[0:7];
	wire [6:0] tag;
	wire [2:0] index;
	wire [1:0] offset;
	wire [135:0] CACHE_line;
	wire [31:0] data_out;
	wire HIT_check;

	reg [3:0] cycle_count;
	reg [1:0] CACHE_mode;


	initial begin
		CACHE_struct[0] <= 0;
		CACHE_struct[1] <= 0;
		CACHE_struct[2] <= 0;
		CACHE_struct[3] <= 0;
		CACHE_struct[4] <= 0;
		CACHE_struct[5] <= 0;
		CACHE_struct[6] <= 0;
		CACHE_struct[7] <= 0;

		cycle_count <= 0;
		CACHE_stall <= 0;
		CACHE_mode <= 0;
		CACHE_DMEM_WEN <= 1;
	end

	// assign tag, index, and offset
	assign tag = CACHE_ADDR_IN[11:5];
	assign index = CACHE_ADDR_IN[4:2];
	assign offset = CACHE_ADDR_IN[1:0];

	assign CACHE_line = CACHE_struct[index];
	assign HIT_check = ((CACHE_line[135] == 1) && (CACHE_line[134:128] == tag));

	// data corresponding to address in the cache
	assign data_out = (offset == 2'b00) ? CACHE_line[127:96] : (offset == 2'b01) ? CACHE_line[95:64] : (offset == 2'b10) ? CACHE_line[63:32] : CACHE_line[31:0];

	
	assign CACHE_ADDR_OUT = CACHE_ADDR_IN[11:2];
	assign CACHE_DMEM_data = CACHE_line[127:0];


	always @(negedge CLK) begin
		if (RSTn && (MEM_isBubble == 0) && ((MEM_Inst[6:0] == 7'b0000011) || (MEM_Inst[6:0] == 7'b0100011))) begin
			// latency guarantee
			if (cycle_count > 0) begin
				cycle_count <= cycle_count - 1;
				CACHE_csn <= 1;
			end

			else if ((CACHE_mode == 2'b00) && (cycle_count == 0)) begin
				// load
				if (MEM_Inst[6:0] == 7'b0000011) begin
					// read-hit
					if (HIT_check == 1) begin
						CACHE_DOUT <= data_out;
						CACHE_stall <= 0;
						CACHE_DMEM_WEN <= 1;
					end

					// read-miss
					else begin
						CACHE_mode <= 2'b01;
						cycle_count <= 4'b1000;
						CACHE_stall <= 1;
						CACHE_DMEM_WEN <= 1;
						CACHE_csn <= 0;
					end
				end

				// write
				else if (MEM_Inst[6:0] == 7'b0100011) begin
					// write-hit
					if (HIT_check == 1) begin
						if (offset == 2'b00) begin
							CACHE_struct[index][135] <= CACHE_line[135];
							CACHE_struct[index][134:128] <= CACHE_line[134:128];
							CACHE_struct[index][127:0] <= {CACHE_MEM_RD2, CACHE_line[95:0]};
						end

						else if (offset == 2'b01) begin
							CACHE_struct[index][135] <= CACHE_line[135];
							CACHE_struct[index][134:128] <= CACHE_line[134:128];
							CACHE_struct[index][127:0] <= {CACHE_line[127:96], CACHE_MEM_RD2, CACHE_line[63:0]};
						end

						else if (offset == 2'b10) begin
							CACHE_struct[index][135] <= CACHE_line[135];
							CACHE_struct[index][134:128] <= CACHE_line[134:128];
							CACHE_struct[index][127:0] <= {CACHE_line[127:64], CACHE_MEM_RD2, CACHE_line[31:0]};
						end

						else if (offset == 2'b11) begin
							CACHE_struct[index][135] <= CACHE_line[135];
							CACHE_struct[index][134:128] <= CACHE_line[134:128];
							CACHE_struct[index][127:0] <= {CACHE_line[127:32], CACHE_MEM_RD2};
						end

						CACHE_mode <= 2'b10;
						cycle_count <= 4'b0111;
						CACHE_stall <= 1;
						CACHE_DMEM_WEN <= 0;
						CACHE_csn <= 0;
					end

					// write-miss
					else begin
						CACHE_mode <= 2'b11;
						cycle_count <= 4'b1000;
						CACHE_stall <= 1;
						CACHE_DMEM_WEN <= 1;
						CACHE_csn <= 0;
					end
				end
			end

			// read-miss case handling
			else if ((CACHE_mode == 2'b01) && (cycle_count == 0)) begin
				CACHE_struct[index][135] <= 1;
				CACHE_struct[index][134:128]  <= tag;
				CACHE_struct[index][127:0] <= DMEM_CACHE_data;

				if (offset == 2'b00) begin
					CACHE_DOUT <= DMEM_CACHE_data[127:96];
				end

				else if (offset == 2'b01) begin
					CACHE_DOUT <= DMEM_CACHE_data[95:64];
				end

				else if (offset == 2'b10) begin
					CACHE_DOUT <= DMEM_CACHE_data[63:32];
				end

				else if (offset == 2'b11) begin
					CACHE_DOUT <= DMEM_CACHE_data[31:0];
				end

				CACHE_mode <= 2'b00;
				CACHE_stall <= 0;
			end

			// write-hit case handling
			else if ((CACHE_mode == 2'b10) && (cycle_count == 0)) begin
				CACHE_mode <= 2'b00;
				CACHE_stall <= 0;
				CACHE_DMEM_WEN <= 1;
			end

			// write-miss case handling
			else if ((CACHE_mode == 2'b11) && (cycle_count == 0)) begin
				if (offset == 2'b00) begin
					CACHE_struct[index][135] <= 1;
					CACHE_struct[index][134:128]  <= tag;
					CACHE_struct[index][127:0] <= {CACHE_MEM_RD2, CACHE_line[95:0]};
				end

				else if (offset == 2'b01) begin
					CACHE_struct[index][135] <= 1;
					CACHE_struct[index][134:128]  <= tag;
					CACHE_struct[index][127:0] <= {CACHE_line[127:96], CACHE_MEM_RD2, CACHE_line[63:0]};
				end

				else if (offset == 2'b10) begin
					CACHE_struct[index][135] <= 1;
					CACHE_struct[index][134:128]  <= tag;
					CACHE_struct[index][127:0] <= {CACHE_line[127:64], CACHE_MEM_RD2, CACHE_line[31:0]};
				end

				else if (offset == 2'b11) begin
					CACHE_struct[index][135] <= 1;
					CACHE_struct[index][134:128]  <= tag;
					CACHE_struct[index][127:0] <= {CACHE_line[127:32], CACHE_MEM_RD2};
				end

				CACHE_mode <= 2'b10;
				cycle_count <= 4'b0111;
				CACHE_DMEM_WEN <= 0;
				CACHE_csn <= 0;
			end
		end

		else begin
			CACHE_stall <= 0;
			CACHE_DMEM_WEN <= 1;
			CACHE_mode <= 0;
			cycle_count <= 0;
			CACHE_csn <= 1;
		end
	end

endmodule


