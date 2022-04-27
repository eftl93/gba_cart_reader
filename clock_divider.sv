module clock_divider #( parameter DIVISOR = 26'd25000000)
							 (	input  logic clk_in,
								input	 logic n_reset,
								output logic clk_out
							 );
logic [25:0] counter;

always_ff @(posedge clk_in, negedge n_reset)
	begin
	
		if(!n_reset)
			counter <= 25'b0;
			
		else
			if(counter >= DIVISOR)
				begin
					counter <= 25'b0;
					clk_out <= ~clk_out;
				end
				
			else
				counter <= counter + 1'b1;
	end
endmodule
			