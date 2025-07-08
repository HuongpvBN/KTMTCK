/**
 * Data Memory (DMEM) - Stores data for load and store instructions
 *
 * Inputs:
 *   - clk: Clock signal
 *   - rst_n: Active-low reset signal
 *   - mem_read: Enable signal for reading from memory
 *   - mem_write: Enable signal for writing to memory
 *   - addr: 32-bit memory address
 *   - write_data: 32-bit data to write to memory
 *
 * Output:
 *   - read_data: 32-bit data read from memory
 */
module dmem (
    input logic clk,
    input logic rst_n,
    input logic mem_read,
    input logic mem_write,
    input logic [31:0] addr,
    input logic [31:0] write_data,
    output logic [31:0] read_data
);
    // Memory array: 256 words of 32 bits each
    logic [31:0] memory [0:255];

    // Read operation (combinational)
    // Only return data when mem_read is asserted
    assign read_data = (mem_read) ? memory[addr[9:2]] : 32'b0;

    // Write operation (sequential)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all memory locations to 0
            for (int i = 0; i < 256; i = i + 1)
                memory[i] <= 32'b0;
        end else if (mem_write) begin
            // Write data to memory when mem_write is asserted
            // Address is word-aligned (divided by 4)
            memory[addr[9:2]] <= write_data;
        end
    end

    // Initialize memory from hex file if available
    initial begin
        if ($fopen("./mem/dmem_init2.hex", "r"))
            $readmemh("./mem/dmem_init2.hex", memory);
        else if ($fopen("./mem/dmem_init.hex", "r"))
            $readmemh("./mem/dmem_init.hex", memory);
    end
endmodule