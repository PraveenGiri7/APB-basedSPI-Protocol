`timescale 1ns / 1ps

module spi_slave_select_tb;

    // Inputs
    reg PRESETn;
    reg [1:0] spi_mode;
    reg mstr;
    reg spiswai;
    reg PCLK;
    reg send_data;
    reg [11:0] BaudRateDivisor;

    // Outputs
    wire ss;
    wire recieve_data;
    wire tip;

    // Instantiate the Unit Under Test (UUT)
    spi_slave_select uut (
        .PRESETn(PRESETn),
        .spi_mode(spi_mode),
        .mstr(mstr),
        .spiswai(spiswai),
        .PCLK(PCLK),
        .send_data(send_data),
        .BaudRateDivisor(BaudRateDivisor),
        .ss(ss),
        .recieve_data(recieve_data),
        .tip(tip)
    );

    // Clock generation
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK; // 100MHz clock
    end

    // Test sequence
    initial begin
        // Initialize inputs
        PRESETn = 0;
        spi_mode = 2'b00;
        mstr = 1;
        spiswai = 0;
        send_data = 0;
        BaudRateDivisor = 12'd2;  // Small divisor for short test

        // Reset the system
        #10;
        PRESETn = 1;

        // Wait a bit and then trigger send_data
        #20;
        send_data = 1;

        // Hold send_data high for 1 clock cycle
        @(posedge PCLK);
        send_data = 0;

        // Observe behavior for a while
        repeat (100) @(posedge PCLK);

        // Change mode to 2'b01 and test with spiswai = 1 (should disable selection)
        spi_mode = 2'b01;
        spiswai = 1;
        send_data = 1;
        @(posedge PCLK);
        send_data = 0;

        repeat (20) @(posedge PCLK);

        $finish;
    end

endmodule
