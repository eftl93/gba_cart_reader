module debouncer( input  logic bouncing,
						input  logic clk,
						output logic debounced
						);
						
logic [6:0]shift_reg;

always_ff @(posedge clk)
begin

	shift_reg <= {shift_reg[5:0],bouncing};
	
	if(shift_reg == 7'b1111111)
		debounced <= 1'b1;
		
	else if(shift_reg == 7'b0000000)
		debounced <= 1'b0;
		
	else
		debounced <= debounced;
end


endmodule
