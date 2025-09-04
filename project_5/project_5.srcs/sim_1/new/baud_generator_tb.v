module baud_generator_tb;

reg PCLK, PRESETn, enable;
reg [11:0] BaudRateDivisor;
wire baud_tick;

baud_generator dut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .enable(enable),
    .BaudRateDivisor(BaudRateDivisor),
    .baud_tick(baud_tick)
);

initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK;  // 100MHz clock
end

initial begin
    PRESETn = 0;
    enable = 0;
    BaudRateDivisor = 12'd10;
    #20;
    PRESETn = 1;
    enable = 1;
    #1000;
    $stop;
end

endmodule
