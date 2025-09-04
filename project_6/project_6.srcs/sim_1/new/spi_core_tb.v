`timescale 1ns / 1ps

module spi_core_tb;

  // DUT Inputs
  reg        PRESETn;
  reg        PCLK;
  reg        PSEL;
  reg        PENABLE;
  reg        PWRITE;
  reg [7:0]  PADDR;
  reg [7:0]  PWDATA;
  reg        send_data;
  reg [7:0]  mosi_data;
  reg        miso;

  // DUT Outputs
  wire [7:0] PRDATA;
  wire       ss;
  wire       tip;
  wire       sclk;
  wire       mosi;
  wire       recieve_data;

  // Instantiate the DUT
  spi_core uut (
    .PRESETn(PRESETn),
    .PCLK(PCLK),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .send_data(send_data),
    .mosi_data(mosi_data),
    .ss(ss),
    .tip(tip),
    .sclk(sclk),
    .mosi(mosi),
    .miso(miso),
    .recieve_data(recieve_data)
  );

  // Clock generation
  always #5 PCLK = ~PCLK;

  initial begin
    // Initialize signals
    PCLK        = 0;
    PRESETn     = 0;
    PSEL        = 0;
    PENABLE     = 0;
    PWRITE      = 0;
    PADDR       = 8'd0;
    PWDATA      = 8'd0;
    send_data   = 0;
    mosi_data   = 8'hA5;  // Example SPI data
    miso        = 0;

    // Apply reset
    #20;
    PRESETn = 1;

    // Wait for reset deassertion
    #20;

    // Write baud rate divisor (example = 50)
    apb_write(8'h04, 8'd50);

    // Small delay
    #50;

    // Start SPI send
    send_data = 1;
    #10;
    send_data = 0;

    // Simulate incoming MISO bits
    repeat (8) begin
      #20;
      miso = $random % 2;
    end

    // Wait and finish
    #200;
    $finish;
  end

  // APB Write Task
  task apb_write(input [7:0] addr, input [7:0] data);
    begin
      @(posedge PCLK);
      PADDR   <= addr;
      PWDATA  <= data;
      PWRITE  <= 1;
      PSEL    <= 1;
      PENABLE <= 0;

      @(posedge PCLK);
      PENABLE <= 1;

      @(posedge PCLK);
      PSEL    <= 0;
      PENABLE <= 0;
      PWRITE  <= 0;
    end
  endtask

endmodule
