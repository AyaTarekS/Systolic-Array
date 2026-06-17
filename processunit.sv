module PU #(parameter N = 4,
    parameter WIDTH = 8,
    parameter out_WIDTH = 2*WIDTH + $clog2(N))(
    input logic [WIDTH-1:0] a_in,
    input logic [WIDTH-1:0] b_in,
    input logic rst_n,clk ,
    output logic [WIDTH-1:0] a_out, b_out,
    output logic [out_WIDTH-1:0] acc_out
);
    //internal signals
    reg [out_WIDTH-1:0] acc;
    reg [WIDTH-1:0] a , b;
    
    assign a_out = a;
    assign b_out = b;
    assign acc_out = acc;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            a <= 0;
            b <= 0;
            acc <= 0;
        end
        else begin
            a <= a_in;
            b <= b_in;
            acc <= acc + (a_in * b_in); // to accumlate the data through the arr
        end
    end
    // In PU module

endmodule