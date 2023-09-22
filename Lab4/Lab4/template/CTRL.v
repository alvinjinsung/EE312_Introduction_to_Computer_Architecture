module CTRL (
	input wire CLK,
	input wire RSTn,
	input wire [31:0] inst,
	output reg RF_WE,
	output reg ALU_MUX1,
	output reg [1:0] ALU_MUX2,
	output reg D_MEM_WEN,
	output reg [3:0] D_MEM_BE,
	output reg [1:0] WD_MUX,
	output reg J_MUX,
	output reg B_MUX,
	output reg PC_update
	);

	reg [2:0] state;
	reg [2:0] state_nxt;

	initial begin
		state_nxt <= 3'b000;
	end

	always @(posedge CLK) begin
		if (RSTn) begin
			state <= state_nxt;
		end
		else begin
			state <= 3'b000;
		end
	end

	always @(*) begin
		if (RSTn) begin
			// JAL
			if (inst[6:0] == 7'b1101111) begin 
				// IF
				if (state == 3'b000) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b00;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 0;
					B_MUX = 0;
					PC_update = 0;
					state_nxt = 3'b001;
				end

				// ID
				else if (state == 3'b001) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b00;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 0;
					B_MUX = 0;
					PC_update = 0;
					state_nxt = 3'b010;
				end

				// EX
				else if (state == 3'b010) begin
					RF_WE = 0;
					ALU_MUX1 = 1;
					ALU_MUX2 = 2'b10;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 1;
					B_MUX = 0;
					PC_update = 0;
					state_nxt = 3'b100;
				end

				// WB
				else if (state == 3'b100) begin
					RF_WE = 1;
					ALU_MUX1 = 1;
					ALU_MUX2 = 2'b10;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 1;
					B_MUX = 0;
					PC_update = 1;
					state_nxt = 3'b000;
				end
			end

			// JALR
			else if (inst[6:0] == 7'b1100111) begin
				// IF
				if (state == 3'b000) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b00;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 0;
					B_MUX = 0;
					PC_update = 0;
					state_nxt = 3'b001;
				end

				// ID
				else if (state == 3'b001) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b00;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 0;
					B_MUX = 0;
					PC_update = 0;
					state_nxt = 3'b010;
				end

				// EX
				else if (state == 3'b010) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b10;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 1;
					B_MUX = 0;
					PC_update = 0;
					state_nxt = 3'b100;
				end

				// WB
				else if (state == 3'b100) begin
					RF_WE = 1;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b10;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 1;
					B_MUX = 0;
					PC_update = 1;
					state_nxt = 3'b000;
				end
			end

			// Btype
			else if (inst[6:0] == 7'b1100011) begin
				// IF
				if (state == 3'b000) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b00;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 0;
					B_MUX = 0;
					PC_update = 0;
					state_nxt = 3'b001;
				end

				// ID
				else if (state == 3'b001) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b00;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 0;
					B_MUX = 0;
					PC_update = 0;
					state_nxt = 3'b010;
				end

				// EX
				else if (state == 3'b010) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b00;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 0;
					B_MUX = 1;
					PC_update = 1;
					state_nxt = 3'b000;
				end
			end

			// Itype load
			else if (inst[6:0] == 7'b0000011) begin
				// LW
				if (inst[14:12] == 3'b010) begin
					// IF
					if (state == 3'b000) begin
						RF_WE = 0;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b00;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b0000;
						WD_MUX = 2'b00;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 0;
						state_nxt = 3'b001;
					end

					// ID
					else if (state == 3'b001) begin
						RF_WE = 0;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b00;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b0000;
						WD_MUX = 2'b00;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 0;
						state_nxt = 3'b010;
					end

					// EX
					else if (state == 3'b010) begin
						RF_WE = 0;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b10;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b0000;
						WD_MUX = 2'b00;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 0;
						state_nxt = 3'b011;
					end

					// MEM
					else if (state == 3'b011) begin
						RF_WE = 0;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b10;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b1111;
						WD_MUX = 2'b00;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 0;
						state_nxt = 3'b100;
					end

					// WB
					else if (state == 3'b100) begin
						RF_WE = 1;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b10;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b1111;
						WD_MUX = 2'b01;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 1;
						state_nxt = 3'b000;
					end
				end
			end

			// Stype
			else if (inst[6:0] == 7'b0100011) begin
				// SW
				if (inst[14:12] == 3'b010) begin
					// IF 
					if (state == 3'b000) begin
						RF_WE = 0;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b00;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b0000;
						WD_MUX = 2'b00;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 0;
						state_nxt = 3'b001;
					end

					// ID
					else if (state == 3'b001) begin
						RF_WE = 0;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b00;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b0000;
						WD_MUX = 2'b00;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 0;
						state_nxt = 3'b010;
					end

					// EX
					else if (state == 3'b010) begin
						RF_WE = 0;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b10;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b0000;
						WD_MUX = 2'b00;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 0;
						state_nxt = 3'b011;
					end

					// MEM
					else if (state == 3'b011) begin
						RF_WE = 0;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b10;
						D_MEM_WEN = 0;
						D_MEM_BE = 4'b1111;
						WD_MUX = 2'b00;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 1;
						state_nxt = 3'b000;
					end
				end
			end

			// Rtype
			else if (inst[6:0] == 7'b0110011) begin
				// IF
				if (state == 3'b000) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b00;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 0;
					B_MUX = 0;
					PC_update = 0;
					state_nxt = 3'b001;
				end

				// ID
				else if (state == 3'b001) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b00;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 0;
					B_MUX = 0;
					PC_update = 0;
					state_nxt = 3'b010;
				end

				// EX
				else if (state == 3'b010) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b00;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 0;
					B_MUX = 0;
					PC_update = 0;
					state_nxt = 3'b100;
				end

				// WB
				else if (state == 3'b100) begin
					RF_WE = 1;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b00;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b10;
					J_MUX = 0;
					B_MUX = 0;
					PC_update = 1;
					state_nxt = 3'b000;
				end
			end

			// Itype
			else if (inst[6:0] == 7'b0010011) begin
				// IF
				if (state == 3'b000) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b00;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 0;
					B_MUX = 0;
					PC_update = 0;
					state_nxt = 3'b001;
				end

				// ID
				else if (state == 3'b001) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b00;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 0;
					B_MUX = 0;
					PC_update = 0;
					state_nxt = 3'b010;
				end

				// EX
				else if (state == 3'b010) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b10;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b00;
					J_MUX = 0;
					B_MUX = 0;
					PC_update = 0;
					state_nxt = 3'b100;
				end

				// WB
				else if (state == 3'b100) begin
					RF_WE = 1;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b10;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b0000;
					WD_MUX = 2'b10;
					J_MUX = 0;
					B_MUX = 0;
					PC_update = 1;
					state_nxt = 3'b000;
				end
			end

			// Custom
			else if (inst[6:0] == 7'b0001011) begin
				// MULT, MODULO
				if (inst[14:12] == 3'b111) begin
					// IF
					if (state == 3'b000) begin
						RF_WE = 0;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b00;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b0000;
						WD_MUX = 2'b00;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 0;
						state_nxt = 3'b001;
					end

					// ID
					else if (state == 3'b001) begin
						RF_WE = 0;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b00;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b0000;
						WD_MUX = 2'b00;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 0;
						state_nxt = 3'b010;
					end

					// EX
					else if (state == 3'b010) begin
						RF_WE = 0;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b00;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b0000;
						WD_MUX = 2'b00;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 0;
						state_nxt = 3'b100;
					end

					// WB
					else if (state == 3'b100) begin
						RF_WE = 1;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b00;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b0000;
						WD_MUX = 2'b10;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 1;
						state_nxt = 3'b000;
					end
				end

				// IS_EVEN
				else if (inst[14:12] == 3'b110) begin
					// IF
					if (state == 3'b000) begin
						RF_WE = 0;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b00;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b0000;
						WD_MUX = 2'b00;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 0;
						state_nxt = 3'b001;
					end

					// ID
					else if (state == 3'b001) begin
						RF_WE = 0;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b00;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b0000;
						WD_MUX = 2'b00;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 0;
						state_nxt = 3'b010;
					end

					// EX
					else if (state == 3'b010) begin
						RF_WE = 0;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b01;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b0000;
						WD_MUX = 2'b00;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 0;
						state_nxt = 3'b100;
					end

					// WB
					else if (state == 3'b100) begin
						RF_WE = 1;
						ALU_MUX1 = 0;
						ALU_MUX2 = 2'b01;
						D_MEM_WEN = 1;
						D_MEM_BE = 4'b0000;
						WD_MUX = 2'b10;
						J_MUX = 0;
						B_MUX = 0;
						PC_update = 1;
						state_nxt = 3'b000;
					end

				end
			end
		end
	end
endmodule

	
