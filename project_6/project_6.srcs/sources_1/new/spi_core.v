module spi_core (
    input        PRESETn,
    input        PCLK,
    input        PSEL,
    input        PENABLE,
    input        PWRITE,
    input [7:0]  PADDR,
    input [7:0]  PWDATA,
    output reg [7:0] PRDATA,
    input        send_data,
    input [7:0]  mosi_data,
    output       ss,
    output       tip,
    output       sclk,
    output reg   mosi,
    input        miso,
    output       recieve_data
);

    // Internal wires
    wire [11:0] baud_div;
    wire        clk_en;

    reg [7:0] shift_reg;
    reg [3:0] bit_cnt;
    reg       sending;

    // Instantiate APB Slave
    wire [7:0] reg_out;
    wire       wr_en;
    apb_slave u_apb_slave (
        .PRESETn   (PRESETn),
        .PCLK      (PCLK),
        .PSEL      (PSEL),
        .PENABLE   (PENABLE),
        .PWRITE    (PWRITE),
        .PADDR     (PADDR),
        .PWDATA    (PWDATA),
        .PRDATA    (reg_out),
        .wr_en     (wr_en)
    );

    // Latch read data
    always @(posedge PCLK) begin
        if (!PRESETn)
            PRDATA <= 8'd0;
        else
            PRDATA <= reg_out;
    end

    // Get baud divisor from APB register (hardcoded to 0x04)
    assign baud_div = {4'd0, reg_out}; // Assuming reg_out gives lower 8 bits of divisor

    // Instantiate Baud Generator
    baud_generator u_baud_gen (
        .PCLK     (PCLK),
        .PRESETn  (PRESETn),
        .enable   (1'b1),
        .divisor  (baud_div),
        .clk_out  (clk_en)
    );

    // Instantiate Slave Select Control
    spi_slave_select u_slave_sel (
        .PRESETn        (PRESETn),
        .spi_mode       (2'b00),
        .mstr           (1'b1),
        .spiswai        (1'b0),
        .PCLK           (PCLK),
        .send_data      (send_data),
        .BaudRateDivisor(baud_div),
        .ss             (ss),
        .recieve_data   (recieve_data),
        .tip            (tip)
    );

    // Clock Generation
    assign sclk = clk_en & sending;

    // SPI State Machine (simple send)
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            bit_cnt   <= 4'd0;
            sending   <= 1'b0;
            shift_reg <= 8'd0;
            mosi      <= 1'b0;
        end
        else if (send_data && !sending) begin
            shift_reg <= mosi_data;
            sending   <= 1'b1;
            bit_cnt   <= 4'd8;
        end
        else if (sending && clk_en) begin
            mosi      <= shift_reg[7];
            shift_reg <= {shift_reg[6:0], miso};
            bit_cnt   <= bit_cnt - 1;
            if (bit_cnt == 4'd1)
                sending <= 1'b0;
        end
    end

endmodule
