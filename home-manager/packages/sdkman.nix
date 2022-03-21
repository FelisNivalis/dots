{ lib, config, pkgs, inputs, versions, ... }:
let
  sdkman-cli-native = pkgs.rustPlatform.buildRustPackage {
    pname = "sdkman-cli-native";
    version = "0.0";
    cargoLock.lockFile = "${inputs.sdkman-cli-native}/Cargo.lock";
    src = inputs.sdkman-cli-native;
  };
  sdkman-cli = pkgs.stdenv.mkDerivation {
    name = "sdkman-cli";
    src = inputs.sdkman-cli;
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p "$out"
      cp -R contrib "$out"/contrib
      cp -R src/main/bash "$out"/src
      rm "$out"/src/sdkman-selfupdate.sh
      mkdir "$out"/bin
      mv "$out"/src/sdkman-init.sh "$out"/bin
      substituteInPlace "$out"/bin/sdkman-init.sh --replace-fail "@SDKMAN_CANDIDATES_API@" "https://api.sdkman.io/2"
    '';
  };
  sdkman_dir = "${config.xdg.dataHome}/sdkman";
in {
  home.file = {
    "${sdkman_dir}" = {
      source = sdkman-cli;
      recursive = true;
    };
    "${sdkman_dir}/src/sdkman-selfupdate.sh".text = ''
      #!/usr/bin/env bash
      function __sdk_selfupdate() {
        cat <<EOF
        Not supported. Update the home manager flake instead.
      EOF
      }
    '';
    "${sdkman_dir}/libexec" = { source = "${sdkman-cli-native}/bin"; };
    "${sdkman_dir}/etc/config" = {
      text = ''
        sdkman_auto_answer=false
        sdkman_colour_enable=true
        sdkman_selfupdate_feature=false
        sdkman_auto_complete=true
        sdkman_auto_env=false
        sdkman_beta_channel=false
        sdkman_checksum_enable=true
        sdkman_curl_connect_timeout=7
        sdkman_curl_max_time=10
        sdkman_debug_mode=false
        sdkman_insecure_ssl=false
        sdkman_native_enable=true
      '';
    };
    "${sdkman_dir}/var/version".text = versions.sdkman-cli;
    "${sdkman_dir}/var/version_native".text = versions.sdkman-cli-native;
    "${sdkman_dir}/var/candidates".source = inputs.sdkman-candidates-all;
    "${sdkman_dir}/var/platform".text = if (pkgs.stdenv.hostPlatform.system == "x86_64-linux") then
      "linuxx64"
    else
      throw "Current system ${pkgs.stdenv.hostPlatform.system} was not configured yet.";

    # a workaround to keep an empty folder: https://github.com/nix-community/home-manager/issues/2104
    "${sdkman_dir}/candidates/.keep".text = "";
    "${sdkman_dir}/tmp/.keep".text = "";
    "${sdkman_dir}/ext/.keep".text = "";
  };
  home.sessionVariables = { SDKMAN_DIR = sdkman_dir; };
  programs.zsh.initContent = lib.mkOrder 950 ''
    # a dirty walkaround
    alias find='find -L'
    . "${sdkman_dir}/bin/sdkman-init.sh"
    unalias find
  '';
  programs.bash.initExtra = ''
    # a dirty walkaround
    alias find='find -L'
    . "${sdkman_dir}/bin/sdkman-init.sh"
    unalias find
  '';
}
