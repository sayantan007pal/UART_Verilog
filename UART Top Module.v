`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.11.2024 01:53:12
// Design Name: 
// Module Name: UART Top Module
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


module uart_top #(
    parameter DATA_WIDTH = 8,
    parameter STOP_BITS = 1,
    parameter SYSTEM_CLK = 50_000_000,
    parameter BAUD_RATE = 115_200
)(
    input wire clk,
    input wire reset,
    input wire [DATA_WIDTH-1:0] tx_data,
    input wire tx_valid,
    output wire [DATA_WIDTH-1:0] rx_data,
    output wire rx_valid,
    output wire tx_ready,
    input wire rx_pin,
    output wire tx_pin
);

    // Baud rate clock wire
    wire baud_clk;

    // Baud Rate Generator
    baud_rate_generator #(
        .SYSTEM_CLK(SYSTEM_CLK),
        .BAUD_RATE(BAUD_RATE)
    ) baud_gen (
        .clk(clk),
        .reset(reset),
        .baud_clk(baud_clk)
    );

    // UART Transmitter
    uart_transmitter #(
        .DATA_WIDTH(DATA_WIDTH),
        .STOP_BITS(STOP_BITS)
    ) transmitter (
        .clk(baud_clk),
        .reset(reset),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready),
        .tx_pin(tx_pin)
    );

    // UART Receiver
    uart_receiver #(
        .DATA_WIDTH(DATA_WIDTH),
        .STOP_BITS(STOP_BITS)
    ) receiver (
        .clk(baud_clk),
        .reset(reset),
        .rx_pin(rx_pin),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_ready(1'b1)  // Always ready to receive
    );
endmodule