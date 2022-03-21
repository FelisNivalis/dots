{ lib, config, pkgs, inputs, ... }:
let
  private = (let filename = ../private/home-manager.nix;
  in if (builtins.pathExists filename) then
    (import filename)
  else
    builtins.trace "Warning: ${filename} does not exist." {
      git.includes = { };
      git.extraConfig.url = { };
      ssh.matchBlocks = { };
    });
in {
  # https://github.com/nix-community/home-manager/issues/5187
  nix = {
    package = pkgs.nix;
    settings.use-xdg-base-directories = true;
  };

  home.file = {
    # xdg also defines `home.file."${xdg.configHome}"`, use relative path to workaround
    "${lib.strings.removePrefix (config.home.homeDirectory + "/")
    config.xdg.configHome}" = {
      source = ../config;
      recursive = true;
    };
    "${config.xdg.dataHome}/jupyter/lab/settings/overrides.json" = {
      text = ''
        {
          "@jupyterlab/apputils-extension:themes": {
            "theme": "JupyterLab Dark"
          }
        }
      '';
    };
    "${config.xdg.configHome}/nano/nanorc".text =
      lib.strings.concatStringsSep "\n"
      (builtins.map (filename: ''include "${inputs.nanorc}/${filename}"'')
        (builtins.filter
          (filename: builtins.match ".*\\.nanorc$" filename != null)
          (builtins.attrNames (builtins.readDir inputs.nanorc))));
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    package = config.lib.packages.delta;
    options = {
      navigate = true;
      line-numbers = true;
      features = lib.strings.concatStringsSep " " [ "arctic-fox" ];
    };
  };
  programs.git = let
    felisNivalis = {
      email = "88343630+FelisNivalis@users.noreply.github.com";
      name = "FelisNivalis";
      signingKey = "94102450F6ED017E";
    };
  in {
    enable = true;
    includes = [
      { path = ./files/delta-themes.gitconfig; }
      { path = "${inputs.toolgit}/aliases.ini"; }
    ] ++ map (url: {
      contents = { user = felisNivalis; };
      condition = "hasconfig:remote.*.url:${url}";
    }) [
      "git@github-felisnivalis:FelisNivalis/**"
      "git@github.com:FelisNivalis/**"
    ] ++ private.git.includes;
    settings = {
      alias = {
        glog =
          "log --graph --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
      };
      core.editor = "nano";
      tag.gpgSign = true;
      commit.gpgSign = true;
      merge.conflictstyle = "zdiff3";
      url = {
        "git@github-felisnivalis:FelisNivalis".insteadOf =
          "git@github.com:FelisNivalis";
      } // private.git.extraConfig.url;
    };
  };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    package = pkgs.openssh;
    matchBlocks = {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "confirm";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
      "github-felisnivalis" = {
        hostname = "github.com";
        identityFile = "~/.ssh/github-felisnivalis";
      };
    } // private.ssh.matchBlocks;
  };
  programs.jujutsu = {
    enable = true;
    package = inputs.jj.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = { };
  };
  home.sessionVariables = {
    # set ASKPASS manually;
    # https://web.archive.org/web/20240518043300/https://discourse.nixos.org/t/bash-script-ssh-askpass-error/45325
    SSH_ASKPASS = "${lib.getExe pkgs.kdePackages.ksshaskpass}";
    TOOLGIT_ROOT = "${inputs.toolgit}";
    NIX_BIN_DIR =
      "${config.xdg.stateHome}/nix/profile/bin"; # for zjstatus commands
  };
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-qt;
  };
}
