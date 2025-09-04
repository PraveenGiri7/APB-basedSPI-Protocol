module baud_generator (
    input            PCLK,
    input            PRESETn,
    input            enable,
    input      [11:0] BaudRateDivisor,
    output reg       baud_tick
);

reg [15:0] counter;

always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        counter   <= 16'd0;
        baud_tick <= 1'b0;
    end
    else if (enable) begin
        if (counter >= ((BaudRateDivisor << 4) - 1)) begin
            counter   <= 16'd0;
            baud_tick <= 1'b1;
        end
        else begin
            counter   <= counter + 1;
            baud_tick <= 1'b0;
        end
    end
    else begin
        baud_tick <= 1'b0;
        counter   <= 0;
    end
end

endmodule
