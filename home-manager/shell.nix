{ lib, config, pkgs, inputs, stableRustPlatform, getRefFromLock, ... }: let
  dotDir = "${config.xdg.configHome}/zsh";
  sessionVariables = {
    BASH_HISTFILE = "${config.xdg.dataHome}/bash_history";
    MAVEN_OPTS = ''-Dmaven.repo.local=${config.xdg.dataHome}/maven/repository'';
  };
in {
  home.file = {
    ".xsessionrc".text = ''
      # defines XDG
      . "${config.xdg.stateHome}/nix/profile/etc/profile.d/hm-session-vars.sh"
      . "${./files/.xsessionrc}"
    '';
    # https://stackoverflow.com/questions/57981225/how-to-install-fonts-with-nix-in-ubuntu https://archive.is/AXyeb
    # https://discourse.nixos.org/t/how-to-install-fonts-on-a-non-nixos-system/14758/2 https://archive.is/7ble9
    "${lib.strings.removePrefix (config.home.homeDirectory + "/") config.xdg.configHome}/fontconfig/conf.d/10-nix-fonts.conf".text = ''
      <?xml version='1.0'?>
      <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
      <fontconfig>
        <dir>${config.xdg.stateHome}/nix/profile/share/fonts/</dir>
      </fontconfig>
    '';
    "${lib.strings.removePrefix (config.home.homeDirectory + "/") config.xdg.dataHome}/textart".source = "${inputs.ansi}";
  };
  systemd.user.services = let
    ollama-wrapper = pkgs.writeShellScriptBin "ollama-wrapper" ''
      mise="${lib.getExe config.lib.packages.mise}"
      if ! ollama="$("$mise" where aqua:ollama/ollama)"; then
        echo "Failed when executing "'"'"$mise where aqua:ollama/ollama"'"'
      else
        if [[ -x "$ollama/bin/ollama" ]]; then
          LD_LIBRARY_PATH="''${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH;}$ollama/lib" "$ollama/bin/ollama" "$@"
        else
          echo "No executable "'"'"$ollama/bin/ollama"'"'" was found."
        fi
      fi
    '';
  in {
    ollama = {
      Unit = {
        Description = "Ollama Service";
        After = "network-online.target";
      };
      Service = {
        # https://web.archive.org/web/20250124085016/https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html#Specifiers
        ExecStart = "${lib.getExe ollama-wrapper} serve";
        # User = "ollama";
        # Group = "ollama";
        Environment = [
          "OLLAMA_MODELS=${config.xdg.dataHome}/ollama"
          "CUDA_CACHE_PATH=%C/nv"
        ];
        Restart = "on-failure";
        RestartSec = 3;
        ProtectSystem = "full";
        # ProtectHome = "yes";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
  home.packages = [
    pkgs.nix-zsh-completions # https://github.com/nix-community/home-manager/blob/892f76bd0aa09a0f7f73eb41834b8a904b6d0fad/modules/programs/zsh.nix#L565
    (pkgs.stdenv.mkDerivation {
      name = "shellCompletions";
      phases = [ "installPhase" ];
      nativeBuildInputs = [ pkgs.installShellFiles ];
      installPhase = ''
        installShellCompletion --zsh --name _jupyter ${inputs.jupyter-zsh-completion}
        installShellCompletion --bash --name jupyter.bash ${inputs.jupyter-bash-completion}
        installShellCompletion --zsh --name _ollama ${inputs.ollama-zsh-completion}
      '';
    })
  ];
  home.sessionVariables = sessionVariables;
  programs.bash = {
    enable = true;
    # so that it won't mess up with zsh's history.
    # especially that the default (HISTSIZE=<a small num>; inherited HISTFILE)
    # will ruin the zsh history
    historyFile = sessionVariables.BASH_HISTFILE;
    historyFileSize = 1000000000;
    # atuin recommends ble.sh to work best in bash; programs.blesh: https://github.com/nix-community/home-manager/pull/3238
  };
  programs.zsh = {
    enable = true;
    # zprof.enable = true;
    enableCompletion = false; # https://github.com/marlonrichert/zsh-autocomplete
    inherit dotDir;
    envExtra = lib.mkAfter ''[ -f "${dotDir}/zshenv.zsh" ] && . "${dotDir}/zshenv.zsh"'';
    initContent = lib.mkMerge [
      # mkBefore = mkOrder 500
      (lib.mkBefore ''[ -f "${config.xdg.stateHome}/nix/profile/etc/profile.d/nix.sh" ] && . "${config.xdg.stateHome}/nix/profile/etc/profile.d/nix.sh"'')
      (lib.mkOrder 1090 ''[ -f "${dotDir}/zshrc.zsh" ] && . "${dotDir}/zshrc.zsh"'')
    ];
    profileExtra = lib.mkAfter ''[ -f "${dotDir}/zprofile.zsh" ] && . "${dotDir}/zprofile.zsh"'';
    history = {
      path = "${dotDir}/.histfile";
      ignoreSpace = false;
      save = 1000000000;
      size = 1000000000;
      extended = true;
      findNoDups = true;
    };
  };
  programs.starship = {
    enable = true;
    package = (pkgs.starship.override (lib.const {
      rustPlatform = stableRustPlatform;
    })).overrideAttrs (drv: {
      src = inputs.starship;
      version = getRefFromLock "starship";
      # buildRustPackage https://github.com/NixOS/nixpkgs/pull/354999
      # override `cargoSha256` https://web.archive.org/web/20241119130908/https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/3
      # cargoDeps https://web.archive.org/web/20241119124923/https://nixos.wiki/wiki/Rust
      # fixed-output derivations: https://nix.dev/manual/nix/2.25/language/advanced-attributes.html?highlight=fixed-output#adv-attr-outputHash
      # `outputHash` needs to be provided manually when overriding the existing `cargoDeps` derivation;
      # while `importCargoLock` builds a derivation from scratch and fills the hash using the `checksum`s from the lock file.
      cargoDeps = pkgs.rustPlatform.importCargoLock { lockFile = "${inputs.starship}/Cargo.lock"; };
    });
  };
}
