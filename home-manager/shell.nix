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
    # https://stackoverflow.com/questions/57981225/how-to-install-fonts-with-nix-in-ubuntu https://archive.is/AXyeb
    # https://discourse.nixos.org/t/how-to-install-fonts-on-a-non-nixos-system/14758/2 https://archive.is/7ble9
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
    initExtra = lib.mkAfter ''
      . ${./files/functions.sh}
      [ -f "${zDotDir}/zshrc.zsh" ] && . ${zDotDir}/zshrc.zsh
    '';
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
    package = pkgs.starship.overrideAttrs (drv: {
      src = inputs.starship;
      version = inputs.starship.rev;
      name = "starship-${inputs.starship.rev}";
      patches = []; # TEMP https://github.com/NixOS/nixpkgs/blob/44a71ff39c182edaf25a7ace5c9454e7cba2c658/pkgs/tools/misc/starship/default.nix#L26
      cargoDeps = drv.cargoDeps.overrideAttrs (lib.const {
        name = "starship-${inputs.starship.rev}-vendor.tar.gz";
        src = inputs.starship;
        version = inputs.starship.rev;
        outputHash = "sha256-tykR9M+PT7kotNwRwb75DuoSyEJImVPCeZ5QDF8GTTo=";
      });
    });
  };
}
