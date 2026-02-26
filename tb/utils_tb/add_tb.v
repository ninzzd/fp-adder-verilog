/*
To run:
iverilog -o add_tb.vvp tb/utils_tb/add_tb.v src/utils/add.v
vvp add_tb.vvp
*/
`timescale 1ns / 1ps
module add_tb;
    reg [7:0] a;
    reg [7:0] b;
    reg cin;
    wire [7:0] s;
    wire cout;

    add uut(
        .a(a),
        .b(b),
        .cin(cin),
        .s(s),
        .cout(cout)
    );

    initial
    begin
        $dumpfile("add_tb.vcd");
        $dumpvars(0,add_tb);
        a <= 34;
        b <= 27;
        cin <= 0;
        #15.000
        a <= 30;
        b <= 30;
        cin <= 1;
        #15.000
        a <= 0;
        b <= 128;
        cin <= 0;
        #15.000
        $finish;
    end
endmodule