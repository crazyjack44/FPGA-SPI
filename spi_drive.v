module spi_driver #(
	parameter 							P_DATA_WIDTH		=	8			,
										P_READ_DATA_WIDTH	=	8			,
										P_CPOL				=	0			,
										P_CPHL				=	0			
	) (
	input								clk									,
	input								rst_n								,

	output								o_spi_clk							,
	output								o_spi_cs							,
	output								o_spi_mosi							,
	input								i_spi_miso							,

	input	[P_DATA_WIDTH-1:0]			i_user_data							,
	input								i_user_valid						,
	output								o_user_ready						,
    output  [P_READ_DATA_WIDTH - 1:0]   o_user_read_data    				,
    output                              o_user_read_valid   
);
/*******************wire*******************/
wire							w_user_active			;

/*******************reg********************/
reg								ro_spi_clk				;
reg								ro_spi_cs				;
reg								ro_spi_mosi				;
reg								ro_user_ready			;
reg [P_DATA_WIDTH-1:0]			r_user_data				;
reg								r_run					;
reg [15:0]						r_cnt					;
reg 							r_spi_cnt				;
reg								ro_user_read_valid		;
reg	[P_READ_DATA_WIDTH - 1:0] 	ro_user_read_data 		;
/*****************assign*******************/
assign w_user_active 		= 	i_user_valid & ro_user_ready;
assign o_spi_clk	 		= 	ro_spi_clk					;
assign o_spi_cs		 		= 	ro_spi_cs					;
assign o_spi_mosi	 		= 	ro_spi_mosi					;
assign o_user_ready  		= 	ro_user_ready;
assign o_user_read_valid 	= 	ro_user_read_valid			;
assign o_user_read_data 	= 	ro_user_read_data			;
/****************always*******************/
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) 
		ro_user_ready <= 'b0;
	else if(r_spi_cnt && r_cnt == 7)
		ro_user_ready <= 1;
	else
		ro_user_ready <= ro_user_ready;
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) 
		r_run <= 'd0;
	else if(r_spi_cnt && r_cnt == 7)
		r_run <= 'd0;
	else if(w_user_active)
		r_run <= 'd1;
	else
		r_run <= r_run;
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) 
		r_user_data <= 0;
	else if(w_user_active)
		r_user_data <= i_user_data;
	else if(r_spi_cnt)
		r_user_data <= r_user_data << 1;
	else
		r_user_data <= r_user_data;
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) 
		ro_spi_cs <= 1'b1;
	else if(w_user_active)
		ro_spi_cs <= 'b0;
	else if(!r_run)
		ro_spi_cs <= 'b1;
	else
		ro_spi_cs <= ro_spi_cs;
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) 
		r_cnt <= 'd0;
	else if(r_spi_cnt == 1)
		r_cnt <= r_cnt + 1'b1;
	else if(r_spi_cnt == 1 && r_cnt == 7)
		r_cnt <= 1'b0;
	else
		r_cnt <= r_cnt;
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) 
		r_spi_cnt <= 'b0;
	else if(r_run)
		r_spi_cnt <= r_spi_cnt + 'b1;
	else
		r_spi_cnt <= 'b0;
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) 
		ro_spi_mosi <= 'b0;
	else if(r_run)
		ro_spi_mosi <= i_user_data[P_DATA_WIDTH-1];
	else if(r_run&&r_spi_cnt)
		ro_spi_mosi <= r_user_data[P_DATA_WIDTH-2];
	else
		ro_spi_mosi <= ro_spi_mosi;
end

always @(posedge ro_spi_clk or negedge rst_n) begin
	if(~rst_n) 
		ro_user_read_data <= 'b0;
	else
		ro_user_read_data <= {ro_user_read_data[P_DATA_WIDTH-2:0],i_spi_miso};
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) 
		ro_user_read_valid <= 'b0;
	else if(r_spi_cnt && r_cnt == 7)
		ro_user_read_valid <= 1;
	else
		ro_user_read_valid <= 'b0;
end
endmodule
