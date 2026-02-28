module priority_encoder
#(
    parameter lm = 23, le = 8
)
(
    input [lm+3:0] in,
    output reg [le-1:0] out
);
    
endmodule