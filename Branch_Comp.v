module branch_comp (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic branch,
    input  logic [2:0] funct3,
    output logic br_taken
);
    always_comb begin
        br_taken = 1'b0;
        if (branch) begin
            case (funct3)
                3'b000: br_taken = (a == b);         // beq
                3'b001: br_taken = (a != b);         // bne
                3'b100: br_taken = ($signed(a) < $signed(b)); // blt
                3'b101: br_taken = ($signed(a) >= $signed(b)); // bge
                3'b110: br_taken = (a < b);          // bltu
                3'b111: br_taken = (a >= b);         // bgeu
                default: br_taken = 1'b0;
            endcase
        end
    end
endmodule