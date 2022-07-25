`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.07.2022 17:02:49
// Design Name: 
// Module Name: Top_UART_tb
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


module Top_UART_tb ();
parameter CLOCK_PERIOD = 10;
reg i_clk = 0;
reg TX_Valid = 0;
wire o_TX_Active ;
wire UART_TX_RX;
wire o_TX_Serial;
wire o_TX ;
wire o_RX_DV ;
reg [7:0] data_TX = 0;
wire [7:0] data_RX;

/*TOP_UART TOP_DUT(
i_clk ,
i_TX_valid ,
data_TX ,
o_TX_Active ,
o_TX,
o_RX_DV ,
data_RX
);
*/
/*TOP_UART(
input i_clk ,
input i_TX_valid ,
input [`WIDTH_DATA-1:0] data_TX ,
output o_TX_Active ,
output o_TX,
output o_RX_DV ,
input i_Rx_Serial ,
output o_Tx_Serial ,
//output [`WIDTH_DATA-1:0] data_RX ,
output [1:0] seg_en ,
output [6:0] Seg_out
//output [`WIDTH_DATA-1:0] seg2_out
);
*/
UART_TX UUT_TX(
.i_clk(i_clk) ,
.i_TX_valid(TX_Valid) ,
.i_TX_DATA(data_TX) , ///data to be transmitted from FPGA TO PC ///
.o_TX_Serial(o_TX_Serial) , ////serial output data to be streamed (Parallel to Serial)to the PC ///
.o_TX_active(o_TX_Active) , ///output showing data transmission is active //
.o_TX(o_TX) //output showing data is successfully transmitted ///
);

Top_UART_Rx DUT_RX(
.i_clk(i_clk) , ///Fpga clk ///
.i_Rx_serial(UART_TX_RX) , ///data is serially loaded from PC through this ////
.o_RX_DV(o_RX_DV) , ////DATA_VALID , output showing data is successfully received //
.o_RX(data_RX) ////output led's showing the received ASCII code from PC //
);



assign UART_TX_RX = o_TX_Active ? o_TX_Serial : 1'b1;

always #(CLOCK_PERIOD/2) i_clk <= ~i_clk;


initial
begin
@(posedge i_clk);
@(posedge i_clk);
TX_Valid <= 1'b1;
data_TX <= 8'h26;
@(posedge i_clk);
TX_Valid <= 1'b0;
end

endmodule
