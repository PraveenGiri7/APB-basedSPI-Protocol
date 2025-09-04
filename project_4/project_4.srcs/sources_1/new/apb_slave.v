module apb_slave (
    input         PCLK,
    input         PRESETn,
    input         PSEL,
    input         PENABLE,
    input         PWRITE,
    input  [7:0]  PADDR,
    input  [31:0] PWDATA,
    output [31:0] PRDATA,
    input         tip,
    output reg    send_data,
    output reg [7:0] tx_data,
    output reg [11:0] BaudRateDivisor,
    output reg        mstr,
    output reg [1:0]  spi_mode,
    output reg        spiswai,
    output reg        spe
);

reg [31:0] reg_data [0:7];  // 8 32-bit registers

assign PRDATA = (PSEL && !PWRITE && PENABLE) ? reg_data[PADDR[4:2]] : 32'd0;

always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        tx_data         <= 8'h00;
        BaudRateDivisor <= 12'd4;
        mstr            <= 1'b1;
        spi_mode        <= 2'b00;
        spiswai         <= 1'b0;
        spe             <= 1'b1;
        send_data       <= 1'b0;
    end
    else if (PSEL && PENABLE && PWRITE) begin
        reg_data[PADDR[4:2]] <= PWDATA;

        case (PADDR[4:2])
            3'd0: tx_data         <= PWDATA[7:0];     // Data to transmit
            3'd1: BaudRateDivisor <= PWDATA[11:0];    // Baud divisor
            3'd2: mstr            <= PWDATA[0];
            3'd3: spi_mode        <= PWDATA[1:0];
            3'd4: spiswai         <= PWDATA[0];
            3'd5: spe             <= PWDATA[0];
            3'd6: send_data       <= PWDATA[0];
            default: ;
        endcase
    end
    else if (tip == 0) begin
        send_data <= 1'b0;  // Clear send_data once transfer finishes
    end
end

endmodule
