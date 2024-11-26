`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.11.2024 01:52:17
// Design Name: 
// Module Name: Baud Rate Generator Module
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


module baud_rate_generator #(
    parameter SYSTEM_CLK = 50_000_000,  // 50 MHz system clock
    parameter BAUD_RATE = 115_200       // Standard UART baud rate
)(
    input wire clk,
    input wire reset,
    output reg baud_clk
);

    // Calculate the number of clock cycles per bit
    localparam CYCLES_PER_BIT = SYSTEM_CLK / (BAUD_RATE * 16);
    
    // Counter for generating baud clock
    reg [$clog2(CYCLES_PER_BIT):0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            baud_clk <= 1'b0;
        end else begin
            if (counter == CYCLES_PER_BIT - 1) begin
                counter <= 0;
                baud_clk <= ~baud_clk;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end
endmodule
