{ lib, config, pkgs, inputs, overrideSrc, ... }: let
  dotDir = "${lib.strings.removePrefix (config.home.homeDirectory + "/") config.xdg.configHome}/zsh";
  zDotDir = "${config.xdg.configHome}/zsh";
in {
  home.file = {
    ".xsessionrc".text = ''
      # defines XDG
      . "${config.xdg.stateHome}/nix/profile/etc/profile.d/hm-session-vars.sh"
      . "${./files/.xsessionrc}"
    '';
    "${lib.strings.removePrefix (config.home.homeDirectory + "/") config.xdg.configHome}/fontconfig/conf.d/10-nix-fonts.conf".text = ''
      <?xml version='1.0'?>
      <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
      <fontconfig>
        <dir>${config.xdg.stateHome}/nix/profile/share/fonts/</dir>
      </fontconfig>
    '';
  };
  home.packages = [ pkgs.nix-zsh-completions ]; # https://github.com/nix-community/home-manager/blob/892f76bd0aa09a0f7f73eb41834b8a904b6d0fad/modules/programs/zsh.nix#L565
  programs.bash = {
    enable = true;
    # so that it won't mess up with zsh's history.
    # especially that the default (HISTSIZE=<a small num>; inherited HISTFILE)
    # will ruin the zsh history
    historyFile = "${config.xdg.dataHome}/bash_history";
    historyFileSize = 1000000000;
    # atuin needs ble.sh to work in bash
  };
  programs.zsh = {
    enable = true;
    # zprof.enable = true;
    enableCompletion = false; # https://github.com/marlonrichert/zsh-autocomplete
    inherit dotDir;
    envExtra = lib.mkAfter ''[ -f "${zDotDir}/zshenv.zsh" ] && . ${zDotDir}/zshenv.zsh'';
    initExtra = lib.mkAfter (
      (lib.replaceStrings
        ["%cling%" "%files%"]
        ["${config.lib.packages.cling.unwrapped}" "${./files}"]
        (lib.readFile ./files/start-jupyter.in.sh))
      + (lib.readFile ./files/install-functions.sh)
      + (lib.replaceStrings ["%xxenv-install%"] ["${./files/xxenv-install}"]
        (lib.readFile ./files/xxenv-install.in.sh))
      + ''
        [ -f "${zDotDir}/zshrc.zsh" ] && . ${zDotDir}/zshrc.zsh
      ''
    );
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
  programs.starship = {
    enable = true;
    package = overrideSrc pkgs.starship inputs.starship;
  };
}
