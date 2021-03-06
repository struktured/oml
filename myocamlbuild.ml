open Ocamlbuild_plugin
open Ocamlbuild_pack

let target_with_extension ext =
  List.exists (fun s -> Pathname.get_extension s = ext) !Options.targets

let rec copy_mlt_files path =
  Pathname.readdir path
  |> Array.iter
    (fun p ->
      if Pathname.is_directory (path / p) then
        copy_mlt_files (path / p)
      else if Pathname.check_extension p "mlt" then
        let src = path / p in
        let dst = !Options.build_dir / path / p in
        Shell.mkdir_p (!Options.build_dir / path);
        Pathname.copy src dst
      else
        ())

let () =
  let additional_rules =
    function
      | Before_hygiene  -> if target_with_extension "test" then copy_mlt_files "src"
      | After_hygiene   -> ()
      | Before_options  -> ()
      | After_options   -> ()
      | Before_rules    -> ()
      | After_rules     ->
          begin
            rule "Create a test target."
              ~prod:"%.test"
              ~dep:"%.native"
              begin fun env _build ->
                let test = env "%.test" and native = env "%.native" in
                Seq [ mv native test
                    ; Cmd (S [ A "ln"
                             ; A "-sf"
                             ; P (!Options.build_dir/test)
                             ; A Pathname.parent_dir_name])
                ]
              end;
            if target_with_extension "test" then
              flag ["pp"] (S [ P (!Options.build_dir / "tools/joiner.native") ; A "camlp4o"])
          end
  in
  dispatch additional_rules
