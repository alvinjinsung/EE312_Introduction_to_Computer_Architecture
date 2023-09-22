module DATA_HAZARD (
	input wire [31:0] EX_Inst, // Instruction between ID/EX Stage
	input wire [31:0] ID_Inst,
	input [4:0] RF_RA1, // rs1 in ID Stage
	input [4:0] RF_RA2, // rs2 in ID stage
	input wire [4:0] EX_WA,
	output reg data_hazard_check
	);

	always @(*) begin
		if (EX_Inst[6:0] == 7'b0000011) begin
			if (ID_Inst[6:0] == 7'b1101111) begin // if instruction in IF/ID is JAL
				data_hazard_check = 0; // No data hazard
			end

			else if (ID_Inst[6:0] == 7'b1100111) begin // if instruction in IF/ID is JALR
				if (EX_WA == RF_RA1) begin
					data_hazard_check = 1;
				end
				else begin
					data_hazard_check = 0;
				end
			end

			else if (ID_Inst[6:0] == 7'b1100011) begin // if instruction in IF/ID is B-type
				if ((EX_WA == RF_RA1) || (EX_WA == RF_RA2)) begin
					data_hazard_check = 1;
				end
				else begin
					data_hazard_check = 0;
				end
			end

			else if (ID_Inst[6:0] == 7'b0000011) begin // if instruction in IF/ID is LW
				if (EX_WA == RF_RA1) begin
					data_hazard_check = 1;
				end
				else begin
					data_hazard_check = 0;
				end
			end

			else if (ID_Inst[6:0] == 7'b0100011) begin // if instruction in IF/ID is SW
				if ((EX_WA == RF_RA1) || (EX_WA == RF_RA2)) begin
					data_hazard_check = 1;
				end
				else begin
					data_hazard_check= 0;
				end
			end

			else if (ID_Inst[6:0] == 7'b0010011) begin // if instruction in IF/ID is I-type
				if (EX_WA == RF_RA1) begin
					data_hazard_check = 1;
				end
				else begin
					data_hazard_check = 0;
				end
			end

			else if (ID_Inst[6:0] == 7'b0110011) begin // if instruction in IF/ID is R-type
				if ((EX_WA == RF_RA1) || (EX_WA == RF_RA2)) begin
					data_hazard_check = 1;
				end
				else begin
					data_hazard_check = 0;
				end
			end

			else if (ID_Inst[6:0] == 7'b0001011) begin // if instruction in IF/ID is Custom
				if ((EX_WA == RF_RA1) || (EX_WA == RF_RA2)) begin
					data_hazard_check = 1;
				end
				else begin
					data_hazard_check = 0;
				end
			end

			else begin
				data_hazard_check = 0;
			end
		end

		else begin
			data_hazard_check = 0;
		end
	end

endmodule

	
