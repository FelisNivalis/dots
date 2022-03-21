{ config, username, ... }: {
  home.username = username;
  home.homeDirectory = /home/${username};

  home.stateVersion = "23.11";

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  home.sessionVariables = {
    XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";
    APP_HOME = "${config.home.homeDirectory}/My/Applications";
    PROJECT_HOME = "${config.home.homeDirectory}/My/Projects";
    MYDOTDIR = "${config.home.sessionVariables.PROJECT_HOME}/dotfiles";
  };
}
