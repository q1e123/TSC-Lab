/***********************************************************************
 * A SystemVerilog top-level netlist to connect testbench to DUT
 **********************************************************************/
`define ADDRESS_MODE 3
`define NUMBER_OF_TRANSACTIONS 20
`define SEED 11
`define TEST_FILE "D:\\UserData\\z004m7ws\\Workshop\\Test-TESC\\Proj\\TSC-Lab\\Lab-3\\tools\\test.csv"

module top;
  timeunit 1ns/1ns;

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*;

  // clock variables
  logic clk;
  logic test_clk;

  // interconnecting signals
  logic          load_en;
  logic          reset_n;
  opcode_t       opcode;
  operand_t      operand_a, operand_b;
  address_t      write_pointer, read_pointer;
  instruction_t  instruction_word;

  transaction_test test_interface ();
  // instantiate testbench and connect ports
  instr_register_test #(`ADDRESS_MODE, `NUMBER_OF_TRANSACTIONS, `SEED) test (
    .clk(clk),
    .load_en(load_en),
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .instruction_word(instruction_word),
    .test_interface(test_interface)
   );

  // instantiate design and connect ports
  instr_register dut (
    .clk(clk),
    .load_en(load_en),
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .instruction_word(instruction_word)
   );
  tester #(`TEST_FILE) tester (
    .clk(clk),
    .test_interface(test_interface)
   );

  // clock oscillators
  initial begin
    clk <= 0;
    forever #5  clk = ~clk;
  end

  initial begin
    test_clk <=0;
    // offset test_clk edges from clk to prevent races between
    // the testbench and the design
    #4 forever begin
      #2ns test_clk = 1'b1;
      #8ns test_clk = 1'b0;
    end
  end

endmodule: top
