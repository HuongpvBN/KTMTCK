module register_file (
    input logic clk,
    input logic rst_n,
    input logic reg_write,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [31:0] write_data,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);
    logic [31:0] registers [0:31];

    assign read_data1 = (rs1 != 0) ? registers[rs1] : 32'b0;
    assign read_data2 = (rs2 != 0) ? registers[rs2] : 32'b0;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end else if (reg_write && rd != 0) begin
            registers[rd] <= write_data;
        end
    end
endmodule