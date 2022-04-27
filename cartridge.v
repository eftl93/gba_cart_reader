module cartridge(output clk,
						output nWR,
						output nRD,
						output nCS,
						output nCS2,
						input  add_dat_en,
						input  [23:0]add_dat,
						inout  [23:0]add_dat_inout,
						output [15:0]data_read
						);
						


	// If we are using the bidir as an output, assign it an output value, 
	// otherwise assign it high-impedence
	assign add_dat_inout = (add_dat_en ? add_dat : {24{1'bz}});

	// Read in the current value of the bidir port, which comes either
	// from the input or from the previous assignment.
	assign data_read = add_dat_inout;

endmodule
