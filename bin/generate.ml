open! Core
open! Hardcaml
open! Hardcaml_demo_project

module Rtl = Hardcaml.Rtl
module Rope = Jane_rope.Rope

let generate_range_finder_rtl () =
  let module C = Circuit.With_interface (Range_finder.I) (Range_finder.O) in
  let scope = Scope.create ~auto_label_hierarchical_ports:true () in
  let circuit = C.create_exn ~name:"range_finder_top" (Range_finder.create) in
  let rtl_circuits =
    Rtl.create ~database:(Scope.circuit_database scope) Verilog [ circuit ]
  in
  let rtl = Rtl.full_hierarchy rtl_circuits |> Rope.to_string in
  print_endline rtl
;;

let range_finder_rtl_command =
  Command.basic
    ~summary:"Generate Range Finder RTL"
    [%map_open.Command
      let () = return () in
      fun () -> generate_range_finder_rtl ()]
;;

let () =
  Command_unix.run
    (Command.group ~summary:"Hardcaml generators" [ "range-finder", range_finder_rtl_command ])
;;
