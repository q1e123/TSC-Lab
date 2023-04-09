import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv

interface transaction_test;
  logic valid;
  instruction_t  instruction_word;
endinterface: transaction_test