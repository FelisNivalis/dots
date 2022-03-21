export RUSTUP_HOME=$XDG_DATA_HOME/rustup
export CARGO_HOME=$XDG_DATA_HOME/cargo
# mise uses asdf-rust, which sets these env vars. Be careful not to make problems.
# [ -f "$CARGO_HOME/env" ] && . "$CARGO_HOME/env" # after mise to override PATH
