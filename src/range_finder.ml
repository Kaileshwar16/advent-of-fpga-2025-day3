open! Base
open Hardcaml

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; digit : 'a [@bits 4]
    ; digit_valid : 'a
    ; line_end : 'a
    }
  [@@deriving sexp_of, hardcaml]
end

module O = struct
  type 'a t =
    { max_joltage : 'a [@bits 7]
    ; total_joltage : 'a [@bits 32]
    }
  [@@deriving sexp_of, hardcaml]
end

let create (i : _ I.t) =
  let open Signal in
  let reg_spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  
  (* Track best 2-digit combo seen so far - try all pairs as we stream *)
  let best_joltage = wire 7 in
  
  (* Keep a history buffer of digits seen - increased to 120 for long lines *)
  let buffer_size = 120 in
  let digit_buffer = List.init buffer_size ~f:(fun _ -> wire 4) in
  let buffer_count = wire 8 in  (* 8 bits can hold up to 255 *)
  
  (* When valid digit comes in, check it against all previous digits *)
  let pairs_to_check = 
    List.mapi digit_buffer ~f:(fun idx prev_digit ->
      let valid_idx = buffer_count >: (of_int ~width:8 idx) in
      (* Form number with prev as tens, current as ones - ONLY THIS ORDER, NO REARRANGING *)
      let pair = (mux prev_digit
        (List.init 10 ~f:(fun i -> of_int ~width:7 (i * 10)) @ [of_int ~width:7 99]))
        +: uresize i.digit 7
      in
      mux2 valid_idx pair (zero 7)
    )
  in
  
  (* Find best among all pairs *)
  let best_of_pairs = 
    List.fold pairs_to_check ~init:(zero 7) ~f:(fun acc pair ->
      mux2 (pair >: acc) pair acc
    )
  in
  
  (* Update best if we found something better *)
  let new_best = 
    mux2 i.digit_valid
      (mux2 (best_of_pairs >: best_joltage) best_of_pairs best_joltage)
      best_joltage
  in
  
  let best_reg = reg reg_spec (mux2 i.line_end (zero 7) new_best) in
  best_joltage <== best_reg;
  
  (* Shift buffer and add new digit *)
  let new_buffer_count = 
    mux2 i.line_end (zero 8)
      (mux2 i.digit_valid
         (mux2 (buffer_count ==: (of_int ~width:8 (buffer_size - 1))) 
            buffer_count 
            (buffer_count +: (of_int ~width:8 1)))
         buffer_count)
  in
  let buffer_count_reg = reg reg_spec new_buffer_count in
  buffer_count <== buffer_count_reg;
  
  List.iteri digit_buffer ~f:(fun idx buf ->
    let new_val = 
      if idx = 0 then
        mux2 i.digit_valid i.digit buf
      else
        let prev_buf = List.nth_exn digit_buffer (idx - 1) in
        mux2 i.digit_valid prev_buf buf
    in
    let buf_reg = reg reg_spec (mux2 i.line_end (zero 4) new_val) in
    buf <== buf_reg
  );
  
  (* Accumulate total *)
  let total = wire 32 in
  let new_total = mux2 i.line_end (total +: uresize best_joltage 32) total in
  let total_reg = reg reg_spec new_total in
  total <== total_reg;
  
  let max_out = reg reg_spec ~enable:i.line_end best_joltage in
  
  { O. max_joltage = max_out; total_joltage = total_reg }
