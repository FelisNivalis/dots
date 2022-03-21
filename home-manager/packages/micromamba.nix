{ lib, config, pkgs, inputs, overrideSrc, ... }: let
  micromamba = (overrideSrc pkgs.micromamba inputs.micromamba);
in {
  home.packages = [ micromamba ];
  programs.zsh.initExtra = ''
    eval "$(${lib.getExe micromamba} shell hook --shell zsh)"
  '';
  programs.bash.initExtra = ''
    eval "$(${lib.getExe micromamba} shell hook --shell bash)"
  '';
}
