open! Base
open Hardcaml

module Range_finder = Advent_of_fpga_day3.Range_finder

let () =
  let module Sim = Cyclesim.With_interface (Range_finder.I) (Range_finder.O) in
  let sim = Sim.create Range_finder.create in
  
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  
  (* Reset *)
  inputs.clear := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;
  
  (* Read input from stdin *)
  Stdio.In_channel.iter_lines Stdio.stdin ~f:(fun line ->
    (* Send each digit *)
    String.iter line ~f:(fun c ->
      let digit = Char.to_int c - Char.to_int '0' in
      inputs.digit := Bits.of_int ~width:4 digit;
      inputs.digit_valid := Bits.vdd;
      Cyclesim.cycle sim;
    );
    
    (* Mark end of line *)
    inputs.digit_valid := Bits.gnd;
    inputs.line_end := Bits.vdd;
    Cyclesim.cycle sim;
    inputs.line_end := Bits.gnd;
  );
  
  (* Final result *)
  Cyclesim.cycle sim;
  Stdio.printf "%d\n" (Bits.to_int !(outputs.total_joltage))
