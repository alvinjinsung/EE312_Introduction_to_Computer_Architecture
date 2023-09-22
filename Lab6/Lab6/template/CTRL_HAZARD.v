module CTRL_HAZARD (
	input wire [31:0] ID_PC,
	input wire [31:0] PC_target,
	input wire EX_isBubble,
	output reg ctrl_hazard_check
	);

	always @(*) begin
		if ((EX_isBubble == 0) && (ID_PC != PC_target)) begin
			ctrl_hazard_check = 1;
		end

		else begin
			ctrl_hazard_check = 0;
		end
	end

endmodule

	
