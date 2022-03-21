rbenv-install() {
  nix-shell "%xxenv-install%" --argstr package "rbenv" --command "%xxenv-install%/xxenv-install.sh rbenv $@"
}
pyenv-install() {
  nix-shell "%xxenv-install%" --argstr package "pyenv" --command "%xxenv-install%/xxenv-install.sh pyenv $@"
}
