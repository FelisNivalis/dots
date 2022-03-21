{
  pkgs ? import <nixpkgs> {},
  package
}:
assert true -> builtins.elem package [ "pyenv" "rbenv" "luaenv" ];
with pkgs; mkShell {
  packages = [
    patchelf pkg-config
  ] ++ pkgs.lib.optionals (package == "luaenv") [
    readline
  ] ++ pkgs.lib.optionals (package == "pyenv") [
    # pyenv
    stdenv.cc.cc.lib
    zlib bzip2 expat xz libffi libxcrypt tcl tk ncurses openssl readline gdbm sqlite libnsl libtirpc
  ] ++ pkgs.lib.optionals (package == "rbenv") [
    # rbenv
    # ruby runtime depends on libc, libgcc-s1, zlib and libgmp10
    openssl libyaml readline zlib gmp ncurses libffi gdbm libdbi libuuid # (if `--with-jemalloc`) jemalloc
    rustc # for yjit
    linuxPackages.systemtap libsystemtap # for dtrace
  ];
  shellHook = ''
    # https://archive.ph/Dcxel https://web.archive.org/web/20240614091847/https://unix.stackexchange.com/questions/435995/how-to-make-autoconf-use-install-instead-of-mkdir-p
    export MKDIR_P="/bin/mkdir -p"
    export INSTALL="/bin/install -c"
  '';
}
