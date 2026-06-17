module top;
    parameter N = 2;
    parameter WIDTH = 8;
    parameter out_WIDTH = 2*WIDTH + $clog2(N);
    logic clk;
    //clk generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    //instances
    sys_arr_if #(.N(N),.WIDTH(WIDTH),.out_WIDTH(out_WIDTH))arrif(.clk(clk));
    sysArr #(.N(N),.WIDTH(WIDTH),.out_WIDTH(out_WIDTH))dut(arrif);
    sysArr_tb #(.N(N),.WIDTH(WIDTH),.out_WIDTH(out_WIDTH))tb(arrif);

endmodule