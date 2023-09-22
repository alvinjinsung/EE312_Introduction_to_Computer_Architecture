module ALU (
	input wire [31:0] inst,
	input wire signed [31:0] operand1,
	input wire signed [31:0] operand2,
	output reg signed [31:0] ALUresult
	);

	always @(*) begin
		// JAL
		if (inst[6:0] == 7'b1101111) begin
			ALUresult = operand1 + operand2;
		end

		// JALR
		else if (inst[6:0] == 7'b1100111) begin
			ALUresult = (operand1 + operand2) & (32'hfffffffe);
		end

		// Btype
		else if (inst[6:0] == 7'b1100011) begin
			// BEQ
			if (inst[14:12] == 3'b000) begin
				ALUresult = (operand1 == operand2) ? 1:0;
			end

			// BNE
			else if (inst[14:12] == 3'b001) begin
				ALUresult = (operand1 != operand2) ? 1:0;
			end

			// BLT
			else if (inst[14:12] == 3'b100) begin
				ALUresult = (operand1 < operand2) ? 1:0;
			end

			// BGE
			else if (inst[14:12] == 3'b101) begin
				ALUresult = (operand1 >= operand2) ? 1:0;
			end

			// BLTU
			else if (inst[14:12] == 3'b110) begin
				ALUresult = ($unsigned(operand1) < $unsigned(operand2)) ? 1:0;
			end

			// BGEU
			else if (inst[14:12] == 3'b111) begin
				ALUresult = ($unsigned(operand1) >= $unsigned(operand2)) ? 1:0;
			end
		end

		// Itype load
		else if (inst[6:0] == 7'b0000011) begin
			ALUresult = operand1 + operand2;
		end

		// Stype
		else if (inst[6:0] == 7'b0100011) begin
			ALUresult = operand1 + operand2;
		end

		// Rtype
		else if (inst[6:0] == 7'b0110011) begin
			// ADD, SUB
			if (inst[14:12] == 3'b000) begin
				// ADD
				if (inst[31:25] == 7'b0000000) begin
					ALUresult = operand1 + operand2;
				end

				// SUB
				else if (inst[31:25] == 7'b0100000) begin
					ALUresult = operand1 - operand2;
				end
			end

			// SLL
			else if (inst[14:12] == 3'b001) begin
				ALUresult = operand1 << operand2[4:0];
			end

			// SLT
			else if (inst[14:12] == 3'b010) begin
				ALUresult = (operand1 < operand2) ? 1:0;
			end

			// SLTU
			else if (inst[14:12] == 3'b011) begin
				ALUresult = ($unsigned(operand1) < $unsigned(operand2)) ? 1:0;
			end

			// XOR
			else if (inst[14:12] == 3'b100) begin
				ALUresult = operand1 ^ operand2;
			end

			// SRL, SRA
			else if (inst[14:12] == 3'b101) begin
				//SRL
				if (inst[31:25] == 7'b0000000) begin
					ALUresult = operand1 >> (operand2[4:0]);
				end

				//SRA
				else if (inst[31:25] == 7'b0100000) begin
					ALUresult = operand1 >>> (operand2[4:0]);
				end
			end

			// OR
			else if (inst[14:12] == 3'b110) begin
				ALUresult = operand1 | operand2;
			end

			// AND
			else if (inst[14:12] == 3'b111) begin
				ALUresult = operand1 & operand2;
			end
		end

		// Itype
		else if (inst[6:0] == 7'b0010011) begin
			// ADDI
			if (inst[14:12] == 3'b000) begin
				ALUresult = operand1 + operand2;
			end

			// SLTI
			else if (inst[14:12] == 3'b010) begin
				ALUresult = (operand1 < operand2) ? 1:0;
			end

			else if (inst[14:12] == 3'b011) begin
				ALUresult = ($unsigned(operand1) < $unsigned(operand2)) ? 1:0;
			end

			// XORI
			else if (inst[14:12] == 3'b100) begin
				ALUresult = operand1 ^ operand2;
			end

			// ORI
			else if (inst[14:12] == 3'b110) begin
				ALUresult = operand1 | operand2;
			end

			// ANDI
			else if (inst[14:12] == 3'b111) begin
				ALUresult = operand1 & operand2;
			end

			// SLLI
			else if (inst[14:12] == 3'b001) begin
				ALUresult = operand1 << (operand2[4:0]);
			end

			// SRLI, SRAI
			else if (inst[14:12] == 3'b101) begin
				// SRLI
				if (inst[31:25] == 7'b0000000) begin
					ALUresult = operand1 >> (operand2[4:0]);
				end

				// SRAI
				else if (inst[31:25] == 7'b0100000) begin
					ALUresult = operand1 >>> (operand2[4:0]);
				end
			end
		end

		// Custom
		else if (inst[6:0] == 7'b0001011) begin
			// MULT, MODULO
			if (inst[14:12] == 3'b111) begin
				// MULT
				if (inst[31:25] == 7'b0000000) begin
					ALUresult = operand1 * operand2;
				end

				// MODULO
				else if (inst[31:25] == 7'b0000001) begin
					ALUresult = operand1 % operand2;
				end
			end

			// IS_EVEN
			else if (inst[14:12] == 3'b110) begin
				if ((operand1 % 2) == 0) begin
					ALUresult = 1;
				end

				else if ((operand1 % 2) == 1) begin
					ALUresult = 0;
				end
			end
		end

	end

endmodule


