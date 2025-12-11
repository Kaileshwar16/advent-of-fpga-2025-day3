open! Base
open Hardcaml

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; digit : 'a
    ; digit_valid : 'a
    ; line_end : 'a
    }
  [@@deriving sexp_of, hardcaml]
end

module O : sig
  type 'a t =
    { max_joltage : 'a
    ; total_joltage : 'a
    }
  [@@deriving sexp_of, hardcaml]
end

val create : Signal.t I.t -> Signal.t O.t
