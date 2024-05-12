module clock_divider(input clk, output reg clkOut);
reg [25:0] count;
always @(negedge clk)
begin
    count <= count + 1;
    if (count == 50000000)
    begin
        clkOut <= ~clkOut;
        count <=0;
    end
end
endmodule

