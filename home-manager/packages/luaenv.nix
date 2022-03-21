{ lib, config, pkgs, inputs, ... }: let
  luaenv_root = "${config.xdg.dataHome}/luaenv";
  plugins = {
    lua-build = inputs.lua-build;
    luaenv-luarocks = inputs.luaenv-luarocks;
    luaenv-update = inputs.luaenv-update;
    luaenv-vars = inputs.luaenv-vars;
  };
  luaenv = (
    import ./xxenv.nix
    {
      inherit pkgs inputs;
      name = "luaenv";
      manPages = "";
    }
  ).luaenv;
in {
  home.file = (pkgs.lib.listToAttrs (
    map
      (plugin: {
        name = "${luaenv_root}/plugins/${plugin.name}";
        value = {
          source = plugin.value;
          recursive = true;
        };
      })
      (pkgs.lib.attrsToList plugins)
  ));
  home.sessionVariables = {
    LUAENV_ROOT = luaenv_root;
  };
  home.packages = [ luaenv ];
  programs.zsh.initContent = lib.mkOrder 950 ''
    eval "$(${luaenv}/bin/luaenv init -)"
    . ${luaenv}/share/zsh/site-functions/_luaenv
  '';
  programs.bash.initExtra = ''
    eval "$(${luaenv}/bin/luaenv init -)"
  '';
  lib.packages.luaenv = luaenv;
}
