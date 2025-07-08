/**
 * Branch Comparator - Determines if branch should be taken based on comparison results
 *
 * Inputs:
 *   - a: First 32-bit operand (rs1 value)
 *   - b: Second 32-bit operand (rs2 value)
 *   - branch: Signal indicating if this is a branch instruction
 *   - funct3: 3-bit function code from instruction to determine branch type
 *
 * Output:
 *   - br_taken: Signal indicating if branch should be taken
 */
module branch_comp (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic branch,
    input  logic [2:0] funct3,
    output logic br_taken
);
    always @(*) begin
        br_taken = 1'b0; // Default: branch not taken
        if (branch) begin
            case (funct3)
                3'b000: br_taken = (a == b);                   // beq - Branch if Equal
                3'b001: br_taken = (a != b);                   // bne - Branch if Not Equal
                3'b100: br_taken = ($signed(a) < $signed(b));  // blt - Branch if Less Than (signed)
                3'b101: br_taken = ($signed(a) >= $signed(b)); // bge - Branch if Greater/Equal (signed)
                3'b110: br_taken = (a < b);                    // bltu - Branch if Less Than (unsigned)
                3'b111: br_taken = (a >= b);                   // bgeu - Branch if Greater/Equal (unsigned)
                default: br_taken = 1'b0;                      // Default: branch not taken
            endcase
        end
    end
endmodule