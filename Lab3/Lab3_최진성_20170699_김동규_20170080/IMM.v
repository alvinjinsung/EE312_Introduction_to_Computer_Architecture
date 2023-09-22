module IMM (
	input wire [31:0] inst,
	output reg [31:0] imm_value
	);

	always @(*) begin
		// LUI
		if (inst[6:0] == 7'b0110111) begin
			imm_value[31:12] = inst[31:12];
			imm_value[11:0] = 12'b000000000000;
		end

		// AUIPC
		else if (inst[6:0] == 7'b0010111) begin
			imm_value[31:12] = inst[31:12];
			imm_value[11:0] = 12'b000000000000;
		end

		// JAL
		else if (inst[6:0] == 7'b1101111) begin
			imm_value[20] = inst[31];
			imm_value[19:12] = inst[19:12];
			imm_value[11] = inst[20];
			imm_value[10:1] = inst[30:21];
			imm_value[0] = 1'b0;

			//sign-extension
			if (imm_value[20] == 1'b1) begin
				imm_value[31:21] = 11'b11111111111;
			end
			else if (imm_value[20] == 1'b0) begin
				imm_value[31:21] = 11'b00000000000;
			end
		end

		// JALR
		else if (inst[6:0] == 7'b1100111) begin
			imm_value[11:0] = inst[31:20];

			//sign-extension
			if (imm_value[11] == 1'b1) begin
				imm_value[31:12] = 20'b11111111111111111111;
			end
			else if (imm_value[11] == 1'b0) begin
				imm_value[31:12] = 20'b00000000000000000000;
			end
		end

		//Btype 
		else if (inst[6:0] == 7'b1100011) begin
			imm_value[12] = inst[31];
			imm_value[11] = inst[7];
			imm_value[10:5] = inst[30:25];
			imm_value[4:1] = inst[11:8];
			imm_value[0] = 1'b0;

			//sign-extension
			if (imm_value[12] == 1'b1) begin
				imm_value[31:13] = 19'b1111111111111111111;
			end
			else if (imm_value[12] == 1'b0) begin
				imm_value[31:13] = 19'b0000000000000000000;
			end
		end

		//Itype - Load
		else if (inst[6:0] == 7'b0000011) begin
			imm_value[11:0] = inst[31:20];

			//sign-extension
			if (imm_value[11] == 1'b1) begin
				imm_value[31:12] = 20'b11111111111111111111;
			end
			else if (imm_value[11] == 1'b0) begin
				imm_value[31:12] = 20'b00000000000000000000;
			end
		end

		//Stype - Store
		else if (inst[6:0] == 7'b0100011) begin
			imm_value[11:5] = inst[31:25];
			imm_value[4:0] = inst[11:7];

			//sign-extension
			if (inst[31] == 1'b1) begin
				imm_value[31:12] = 20'b11111111111111111111;
			end
			else if (inst[31] == 1'b0) begin
				imm_value[31:12] = 20'b00000000000000000000;
			end
		end

		//Itype - Arithmetic
		else if (inst[6:0] == 7'b0010011) begin
			imm_value[11:0] = inst[31:20];

			//sign-extension
			if (inst[31] == 1'b1) begin
				imm_value[31:12] = 20'b11111111111111111111;
			end
			else if (inst[31] == 1'b0) begin
				imm_value[31:12] = 20'b00000000000000000000;
			end
		end

		else begin
			imm_value[31:0] = 0;
		end
	end

endmodule


