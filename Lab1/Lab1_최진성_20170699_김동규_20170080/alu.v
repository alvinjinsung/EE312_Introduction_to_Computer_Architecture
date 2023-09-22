`timescale 1ns / 100ps

module ALU(A,B,OP,C,Cout);

	input [15:0]A;
	input [15:0]B;
	input [3:0]OP;
	output [15:0]C;
	output Cout;

	//TODO
	
	reg [15:0]C;
	reg Cout;

	initial Cout = 1'b0;

	always @(*) begin
		case (OP)
			4'b0000: begin // 16-bit addition
				C = A+B;
				Cout = (A[15] & B[15] & ~C[15]) | (~A[15] & ~B[15] & C[15]);
				end

			4'b0001: begin // 16-bit substraction
				C = A-B;
				Cout = (A[15] & ~B[15] & ~C[15]) | (~A[15] & B[15] & C[15]);
				end

			4'b0010: begin C = A & B; Cout = 1'b0; end // 16-bit and
				

			4'b0011: begin C = A | B; Cout = 1'b0; end // 16-bit or


			4'b0100: begin C = ~(A & B); Cout = 1'b0; end // 16-bit nand
				

			4'b0101: begin C = ~(A | B); Cout = 1'b0; end // 16-bit nor
				

			4'b0110: begin C = A ^ B; Cout = 1'b0; end // 16-bit xor


			4'b0111: begin C = ~(A ^ B); Cout = 1'b0; end // 16-bit xnor
				

			4'b1000: begin C = A; Cout = 1'b0; end // Identity
				

			4'b1001: begin C = ~ A; Cout = 1'b0; end // 16-bit bitwise not
				

			4'b1010: begin C = A >> 1; Cout = 1'b0; end // logical right shift
				

			4'b1011: begin // arithmetic right shift
				C = A>>>1;
				C[15] = A[15];
				Cout = 1'b0;
				end

			4'b1100: begin C = {A[0], A[15:1]}; Cout = 1'b0; end // rotate right
				

			4'b1101: begin C = A << 1; Cout = 1'b0; end // logical left shift


			4'b1110: begin C = A <<< 1; Cout = 1'b0; end // arithmetic left shift
				

			4'b1111: begin C = {A[14:0], A[15]}; Cout = 1'b0; end // rotate left

			
			default: begin
				C = 0;
				Cout = 0;
			end				

		endcase
	end

endmodule