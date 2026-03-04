/*
To run:
iverilog -o fpadd_tb.vvp tb/fpadd_tb.v src/*.v src/utils/*.v src/datapath/*.v
vvp fpadd_tb.vvp
*/
module fpadd_tb;
    parameter lm = 23, le = 8;
    reg [lm+le:0] a;
    reg [lm+le:0] b;
    reg op;
    wire [lm+le:0] c;
    fpadd #(
        .le(le),
        .lm(lm)
    ) uut (
        .a(a),
        .b(b),
        .op(op),
        .c(c)
    );
    initial begin 
        
    end
endmodule