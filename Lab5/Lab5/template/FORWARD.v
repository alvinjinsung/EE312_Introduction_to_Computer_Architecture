module FORWARD (
	input wire [4:0] EX_RA1,
	input wire [4:0] EX_RA2,
	input wire [4:0] MEM_WA,
	input wire [4:0] WB_WA, 
	input wire MEM_RF_WE, // RF_WE control signal in EX/MEM stage
	input wire WB_RF_WE, // RF_WE control signal in MEM/WB stage
	output reg[1:0] forward_A,
	output reg[1:0] forward_B
	);


	always @(*) begin // forward A signal
		if ((EX_RA1 != 0) && (EX_RA1 == MEM_WA)) begin // if RA1 id is identical to writeback register ID in EX/MEM stage
			if (MEM_RF_WE == 1) begin // if RF_WE control signal in EX/MEM is "1",
				forward_A = 2'b01;
			end
			else begin
				forward_A = 2'b00;
			end
		end
		
		else if ((EX_RA1 != 0) && (EX_RA1 == WB_WA)) begin // if RA1 id is identical to writeback register ID in MEM/WB stage
			if (WB_RF_WE == 1) begin // if RF_WE control signal in MEM/WB is "1"
				forward_A = 2'b10;
			end
			else begin
				forward_A = 2'b00;
			end
		end

		else begin
			forward_A = 2'b00;
		end
	end

	always @(*) begin // forward B signal
		if ((EX_RA2 != 0) && (EX_RA2 == MEM_WA)) begin // if RA2 id is identical to writeback register ID in EX/MEM stage
			if (MEM_RF_WE == 1) begin // if RF_WE control signal in EX/MEM is "1",
				forward_B = 2'b01;
			end
			else begin
				forward_B = 2'b00;
			end
		end
		
		else if ((EX_RA2 != 0) && (EX_RA2 == WB_WA)) begin // if RA2 id is identical to writeback register ID in MEM/WB stage
			if (WB_RF_WE == 1) begin // if RF_WE control signal in MEM/WB is "1"
				forward_B = 2'b10;
			end
			else begin
				forward_B = 2'b00;
			end
		end

		else begin
			forward_B = 2'b00;
		end
	end

endmodule
	
