/*
To run: 
iverilog -o minmax_tb.vvp tb/utils_tb/minmax_tb.v src/utils/*.v
vvp minmax_tb.vvp
*/
`timescale 1ns / 1ps
module minmax_tb;
    reg [7:0] a;
    reg [7:0] b;
    reg mode;
    wire [7:0] out;

    minmax #(
        .W(8)    
    )uut(
        .a(a),
        .b(b),
        .mode(mode),
        .out(out)
    );

    initial
    begin
        $dumpfile("minmax_tb.vcd");
        $dumpvars(0,minmax_tb);
        a <= 10;
        b <= 20;
        mode <= 0; // min
        #15.000
        a <= 10;
        b <= 20;
        mode <= 1; // max
        #15.000
        a <= 5;
        b <= 3;
        mode <= 0; // min
        #15.000
        a <= 5;
        b <= 3;
        mode <= 1; // max
        #15.000
        $finish;
    end
endmodule