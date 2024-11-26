`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.11.2024 01:24:59
// Design Name: 
// Module Name: UART Receiver Module
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

module uart_receiver #(
    parameter DATA_WIDTH = 8,
    parameter STOP_BITS = 1
)(
    input wire clk,
    input wire reset,
    input wire rx_pin,
    output reg [DATA_WIDTH-1:0] rx_data,
    output reg rx_valid,
    input wire rx_ready
);

    // Receiver states
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
            rx_data <= {DATA_WIDTH{1'b0}};
            rx_valid <= 1'b0;
            bit_counter <= 4'b0;
        end else begin
            current_state <= next_state;
            
            case(current_state)
                IDLE: begin
                    rx_valid <= 1'b0;
                    if (!rx_pin) begin  // Detect start bit
                        shift_data <= {DATA_WIDTH{1'b0}};
                    end
                end
                
                START: begin
                    // Wait for middle of start bit
                end
                
                DATA: begin
                    shift_data <= {rx_pin, shift_data[DATA_WIDTH-1:1]};
                end
                
                STOP: begin
                    if (rx_ready) begin
                        rx_data <= shift_data;
                        rx_valid <= 1'b1;
                    end
                end
            endcase
        end
    end

    // Next state logic
    always @(*) begin
        case(current_state)
            IDLE: begin
                next_state = !rx_pin ? START : IDLE;
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