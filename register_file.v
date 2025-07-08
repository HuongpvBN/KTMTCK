/**
 * Register File - Contains the 32 general-purpose registers of the RISC-V processor
 *
 * Inputs:
 *   - clk: Clock signal
 *   - rst_n: Active-low reset signal
 *   - reg_write: Enable signal for writing to a register
 *   - rs1: 5-bit address for first source register
 *   - rs2: 5-bit address for second source register
 *   - rd: 5-bit address for destination register
 *   - write_data: 32-bit data to write to the register
 *
 * Outputs:
 *   - read_data1: 32-bit data from first source register (rs1)
 *   - read_data2: 32-bit data from second source register (rs2)
 */
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
    // Register array: 32 registers of 32 bits each
    logic [31:0] registers [0:31];

    // Read operations (combinational)
    // Register 0 is hardwired to 0 in RISC-V
    assign read_data1 = (rs1 != 0) ? registers[rs1] : 32'b0;
    assign read_data2 = (rs2 != 0) ? registers[rs2] : 32'b0;

    // Write operation (sequential)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers to 0
            for (int i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end else if (reg_write && rd != 0) begin
            // Write data to register rd when reg_write is asserted
            // Register 0 is read-only (always 0)
            registers[rd] <= write_data;
        end
    end
endmodule