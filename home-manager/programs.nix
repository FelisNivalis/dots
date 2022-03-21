{ lib, config, pkgs, ... }: {
  # https://github.com/nix-community/home-manager/issues/5187
  nix = {
    package = pkgs.nix;
    settings.use-xdg-base-directories = true;
  };

  home.file = {
    # xdg also defines `home.file."${xdg.configHome}"`, use relative path to workaround
    "${lib.strings.removePrefix (config.home.homeDirectory + "/") config.xdg.configHome}" = {
      source = ../config;
      recursive = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userEmail = "88343630+FelisNivalis@users.noreply.github.com";
    userName = "FelisNivalis";
    extraConfig = {
      core.editor = "nano";
    };
  };
  programs.ssh = {
    enable = true;
    package = pkgs.openssh;
    matchBlocks = {
      "github-felisnivalis" = {
        hostname = "github.com";
        identityFile = "~/.ssh/github-felisnivalis";
      };
    };
  };
}
