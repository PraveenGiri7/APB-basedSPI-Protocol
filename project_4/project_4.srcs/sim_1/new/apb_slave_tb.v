module apb_slave_tb;

reg         PCLK, PRESETn;
reg         PSEL, PENABLE, PWRITE;
reg  [7:0]  PADDR;
reg  [31:0] PWDATA;
wire [31:0] PRDATA;
reg         tip;
wire        send_data;
wire [7:0]  tx_data;
wire [11:0] BaudRateDivisor;
wire        mstr;
wire [1:0]  spi_mode;
wire        spiswai, spe;

apb_slave uut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .tip(tip),
    .send_data(send_data),
    .tx_data(tx_data),
    .BaudRateDivisor(BaudRateDivisor),
    .mstr(mstr),
    .spi_mode(spi_mode),
    .spiswai(spiswai),
    .spe(spe)
);

initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK;  // 100MHz
end

initial begin
    PRESETn = 0;
    PSEL = 0; PENABLE = 0; PWRITE = 0;
    PADDR = 0; PWDATA = 0;
    tip = 0;
    #20;
    PRESETn = 1;

    // Write tx_data = 0xA5
    #10;
    apb_write(8'h00, 32'h000000A5);

    // Write BaudRateDivisor = 16
    #10;
    apb_write(8'h04, 32'd16);

    // Set mstr = 1
    #10;
    apb_write(8'h08, 32'd1);

    // Set spi_mode = 2'b10
    #10;
    apb_write(8'h0C, 32'd2);

    // Set spiswai = 1
    #10;
    apb_write(8'h10, 32'd1);

    // Set spe = 1
    #10;
    apb_write(8'h14, 32'd1);

    // Trigger send_data = 1
    #10;
    apb_write(8'h18, 32'd1);

    // Simulate SPI transfer complete by clearing tip
    #50;
    tip = 0;

    #100;
    $stop;
end

task apb_write(input [7:0] addr, input [31:0] data);
begin
    @(posedge PCLK);
    PADDR = addr;
    PWDATA = data;
    PWRITE = 1;
    PSEL = 1;
    PENABLE = 0;
    @(posedge PCLK);
    PENABLE = 1;
    @(posedge PCLK);
    PSEL = 0;
    PENABLE = 0;
    PWRITE = 0;
end
endtask

endmodule
