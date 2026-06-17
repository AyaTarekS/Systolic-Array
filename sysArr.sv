module sysArr #(parameter N = 2,
    parameter WIDTH = 8,
    parameter out_WIDTH = 2*WIDTH + $clog2(N))(sys_arr_if.DUT arrif);


    //internal buses
    //no need for the initialization (we handle this inside the generate block)
    logic [WIDTH-1:0] a_bus [N][N+1]; 
    logic [WIDTH-1:0] b_bus [N+1][N];
    logic [out_WIDTH-1:0] c_bus[N][N];
    logic [$clog2(2*N)-1:0] inj_count = 0;
    logic pu_rst_n;
    /////////////////injection contorl/////////////////
    //injection counter
    always_ff @(posedge arrif.clk) begin
        if(!arrif.reset)begin //make sure the injection reset is synchronus with the clk
            inj_count <= 0;
        end
        else begin
            if(inj_count < 2*N-1) // it finishes the injection at 2N-1 7 times from 0 to 6 
                inj_count <= inj_count + 1;
        end
    end
    //injection shifters
    genvar i;
    generate
            for(i=0;i<N;i++)begin
                always_ff @(posedge arrif.clk or negedge arrif.reset)begin
                    if(!arrif.reset)
                        a_bus[i][0]<=0;
                else begin 
                    if(inj_count >= i && inj_count < i + N) // to limit the injection count and to access the right column
                        a_bus[i][0]<=arrif.a[i][inj_count-i]; //assigning the data from the col 0 always
                    else
                        a_bus[i][0]<=0; // to avoid the data from the previous injection
                end

            end
        end
    endgenerate
    genvar j;
    generate
        for(j=0;j<N;j++)begin
            always_ff @(posedge arrif.clk or negedge arrif.reset)begin
                if(!arrif.reset)
                    b_bus[0][j] <= 0;
                else begin
                    if(inj_count >= j && inj_count < j + N) //  to have a cycle of N each time 
                        b_bus[0][j] <= arrif.b[inj_count-j][j]; //assigning the data from the row 0 always
                    else
                        b_bus[0][j] <= 0; // to avoid the data from the previous injection
                end

            end
        end
    endgenerate

    genvar row, col; // no need for the data type
    generate
        for(row=0;row<N;row++)begin
            for(col=0;col<N;col++)begin
                PU #(.WIDTH(WIDTH),.N(N))pu_inst(
                .a_in(a_bus[row][col]),
                .b_in(b_bus[row][col]),
                .rst_n(arrif.reset),
                .clk(arrif.clk),
                .a_out(a_bus[row][col+1]), // to assign it for the next PU
                .b_out(b_bus[row+1][col]),
                .acc_out(c_bus[row][col]));
            end
        end
    endgenerate
genvar r, s;
generate
    for (r = 0; r < N; r++) begin
        for (s = 0; s < N; s++) begin
            assign arrif.c[r][s] = c_bus[r][s];
        end
    end
endgenerate


endmodule