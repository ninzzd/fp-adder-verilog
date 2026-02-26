// Floating-Point Adder/Subtractor
module fpadd #(
    parameter le = 8, lm = 23
)(
    input [le+lm:0] a,
    input [le+lm:0] b,
    input op,
    output [le+lm:0] c
);
    wire na; // is 'a' normalized
    wire nb; // is 'b' normalized

    wire [lm:0] am; // complete mantissa of a with leading bit after decimal point
    wire [lm:0] bm; // complete mantissa of b with leading bit after decimal point

    wire [lm:0] a0m;
    wire [lm:0] b0m;
    wire [lm+3:0] exta0m; // extended mantissa to hold rounding bits
    wire a0s;
    wire b0s;

    wire ageb;
    wire [le-1:0] b0_shamt;

    wire maddop;
    

    assign na = ~|(a[le+lm-1:lm]); // Reduction NOR
    assign nb = ~|(b[le+lm-1:lm]); 

    assign am = {na, a[lm-1:0]};
    assign bm = {nb, b[lm-1:0]};

    assign exta0m = {a0m, 3'b000};
    assign maddop = a[lm+le+1] ^ b[lm+le+1] ^ op;

    mux #(.W(lm+1), .N(2)) a0m_mux (
        .in({am,bm}),
        .sel(ageb),
        .out(a0m)
    );

    mux #(.W(lm+1), .N(2)) b0m_mux (
        .in({bm,am}),
        .sel(ageb),
        .out(b0m)
    );

    mux #(.W(1), .N(2)) a0s_mux (
        .in({a[le+lm],b[le+lm]}),
        .sel(ageb),
        .out(a0s)
    );
    // b0s might be redundant
    mux #(.W(1), .N(2)) b0s_mux (
        .in({b[le+lm],a[le+lm]}),
        .sel(ageb),
        .out(b0s)
    );

    e_comparator #(.le(le)) exp_comp (
        .a(a[le+lm-1:lm]),
        .b(b[le+lm-1:lm]),
        .a_ge_b(ageb),
        .m_shamt(b0_shamt)
    );
endmodule