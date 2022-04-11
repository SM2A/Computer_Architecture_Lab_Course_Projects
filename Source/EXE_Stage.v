module EXE_Stage (
    input clk, rst,wb_en_in, mem_r_en_in, mem_w_en_in, imm,
    input [3:0]exe_cmd, sr,
    input [11:0] shift_operand,
    input [23:0] imm_signed_24,
    input [31:0]PC_in, val_rn, val_rm,
    output wb_en, mem_r_en, mem_w_en,
    output [3:0]status,
    output [31:0]alu_result, br_addr
);
    
    wire or_output;
    wire [31:0] val_2;
    assign or_output = mem_r_en_in || mem_w_en_in;

    assign wb_en = wb_en_in;
    assign mem_r_en = mem_r_en_in;
    assign mem_w_en = mem_w_en_in;

    assign br_addr = PC_in + ({{8{imm_signed_24[23]}}, {imm_signed_24}} << 2);
    ALU alu (clk, rst, val_rn, val_2, exe_cmd, sr, alu_result, status);
    Val2Generator val_2_generator (clk, rst, val_rm, shift_operand, imm, or_output, val_2);

endmodule
