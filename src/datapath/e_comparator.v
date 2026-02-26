module e_comparator
#( parameter le = 8)
(
    input [le-1:0] a,
    input [le-1:0] b,
    output a_ge_b,
    output [le-1:0] m_shamt
);
    add #(.W(le)) adder (
        .a(a),
        .b(~b),
        .cin(1'b1),
        .s(),
        .cout(a_ge_b)
    );
endmodule
