interface sys_arr_if #(parameter WIDTH = 8 ,parameter N = 2, parameter out_WIDTH = 2*WIDTH + $clog2(N))(input logic clk);
    logic reset;
    logic [WIDTH-1:0]a [N][N];
    logic [WIDTH-1:0]b [N][N];
    logic [out_WIDTH-1:0]c [N][N];
    clocking cb @(posedge clk);
        output reset , a, b;
        input c;
    endclocking
    modport DUT (input a , b , reset, clk, output c);
    modport TEST(input c, clk, output a , b, reset);
    modport MON (input a , b , c , reset, clk );
endinterface