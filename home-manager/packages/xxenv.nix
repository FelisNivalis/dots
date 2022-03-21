{
  pkgs, inputs, name,
  manPages ? "man/man1/${name}.1",
  completionFiles ? "completions/${name}.{bash,fish,zsh}"
}:
let
  xxenv = pkgs.stdenv.mkDerivation {
    pname = name;
    version = inputs."${name}".rev;
    srcs = [ inputs."${name}" ];
    sourceRoot = "src";
    nativeBuildInputs = [ pkgs.installShellFiles ];
    configureScript = "src/configure";
    makeFlags = ["-C" "src"];
    unpackPhase = ''
      mkdir src
      cp -R "${inputs."${name}"}"/* src

      chmod +w -R src
    '';
    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -R bin "$out/bin"
      cp -R libexec "$out/libexec"
      if [ -d "plugins" ]; then
        cp -R plugins "$out/plugins"
      fi

      runHook postInstall
    '';
    postInstall = ''
      ${pkgs.lib.optionalString (manPages != "") "installManPage ${manPages}"}
      ${pkgs.lib.optionalString (completionFiles != "") "installShellCompletion ${completionFiles}"}
    '';
    meta = {
      mainProgram = name;
    };
  };
in {
  "${name}" = xxenv;
}
