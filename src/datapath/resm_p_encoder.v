module resm_p_encoder
#(
    parameter le = 8, lm = 23
)(
    input [lm+3:0] mres,
    output isZero,
    output [le-1:0] shamt
);
    assign isZero = ~|(mres); // reduction NOR of all bits
    wire [lm+3:0] f [0:le-1]; // le-1 priority functions, each function having lm+4 outputs corresponding to each priority level 
    genvar i;
    genvar j;
    generate
        for (i = 0;i < le; i = i + 1) begin : gen_priority
            for(j = 0;j < lm+4;j = j + 1)begin
                wire temp;
                assign temp = j >> i;
                assign f[i][j] = temp; // not real right shifting, precomputing priority functions
            end
            p_encoder #(.N(lm+4)) pe (
                .in(mres),
                .f(f[i]),
                .out(shamt[i])
            );
        end
    endgenerate
endmodule