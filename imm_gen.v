/**
 * Immediate Generator - Extracts and sign-extends immediate values from instructions
 *
 * Inputs:
 *   - inst: 32-bit instruction
 *
 * Output:
 *   - imm_out: 32-bit sign-extended immediate value
 */
module imm_gen (
    input  logic [31:0] inst,
    output logic [31:0] imm_out
);
    // Extract opcode from instruction
    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            7'b0000011, // I-type instructions (load)
            7'b0010011, // I-type arithmetic
            7'b1100111: // jalr
                // I-type immediate: sign-extend [31:20]
                imm_out = {{20{inst[31]}}, inst[31:20]};

            7'b0100011: // S-type instructions (store)
                // S-type immediate: sign-extend [31:25,11:7]
                imm_out = {{20{inst[31]}}, inst[31:25], inst[11:7]};

            7'b1100011: // B-type instructions (branch)
                // B-type immediate: sign-extend [31,7,30:25,11:8,0]
                imm_out = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};

            7'b0010111, // auipc - Add Upper Immediate to PC
            7'b0110111: // lui - Load Upper Immediate
                // U-type immediate: [31:12] + 12 zeros
                imm_out = {inst[31:12], 12'b0};

            7'b1101111: // jal - Jump and Link
                // J-type immediate: sign-extend [31,19:12,20,30:21,0]
                imm_out = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

            default:
                imm_out = 32'b0; // Default value when opcode doesn't match
        endcase
    end
endmodule