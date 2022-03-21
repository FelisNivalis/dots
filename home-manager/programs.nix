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
  programs.git = let
    felisNivalis = {
      email = "88343630+FelisNivalis@users.noreply.github.com";
      name = "FelisNivalis";
      signingKey = "94102450F6ED017E";
    };
  in {
    enable = true;
    extraConfig = {
      url = {
        "git@github-felisnivalis:FelisNivalis".insteadOf = "git@github.com:FelisNivalis";
      };
    };
    includes = map (url: {
      contents = { user = felisNivalis; };
      condition = "hasconfig:remote.*.url:${url}";
    }) [
      "github-felisnivalis:FelisNivalis/**"
      "git@github.com:FelisNivalis/**"
    ];
    aliases = {
      glog = "log --graph --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
    };
    extraConfig = {
      core.editor = "nano";
      tag.gpgSign = true;
      commit.gpgSign = true;
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
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
}
