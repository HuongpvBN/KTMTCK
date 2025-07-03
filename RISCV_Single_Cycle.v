module RISCV_Single_Cycle(
    input logic clk,
    input logic rst_n,
    output logic [31:0] PC_out_top,
    output logic [31:0] Instruction_out_top
);

    // Program Counter
    logic [31:0] pc_next;

    // Wires for instruction fields
    logic [4:0] rs1, rs2, rd;
    logic [2:0] funct3;
    logic [6:0] opcode, funct7;

    // Immediate value
    logic [31:0] imm;

    // Register file wires
    logic [31:0] read_data1, read_data2, write_data;

    // ALU
    logic [31:0] alu_in2, alu_result;
    logic alu_zero;

    // Data Memory
    logic [31:0] mem_read_data;

    // Control signals
    logic [1:0] alu_src;
    logic [3:0] alu_ctrl;
    logic branch, mem_read, mem_write, mem_to_reg;
    logic reg_write, pc_sel;

    // PC update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            PC_out_top <= 32'b0;
        else
            PC_out_top <= pc_next;
    end

    // Instruction Memory (IMEM)
    imem IMEM_inst(
        .addr(PC_out_top),
        .instruction(Instruction_out_top)
    );

    // Instruction field decoding
    assign opcode = Instruction_out_top[6:0];
    assign rd     = Instruction_out_top[11:7];
    assign funct3 = Instruction_out_top[14:12];
    assign rs1    = Instruction_out_top[19:15];
    assign rs2    = Instruction_out_top[24:20];
    assign funct7 = Instruction_out_top[31:25];

    // Immediate generator
    imm_gen imm_gen_inst(
        .inst(Instruction_out_top),
        .imm_out(imm)
    );

    // Register File (instance name must be Reg_inst for tb)
    register_file Reg_inst(
        .clk(clk),
        .rst_n(rst_n),
        .reg_write(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // ALU input selection
    assign alu_in2 = (alu_src[0]) ? imm : read_data2;

    // ALU
    alu alu_inst(
        .a(read_data1),
        .b(alu_in2),
        .alu_op(alu_ctrl),
        .result(alu_result),
        .zero(alu_zero)
    );

    // Data Memory (DMEM)
    dmem DMEM_inst(
        .clk(clk),
        .rst_n(rst_n),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(alu_result),
        .write_data(read_data2),
        .read_data(mem_read_data)
    );

    // Write-back mux
    assign write_data = (mem_to_reg) ? mem_read_data : alu_result;

    // Control unit
    control_unit ctrl_inst(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_src(alu_src),
        .alu_op(alu_ctrl),
        .branch(branch),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write)
    );

    // Branch comparator
    branch_comp comp_inst(
        .a(read_data1),
        .b(read_data2),
        .branch(branch),
        .funct3(funct3),
        .br_taken(pc_sel)
    );

    // Next PC logic
    assign pc_next = (pc_sel) ? PC_out_top + imm : PC_out_top + 4;

endmodule