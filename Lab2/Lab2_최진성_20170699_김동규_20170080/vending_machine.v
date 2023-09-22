`include "vending_machine_def.v"

module vending_machine (

	clk,							// Clock signal
	reset_n,						// Reset signal (active-low)

	i_input_coin,				// coin is inserted.
	i_select_item,				// item is selected.
	i_trigger_return,			// change-return is triggered

	o_available_item,			// Sign of the item availability
	o_output_item,			// Sign of the item withdrawal
	o_return_coin,				// Sign of the coin return
	stopwatch,
	current_total,
	return_temp,
);

	// Ports Declaration
	// Do not modify the module interface
	input clk;
	input reset_n;

	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0] i_select_item;
	input i_trigger_return;

	output reg [`kNumItems-1:0] o_available_item;
	output reg [`kNumItems-1:0] o_output_item;
	output reg [`kNumCoins-1:0] o_return_coin;

	output [3:0] stopwatch;
	output [`kTotalBits-1:0] current_total;
	output [`kTotalBits-1:0] return_temp;
	// Normally, every output is register,
	//   so that it can provide stable value to the outside.

	//////////////////////////////////////////////////////////////////////	/

	//we have to return many coins
	reg [`kCoinBits-1:0] returning_coin_0;
	reg [`kCoinBits-1:0] returning_coin_1;
	reg [`kCoinBits-1:0] returning_coin_2;
	reg block_item_0;
	reg block_item_1;
	//check timeout
	reg [3:0] stopwatch;
	//when return triggered
	reg have_to_return;
	reg  [`kTotalBits-1:0] return_temp;
	reg [`kTotalBits-1:0] temp;
	////////////////////////////////////////////////////////////////////////

	// Net constant values (prefix kk & CamelCase)
	// Please refer the wikepedia webpate to know the CamelCase practive of writing.
	// http://en.wikipedia.org/wiki/CamelCase
	// Do not modify the values.
	wire [31:0] kkItemPrice [`kNumItems-1:0];	// Price of each item
	wire [31:0] kkCoinValue [`kNumCoins-1:0];	// Value of each coin
	assign kkItemPrice[0] = 400;
	assign kkItemPrice[1] = 500;
	assign kkItemPrice[2] = 1000;
	assign kkItemPrice[3] = 2000;
	assign kkCoinValue[0] = 100;
	assign kkCoinValue[1] = 500;
	assign kkCoinValue[2] = 1000;


	// NOTE: integer will never be used other than special usages.
	// Only used for loop iteration.
	// You may add more integer variables for loop iteration.
	integer i, j, k,l,m,n;

	// Internal states. You may add your own net & reg variables.
	reg [`kTotalBits-1:0] current_total;
	reg [`kItemBits-1:0] num_items [`kNumItems-1:0];
	reg [`kCoinBits-1:0] num_coins [`kNumCoins-1:0];

	// Next internal states. You may add your own net and reg variables.
	reg [`kTotalBits-1:0] current_total_nxt;
	reg [`kItemBits-1:0] num_items_nxt [`kNumItems-1:0];
	reg [`kCoinBits-1:0] num_coins_nxt [`kNumCoins-1:0];

	// Variables. You may add more your own registers.
	reg [`kTotalBits-1:0] input_total, output_total, output_coin_total, return_total_0, return_total_1, return_total_2;


	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).

		o_return_coin = 0;


		if (have_to_return == 1) begin

			return_temp = current_total;

			return_total_2 = return_temp / kkCoinValue[2];
			return_temp = return_temp - return_total_2*kkCoinValue[2];
			return_total_1 = return_temp / kkCoinValue[1];
			return_temp = return_temp - return_total_1*kkCoinValue[1];
			return_total_0 = return_temp / kkCoinValue[0];

			if (return_total_2 > 0) begin
				output_coin_total = kkCoinValue[2];
				o_return_coin[2] = 1;
				o_return_coin[1] = 0;
				o_return_coin[0] = 0;
			end

			else if ((return_total_2 == 0) && (return_total_1 > 0)) begin
				output_coin_total = kkCoinValue[1];
				o_return_coin[2] = 0;
				o_return_coin[1] = 1;
				o_return_coin[0] = 0;
			end

			else if((return_total_2 == 0) && (return_total_1 == 0) && (return_total_0 > 0)) begin
				output_coin_total = kkCoinValue[0];
				o_return_coin[2] = 0;
				o_return_coin[1] = 0;
				o_return_coin[0] = 1;
			end

			else if((return_total_2 == 0) && (return_total_1 == 0) && (return_total_0 == 0)) begin
				have_to_return = 0;
				output_coin_total = 0;
				o_return_coin[2] = 0;
				o_return_coin[1] = 0;
				o_return_coin[0] = 0;
			end

		end

		else begin
			output_coin_total = 0;
			o_return_coin[2] = 0;
			o_return_coin[1] = 0;
			o_return_coin[0] = 0;
		end

		if (i_input_coin > 0) begin
			stopwatch = 10;
			input_total = (i_input_coin[0] * kkCoinValue[0]) +  (i_input_coin[1] * kkCoinValue[1]) + (i_input_coin[2] * kkCoinValue[2]);
		end
		else begin
			input_total = 0;
		end


		if (i_select_item > 0) begin
			stopwatch = 10;
			if (i_select_item[0] == 1) begin
				if (current_total_nxt >= kkItemPrice[0]) begin
					output_total = kkItemPrice[0];
				end
				else begin 
					output_total = 0;
				end
			end

			if (i_select_item[1] == 1) begin
				if (current_total_nxt >= kkItemPrice[1]) begin
					output_total = kkItemPrice[1];
				end
				else begin 
					output_total = 0;
				end
			end

			if (i_select_item[2] == 1) begin
				if (current_total_nxt >= kkItemPrice[2]) begin
					output_total = kkItemPrice[2];
				end
				else begin 
					output_total = 0;
				end
			end

			if (i_select_item[3] == 1) begin
				if (current_total_nxt >= kkItemPrice[3]) begin
					output_total = kkItemPrice[3];
				end
				else begin 
					output_total = 0;
				end
			end

		end

		else begin
			output_total = 0;
		end

		current_total_nxt = current_total + input_total - output_total - output_coin_total;


		// Calculate the next current_total state. current_total_nxt =


	end


	// Combinational logic for the outputs
	always @(*) begin
	// TODO: o_available_item


		if (current_total >= kkItemPrice[0]) begin
			o_available_item[0] = 1;
		end
		else begin 
			o_available_item[0] = 0;
		end

		if (current_total >= kkItemPrice[1]) begin
			o_available_item[1] = 1;
		end
		else begin 
			o_available_item[1] = 0;
		end

		if (current_total >= kkItemPrice[2]) begin
			o_available_item[2] = 1;
		end
		else begin 
			o_available_item[2] = 0;
		end

		if (current_total >= kkItemPrice[3]) begin
			o_available_item[3] = 1;
		end
		else begin 
			o_available_item[3] = 0;
		end

	// TODO: o_output_item

		if ((i_select_item[0] == 1) && (o_available_item[0] == 1)) begin
			o_output_item[0] = 1;
		end
		else begin
			o_output_item[0] = 0;
		end

		if ((i_select_item[1] == 1) && (o_available_item[1] == 1)) begin
			o_output_item[1] = 1;
		end
		else begin
			o_output_item[1] = 0;
		end

		if ((i_select_item[2] == 1) && (o_available_item[2] == 1)) begin
			o_output_item[2] = 1;
		end
		else begin
			o_output_item[2] = 0;
		end

		if ((i_select_item[3] == 1) && (o_available_item[3] == 1)) begin
			o_output_item[3] = 1;
		end
		else begin
			o_output_item[3] = 0;
		end

	end

	// Sequential circuit to reset or update the states
	always @(posedge clk) begin
		if (!reset_n) begin
			// TODO: reset all states.

			stopwatch <= 10;
			current_total <= 0;
			current_total_nxt <= 0;
			return_total_0 <= 0;
			return_total_1 <= 0;
			return_total_2 <= 0;
			have_to_return <= 0;
			input_total <= 0;
			output_total <= 0;
			output_coin_total <= 0;

		end
		else begin
			// TODO: update all states.

			current_total <= current_total_nxt;

			input_total <= 0;
			output_total <= 0;
			output_coin_total <= 0;
			

	/////////////////////////////////////////////////////////////////////////

			// decreas stopwatch

			if (stopwatch == 0) begin
				have_to_return <= 1;
			end
			else begin
				have_to_return <= i_trigger_return;
				stopwatch <= stopwatch-1;
			end


			//if you have to return some coins then you have to turn on the bit


	/////////////////////////////////////////////////////////////////////////
		end		   //update all state end
	end	   //always end
endmodule