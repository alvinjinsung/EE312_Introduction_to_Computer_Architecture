module CTRL (
	input wire RSTn,
	input wire [31:0] inst,
	output reg RF_WE,
	output reg ALU_MUX1,
	output reg [1:0] ALU_MUX2,
	output reg D_MEM_WEN,
	output reg [3:0] D_MEM_BE,
	output reg [1:0] WD_MUX,
	output reg J_MUX,
	output reg B_MUX
	);

	always @(*) begin
		if (RSTn) begin
			// JAL
			if (inst[6:0] == 7'b1101111) begin 
				RF_WE = 1;
				ALU_MUX1 = 1;
				ALU_MUX2 = 2'b10;
				D_MEM_WEN = 1;
				//D_MEM_BE = *;
				WD_MUX = 2'b00;
				J_MUX = 1;
				B_MUX = 0;
			end

			// JALR
			else if (inst[6:0] == 7'b1100111) begin
				RF_WE = 1;
				ALU_MUX1 = 0;
				ALU_MUX2 = 2'b10;
				D_MEM_WEN = 1;
				//D_MEM_BE = *;
				WD_MUX = 2'b00;
				J_MUX = 1;
				B_MUX = 0;
			end

				// Btype
			else if (inst[6:0] == 7'b1100011) begin
				RF_WE = 0;
				ALU_MUX1 = 0;
				ALU_MUX2 = 2'b00;
				D_MEM_WEN = 1;
				//D_MEM_BE = *;
				WD_MUX = 2'b10;
				J_MUX = 0;
				B_MUX = 1;
			end

			// Itype load
			else if (inst[6:0] == 7'b0000011) begin
				// LW
				if (inst[14:12] == 3'b010) begin
					RF_WE = 1;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b10;
					D_MEM_WEN = 1;
					D_MEM_BE = 4'b1111;
					WD_MUX = 2'b01;
					J_MUX = 0;
					B_MUX = 0;
				end
			end

			// Stype
			else if (inst[6:0] == 7'b0100011) begin
				// SW
				if (inst[14:12] == 3'b010) begin
					RF_WE = 0;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b10;
					D_MEM_WEN = 0;
					D_MEM_BE = 4'b1111;
					WD_MUX = 2'b10;
					J_MUX = 0;
					B_MUX = 0;
				end
			end

			// Rtype
			else if (inst[6:0] == 7'b0110011) begin
				RF_WE = 1;
				ALU_MUX1 = 0;
				ALU_MUX2 = 2'b00;
				D_MEM_WEN = 1;
				//D_MEM_BE = *;
				WD_MUX = 2'b10;
				J_MUX = 0;
				B_MUX = 0;
			end

			// Itype
			else if (inst[6:0] == 7'b0010011) begin
				RF_WE = 1;
				ALU_MUX1 = 0;
				ALU_MUX2 = 2'b10;
				D_MEM_WEN = 1;
				//D_MEM_BE = *;
				WD_MUX = 2'b10;
				J_MUX = 0;
				B_MUX = 0;
			end

			// Custom
			else if (inst[6:0] == 7'b0001011) begin
				// MULT, MODULO
				if (inst[14:12] == 3'b111) begin
					RF_WE = 1;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b00;
					D_MEM_WEN = 1;
					//D_MEM_BE = *;
					WD_MUX = 2'b10;
					J_MUX = 0;
					B_MUX = 0;
				end

				// IS_EVEN
				else if (inst[14:12] == 3'b110) begin
					RF_WE = 1;
					ALU_MUX1 = 0;
					ALU_MUX2 = 2'b01;
					D_MEM_WEN = 1;
					//D_MEM_BE = *;
					WD_MUX = 2'b10;
					J_MUX = 0;
					B_MUX = 0;
				end
			end
		end
		
	end
endmodule

	
