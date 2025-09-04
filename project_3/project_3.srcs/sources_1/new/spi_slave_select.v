module spi_slave_select (
    input              PRESETn,
    input       [1:0]  spi_mode,
    input              mstr,
    input              spiswai,
    input              PCLK,
    input              send_data,
    input      [11:0]  BaudRateDivisor,
    output reg         ss,
    output reg         recieve_data,
    output             tip
);

reg [15:0] count;
wire [15:0] target;
reg        rcv;

assign target = BaudRateDivisor * 5'd16;
assign tip = ~ss;

always @(negedge PRESETn or posedge PCLK) begin
    if (!PRESETn) begin
        count         <= 16'hFFFF;
        ss            <= 1'b1;
        rcv           <= 1'b0;
        recieve_data  <= 1'b0;
    end
    else if (mstr && (spi_mode == 2'b00 || (spi_mode == 2'b01 && ~spiswai))) begin
        if (send_data) begin
            ss    <= 1'b0;
            count <= 16'h0;
        end
        else if (count <= (target - 1'b1)) begin
            ss    <= 1'b0;
            count <= count + 1'b1;
        end
        else begin
            ss    <= 1'b1;
            rcv   <= 1'b1;
        end
    end
    else begin
        ss   <= 1'b1;
        rcv  <= 1'b0;
    end

    if (rcv) begin
        recieve_data <= 1'b1;
        rcv <= 1'b0;
    end
    else begin
        recieve_data <= 1'b0;
    end
end

endmodule
