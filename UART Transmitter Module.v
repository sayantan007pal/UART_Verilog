`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.11.2024 01:21:50
// Design Name: 
// Module Name: UART Transmitter Module
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


module uart_transmitter #(
    parameter DATA_WIDTH = 8,
    parameter STOP_BITS = 1
)(
    input wire clk,
    input wire reset,
    input wire [DATA_WIDTH-1:0] tx_data,
    input wire tx_valid,
    output reg tx_ready,
    output reg tx_pin
);

    // Transmission states
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;

    // State and control signals
    reg [1:0] current_state, next_state;
    reg [3:0] bit_counter;
    reg [DATA_WIDTH-1:0] shift_data;

    // State transition and data handling
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            tx_pin <= 1'b1;  // Idle high for UART
            tx_ready <= 1'b1;
            bit_counter <= 4'b0;
        end else begin
            current_state <= next_state;
            
            case(current_state)
                IDLE: begin
                    tx_pin <= 1'b1;
                    if (tx_valid) begin
                        tx_ready <= 1'b0;
                        shift_data <= tx_data;
                    end
                end
                
                START: begin
                    tx_pin <= 1'b0;  // Start bit is always low
                end
                
                DATA: begin
                    tx_pin <= shift_data[0];
                    shift_data <= shift_data >> 1;
                end
                
                STOP: begin
                    tx_pin <= 1'b1;  // Stop bit is always high
                end
            endcase
        end
    end

    // Next state and bit counter logic
    always @(*) begin
        case(current_state)
            IDLE: begin
                next_state = tx_valid ? START : IDLE;
            end
            
            START: begin
                next_state = DATA;
            end
            
            DATA: begin
                if (bit_counter == DATA_WIDTH - 1) 
                    next_state = STOP;
                else
                    next_state = DATA;
            end
            
            STOP: begin
                if (bit_counter == STOP_BITS)
                    next_state = IDLE;
                else
                    next_state = STOP;
            end
            
            default: next_state = IDLE;
        endcase
    end

    // Bit counter management
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_counter <= 4'b0;
        end else begin
            case(current_state)
                START: bit_counter <= 4'b0;
                DATA: bit_counter <= bit_counter + 1'b1;
                STOP: bit_counter <= bit_counter + 1'b1;
                default: bit_counter <= 4'b0;
            endcase
        end
    end
endmodule
