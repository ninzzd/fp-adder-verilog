module m_shifter
#(
    parameter lm = 23, le = 8
)
(
    input [lm:0] in,
    input [le-1:0] shamt,
    output [lm+3:0] out
);
    wire [le-1:0] s_mask;
endmodule