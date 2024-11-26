`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.11.2024 01:54:16
// Design Name: 
// Module Name: UART Testbench
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


module uart_testbench();

    // Testbench parameters
    parameter DATA_WIDTH = 8;
    parameter SYSTEM_CLK = 50_000_000;
    parameter BAUD_RATE = 115_200;

    // Testbench signals
    reg clk, reset;
    reg [DATA_WIDTH-1:0] tx_data;
    reg tx_valid;
    wire [DATA_WIDTH-1:0] rx_data;
    wire rx_valid, tx_ready;
    wire tx_pin, rx_pin;

    // Instantiate the UART Top Module
    uart_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .SYSTEM_CLK(SYSTEM_CLK),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .clk(clk),
        .reset(reset),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .tx_ready(tx_ready),
        .rx_pin(tx_pin),  // Connect tx_pin to rx_pin for loopback
        .tx_pin(tx_pin)
    );

    // Clock generation
    always #10 clk = ~clk;  // 50 MHz clock

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        tx_data = 0;
        tx_valid = 0;

        // Release reset
        #100 reset = 0;

        // Test transmission of multiple bytes
        @(posedge clk);
        tx_data = 8'hA5;  // Test pattern
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;

        // Wait for transmission and reception
        #10000;

        // Second transmission
        @(posedge clk);
        tx_data = 8'h3C;  // Another test pattern
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;

        // Final checks
        #10000;

        // Verify received data
        if (rx_data === 8'h3C && rx_valid) 
            $display("UART Transmission Successful!");
        else
            $display("UART Transmission Failed!");

        // End simulation
        $finish;
    end

    // Optional: Waveform dumping for ModelSim/Quartus
    initial begin
        $dumpfile("uart_testbench.vcd");
        $dumpvars(0, uart_testbench);
    end
endmodule