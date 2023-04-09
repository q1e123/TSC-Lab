/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/
import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv

module tester #(parameter TEST_FILE="test.csv")
  (input  logic          clk,
    transaction_test  test_interface
  );

timeunit 1ns/1ns;

initial begin
  $display("Starting tester...");
end 
always @(posedge clk) begin
      check_result();
end

function void check_result;
  Number_64 expected_result;
  logic check_result;
  int file_handle;
  $display("TF: %d", test_interface.valid);
  if (test_interface.valid) begin
    unique case (test_interface.instruction_word.opc)
      PASSA: expected_result = test_interface.instruction_word.op_a;
      PASSB: expected_result = test_interface.instruction_word.op_b;
      ADD: expected_result = test_interface.instruction_word.op_a + test_interface.instruction_word.op_b;
      SUB: expected_result = test_interface.instruction_word.op_a - test_interface.instruction_word.op_b;
      MULT: expected_result = test_interface.instruction_word.op_a * test_interface.instruction_word.op_b;
      DIV: expected_result = test_interface.instruction_word.op_a / test_interface.instruction_word.op_b;
      MOD: expected_result = test_interface.instruction_word.op_a % test_interface.instruction_word.op_b;
      default: expected_result = 0;
    endcase;
    file_handle = $fopen(TEST_FILE, "a");
    check_result = (test_interface.instruction_word.result == expected_result);
    $display("Tester opcode = %0d (%s)", test_interface.instruction_word.opc, test_interface.instruction_word.opc.name);
    $display("Tester operand_a = %0d",   test_interface.instruction_word.op_a);
    $display("Tester operand_b = %0d\n", test_interface.instruction_word.op_b);
    $display("Tester result = %0d\n", test_interface.instruction_word.result);
    $fwrite(file_handle, "%0d,%0d,%0d,%0d,%s\n", test_interface.instruction_word.opc, test_interface.instruction_word.op_a, test_interface.instruction_word.op_b, test_interface.instruction_word.result, check_result ? "PASS" : "FAIL");
    $fclose(file_handle);  
  end else begin
    $display("Skipping testing...");
  end
endfunction: check_result

endmodule: tester
