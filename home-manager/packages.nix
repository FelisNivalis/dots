{ lib, pkgs, inputs, bits, ... }: with pkgs; {
  home.packages = [
    # for fun
    ponysay lolcat
    fortune-kind
    charasay pokemonsay
    (pkgs.lib.setPrio (5) neo-cowsay)
    dotacat nyancat
    asciiquarium

    # other tools
    unzip # required by mason
    zip # required by sdkman
    bzip2 xz bc
    ffmpeg asciicam asciinema-agg asciinema
    lnav ov hurl
    has fzf
    nix-index nix-du
    hr sd procs tlrc
    pastebinit
    fd bat lsd du-dust
    parallel-full

    # systools
    nettools wirelesstools
    netdiscover mtr
    bandwhich bmon iw
    sysstat dnsutils
    stow sysfsutils lshw
    hyfetch fastfetch cpufetch onefetch ramfetch
    pciutils
    psmisc usbutils wavemon clinfo

    # development tools
    cmake gnumake
    libtree
    cling gh
    tree-sitter
    direnv upterm
    sqlite
    checkbashisms

    rustup cargo-binstall

    # GUI
    conky xdg-user-dirs gucharmap

    # fonts
    twemoji-color-font
    fira-code-nerdfont
    babelstone-han

    # https://wiki.archlinux.org/title/core_utilities
    # https://sts10.github.io/docs/rust-command-line-tools.html
    # https://github.com/wimpysworld/nix-config/blob/main/home-manager/default.nix

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ]
  ++ (lib.optional bits.WSL wslu);
  lib.packages = {
    cling = cling;
  };
}
