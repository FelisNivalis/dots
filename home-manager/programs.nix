{ lib, config, pkgs, ... }: {
  # https://github.com/nix-community/home-manager/issues/5187
  nix = {
    package = pkgs.nix;
    settings.use-xdg-base-directories = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.bash.enable = false;
  programs.zsh = let
    dotDir = "${lib.strings.removePrefix (config.home.homeDirectory + "/") config.xdg.configHome}/zsh";
    zDotDir = "${config.xdg.configHome}/zsh";
  in {
    enable = true;
    enableCompletion = true;
    completionInit = ''
      autoload -U compinit && compinit
      autoload -U bashcompinit && bashcompinit
    '';
    inherit dotDir;
    envExtra = lib.mkAfter ''[ -f "${zDotDir}/zshenv.zsh" ] && . ${zDotDir}/zshenv.zsh'';
    initExtra = lib.mkAfter ''[ -f "${zDotDir}/zshrc.zsh" ] && . ${zDotDir}/zshrc.zsh'';
    initExtraFirst = ''[ -f "${config.xdg.stateHome}/nix/profile/etc/profile.d/nix.sh" ] && . ${config.xdg.stateHome}/nix/profile/etc/profile.d/nix.sh'';
    profileExtra = lib.mkAfter ''[ -f "${zDotDir}/zprofile.zsh" ] && . ${zDotDir}/zprofile.zsh'';
    history = {
      path = "${zDotDir}/.histfile";
      ignoreSpace = false;
      save = 1000000000;
      size = 1000000000;
      extended = true;
    };
  };
}
