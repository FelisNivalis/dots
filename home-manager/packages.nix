{ lib, pkgs, wsl, ... }: with pkgs; {
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # for fun
    ponysay lolcat
    fortune-kind
    (pkgs.lib.setPrio (5) neo-cowsay)
    dotacat nyancat
    hyfetch

    # random tools
	  unzip # required by mason
    zip # required by sdkman
    xz bc
    direnv ffmpeg
    lnav ov hurl gtop
    fd ripgrep bat dua lsd has
    nix-index nix-du
    hr dua duf jiq sd procs tldr
    pastebinit

    # systools
    nettools wirelesstools sysstat dnsutils
    stow sysfsutils lshw

    # development tools
    cmake gnumake clang
    # automake pkg-config # the tools have `setup-hooks` with envvars (`$PKG_CONFIG_PATH`, `$ACLOCAL_PATH`)
    # zlib bzip2 expat xz libffi libxcrypt tcl tk ncurses openssl readline gdbm sqlite
    # Using non-Nix Python Packages with Binaries on NixOS
    # https://github.com/mcdonc/.nixconfig/blob/e7885ad18b7980f221e59a21c91b8eb02795b541/videos/pydev/script.rst
    # https://discourse.nixos.org/t/what-package-provides-libstdc-so-6/18707/4
    # `pip install` uses pre-built shared libraries, so packages that use e.g. `libstdc++.so.6` cannot link, if the python was built with nix's toolchain.
    # unless a package doesn't ship with its required c libraries, `pip install --no-binary :all: some-package` will work.
    # It fetches the source and builds the package from the source code.
    # Pay attention that some packages has additional compile-time dependencies, e.g. `cmake` for `numpy`
    # but installing via pip after build phase is not declarative, so can break if the dependencies are deleted.

    # compared to e.g. conda, nix modifies the `INTERP` field, which makes "normal" installation using pip not working.

    lazygit

    # GUI
    conky

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ]
  ++ (lib.optional wsl wslu);
}
