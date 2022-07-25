`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07/03/2022 10:57:27 AM
// Design Name:
// Module Name: UART_TX
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
///Design name : UART_TX
///UART TRANSMITTER (sending data from FPGA to PC )
///Buad rate = 115200 bps //
///Fpga clk = 100MHZ

///CLK_PER_BIT_TX = Fpga_clk (100MHZ)/Baud_rate(115200)/// = 868

`define CLK_PER_BIT_TX 868
`define CNT_BYTE_TX 3
`define STATE_WIDTH_TX 3
`define DATA_WIDTH_TX 8
`define WIDTH_CLK_CNT_TX 10
module UART_TX(
input i_clk ,
input i_TX_valid ,
input [`DATA_WIDTH_TX-1:0] i_TX_DATA , ///data to be transmitted from FPGA TO PC ///
output reg o_TX_Serial , ////serial output data to be streamed (Parallel to Serial)to the PC ///
output o_TX_active , ///output showing data transmission is active //
output o_TX //output showing data is successfully transmitted ///
);

parameter IDLE = 3'b000;
parameter TX_START_BIT = 3'b001;
parameter TX_DATA_BITS = 3'b010;
parameter TX_STOP_BIT = 3'b011;
parameter CLEAN_BITS_TX = 3'b100;


reg[`WIDTH_CLK_CNT_TX-1:0] clk_count_TX = 0 ; ///counter counting the CLK_PER_BIT (2^10 =1024, COUNTING TILL 868 ( 0 to 867)////
reg[`CNT_BYTE_TX-1:0] tx_cnt = 0; // transmitter couter counting the data received bits(8 bits) ///
reg[`DATA_WIDTH_TX-1:0] tx_BYTE = 0 ; ///data sent from FPGA to PC ///
reg [2:0] p_STATE = 0; ///FSM state ///
reg o_TX_byte = 0; ///output showing data is successfully transmitted ////
reg TX_Active = 0; ///output showing data is initialized for transmitting from FPGA to PC //


assign o_TX = o_TX_byte ; ////output showing data is successfully transmitted ////
assign o_TX_active = TX_Active ;

always @(posedge i_clk)
begin
case (p_STATE)

IDLE :
begin

tx_cnt <= 0; ///none of the bits have been transmitted //
clk_count_TX <= 0;
o_TX_Serial <=1; ///start bit of transmitter goes high (no transmission)//
o_TX_byte <= 0; ///data hasn't been transmitted yet ///
if (i_TX_valid == 1'b1)
begin
p_STATE <= TX_START_BIT ; ////p_STATE
TX_Active <= 1'b1 ; ///data is initialised for transmission //
o_TX_Serial <= 0; ///start bit goes active low for serial transmission ///
tx_BYTE <= i_TX_DATA ; ///data is loaded in register "tx_BYTE" //


end
else
p_STATE <= IDLE ;

end

////make start bit 0 so as to active the transmission of data///
TX_START_BIT :
begin
o_TX_Serial <= 1'b0;
if ( clk_count_TX < `CLK_PER_BIT_TX-1)
begin
clk_count_TX <= clk_count_TX + 1'b1 ;
p_STATE <= TX_START_BIT ;
end
else
begin
p_STATE <= TX_DATA_BITS ;
clk_count_TX <= 0;
end
end

TX_DATA_BITS : begin
o_TX_Serial <= tx_BYTE[tx_cnt]; ///load the parallel data from FPGA Serially /
if (clk_count_TX < `CLK_PER_BIT_TX-1)
begin
clk_count_TX <= clk_count_TX + 1'b1 ;
p_STATE <= TX_DATA_BITS ;
end
else
begin
// o_TX_Serial <= tx_BYTE[tx_cnt]; ///load the parallel data from FPGA Serially /
clk_count_TX <= 0;
///checking if the data transmitted is 8 bit or not ///
if (tx_cnt <7)
begin
tx_cnt <= tx_cnt + 1'b1 ;
p_STATE <= TX_DATA_BITS ;
end
else
begin
tx_cnt <= 0;
p_STATE <= TX_STOP_BIT ;
end
end
end

TX_STOP_BIT : begin
o_TX_Serial <= 1'b1; ///stop bit =1
if (clk_count_TX < `CLK_PER_BIT_TX-1)
begin
clk_count_TX <= clk_count_TX + 1'b1 ;
p_STATE <= TX_STOP_BIT ;
end
else
begin
clk_count_TX <= 0;
o_TX_byte <= 1'b1; //data is succesfully transmitted///
// o_TX_Serial <= 1'b1; ///stop bit =1///
TX_Active <= 1'b0 ; ///no data transmission///
p_STATE <= CLEAN_BITS_TX ;
end
end

CLEAN_BITS_TX : begin
o_TX_byte <= 1'b1;
p_STATE <= IDLE ;
end

default : begin
p_STATE <= IDLE ;
end
endcase
end
endmodule