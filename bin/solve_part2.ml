open! Base
open Stdio

(* Greedy algorithm to select k digits from a line to maximize the resulting number *)
let solve_line line k =
  let digits = String.to_array line in
  let n = Array.length digits in
  
  let result = Array.create ~len:k '0' in
  let start_pos = ref 0 in
  
  (* For each position in result, find the best digit we can take *)
  for i = 0 to k - 1 do
    let remaining_needed = k - i in
    let must_take_by = n - remaining_needed + 1 in
    
    (* Find the maximum digit in the valid range *)
    let best_digit = ref '0' in
    let best_pos = ref !start_pos in
    
    for j = !start_pos to must_take_by - 1 do
      if Char.(digits.(j) > !best_digit) then begin
        best_digit := digits.(j);
        best_pos := j
      end
    done;
    
    result.(i) <- !best_digit;
    start_pos := !best_pos + 1
  done;
  
  String.of_array result

let () =
  let total = ref (Bigint.of_int 0) in
  
  In_channel.iter_lines stdin ~f:(fun line ->
    let result = solve_line line 12 in
    total := Bigint.(!total + of_string result)
  );
  
  printf "%s\n" (Bigint.to_string !total)
