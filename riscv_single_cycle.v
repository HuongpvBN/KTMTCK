/**
 * RISC-V Single Cycle Processor - Top-level module
 *
 * This module implements a single-cycle RISC-V processor that executes
 * one instruction per clock cycle. It supports basic RV32I instructions
 * including arithmetic, logic, memory, and branch operations.
 *
 * Inputs:
 *   - clk: Clock signal
 *   - rst_n: Active-low reset signal
 *
 * Outputs:
 *   - PC_out_top: Current program counter value
 *   - Instruction_out_top: Current instruction being executed
 */
module RISCV_Single_Cycle(
    input logic clk,
    input logic rst_n,
    output logic [31:0] PC_out_top,
    output logic [31:0] Instruction_out_top
);

    // ===== Internal Signals =====
    
    // Program Counter signals
    logic [31:0] pc_next;        // Next value of the program counter

    // Instruction decode signals - extracted fields from the instruction
    logic [4:0] rs1;             // Source register 1 address
    logic [4:0] rs2;             // Source register 2 address
    logic [4:0] rd;              // Destination register address
    logic [2:0] funct3;          // 3-bit function code
    logic [6:0] opcode;          // Instruction opcode
    logic [6:0] funct7;          // 7-bit function code for R-type instructions

    // Immediate value generated from instruction
    logic [31:0] imm;            // Immediate value for I, S, B, U, J instruction types

    // Register file signals
    logic [31:0] read_data1;     // Data read from source register 1
    logic [31:0] read_data2;     // Data read from source register 2
    logic [31:0] write_data;     // Data to write to destination register

    // ALU signals
    logic [31:0] alu_in2;        // Second input to ALU (either reg or immediate)
    logic [31:0] alu_result;     // ALU operation result
    logic alu_zero;              // ALU zero flag (result == 0)

    // Data Memory signals
    logic [31:0] mem_read_data;  // Data read from memory

    // Control signals
    logic [1:0] alu_src;         // Selects second ALU input source
    logic [3:0] alu_ctrl;        // ALU operation control
    logic branch;                // Branch instruction indicator
    logic mem_read;              // Memory read enable
    logic mem_write;             // Memory write enable
    logic mem_to_reg;            // Select between ALU result and memory data
    logic reg_write;             // Register write enable
    logic pc_sel;                // PC selection (branch taken or PC+4)

    // ===== Program Counter Update =====
    // Updates the PC on every clock cycle or resets it to 0 when rst_n is low
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            PC_out_top <= 32'b0;  // Reset PC to 0
        else
            PC_out_top <= pc_next; // Update PC to next value
    end

    // ===== Instruction Memory (IMEM) =====
    // Fetches the instruction at the current PC address
    imem IMEM_inst(
        .addr(PC_out_top),         // Current PC value
        .instruction(Instruction_out_top) // Fetched instruction
    );

    // ===== Instruction Decode =====
    // Extract individual fields from the 32-bit instruction
    assign opcode = Instruction_out_top[6:0];   // Bits 0-6: Operation code
    assign rd     = Instruction_out_top[11:7];  // Bits 7-11: Destination register
    assign funct3 = Instruction_out_top[14:12]; // Bits 12-14: Function code
    assign rs1    = Instruction_out_top[19:15]; // Bits 15-19: Source register 1
    assign rs2    = Instruction_out_top[24:20]; // Bits 20-24: Source register 2
    assign funct7 = Instruction_out_top[31:25]; // Bits 25-31: Extended function code

    // ===== Immediate Generation =====
    // Generates appropriate immediate value based on instruction type
    imm_gen imm_gen_inst(
        .inst(Instruction_out_top), // Current instruction
        .imm_out(imm)               // Generated immediate value
    );

    // ===== Register File =====
    // Note: Instance name must be Reg_inst for testbench compatibility
    register_file Reg_inst(
        .clk(clk),                 // Clock signal
        .rst_n(rst_n),             // Reset signal
        .reg_write(reg_write),     // Register write enable
        .rs1(rs1),                 // Source register 1 address
        .rs2(rs2),                 // Source register 2 address
        .rd(rd),                   // Destination register address
        .write_data(write_data),   // Data to write to destination register
        .read_data1(read_data1),   // Data from source register 1
        .read_data2(read_data2)    // Data from source register 2
    );

    // ===== ALU Input Selection =====
    // Select between register value and immediate value for second ALU input
    assign alu_in2 = (alu_src[0]) ? imm : read_data2;

    // ===== Arithmetic Logic Unit (ALU) =====
    // Performs the arithmetic or logic operation specified by alu_ctrl
    alu alu_inst(
        .a(read_data1),            // First operand (rs1 value)
        .b(alu_in2),               // Second operand (rs2 or immediate)
        .alu_op(alu_ctrl),         // ALU operation control
        .result(alu_result),       // Operation result
        .zero(alu_zero)            // Zero flag
    );

    // ===== Data Memory (DMEM) =====
    // Handles load and store operations
    dmem DMEM_inst(
        .clk(clk),                 // Clock signal
        .rst_n(rst_n),             // Reset signal
        .mem_read(mem_read),       // Memory read enable
        .mem_write(mem_write),     // Memory write enable
        .addr(alu_result),         // Memory address (calculated by ALU)
        .write_data(read_data2),   // Data to write to memory (rs2 value)
        .read_data(mem_read_data)  // Data read from memory
    );

    // ===== Write-Back Multiplexer =====
    // Select between ALU result and memory data for register write-back
    assign write_data = (mem_to_reg) ? mem_read_data : alu_result;

    // ===== Control Unit =====
    // Generates control signals based on instruction opcode and function codes
    control_unit ctrl_inst(
        .opcode(opcode),           // Instruction opcode
        .funct3(funct3),           // Function code
        .funct7(funct7),           // Extended function code
        .alu_src(alu_src),         // ALU source selection
        .alu_op(alu_ctrl),         // ALU operation control
        .branch(branch),           // Branch instruction indicator
        .mem_read(mem_read),       // Memory read enable
        .mem_write(mem_write),     // Memory write enable
        .mem_to_reg(mem_to_reg),   // Select between ALU and memory for write-back
        .reg_write(reg_write)      // Register write enable
    );

    // ===== Branch Comparator =====
    // Determines if a branch should be taken based on register values and branch type
    branch_comp comp_inst(
        .a(read_data1),            // First operand (rs1 value)
        .b(read_data2),            // Second operand (rs2 value)
        .branch(branch),           // Branch instruction indicator
        .funct3(funct3),           // Branch type (beq, bne, blt, etc.)
        .br_taken(pc_sel)          // Branch taken signal
    );

    // ===== Next PC Logic =====
    // Determines the next program counter value
    // If branch is taken, PC = current_PC + immediate offset
    // Otherwise, PC = current_PC + 4 (next sequential instruction)
    assign pc_next = (pc_sel) ? PC_out_top + imm : PC_out_top + 4;

endmodule