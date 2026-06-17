module sysArr_tb(sys_arr_if.TEST arrif);
    parameter int N = 2;
    parameter int WIDTH = 8;
    parameter out_WIDTH = 2*WIDTH + $clog2(N);
    int count = 0;

    initial begin 
        arrif.reset = 0;
        arrif.a = '{default:0};
        arrif.b = '{default:0};
        repeat(2) @(posedge arrif.clk);
        arrif.reset = 1; // Release reset with for the injection to start with driving the data
        arrif.a = '{ '{1, 2},
                        '{3, 4}};

        arrif.b = '{ '{10, 9},
                    '{5, 5} };
        while (count < 2*N + 2) begin
            @(negedge arrif.clk);
            count += 1;
            $display("checking the count :%0d" ,count);
            foreach (arrif.c[i,j]) begin
            $display("C[%0d][%0d] = %0d", i, j, arrif.c[i][j]);
            end
            
        end
        // Display result
        $display("===== Result C = A × B =====");
        foreach(arrif.a[i,j])begin
            $display("a[%0d][%0d] = %0d",i , j , arrif.a[i][j]);
        end
        foreach(arrif.b[i,j])begin
            $display("b[%0d][%0d] = %0d",i , j , arrif.b[i][j]);
        end
        foreach (arrif.c[i,j]) begin
            $display("C[%0d][%0d] = %0d", i, j, arrif.c[i][j]);
        end
        $finish();
    end
endmodule