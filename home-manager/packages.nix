{ lib, pkgs, features, ... }:
with pkgs; {
  home.packages = [
    ponysay lolcat
    fortune-kind
    charasay pokemonsay
    (pkgs.lib.setPrio (5) neo-cowsay)
    # dotacat nyancat
    # asciiquarium

    p7zip
    unzip # required by mason
    zip # required by sdkman
    bzip2 xz zstd
    ouch # a CLI tool for compressing and decompressing for various formats
    # pngquant jpegoptim gifsicle

    # nix-index nix-du

    aria2 wget2 you-get

    # ffmpeg
    # mupdf-headless # MuPDF
    # asciicam # Displays your webcam on the terminal
    # asciinema-agg asciinema # Terminal session recorder
    bc # GNU software calculator
    lnav # The Logfile Navigator
    ov # ov is a terminal pager
    hurl # Hurl is a command line tool that runs HTTP requests defined in a simple plain text format
    has # has checks presence of various command line tools on the PATH and reports their installed version
    # hr # Hr prints a repeated string of characters the width of the terminal
    sd # sd is an intuitive find & replace CLI
    procs # procs is a replacement for ps written in Rust
    tlrc # A tldr client written in Rust
    jc # jc JSONifies the output of many CLI tools, file-types, and common strings for easier parsing in scripts
    pastebinit # pastebin.com; lets you send anything you want directly to a pastebin from the command line
    # progress # show progress for coreutils basic commands (cp, mv, dd, tar, gzip/gunzip, cat, etc.)
    # boxxy
    (q-text-as-data # Run SQL directly on CSV or TSV files
      .overrideAttrs {
        postInstall = "mv $out/bin/q $out/bin/q-text-as-data";
      }) # collision
    sq # Provide jq-style access to structured data sources: SQL databases, or document formats like CSV or Excel
    # xan # process CSV files
    # try # Inspect a command's effects before modifying your live system
    ripgrep # rg ~ `grep` replacement
    # ripgrep-all # rga: ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, etc.
    fzf lsd dust duf
    bat # better cat
    # bottom # btm ~ better top, htop, etc
    broot # interactive directory navigation
    chafa # terminal graphics viewer
    ctpv # terminal file previewer
    # cyme # better `lsusb`
    dua # disk usage, interactively
    # eza # improved `ls`
    fd # `find` replacement
    fend # better CLI calculator
    # htop # graphical top
    # iotop # io top
    # sudo-rs # memory-safe `sudo` # built-in since Ubuntu-25.10
    # uutils-coreutils-noprefix # replaces GNU `coreutils`
    # viddy # better watch
    # gtop btop
    # parallel-full # Shell tool for executing jobs in parallel
    # wine
    graphviz
    # diff-pdf
    # diffoscope # In-depth comparison of files, archives, and directories.
    difftastic
    jd-diff-patch
    nur.repos.charmbracelet.sequin
    nur.repos.charmbracelet.glow
    # carapace # A multi-shell completion library
    jaq
    # visidata
    # desed
    # toolong # A terminal application to view, tail, merge, and search log files (plus JSONL).
    # monolith # CLI tool for saving complete web pages as a single HTML file
    # git-sim # Visually simulate Git operations
    # zizmor # A static analysis tool for GitHub Actions
    # hashcat # Fast password cracker
    # tmpmail # A temporary email right from your terminal
    dateutils
    (busybox.override {
      enableAppletSymlinks = false;
    }) # The Swiss Army Knife of Embedded Linux

    nettools wirelesstools
    # netdiscover mtr
    # bandwhich bmon iw
    # sysstat dnsutils
    stow sysfsutils lshw
    hyfetch fastfetch cpufetch onefetch ramfetch
    # pciutils
    # psmisc usbutils wavemon clinfo
    # glances
    xorg.xauth
    gping
    httpie
    curlie
    # lurk
    # q # Tiny and feature-rich command line DNS client

    cmake gnumake
    git-lfs
    # seer # Qt gui frontend for GDB
    libtree
    cling gh
    tree-sitter
    direnv
    # dotenvx
    # upterm # Secure terminal-session sharing
    sqlite litecli
    # checkbashisms shellcheck
    delta # better syntax highlighting diff
    rustup cargo-binstall
    just # updated gnumake replacement
    # honcho
    lazygit
    jjui
    lefthook
    pre-commit
    # hexyl # hex pretty printer
    # hyperfine # Command-line benchmarking tool
    # pyinfra
    # binsider # ELF binaries analyzer
    # functiontrace-server
    # sile # The SILE Typesetter

    wl-clipboard # dependency of img-clip.nvim
    # imagemagick ueberzugpp # dependency of 3rd/image.nvim

    # https://wiki.archlinux.org/title/core_utilities
    # https://sts10.github.io/docs/rust-command-line-tools.html
    # https://github.com/wimpysworld/nix-config/blob/main/home-manager/default.nix

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ] ++ (lib.optional features.wsl wslu)
    ++ (lib.optionals features.gui [ conky xdg-user-dirs gucharmap kitty ])
    ++ (lib.optionals features.fonts [
      twemoji-color-font
      nerd-fonts.fira-code
      babelstone-han
    ]);
  lib.packages = {
    cling = cling;
    delta = delta;
    jaq = jaq;
  };
}
