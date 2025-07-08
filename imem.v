/**
 * Instruction Memory (IMEM) - Stores program instructions
 *
 * Inputs:
 *   - addr: 32-bit address to fetch instruction from
 *
 * Output:
 *   - instruction: 32-bit instruction fetched from memory
 */
module imem (
    input  [31:0] addr,
    output [31:0] instruction
);
    // Memory array: 256 words of 32 bits each
    reg [31:0] memory [0:255];
    
    // Read instruction from memory at the given address
    // If address is out of range, return a beq x0, x0, 0 instruction (halt)
    assign instruction = (addr[11:2] < 128) ? memory[addr[11:2]] : 32'h00000063; // halt = beq x0, x0, 0

    // Initialize memory from hex file if available
    initial begin
        if ($fopen("./mem/imem2.hex", "r"))
            $readmemh("./mem/imem2.hex", memory);
        else if ($fopen("./mem/imem.hex", "r"))
            $readmemh("./mem/imem.hex", memory);
    end
endmodule