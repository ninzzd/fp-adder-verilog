/*
To run:
iverilog -o fpadd_tb.vvp tb/fpadd_tb.v src/*.v src/utils/*.v src/datapath/*.v
vvp fpadd_tb.vvp
gtkwave fpadd_tb.vcd
*/
module fpadd_tb;
    parameter lm = 23, le = 8;
    integer file;
    integer n;
    integer nflag;
    integer vecflag;
    integer i;
    reg [lm+le:0] a;
    reg [lm+le:0] b;
    reg op;
    reg [lm+le:0] exp_res;
    wire [lm+le:0] c;
    wire err;

    fpadd #(
        .le(le),
        .lm(lm)
    ) uut (
        .a(a),
        .b(b),
        .op(op),
        .c(c)
    );

    assign err = c != exp_res;
    
    initial begin 
        $dumpfile("fpadd_tb.vcd");
        $dumpvars(0,fpadd_tb);
        file = $fopen("./test_vectors.hex","r");
        nflag = $fscanf(file,"%d\n",n);
        if(nflag == 1)
        begin
            for(i = 0;i < n;i = i+1)
            begin: test_vector_loop
                vecflag = $fscanf(file,"%h %h %1b %h",a,b,op,exp_res);
                #10;
            end
        end
    end
endmodule