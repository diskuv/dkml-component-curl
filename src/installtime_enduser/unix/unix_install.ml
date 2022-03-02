let () =
  (* Command line parsing *)
  let anon_fun (_ : string) = () in
  let opt_target = ref "" in
  Arg.(
    parse
      [
        ( "-target",
          Set_string opt_target,
          "Destination path for a symlink to the curl on the PATH" );
      ]
      anon_fun "Install curl on Unix");
  (* Installation: Make a symlink *)
  let ( let* ) = Rresult.R.( >>= ) in
  let open Bos in
  let install_sequence =
    let* target_curl = Fpath.of_string !opt_target in
    let* src_curl = OS.Cmd.get_tool (Cmd.v "curl") in
    Unix.mkdir (Fpath.to_string (Fpath.parent target_curl)) 0o750;
    OS.Path.symlink ~target:target_curl src_curl
  in
  Rresult.R.error_msg_to_invalid_arg install_sequence
