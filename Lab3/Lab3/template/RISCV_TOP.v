module RISCV_TOP (
	//General Signals
	input wire CLK,
	input wire RSTn,

	//I-Memory Signals
	output wire I_MEM_CSN,
	input wire [31:0] I_MEM_DI,//input from IM
	output reg [11:0] I_MEM_ADDR,//in byte address

	//D-Memory Signals
	output wire D_MEM_CSN,
	input wire [31:0] D_MEM_DI,
	output wire [31:0] D_MEM_DOUT,
	output wire [11:0] D_MEM_ADDR,//in word address
	output wire D_MEM_WEN,
	output wire [3:0] D_MEM_BE,

	//RegFile Signals
	output wire RF_WE,
	output wire [4:0] RF_RA1,
	output wire [4:0] RF_RA2,
	output wire [4:0] RF_WA1,
	input wire [31:0] RF_RD1,
	input wire [31:0] RF_RD2,
	output wire [31:0] RF_WD,
	output wire HALT,                   // if set, terminate program
	output reg [31:0] NUM_INST,         // number of instruction completed
	output wire [31:0] OUTPUT_PORT      // equal RF_WD this port is used for test
	);

	assign OUTPUT_PORT = RF_WD;

	initial begin
		NUM_INST <= 0;
	end

	// Only allow for NUM_INST
	always @ (negedge CLK) begin
		if (RSTn) NUM_INST <= NUM_INST + 1;
	end

	// TODO: implement


	// Register
	reg [31:0] PC;
	reg [31:0] PC_next;
	reg [31:0] operand1;
	reg [31:0] operand2;
	reg [31:0] D_MEM_DOUT_WD;

	// Wire
	wire RF_WE_value;
	wire ALU_MUX1_value;
	wire [1:0] ALU_MUX2_value;
	wire D_MEM_WEN_value;
	wire [3:0] D_MEM_BE_value;
	wire [1:0] WD_MUX_value;
	wire J_MUX_value;
	wire B_MUX_value;
	wire [31:0] imm_value;
	wire [31:0] alu_result;
 

	// Initial procedure
	initial PC = 0;


	// Instruction memory
	always @(*) begin
		if (RSTn) begin
			I_MEM_ADDR = PC[11:0];
		end
	end

	assign I_MEM_CSN = (~RSTn) ? 1:0;

	// Control Signals
	CTRL ctrl(RSTn, I_MEM_DI, RF_WE_value, ALU_MUX1_value, ALU_MUX2_value, D_MEM_WEN_value, D_MEM_BE_value, WD_MUX_value, J_MUX_value, B_MUX_value);


	// assign value_register file
	assign RF_WE = RF_WE_value;
	

	// Register file
	assign RF_RA1 = I_MEM_DI[19:15];
	assign RF_RA2 = I_MEM_DI[24:20];
	assign RF_WA1 = I_MEM_DI[11:7];


	// Immediate value
	IMM imm(I_MEM_DI, imm_value);


	// ALU operand
	always @(*) begin
		if (ALU_MUX1_value == 0) begin
			operand1 = RF_RD1;
		end

		else if (ALU_MUX1_value == 1) begin
			operand1 = PC;
		end
	end
	
	always @(*) begin
		if (ALU_MUX2_value == 2'b00) begin
			operand2 = RF_RD2;
		end

		else if (ALU_MUX2_value == 2'b01) begin
			operand2 = 2;
		end

		else if (ALU_MUX2_value == 2'b10) begin
			operand2 = imm_value;
		end
	end
	

	ALU alu(I_MEM_DI, operand1, operand2, alu_result);


	// assign value_data memmory
	assign D_MEM_WEN = D_MEM_WEN_value;
	assign D_MEM_BE = D_MEM_BE_value;

	assign D_MEM_CSN = (~RSTn) ? 1:0;

	assign D_MEM_ADDR = alu_result[11:0];
	assign D_MEM_DOUT = RF_RD2;


	// Data memory
	always @(*) begin
		if (D_MEM_BE_value == 4'b0001) begin
			D_MEM_DOUT_WD = {{24{D_MEM_DI[7]}}, {D_MEM_DI[7:0]}};
		end

		else if (D_MEM_BE_value == 4'b0011) begin
			D_MEM_DOUT_WD = {{16{D_MEM_DI[15]}}, {D_MEM_DI[15:0]}};
		end

		else if (D_MEM_BE_value == 4'b1111) begin
			D_MEM_DOUT_WD = D_MEM_DI;
		end

		else if (D_MEM_BE_value == 4'b1110) begin
			D_MEM_DOUT_WD = {{24{1'b0}}, {D_MEM_DI[7:0]}};
		end

		else if (D_MEM_BE_value == 4'b1100) begin
			D_MEM_DOUT_WD = {{16{1'b0}}, {D_MEM_DI[15:0]}};
		end
	end


	// Register write
	assign RF_WD = (I_MEM_DI[6:0] == 7'b0100011) ? alu_result : (I_MEM_DI[6:0] == 7'b1100011) ? alu_result : (WD_MUX_value == 2'b00) ? PC + 4 : (WD_MUX_value == 2'b01) ? D_MEM_DOUT_WD : (WD_MUX_value == 2'b10) ? alu_result : (WD_MUX_value == 2'b11) ? imm_value : 0;
	
	always @(*) begin
		if ((alu_result == 1) && (B_MUX_value == 1)) begin
			PC_next = PC + imm_value;
		end

		else begin
			if (J_MUX_value == 1) begin
				PC_next = alu_result;
			end

			else begin
				PC_next = PC + 4;
			end
		end
	end
	

	always @(posedge CLK) begin
		if (RSTn) begin
			PC <= PC_next;
		end
	end


// HALT
	assign HALT = ((I_MEM_DI[31:0]==32'h00008067) && (RF_RD1[31:0]==32'h0000000c)) ? 1:0;



endmodule //
