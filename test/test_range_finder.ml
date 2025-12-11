open! Base
open Hardcaml
module Range_finder = Advent_of_fpga_day3.Range_finder

let test_data = 
  [ "987654321111111"
  ; "811111111111119"
  ; "234234234234278"
  ; "818181911112111"
  ]

let char_to_digit c = Char.to_int c - Char.to_int '0'

let%expect_test "battery_joltage" =
  let module Sim = Cyclesim.With_interface (Range_finder.I) (Range_finder.O) in
  let sim = Sim.create Range_finder.create in
  
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  
  inputs.clear := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;
  
  List.iter test_data ~f:(fun line ->
    String.iter line ~f:(fun c ->
      inputs.digit := Bits.of_int ~width:4 (char_to_digit c);
      inputs.digit_valid := Bits.vdd;
      Cyclesim.cycle sim;
    );
    
    inputs.digit_valid := Bits.gnd;
    inputs.line_end := Bits.vdd;
    Cyclesim.cycle sim;
    inputs.line_end := Bits.gnd;
    
    Stdio.printf "Line: %s -> Max: %d\n" line (Bits.to_int !(outputs.max_joltage));
  );
  
  Cyclesim.cycle sim;
  Stdio.printf "\nTotal output joltage: %d\n" (Bits.to_int !(outputs.total_joltage));
  [%expect {|
    Line: 987654321111111 -> Max: 98
    Line: 811111111111119 -> Max: 98
    Line: 234234234234278 -> Max: 87
    Line: 818181911112111 -> Max: 98

    Total output joltage: 381
    |}]
