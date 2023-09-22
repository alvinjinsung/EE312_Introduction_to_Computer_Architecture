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
	output wire HALT,
	output reg [31:0] NUM_INST,
	output wire [31:0] OUTPUT_PORT
	);

	// TODO: implement multi-cycle CPU

	// PC registers
	reg [31:0] PC;
	reg [31:0] PC_pred;
	wire [31:0] PC_target;

	// IF/ID pipeline registers
	//datapath
	reg [31:0] ID_PC;
	reg [31:0] ID_Inst;

	// control
	reg ID_isBubble;

	// ID/EX pipeline registers
	// datapath
	reg [31:0] EX_PC;
	reg [31:0] EX_Inst;
	reg [31:0] EX_RD1;
	reg [31:0] EX_RD2;
	reg [31:0] EX_Imm;
	reg [4:0] EX_RA1;
	reg [4:0] EX_RA2;
	reg [4:0] EX_WA;

	// control
	reg EX_RF_WE;
	reg EX_ALU_MUX1;
	reg [1:0] EX_ALU_MUX2;
	reg EX_D_MEM_WEN;
	reg [3:0] EX_D_MEM_BE;
	reg [1:0] EX_WD_MUX;
	reg EX_J_MUX;
	reg EX_B_MUX;
	reg EX_isBubble;

	// EX/MEM pipeline registers
	// datapath
	reg [31:0] MEM_PC;
	reg [31:0] MEM_Inst;
	reg [31:0] MEM_ALUresult;
	reg [31:0] MEM_RD2;
	reg [4:0] MEM_WA;

	// control
	reg MEM_RF_WE;
	reg MEM_D_MEM_WEN;
	reg [3:0] MEM_D_MEM_BE;
	reg [1:0] MEM_WD_MUX;
	reg MEM_isBubble;

	// MEM/WB pipeline registers
	// datapath
	reg [31:0] WB_PC;
	reg [31:0] WB_Inst;
	reg [31:0] WB_ALUresult;
	reg [31:0] WB_DOUT;
	reg [4:0] WB_WA;

	// control
	reg WB_RF_WE;
	reg [1:0] WB_WD_MUX;
	reg WB_isBubble;

	// ID reg/wire
	wire ID_RF_WE_wire;
	wire ID_ALU_MUX1_wire;
	wire [1:0] ID_ALU_MUX2_wire;
	wire ID_D_MEM_WEN_wire;
	wire [3:0] ID_D_MEM_BE_wire;
	wire [1:0] ID_WD_MUX_wire;
	wire ID_J_MUX_wire;
	wire ID_B_MUX_wire;
	wire [31:0] ID_Imm_wire;

	// EX reg/wire
	wire [1:0] forward_A;
	wire [1:0] forward_B;
	reg [31:0] EX_RD1_chosen;
	reg [31:0] EX_RD2_chosen;
	reg [31:0] EX_operand1;
	reg [31:0] EX_operand2;
	wire [31:0] EX_ALUresult_wire;

	// WB reg/wire
	wire [31:0] RF_WD_wire;
	reg [31:0] RF_WD_reg;

	// hazard check
	reg ctrl_hazard_check;
	reg data_hazard_check;
	wire ctrl_hazard_check_wire;
	wire data_hazard_check_wire;

	// BTB/BHT registers
	reg [55:0] Buffer[0:1023];
	reg [1:0] state;

	// memory activation
	assign I_MEM_CSN = (~RSTn) ? 1:0;
	assign D_MEM_CSN = (~RSTn) ? 1:0;

	// initialization
	initial begin
		NUM_INST <= 0;
		PC <= 0;
		ctrl_hazard_check <= 0;
		data_hazard_check <= 0;
		state <= 2'b10;
	end

	always @(*) begin
		if (RSTn) begin
			I_MEM_ADDR = PC[11:0];
		end
	end

	// PC predict using 2-bit saturation counter BTB
	always @(*) begin
		if ((Buffer[PC[11:2]][34] === 1) || (Buffer[PC[11:2]][35] === 1)) begin
			if (Buffer[PC[11:2]][55:36] === PC[31:12]) begin
				if (Buffer[PC[11:2]][34] === 1) begin
					if ((Buffer[PC[11:2]][33:32] === 2'b10) || (Buffer[PC[11:2]][33:32] === 2'b11)) begin
						PC_pred = Buffer[PC[11:2]][31:0];
					end

					else begin
						PC_pred = PC+4;
					end
				end

				else if (Buffer[PC[11:2]][35] === 1) begin
					PC_pred = Buffer[PC[11:2]][31:0];
				end
			end

			else begin
				PC_pred = PC+4;
			end
		end

		else begin
			PC_pred = PC+4;
		end
	end

	// PC update
	always @(posedge CLK) begin
		if (RSTn) begin
			if ((ctrl_hazard_check == 0) && (data_hazard_check == 0)) begin
				PC <= PC_pred;
			end

			else if ((ctrl_hazard_check == 1) && (data_hazard_check == 0)) begin
				PC <= PC_target;
			end
		end
	end

	// IF/ID pipeline update
	always @(posedge CLK) begin
		if (ctrl_hazard_check == 1) begin
			ID_PC <= 0;
			ID_Inst <= 0;

			ID_isBubble <= 1;
		end

		else if (data_hazard_check == 0) begin
			ID_PC <= PC;
			ID_Inst <= I_MEM_DI;

			ID_isBubble <= 0;
		end
	end


	// ID
	assign RF_RA1 = ID_Inst[19:15];
	assign RF_RA2 = ID_Inst[24:20];
	assign RF_WE = WB_RF_WE;
	assign RF_WA1 = WB_WA;
	assign RF_WD = RF_WD_wire;


	// control signal generation
	CTRL ctrl(RSTn, ID_Inst, ID_RF_WE_wire, ID_ALU_MUX1_wire,  ID_ALU_MUX2_wire, ID_D_MEM_WEN_wire, ID_D_MEM_BE_wire, ID_WD_MUX_wire, ID_J_MUX_wire, ID_B_MUX_wire);

	// immediate value generation
	IMM imm(ID_Inst, ID_Imm_wire);

	// ID/EX pipeline update
	always @(posedge CLK) begin
		if ((ctrl_hazard_check == 1) || (data_hazard_check == 1)) begin
			EX_PC <= 0;
			EX_Inst <= 0;
			EX_RD1 <= 0;
			EX_RD2 <= 0;
			EX_Imm <= 0;
			EX_RA1 <= 0;
			EX_RA2 <= 0;
			EX_WA <= 0;

			EX_RF_WE <= 0;
			EX_ALU_MUX1 <= 0;
			EX_ALU_MUX2 <= 0;
			EX_D_MEM_WEN <= 1;
			EX_D_MEM_BE <= 0;
			EX_WD_MUX <= 0;
			EX_J_MUX <= 0;
			EX_B_MUX <= 0;
			EX_isBubble <= 1;
		end

		else begin
			EX_PC <= ID_PC;
			EX_Inst <= ID_Inst;

			if ((RF_RA1 == RF_WA1) && (RF_WE == 1)) begin
				EX_RD1 <= RF_WD;
			end

			else begin
				EX_RD1 <= RF_RD1;
			end

			if ((RF_RA2 == RF_WA1) && (RF_WE == 1)) begin
				EX_RD2 <= RF_WD;
			end

			else begin
				EX_RD2 <= RF_RD2;
			end

			EX_Imm <= ID_Imm_wire;
			EX_RA1 <= ID_Inst[19:15];
			EX_RA2 <= ID_Inst[24:20];
			EX_WA <= ID_Inst[11:7];

			EX_RF_WE <= ID_RF_WE_wire;
			EX_ALU_MUX1 <= ID_ALU_MUX1_wire;
			EX_ALU_MUX2 <= ID_ALU_MUX2_wire;
			EX_D_MEM_WEN <= ID_D_MEM_WEN_wire;
			EX_D_MEM_BE <= ID_D_MEM_BE_wire;
			EX_WD_MUX <= ID_WD_MUX_wire;
			EX_J_MUX <= ID_J_MUX_wire;
			EX_B_MUX <= ID_B_MUX_wire;
			EX_isBubble <= ID_isBubble;
		end
	end

	// EX
	// forward check
	FORWARD forward(EX_RA1, EX_RA2, MEM_WA, WB_WA, MEM_RF_WE, WB_RF_WE, forward_A, forward_B);

	// choose data based on forward signal
	always @(*) begin
		if (forward_A == 2'b00) begin
			EX_RD1_chosen = EX_RD1;
		end

		else if (forward_A == 2'b01) begin
			EX_RD1_chosen = MEM_ALUresult;
		end

		else if (forward_A == 2'b10) begin
			EX_RD1_chosen = RF_WD_wire;
		end
	end

	// choose operand for ALU
	always @(*) begin
		if (EX_ALU_MUX1 == 0) begin
			EX_operand1 = EX_RD1_chosen;
		end

		else if (EX_ALU_MUX1 == 1) begin
			EX_operand1 = EX_PC;
		end
	end

	// choose data based on forward signal
	always @(*) begin
		if (forward_B == 2'b00) begin
			EX_RD2_chosen = EX_RD2;
		end

		else if (forward_B == 2'b01) begin
			EX_RD2_chosen = MEM_ALUresult;
		end

		else if (forward_B == 2'b10) begin
			EX_RD2_chosen = RF_WD_wire;
		end
	end

	// choose operand for ALU
	always @(*) begin
		if (EX_ALU_MUX2 == 2'b00) begin
			EX_operand2 = EX_RD2_chosen;
		end

		else if (EX_ALU_MUX2 == 2'b01) begin
			EX_operand2 = 2;
		end

		else if (EX_ALU_MUX2 == 2'b10) begin
			EX_operand2 = EX_Imm;
		end
	end

	// ALU calculation
	ALU alu(EX_Inst, EX_operand1, EX_operand2, EX_ALUresult_wire);

	// correct PC value
	assign PC_target = (EX_J_MUX == 1) ? EX_ALUresult_wire : ((EX_B_MUX == 1) && (EX_ALUresult_wire == 1)) ? EX_PC + EX_Imm : EX_PC+4;

	// control hazard check
	CTRL_HAZARD ctrl_hazard(ID_PC, PC_target, EX_isBubble, ctrl_hazard_check_wire);

	always @(*) begin
		ctrl_hazard_check <= ctrl_hazard_check_wire;
	end

	// data hazard check
	DATA_HAZARD data_hazard(EX_Inst, ID_Inst, RF_RA1, RF_RA2, EX_WA, data_hazard_check_wire);

	always @(*) begin
		data_hazard_check <= data_hazard_check_wire;
	end


	// BHT update
	always @(*) begin
		if (EX_Inst[6:0] == 7'b1100011) begin
			if (Buffer[EX_PC[11:2]][33:32] === 2'b00) begin
				if (EX_ALUresult_wire == 0) begin
					state = 2'b00;
				end

				else begin
					state = 2'b01;
				end
			end

			else if (Buffer[EX_PC[11:2]][33:32] === 2'b01) begin
				if (EX_ALUresult_wire == 0) begin
					state = 2'b00;
				end

				else begin
					state = 2'b10;
				end
			end

			else if (Buffer[EX_PC[11:2]][33:32] === 2'b10) begin
				if (EX_ALUresult_wire == 0) begin
					state = 2'b01;
				end

				else begin
					state = 2'b11;
				end
			end

			else if (Buffer[EX_PC[11:2]][33:32] === 2'b11) begin
				if (EX_ALUresult_wire == 0) begin
					state = 2'b10;
				end

				else begin
					state = 2'b11;
				end
			end
		end
	end

	// BTB/Tag_table update
	always @(*) begin
		if (EX_Inst[6:0] == 7'b1100011) begin
			Buffer[EX_PC[11:2]][31:0] = PC_target;
			Buffer[EX_PC[11:2]][55:36] = EX_PC[31:12];
			Buffer[EX_PC[11:2]][35] = 0;
			Buffer[EX_PC[11:2]][34] = 1;
		end

		else if ((EX_Inst[6:0] == 7'b1101111) || (EX_Inst[6:0] == 7'b1100111)) begin
			Buffer[EX_PC[11:2]][31:0] = PC_target;
			Buffer[EX_PC[11:2]][55:36] = EX_PC[31:12];
			Buffer[EX_PC[11:2]][35] = 1;
			Buffer[EX_PC[11:2]][34] = 0;
		end
	end
	

	always @(posedge CLK) begin
		if (EX_Inst[6:0] == 7'b1100011) begin
			Buffer[EX_PC[11:2]][33:32] <= state;
		end
	end

	// EX/MEM pipeline update
	always @(posedge CLK) begin
		MEM_PC <= EX_PC;
		MEM_Inst <= EX_Inst;
		MEM_ALUresult <= EX_ALUresult_wire;
		MEM_RD2 <= EX_RD2_chosen;
		MEM_WA <= EX_WA;

		MEM_RF_WE <= EX_RF_WE;
		MEM_D_MEM_WEN <= EX_D_MEM_WEN;
		MEM_D_MEM_BE <= EX_D_MEM_BE;
		MEM_WD_MUX <= EX_WD_MUX;
		MEM_isBubble <= EX_isBubble;
	end

	// MEM
	assign D_MEM_WEN = MEM_D_MEM_WEN;
	assign D_MEM_BE = MEM_D_MEM_BE;
	assign D_MEM_ADDR = MEM_ALUresult;
	assign D_MEM_DOUT = MEM_RD2;

	// MEM/WB pipeline update
	always @(posedge CLK) begin
		WB_PC <= MEM_PC;
		WB_Inst <= MEM_Inst;
		WB_ALUresult <= MEM_ALUresult;
		WB_DOUT <= D_MEM_DI;
		WB_WA <= MEM_WA;

		WB_RF_WE <= MEM_RF_WE;
		WB_WD_MUX <= MEM_WD_MUX;
		WB_isBubble <= MEM_isBubble;
	end

	// WB
	assign RF_WD_wire = (WB_WD_MUX == 2'b00) ? WB_PC+4 : (WB_WD_MUX == 2'b01) ? WB_DOUT : (WB_WD_MUX == 2'b10) ? WB_ALUresult : 0;

	always @(posedge CLK) begin
		RF_WD_reg <= RF_WD_wire;
	end

	assign OUTPUT_PORT = RF_WD_reg;

	always @(posedge CLK) begin 
		if ((WB_Inst[6:0] == 7'b1101111) || (WB_Inst[6:0] == 7'b1100111) || (WB_Inst[6:0] == 7'b1100011) || (WB_Inst[6:0] == 7'b0000011) || (WB_Inst[6:0] == 7'b0100011) || (WB_Inst[6:0] == 7'b0010011) || (WB_Inst[6:0] == 7'b0110011) || (WB_Inst[6:0] == 7'b0001011)) begin
			if (WB_isBubble == 0) begin
				NUM_INST <= NUM_INST+1;
			end
		end
	end

	assign HALT = ((WB_Inst == 32'h00c00093) && (MEM_Inst == 32'h00008067)) ? 1:0;



endmodule //
