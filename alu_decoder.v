/**
 * ALU Decoder - Generates control signals for the ALU based on instruction type
 *
 * Inputs:
 *   - alu_op: 2-bit ALU operation type from the main control unit
 *   - funct3: 3-bit function code from the instruction
 *   - funct7_b5: The 5th bit of the funct7 field (for R-type instructions)
 * 
 * Output:
 *   - alu_control: 4-bit control signal for the ALU
 */
module alu_decoder(
    input  [1:0] alu_op,
    input  [2:0] funct3,
    input        funct7_b5,
    output logic [3:0] alu_control
);
    always @(*) begin
        alu_control = 4'b0010; // Default to ADD (for load/store)
        case (alu_op)
            2'b00: alu_control = 4'b0010; // ADD operation
            2'b01: alu_control = 4'b0110; // SUB operation (for branch)
            2'b10: begin // R-type/I-type instructions
                case (funct3)
                    3'b000: alu_control = (funct7_b5 ? 4'b0110 : 4'b0010); // SUB : ADD
                    3'b111: alu_control = 4'b0000; // AND
                    3'b110: alu_control = 4'b0001; // OR
                    3'b010: alu_control = 4'b0111; // SLT
                    default: alu_control = 4'b0010; // Default to ADD
                endcase
            end
            default: alu_control = 4'b0010; // Default to ADD
        endcase
    end
endmodule