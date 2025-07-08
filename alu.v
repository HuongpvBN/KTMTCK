/**
 * Arithmetic Logic Unit (ALU) - Performs arithmetic and logic operations
 *
 * Inputs:
 *   - a: First 32-bit operand
 *   - b: Second 32-bit operand
 *   - alu_op: 4-bit operation selector
 *
 * Outputs:
 *   - result: 32-bit result of the operation
 *   - zero: Flag indicating if result is zero (used for branch instructions)
 */
module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  alu_op,
    output logic [31:0] result,
    output logic zero
);
    always @(*) begin
        case (alu_op)
            4'b0000: result = a & b;     // AND - Bitwise AND
            4'b0001: result = a | b;     // OR - Bitwise OR
            4'b0010: result = a + b;     // ADD - Addition
            4'b0110: result = a - b;     // SUB - Subtraction
            4'b0111: result = ($signed(a) < $signed(b)) ? 1 : 0; // SLT - Set Less Than (signed)
            4'b0100: result = a ^ b;     // XOR - Bitwise XOR
            4'b0101: result = a << b[4:0];  // SLL - Shift Left Logical
            4'b1000: result = a >> b[4:0];  // SRL - Shift Right Logical
            4'b1001: result = $signed(a) >>> b[4:0]; // SRA - Shift Right Arithmetic
            4'b1010: result = (a < b) ? 1 : 0;       // SLTU - Set Less Than Unsigned
            default: result = 32'b0;     // Default case - return 0
        endcase
    end
    
    // Zero flag is set when the result is equal to zero
    assign zero = (result == 32'b0);
endmodule