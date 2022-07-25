`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.07.2022 17:06:45
// Design Name: 
// Module Name: Top_UART_Rx
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
//UART = UNIVERSAL ASYNCHRONOUS RECEIVER TRANSMITTER ////
//Design name = UART_RX(Reciever Module///
//Data(ASCII CODE --8 bit) is loaded from PC to FPGA RX pin which is displayed in the form of binary code on led's
//Baud RATE = 115200 bps////
//CLK_PER_BIT = Fpga_clk (100MHZ)/Baud_rate(115200)/// = 868

`define CLK_PER_BIT 868
`define CNT_BYTE 3
`define STATE_WIDTH 3
`define DATA_WIDTH 8
`define WIDTH_CLK_CNT 10
module Top_UART_Rx(
input i_clk , ///Fpga clk ///
input i_Rx_serial , ///data is serially loaded from PC through this ////
output o_RX_DV , ////DATA_VALID , output showing data is successfully received //
output [`DATA_WIDTH-1:0] o_RX, ////output led's showing the received ASCII code from PC //
input i_TX_valid ,
input [`DATA_WIDTH-1:0] data_TX , ///data to be transmitted from FPGA TO PC ///
output o_TX_Serial , ////serial output data to be streamed (Parallel to Serial)to the PC ///
output o_TX_active , ///output showing data transmission is active //
output o_TX //output showing data is successfully transmitted ///
);

UART_TX Transmitter(
.i_clk(i_clk) ,
.i_TX_valid(i_TX_valid) ,
.i_TX_DATA(data_TX) , ///data to be transmitted from FPGA TO PC ///
.o_TX_Serial(o_TX_Serial) , ////serial output data to be streamed (Parallel to Serial)to the PC ///
.o_TX_active(o_TX_active) , ///output showing data transmission is active //
.o_TX(o_TX) //output showing data is successfully transmitted ///
);


parameter IDLE = 3'b000;
parameter RX_START_BIT = 3'b001;
parameter RX_DATA_BITS = 3'b010;
parameter RX_STOP_BIT = 3'b011;
parameter CLEAN_BITS = 3'b100;


reg[`WIDTH_CLK_CNT-1:0] clk_count = 0 ; ///counter counting the CLK_PER_BIT (2^10 =1024, COUNTING TILL 868 ( 0 to 867)////
reg[`CNT_BYTE-1:0] rx_cnt = 0; // reciever couter counting the data received bits(8 bits) ///
reg[`DATA_WIDTH-1:0] rx_BYTE = 0 ; ///data received from PC ///
reg [`STATE_WIDTH-1:0] p_STATE = 0; ///FSM state ///
reg o_RX_byte = 0; ///output showing data is successfully received ////


///FSM state machine////

always @(posedge i_clk)
begin
case (p_STATE)
IDLE :
begin
rx_cnt <= 0;
o_RX_byte <= 0;
clk_count <= 0;
if (i_Rx_serial==1'b0)
p_STATE <= RX_START_BIT ; /////transmission bit is received serially as logical low///
else
p_STATE <= IDLE ;
end


///to check if data is still low in the middle of start bit ///
RX_START_BIT :
begin
if (clk_count == (`CLK_PER_BIT-1)/2)
begin
if (i_Rx_serial == 1'b0)
begin
p_STATE <= RX_DATA_BITS ;
clk_count <= 0;
end
else
p_STATE <= IDLE ;
end

else
begin
clk_count <= clk_count + 1;
p_STATE <= RX_START_BIT;
end
end



RX_DATA_BITS :
begin
if (clk_count < `CLK_PER_BIT-1)
begin
clk_count <= clk_count + 1;
p_STATE <= RX_DATA_BITS;
end
else
begin
clk_count <= 0;
rx_BYTE [rx_cnt] <= i_Rx_serial ; ///data is loaded into receiver counter index /////
///// Receiver couter counting if the data received bits(8 bits) or not ///
if (rx_cnt<7)
begin
rx_cnt <= rx_cnt + 1 ;
p_STATE <= RX_DATA_BITS ;
end
else
begin
rx_cnt <= 0;
p_STATE <= RX_STOP_BIT;
end
end
end
///Receive stop bit//

RX_STOP_BIT :
begin
if (clk_count < `CLK_PER_BIT-1)
begin
clk_count <= clk_count + 1;
p_STATE <= RX_STOP_BIT ;
end
else
begin
o_RX_byte <= 1'b1 ;
clk_count <= 0;
p_STATE <= CLEAN_BITS ;
end
end

CLEAN_BITS : begin
p_STATE <= IDLE ;
o_RX_byte <= 1'b0;
end
default: p_STATE <= IDLE ;
endcase
end


assign o_RX = rx_BYTE ;
assign o_RX_DV = o_RX_byte ;

endmodule
