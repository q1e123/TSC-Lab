/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/
import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv

int wrong = 0;
module instr_register_test #(parameter ADDRESS_MODE = 0, NUMBER_OF_TRANSACTIONS = 5, SEED = 555, TEST_FILE="test-results.csv")
  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word,
   transaction_test  test_interface
  );

  timeunit 1ns/1ns;

  //int number_of_transactions = $unsigned($random)%16;
  // int number_of_transactions =11;
  int STACK_SIZE = 32;
  initial begin
    $srandom(SEED);
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");
    case (ADDRESS_MODE)
        0: $display("\nADDRESS MODE: Both incremental"); 
        1: $display("\nADDRESS MODE: Write incremental; Read random");
        2: $display("\nADDRESS MODE: Write random; Read incremental");
        3: $display("\nADDRESS MODE: Both random");
        default: $display("\nERROR: INVALID ADDRESS MODE!");  
    endcase;
    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)
    
  $display("\nNumber of transactions = %d\n", NUMBER_OF_TRANSACTIONS);
    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    repeat (NUMBER_OF_TRANSACTIONS) begin
      case (ADDRESS_MODE)
        0,1: @(posedge clk) begin
              randomize_transaction;
              write_pointer <= write_pointer + 1;
            end 
        2,3 :  @(posedge clk) begin
              randomize_transaction;
              write_pointer <= $unsigned($random)%STACK_SIZE;;
            end 
        default:
              $display("\nERROR: INVALID ADDRESS MODE!");
      endcase;
      @(negedge clk) begin
        print_results;
        check_result;
      end
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i<=2; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      case (ADDRESS_MODE)
        0,2: @(posedge clk) begin
              randomize_transaction;
              read_pointer <= read_pointer + 1;
            end 
        1,3 :  @(posedge clk) begin
              randomize_transaction;
              read_pointer = $unsigned($random)%STACK_SIZE;
            end 
        default:
              $display("\nERROR: INVALID ADDRESS MODE!");
      endcase;
      @(negedge clk) begin
        print_results;  
      end
    end

    @(posedge clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    operand_a     <= $random % 16;                 // between -15 and 15
    operand_b     <= $unsigned($random)%16;            // between 0 and 15
    opcode        <= opcode_t'($unsigned($random)%7 + 1);  // between 0 and 7, cast to opcode_t type
    write_pointer <= $unsigned($random)%STACK_SIZE;
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d\n", instruction_word.op_b);
    $display("  result = %0d\n", instruction_word.result);
    
    test_interface.valid <= 1;
    test_interface.instruction_word <= instruction_word;
    test_interface.valid <= 0;
  endfunction: print_results


  function void check_result;
    Number_64 expected_result;
    logic check_result;
    int file_handle;
   unique case (instruction_word.opc)
        PASSA: expected_result = instruction_word.op_a;
        PASSB: expected_result = instruction_word.op_b;
        ADD: expected_result = instruction_word.op_a + instruction_word.op_b;
        SUB: expected_result = instruction_word.op_a - instruction_word.op_b;
        MULT: expected_result = instruction_word.op_a * instruction_word.op_b;
        DIV: expected_result = instruction_word.op_a / instruction_word.op_b;
        MOD: expected_result = instruction_word.op_a % instruction_word.op_b;
        default: expected_result = 0;
    endcase;
    check_result = (instruction_word.result == expected_result);
    if(check_result) begin
      ++wrong;
      $display("Tests failed: %0d\n", wrong);
    end
  endfunction: check_result

endmodule: instr_register_test
