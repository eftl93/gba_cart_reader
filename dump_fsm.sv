module dump_fsm #(parameter N = 7,
						DELAYED_CYCLES = 7'd100,
						MAX_ADDR = 24'hFFFFFF)
					( input  logic clk,
					  input  logic start_dump,
					  input  logic n_reset,
					  output logic n_rd,
					  output logic n_wr,
					  output logic n_cs,
					  output logic n_cs2,
					  output logic out_en,
					  output logic out_done,
					  output logic [23:0] current_address,
					  output logic data_ready
					  );
					  
					  
typedef enum logic [3:0] {IDLE,INIT,ADDR_ON_BUS,LATCH_ADDR,DA_HZ,RD_LOW,SAVE_DATA,RD_HIGH,DONE} state_type;

//=======================================================
//  REG/WIRE/LOGIC declarations
//=======================================================

state_type  current_state, next_state;
logic 		[N-1:0] t = 0;
reg [23:0] MEM_ADDR = 0;
reg [23:0] NEXT_MEM_ADDR = 0;

//=======================================================
//  Structural coding
//=======================================================

assign current_address = MEM_ADDR;

//state registers process
always_ff @(posedge clk, negedge n_reset)
begin
	if(!n_reset)
		current_state <= IDLE;
	else
		current_state <= next_state;
end

//update MEM_ADDR on rising edge
always_ff @(posedge clk, negedge n_reset)
begin
	if(!n_reset)
		MEM_ADDR <= 0;
	else
		MEM_ADDR <= NEXT_MEM_ADDR;
end

//timer process
always_ff @(posedge clk, negedge n_reset)
begin
		if(!n_reset)
			t <= 0;
		else
			if(current_state != next_state)
				t <= 0;
			else
				t <= t + 1'b1;
end


//logic process to define what the next_state register be
always_comb
begin
	next_state = current_state; //default next_state
	NEXT_MEM_ADDR = MEM_ADDR;
	case(current_state)
	
		IDLE			: 
		begin
			if(start_dump & (t >= 0))
				next_state = INIT;
			else if(MEM_ADDR >= MAX_ADDR)
				next_state = IDLE;
			else
				next_state = IDLE;
		end
		
		INIT			: 
		begin
			if(t >= DELAYED_CYCLES)
				next_state = ADDR_ON_BUS;
			else
				next_state = INIT;
		end
		
		ADDR_ON_BUS : 
		begin
			if(t >= DELAYED_CYCLES)
				next_state = LATCH_ADDR;
			else
				next_state = ADDR_ON_BUS;
		end
		
		LATCH_ADDR	: 
		begin
			if(t >= DELAYED_CYCLES)
				next_state = DA_HZ;
			else
				next_state = LATCH_ADDR;
		end
		
		DA_HZ			: 
		begin
			next_state = RD_LOW;
		end
		
		RD_LOW		: 
		begin
			if((MEM_ADDR >= MAX_ADDR) & (t >= DELAYED_CYCLES))
				next_state = DONE;
			else if(t >= DELAYED_CYCLES)
				next_state = SAVE_DATA;
			else
				next_state = RD_LOW;
		end
		
		SAVE_DATA	:	 //in this state we need to read the AD buss
		begin
			next_state = RD_HIGH;
			NEXT_MEM_ADDR = MEM_ADDR + 1'b1;
		end
		
		RD_HIGH		:	
		begin
			if(t >= DELAYED_CYCLES)
				next_state = RD_LOW;
			else
				next_state = RD_HIGH;
		end
		
		DONE			:
		begin
			next_state = DONE;
		end
		
		default		:	
		begin
			next_state = IDLE;
		end
	endcase
end





always_comb
begin
	case(current_state)
		IDLE			: 
		begin
			n_rd				= 1'b1;
			n_wr				= 1'b1;
			n_cs				= 1'b1;
			n_cs2				= 1'b1;
			out_en			= 1'b0;
			out_done			= 1'b0;
			data_ready		= 1'b0;
		end
		
		INIT			: 
		begin
			n_rd				= 1'b1;
			n_wr				= 1'b1;
			n_cs				= 1'b1;
			n_cs2				= 1'b1;
			out_en			= 1'b0;
			out_done			= 1'b0;
			data_ready		= 1'b0;
		end
		
		ADDR_ON_BUS : 
		begin
			n_rd				= 1'b1;
			n_wr				= 1'b1;
			n_cs				= 1'b1; 
			n_cs2				= 1'b1;
			out_en			= 1'b1; //set bus as output
			out_done			= 1'b0;
			data_ready		= 1'b0;
		end
		
		LATCH_ADDR: 
		begin
			n_rd				= 1'b1; 
			n_wr				= 1'b1;
			n_cs				= 1'b0; //FLASH will latch address at this point and is selected
			n_cs2				= 1'b1;
			out_en			= 1'b1; //AD bus is still an output	
			out_done			= 1'b0;
			data_ready		= 1'b0;
		end
		
		DA_HZ			: 
		begin
			n_rd				= 1'b1;
			n_wr				= 1'b1;
			n_cs				= 1'b0; //FLASH still selected
			n_cs2				= 1'b1;
			out_en			= 1'b0; //change DA to Hi impedance	
			out_done			= 1'b0;
			data_ready		= 1'b0;	
		end
		
		RD_LOW		: 
		begin
			n_rd				= 1'b0; //FLASH outputs data
			n_wr				= 1'b1;
			n_cs				= 1'b0; //FLASH still low for sequential reading
			n_cs2				= 1'b1;
			out_en			= 1'b0;
			out_done			= 1'b0;
			data_ready		= 1'b0;
		end
		
		SAVE_DATA	:	
		begin
			n_rd				= 1'b0; //FLASH still outputs data
			n_wr				= 1'b1;
			n_cs				= 1'b0; //FLASH still low for sequential reading
			n_cs2				= 1'b1;
			out_en			= 1'b0;	
			out_done			= 1'b0;
			data_ready		= 1'b1;	
		end
		
		RD_HIGH		:	
		begin
			n_rd				= 1'b1;
			n_wr				= 1'b1;
			n_cs				= 1'b0; //FLASH still low for sequential reading
			n_cs2				= 1'b1;
			out_en			= 1'b0;
			out_done			= 1'b0;
			data_ready		= 1'b0;
		end
		
		DONE			:
		begin
			n_rd				= 1'b1;
			n_wr				= 1'b1;
			n_cs				= 1'b1; //FLASH still low for sequential reading
			n_cs2				= 1'b1;
			out_en			= 1'b0;
			out_done			= 1'b1;
			data_ready		= 1'b0;			
		end
		
		default		:	
		begin
			n_rd				= 1'b1;
			n_wr				= 1'b1;
			n_cs				= 1'b1;
			n_cs2				= 1'b1;
			out_en			= 1'b0;
			out_done			= 1'b0;	
		end
	endcase
end
endmodule
