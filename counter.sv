module counter #(parameter WIDTH = 4)(
    input logic clk,
    input logic rst_n,
    output logic [WIDTH-1:0] count
);
localparam MAX_COUNT = (1 << WIDTH) - 1;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else begin
            count <= (count == MAX_COUNT) ? '0 : (count + 1);
        end
    end
endmodule