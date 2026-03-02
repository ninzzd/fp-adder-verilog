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
    wire [le-1:0] a0e;
    wire [lm:0] b0m;
    wire [lm+3:0] b0m_shifted;
    wire a0s;
    wire b0s;

    wire ageb;
    wire [le-1:0] b0_shamt;

    wire maddop;
    wire [lm+3:0] maddres;
    wire [lm+3:0] maddres_2s; // absolute value of maddres
    wire [lm+3:0] maddres_ls;
    wire [lm+3:0] maddres_rs;
    wire [lm+3:0] resm_bround;
    wire maddres_isZero;
    wire [le-1:0] maddres_lshamt;
    wire [le-1:0] a0e_lshamt_min;
    wire maddcout;
    wire flag;
    

    assign na = ~|(a[le+lm-1:lm]); // Reduction NOR
    assign nb = ~|(b[le+lm-1:lm]); 

    assign am = {na, a[lm-1:0]};
    assign bm = {nb, b[lm-1:0]};

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
        .m_shamt(b0_shamt),
        .a0e(a0e)
    );

    lm_r_shifter #(
        .le(le),
        .lm(lm)
    ) 
    b0_shifter (
        .in(b0m),
        .shamt(b0_shamt),
        .out(b0m_shifted)
    );

    add #(
        .W(lm+4)
    ) mantissa_adder (
        .a({a0m,3'b000}),
        .b({(lm+4){maddop}} ^ b0m_shifted),
        .cin(maddop),
        .s(maddres),
        .cout(maddcout)
    );

    assign flag = ~maddcout&maddop; // if the result is negative, we need to take 2's complement
    
    inc #(
        .W(lm+4)
    ) mantissa_inc (
        .in({(lm+4){flag}} ^ maddres),
        .out(maddres_2s),
        .cin(flag)
    );

    resm_p_encoder #(
        .le(le),
        .lm(lm)
    ) resm_pe (
        .resm(maddres_2s),
        .isZero(maddres_isZero),
        .shamt(maddres_lshamt)
    );

    min #(
        .W(le)
    ) a0e_lshamt_cap (
        .a(a0e),
        .b(maddres_lshamt),
        .out(a0e_lshamt_min)
    );

    add #(
        .W(le)
    ) rese_sub (
        .a(a0e),
        .b(~a0e_lshamt_min),
        .cin(1'b1),
        .s(c[lm+le-1:lm]),
        .cout()
    );

    resm_l_shifter #(
        .le(le),
        .lm(lm)
    ) resm_ls (
        .in(maddres_2s),
        .shamt(a0e_lshamt_min),
        .out(maddres_ls)
    );
    assign c[lm+le] = a0s ^ flag; // sign of the result

    mux #(
        .W(lm+4),
        .N(2)
    ) add_resm_mux (
        .in({{maddcout,maddres_2s[lm+3:1]},maddres_2s}),
        .sel(maddcout),
        .out(maddres_rs)
    );

    mux #(
        .W(lm+4),
        .N(2)
    ) add_sub_resm_mux (
        .in({maddres_ls,maddres_rs}),
        .sel(maddop),
        .out(resm_bround) // result mantissa before rounding
    );

endmodule