open Dkml_install_api
open Dkml_install_register
open Bos

let execute_install ctx =
  let ocamlrun =
    ctx.Context.path_eval "%{staging-ocamlrun:share-abi}%/bin/ocamlrun"
  in
  if not Sys.win32 then
    log_spawn_and_raise
      Cmd.(
        v (Fpath.to_string ocamlrun)
        % Fpath.to_string
            (ctx.Context.path_eval "%{_:share-generic}%/unix_install.bc")
        % "-target"
        % Fpath.to_string (ctx.Context.path_eval "%{_:share-generic}%/bin/curl"))

let () =
  let reg = Component_registry.get () in
  Component_registry.add_component reg
    (module struct
      include Default_component_config

      let component_name = "staging-curl"

      let depends_on = [ "staging-ocamlrun" ]

      let install_user_subcommand ~component_name:_ ~subcommand_name ~ctx_t =
        let doc = "Install Unix utilities" in
        Result.ok
        @@ Cmdliner.Term.
             (const execute_install $ ctx_t, info subcommand_name ~doc)
    end)
