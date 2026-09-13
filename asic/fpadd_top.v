// To compile (from the repo root):
//   iverilog -s fpadd_top -o fpadd_top.vvp asic/fpadd_top.v rtl/fpadd.v rtl/utils/*.v rtl/datapath/*.v
// Override the format with -P, e.g. -Pfpadd_top.lm=7 -Pfpadd_top.le=8 (bf16).
// Keep this header in line comments: a file glob inside a block comment reads
// as a nested comment opener, which iverilog 12.0-2build2 rejects as an error.
module #(
    parameter lm = 23,
    parameter le = 8
) fpadd_top
(
    input clk,
    input rst_p,
    input [lm+le:0] a_in;
    input [lm+le:0] b_in;
    input op_in,

    output reg [lm+le:0] c_out;
);

reg [lm+le:0] a, b;
rep op;
wire [lm+le:0] c;

fpadd #(
    .lm(lm),
    .le(le)
) uut(
    .a(a),
    .b(b),
    .op(op),
    .c(c)
);

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        a <= {(lm+le+1){1'b0}};
        b <= {(lm+le+1){1'b0}};
        op <= 1'b0;
        c_out <= {(lm+le+1){1'b0}};
    end
    else
    begin
        a <= a_in;
        b <= b_in;
        op <= op_in;
        c_out <= c;
    end
end

endmodule