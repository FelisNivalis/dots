{ lib, pkgs, config, ... }: let
	getPkgExe = name: "${config.lib.packages.${name}}/bin/${name}";
	pyenv = getPkgExe "pyenv";
	rbenv = getPkgExe "rbenv";
	plenv = getPkgExe "plenv";
	luaenv = getPkgExe "luaenv";
	mise = getPkgExe "mise";
	jaq = lib.getExe config.lib.packages.jaq;
	# zeromq = pkgs.zeromq;
	packages = {
		disable-byobu = pkgs.writeShellScriptBin "disable-byobu" ''
			touch "$HOME/.no-byobu-launch"
		'';
		# tmux-window-name = pkgs.runCommand "tmux-window-name" {} ''
		# 	install -D ${../../config/byobu/bin/tmux_window_name.sh} "$out/bin/tmux-window-name"
		# '';
		tpm-install = pkgs.writeShellScriptBin "tpm-install" ''
			tmux run-shell "$TPM_ROOT/bindings/install_plugins"
			tmux run-shell "$TPM_ROOT/bindings/update_plugins"
			tmux run-shell "$TPM_ROOT/bindings/clean_plugins"
		'';
		install-completions = pkgs.writeShellScriptBin "install-completions" ''
			__mkdir() {
				if [[ ! -d "$1" ]]; then
					mkdir -p "$1"
				fi
			}
			write-file() {
				__mkdir "$(dirname "$2")"
				local ret=$(eval "$1")
				if (( $? == 0 )); then
					echo "Writing the results of command \`$1\` into \`$2\`..."
					echo "$ret" > "$2"
				fi
			}
			write-powershell-completion() {
				: # write-file "$2" "/path/to/$1.ps1"
			}
			write-elvish-completion() {
				: # write-file "$2" "/path/to/$1.elv"
			}
			write-bash-completion() {
				write-file "$2" "''${BASH_COMPLETION_USER_DIR:-$XDG_DATA_HOME/bash-completion}/completions/$1"
			}
			write-fish-completion() {
				write-file "$2" "$XDG_CONFIG_HOME/fish/completions/$1.fish"
			}
			write-zsh-completion() {
				write-file "$2" "$XDG_CACHE_HOME/zsh/completions/_$1"
			}
			write-manpage() {
				write-file "$2" "$XDG_DATA_HOME/man/man1/$1.1"
			}
			write-completions() {
				local shell
				for shell in $(IFS='\n' echo "$3" | tr ';' '\n'); do
					eval "write-$shell-completion '$1' '$(eval "echo \"$2\"")'"
				done
			}
			write-completions juliaup "juliaup completions \$shell" "bash;elvish;fish;powershell;zsh"
			write-completions zellij "zellij setup --generate-completion \$shell" "bash;fish;zsh"
			# https://github.com/fastapi/typer/blob/3b17788dfbb5c25b0d066fab6db362cf33485754/typer/completion.py#L54
			write-zsh-completion comfy "_TYPER_COMPLETE_TEST_DISABLE_SHELL_DETECTION=1 comfy --show-completion zsh"

			# https://serverfault.com/questions/506612/standard-place-for-user-defined-bash-completion-d-scripts
			# bash: $XDG_DATA_DIRS; zsh: $fpath
			# https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/in/installShellFiles/setup-hook.sh
			# nix-shell -p installShellFiles
		'';
		install-all = pkgs.writeShellScriptBin "install-all" ''
			install-completions
			rustup show # rustup show will install latest if none was installed
			rustup component add rust-analyzer
			rustup update
			zimfw update -v
			juliaup update release
			pyenv-install-latest
			rbenv-install-latest
			luaenv-install-latest
			mise-install-all
			printf "mise precompiled python version: latest: %s; current: %s\n" \
	"$(curl http://mise-versions.jdx.dev/python-precompiled 2>/dev/null | sed -n 's/^[^0-9]*\([0-9]\+\.[0-9]\+\.[0-9]\+\)+.*$/\1/p' | tail -n 1)" \
	"$(mise ls --installed | grep python | awk '{print $2}' | tr '\n' ';')"
			nvim-install-env
			tpm-install
			nix upgrade-nix
			sdkman-install-all
			sdk update && sdk upgrade
		'';
		sdkman-install-all = pkgs.writeShellScriptBin "sdkman-install-all" ''
			sdk install java
			sdk install maven
			sdk install scala
		'';
		zjstatus-command = pkgs.writeShellScriptBin "zjstatus-command" ''
			case $1 in
				uptime)
					# uptime | sed -e "s/.* up *//" -e "s/ *days, */d/" -e "s/:/h/" -e "s/,.*/m/"
					t=$(($(date +%s) - $(date -d "$(uptime --since)" +%s))); echo "$(($t/3600)):$(($t/60%60))"
					;;
				updates-available)
					apt-get --simulate --option Debug::NoLocking=true upgrade | grep -c ^Inst
					;;
				processes)
					ps -ef | wc -l
					;;
				distro)
					(. /etc/os-release && echo "$NAME $VERSION")
					;;
				load-average)
					cat /proc/loadavg | cut -d' ' -f1-3
					;;
			esac
		'';
		xxenv-install = pkgs.writeShellScriptBin "xxenv-install" ''
			nix-shell "${../files/xxenv-install}" --argstr package "$1" --command "${../files/xxenv-install/xxenv-install.sh} $*"
		'';
		pyenv-install-latest = pkgs.writeShellScriptBin "pyenv-install-latest" ''
			set -e
			_ver=$(${pyenv} latest -k 3)
			if ! ${pyenv} versions --bare | grep $_ver >/dev/null; then
				${getPkgExe "xxenv-install"} pyenv $_ver
			fi
			${pyenv} global $_ver
		'';
		rbenv-install-latest = pkgs.writeShellScriptBin "rbenv-install-latest" ''
			set -e
			_ver=$(${rbenv} install --list | grep -v - | tail -n 1 | sed 's/^[ \t]*//;s/[ \t]*$//')
			if ! ${rbenv} versions --bare | grep $_ver >/dev/null; then
				${getPkgExe "xxenv-install"} rbenv $_ver
			fi
			${rbenv} global $_ver
		'';
		luaenv-install = pkgs.writeShellScriptBin "luaenv-install" ''
			set -e
			_install() {
				${getPkgExe "xxenv-install"} luaenv "$@"
				LUAENV_VERSION=$1 ${luaenv} luarocks
			}
			for i in $@; do
				_install $i
			done
		'';
		luaenv-install-latest = pkgs.writeShellScriptBin "luaenv-install-latest" ''
			set -e
			_ver=$(${luaenv} install --list | grep -v - | tail -n 1 | sed 's/^[ \t]*//;s/[ \t]*$//')
			if ! ${luaenv} versions --bare | grep $_ver >/dev/null; then
				${getPkgExe "luaenv-install"} $_ver
			fi
			${luaenv} global $_ver
		'';
		nvim-install-env = pkgs.writeShellScriptBin "nvim-install-env" ''
			set -e

			while [[ $# -gt 0 ]]; do
			  case $1 in
				--update)
					update=1
					shift
					;;
				*)
					echo "Unknown option $1"
					exit 1
					;;
			  esac
			done

			echo "---------------------"
			echo "Check Python environments..."
			export PYENV_ROOT=''${PYENV_ROOT:-${config.home.sessionVariables.PYENV_ROOT}}
			if [ -n "$update" ] || [ $(${pyenv} global) = "system" ]; then
				${getPkgExe "pyenv-install-latest"}
			fi
			if [ -n "$update" ] && \
				[ -d "$PYENV_ROOT/versions/neovim" ] && \
				[ "$(${pyenv} latest -k 3)" != "$(PYENV_VERSION=neovim pyenv exec python --version | awk '{print $2;}')" ]
			then
				${pyenv} uninstall --force neovim
			fi
			if [ ! -d "$PYENV_ROOT/versions/neovim" ]; then
				echo "Installing Python provider..."
				${pyenv} virtualenv $(${pyenv} global 2>/dev/null) neovim
				"$PYENV_ROOT/versions/neovim/bin/pip" install neovim
			fi

			echo "---------------------"
			echo "Check Ruby environments..."
			export RBENV_ROOT=''${RBENV_ROOT:-${config.home.sessionVariables.RBENV_ROOT}}
			if [ -n "$update" ] || [ $(${rbenv} global) = "system" ]; then
				${getPkgExe "rbenv-install-latest"}
			fi
			NVIM_GEMSET_VERSION=$(RBENV_GEMSETS=neovim rbenv exec ruby --version | awk '{print $2;}')
			if [ -n "$update" ] && \
				(rbenv gemset list | grep neovim >/dev/null) && \
				[ "$(${rbenv} install --list | grep -v - | tail -n 1 | sed 's/^[ \t]*//;s/[ \t]*$//')" != "$NVIM_GEMSET_VERSION" ]
			then
				${rbenv} gemset delete "$NVIM_GEMSET_VERSION" neovim
			fi
			if [ ! -d "$RBENV_ROOT/versions/$NVIM_GEMSET_VERSION/gemsets/neovim" ]; then
				echo "Installing Ruby provider..."
				${rbenv} gemset create $(${rbenv} global 2>/dev/null) neovim
				RBENV_GEMSETS=neovim rbenv exec gem install neovim
				# rbenv-gemset doesn't rehash
				${rbenv} rehash
			fi

			echo "---------------------"
			echo "Check Perl environments..."
			export PLENV_ROOT=''${PLENV_ROOT:-${config.home.sessionVariables.PLENV_ROOT}}
			_ver=$(realpath "$PLENV_ROOT/versions/neovim/bin/perl" | sed "s/^.*perl//")
			if [ -n "$update" ]; then
				_cur_ver=$_ver
				_ver=$(${plenv} install --list | grep -v - | sed -n 's/^[ \t]*//;s/[ \t]*$//;/[0-9]\+\.[0-9]\+\.[0-9]\+/p' | head -n 1)
				if [ -d "$PLENV_ROOT/versions/neovim" ] && [ ! -f "$PLENV_ROOT/versions/neovim/bin/perl$_ver" ]; then # not latest version
					echo "Detected latest Perl version: $_ver. (current: $_cur_ver)"
					${plenv} uninstall -f neovim
				else
					echo "Latest version $_ver was already installed."
				fi
			fi
			if [ ! -d "$PLENV_ROOT/versions/neovim" ]; then
				echo "Installing Perl environment..."
				${plenv} install "$_ver" --as neovim -Dusedevel
				PLENV_VERSION=neovim ${plenv} install-cpanm
			else
				echo "There exists a Perl version \`neovim\`."
			fi
			if [ ! -d "$PLENV_ROOT"/versions/neovim/lib/perl"$(echo "$_ver" | cut -b 1)"/site_perl/"$_ver"/Neovim ]; then
				echo "Installing Perl provider..."
				PLENV_VERSION=neovim ${plenv} install-cpanm
				PLENV_VERSION=neovim "$PLENV_ROOT/shims/cpanm" -n Neovim::Ext
			else
				echo "Perl provider already installed."
			fi

			echo "---------------------"
			echo "Check Lua environments..."
			export LUAENV_ROOT=''${LUAENV_ROOT:-${config.home.sessionVariables.LUAENV_ROOT}}
			# nvim requires lua 5.1; https://neovim.io/doc/user/lua.html
			lua_ver=5.1
			lua_latest_ver=$(${luaenv} install --list | sed 's/^[ \t]*//;s/[ \t]*$//' | grep -E '^'$lua_ver | tail -n 1)
			if [ -n "$update" ]; then
				find_ver=$lua_latest_ver
			else
				find_ver=$lua_ver.
			fi
			if [ -z "$(find "$LUAENV_ROOT"/versions -maxdepth 1 -type d -name "$find_ver*")" ]; then
				echo "Installing Lua $lua_latest_ver..."
				${getPkgExe "luaenv-install"} $lua_latest_ver
			else
				echo "Found versions $find_ver*, nothing to do."
			fi
		'';
		mise-install-all = pkgs.writeShellScriptBin "mise-install-all" ''
			# set -e
			${mise} ls-remote --all >/dev/null
			if ${mise} ls --global >/dev/null 2>&1 && \
				[ -z "$(${mise} outdated --quiet)" ]
			then
				echo "All mise packages are up to date."
			else
				echo "Installing mise packages..."
				# npm needs bash, so have to include `/usr/bin`
				# mise will only append paths of the tools to be installed. setting $PATH to force use the mise ones.
				__tmp=$(mktemp -d)
				ln -s ${mise} $__tmp # some npm packages needs mise, link to a temp folder
				# npm needs ssh to clone git repos
				export PATH=''${MISE_DATA_DIR:-${config.xdg.dataHome}/mise}/shims:/usr/bin:${pkgs.openssh}/bin:$__tmp
				eval "$(${mise} activate bash 2>/dev/null)"
				# we're in a script, so need to run the hook manually
				eval "$(${mise} --cd $HOME hook-env -s bash)"
				# https://github.com/asdf-community/asdf-nim creates a `tmp/nim/$ver` folder inside `ASDF_DATA_DIR`
				# although the tool cleans up the folder, the upper levels (`ASDF_DATA_DIR`, `tmp`, `nim`) are not removed.
				export ASDF_DATA_DIR=$__tmp
				if [ -n "$(${mise} ls --global --missing --no-header)" ]; then
					${mise} --cd $HOME install --verbose --yes
				fi
				if [ -n "$(${mise} upgrade --dry-run)" ]; then
					${mise} --cd $HOME upgrade --yes
					# pipx creates venvs with some python version
					# if the version is later deleted, mise won't check if the venv still exists.
					# and the venvs would be linking to a non-existing python.
					# this should reinstall pipx packages according to doc
					# ${mise} --cd $HOME upgrade python --yes
				fi
			fi
			${mise} --cd $HOME prune --yes
			PATH=${config.xdg.stateHome}/nix/profile/bin ${mise} reshim # reshim looks for `mise` in `PATH`
			invalid_links=($(find "''${MISE_DATA_DIR:-${config.xdg.dataHome}/mise}/shims" -type l ! -exec test -e {} \; -exec basename {} \; -delete))
			if [[ -n "''${invalid_links[*]}" ]]; then
				echo "Removed invalid symbolic links \"''${invalid_links[@]}\""
			fi
		'';
		start-jupyter = pkgs.writeShellScriptBin "start-jupyter" ''
			set -e
			while [[ $# -gt 0 ]]; do
				case $1 in
					update)
						update=1
						shift
						;;
					install)
						install=1
						shift
						;;
					*)
						echo "Unknown option $1"
						exit 1
						;;
			  	esac
			done
			export PYENV_ROOT=''${PYENV_ROOT:-${config.home.sessionVariables.PYENV_ROOT}}
			export XDG_DATA_HOME=''${XDG_DATA_HOME:-${config.xdg.dataHome}}
			export MAMBA_ROOT_PREFIX=''${MAMBA_ROOT_PREFIX:-${config.xdg.dataHome}/conda}

			# iruby
			# https://github.com/chuckremes/ffi-rzmq-core/blob/master/lib/ffi-rzmq-core/libzmq.rb
			# export ZMQ_LIB_PATH=$${zeromq}/lib
			# export RBENV_GEMSETS=playground
			# nixpkgs.iruby doesn't seem to have libzmq...

			[ $(${pyenv} global) = "system" ] && ${getPkgExe "pyenv-install-latest"}
			if [ ! -d "$PYENV_ROOT/versions/playground" ]; then
				printf "\n\033[1;33mCreating Python virtual env ...\033[0m\n"
				${pyenv} virtualenv $(${pyenv} global) playground
			else
				printf "\n\033[0;32mPython virtual env OK...\033[0m\n"
			fi
			eval "$(${pyenv} init -)"
			eval "$(${pyenv} virtualenv-init -)"
			pyenv activate playground

			if [[ -n "$update" ]]; then
				printf "\n\033[1;33mChecking upgrades for pip packages (dry run) ...\033[0m\n"
				(pip install --dry-run --upgrade -r "${../files/playground.requirements.txt}"; pip install --dry-run --upgrade -r "${../files/playground.torch.requirements.txt}") | grep -v "Requirement already satisfied"
				read -p "That was a dry run. Update? (y/n) " -n 1 -r
				echo ""
				if [[ "$REPLY" =~ ^[yY]$ ]]; then
					printf "\n\033[1;33mUpgrading pip ...\033[0m\n"
					pip install --upgrade pip
					printf "\n\033[1;33mUpgrading pip packages ...\033[0m\n"
					(pip install --upgrade -r "${../files/playground.requirements.txt}"; pip install --upgrade -r "${../files/playground.torch.requirements.txt}") | grep -v "Requirement already satisfied"
				fi
			elif [[ -n "$install" ]]; then
				printf "\n\033[0;32mInstall Python packages...\033[0m\n"
				(pip install -r "${../files/playground.requirements.txt}"; pip install -r "${../files/playground.torch.requirements.txt}") | grep -v "Requirement already satisfied" || printf "\n\033[0;32mPip packages ok...\033[0m\n"
			fi
			pyenv rehash

			if [[ -n "$install" ]] || [[ -n "$update" ]]; then
				(jupyter-kernelspec list | grep bash >/dev/null) || \
					(printf "\n\033[1;33mInstalling bash kernel...\033[0m\n" && python -m bash_kernel.install)

				# https://github.com/dahn-zk/zsh-jupyter-kernel/blob/1bb6fe690930feffaee63faea5e77e3589ee9a98/zsh_jupyter_kernel/install.py#L19
				(jupyter-kernelspec list | grep bash >/dev/null) || \
					(printf "\n\033[1;33mInstalling bash kernel...\033[0m\n" && python -m zsh_jupyter_kernel.install --user)

				# https://vatlab.github.io/sos-docs/running.html#Local-installation
				# https://github.com/vatlab/sos-notebook/blob/48b9c2d6d0bcb60af39f7af93f82ccb38948311e/src/sos_notebook/install.py#L46
				(jupyter-kernelspec list | grep sos >/dev/null) || \
					(printf "\n\033[1;33mInstalling Script of Script...\033[0m\n" && python -m sos_notebook.install --prefix "$XDG_DATA_HOME"/..)
			fi

			if command -v micromamba >/dev/null; then
				has_mamba=1
			fi
			mamba_env_name=jupyter-kernels
			if [[ -n "$has_mamba" ]]; then
				# skip if no `update` or `install` flags
				if [[ -n "$update" ]] || [[ -n "$install" ]]; then
					if ! (micromamba list --name $mamba_env_name | grep xeus-lua >/dev/null 2>/dev/null); then
						printf "\n\033[0;31mConda environment \"$mamba_env_name\" does not have package \"xeus-lua\", so the environment will be removed first...\033[0m\n"
						micromamba env remove --name $mamba_env_name
					fi
					if [ ! -d "$MAMBA_ROOT_PREFIX/envs/$mamba_env_name" ]; then
						printf "\n\033[1;33mInstalling conda environment...\033[0m\n"
						micromamba create -n $mamba_env_name
						micromamba install --file "${../files/jupyter-kernels.yml}"
					else
						if [[ -n "$update" ]]; then
							printf "\n\033[1;33mUpgrading conda environment...\033[0m\n"
							micromamba update --file "${../files/jupyter-kernels.yml}"
						else
							printf "\n\033[0;32mConda environment OK...\033[0m\n"
						fi
					fi
				fi
			else
				printf "\n\033[0;31mNo \"micromamba\" binary. Skipping...\033[0m\n"
			fi

			if [[ -n "$install" ]] || [[ -n "$update" ]]; then
				# `ijavascript` invokes `jupyter kernelspec install`
				if command -v ijsinstall >/dev/null; then
					(jupyter-kernelspec list | grep javascript >/dev/null) || \
					(printf "\n\033[1;33mInstalling ijavascript...\033[0m\n" && ijsinstall)
				else
					printf "\n\033[0;31mijsinstall not found... Skipped...\033[0m\n"
				fi

				# https://github.com/winnekes/itypescript/blob/master/doc/usage.md
				if command -v its >/dev/null; then
					if ! (jupyter-kernelspec list | grep typescript >/dev/null); then
						its_update=1
					fi
					its_node=$(${jaq} --raw-output ".argv[0]" < "$XDG_DATA_HOME"/jupyter/kernels/typescript/kernel.json)
					if ! [[ -f "$its_node" ]]; then
						printf "\n\033[1;33mNode ($its_node) specified in \`kernel.json\` doesn't exist.\033[0m\n$(${mise} which node)"
						its_update=1
					fi
					its_its=$(${jaq} --raw-output ".argv[1]" < "$XDG_DATA_HOME"/jupyter/kernels/typescript/kernel.json)
					if ! [[ -f "$its_its" ]]; then
						printf "\n\033[1;33mItypescript ($its_its) specified in \`kernel.json\` doesn't exist.\033[0m\n$(${mise} which its)"
						its_update=1
					fi
					if [[ -n "$its_update" ]]; then
						printf "\n\033[1;33mInstalling itypescript...\033[0m\n"
						its --install=local
					fi
				else
					printf "\n\033[0;31mCommand \`its\` not on PATH... Skipped...\033[0m\n"
				fi

				# https://github.com/evcxr/evcxr/blob/main/evcxr_jupyter/README.md
				# `evcxr` doesn't recognise `:` in `JUPYTER_PATH`. Let's just install to the default path, `$XDG_DATA_HOME/jupyter`
				if command -v evcxr_jupyter >/dev/null; then
					if ! (jupyter-kernelspec list | grep rust > /dev/null); then
						rust_update=1
					fi
					evcxr=$(${jaq} --raw-output ".argv[0]" < "$XDG_DATA_HOME"/jupyter/kernels/rust/kernel.json)
					if ! [[ -f "$evcxr" ]]; then
						printf "\n\033[1;33mevcxr_jupyter ($evcxr) specified in \`kernel.json\` doesn't exist.\033[0m\n$(${mise} which evcxr_jupyter)"
						rust_update=1
					fi
					if [[ -n "$rust_update" ]]; then
						printf "\n\033[1;33mInstalling evcxr...\033[0m\n"
						JUPYTER_PATH=$XDG_DATA_HOME/jupyter evcxr_jupyter --install
					fi
				else
					printf "\n\033[0;31mevcxr_jupyter not found... Skipped...\033[0m\n"
				fi

				# https://github.com/root-project/cling/tree/master/tools/Jupyter
				if [[ -n "$update" ]]; then
					cling_kernel_version=$(pip list | grep clingkernel | awk '{print $2;}')
					cling_pkg_version=$(PYTHONPATH=${config.lib.packages.cling.unwrapped}/share/Jupyter/kernel python -c "from setup import setup_args; print(setup_args['version'])")
					if [[ "$cling_kernel_version" != "$cling_pkg_version" ]]; then
						printf "\n\033[1;33mCling version: $cling_kernel_version; Latest version: $cling_pkg_version\033[0m\n"
						cling_update=1
					fi
				fi
				if ! (pip list | grep clingkernel) > /dev/null || [[ -n "$cling_update" ]]; then
					tmpdir=$(mktemp -d)
					cp -r "${config.lib.packages.cling.unwrapped}/share/Jupyter/kernel" "$tmpdir"
					chmod +w -R "$tmpdir"/kernel
					pip install -e "$tmpdir"/kernel
					rm -rf "$tmpdir"
				fi
				for k in "cling-cpp11" "cling-cpp14" "cling-cpp17" "cling-cpp1z"; do
					(jupyter-kernelspec list | grep $k > /dev/null) || \
						(printf "\n\033[1;33mInstalling $k...\033[0m\n" && \
						jupyter-kernelspec install --prefix "$XDG_DATA_HOME/.." "${config.lib.packages.cling.unwrapped}/share/Jupyter/kernel/$k" && \
						chmod +w -R "$XDG_DATA_HOME/jupyter/kernels/$k")
				done

				# https://julialang.github.io/IJulia.jl/stable/manual/usage/
				if command -v juliaup >/dev/null; then
					julia_latest_ver=$(juliaup status | grep '\*' | awk '{print $3}' | sed -n 's/^\([0-9]\+\.[0-9]\+\).*/\1/p')
					# Delete old versions
					julia_kernel_vers=($(jupyter-kernelspec list | grep julia | awk '{print $1}'))
					for ver in "''${julia_kernel_vers[@]}"; do
						if [[ "$ver" != "julia-$julia_latest_ver" ]]; then
							printf "\n\033[1;31mDeleting old Julia kernel version $ver\033[0m\n"
							rm -rf "$XDG_DATA_HOME/jupyter/kernels/$ver"
						fi
					done
					if !(jupyter-kernelspec list | grep julia-"$julia_latest_ver" >/dev/null); then
						julia_update=1
					else
						julia=$(${jaq} --raw-output ".argv[0]" < "$XDG_DATA_HOME"/jupyter/kernels/julia-"$julia_latest_ver"/kernel.json)
						if ! [[ -f "$julia" ]]; then
							printf "\n\033[1;33mThe Julia ($julia) specified in \`kernel.json\` doesn't exist.\033[0m\n"
							julia_update=1
						fi
					fi
					if [[ -n "$julia_update" ]]; then
						printf "\n\033[1;33mInstalling IJulia...\033[0m\n"
						julia --project="$XDG_DATA_HOME"/jupyter/envs/ijulia -E '
							import Pkg; Pkg.add("IJulia")
							import IJulia; IJulia.installkernel("julia", "--project=$(ENV["XDG_DATA_HOME"])/jupyter/envs/ijulia")
						'
					fi
				else
				  printf "\n\033[0;31mjuliaup not found... Skipped...\033[0m\n"
				fi

				# printf "\n\033[1;33mChecking iruby ...\033[0m\n"
				# if !(${rbenv} gemset list | grep playground >/dev/null); then
				# 	printf "\n\033[1;33mCreating gemset \"playground\"...\033[0m\n"
				# 	${rbenv} gemset create $(${rbenv} global 2>/dev/null) playground
				# fi
				# export RBENV_GEMSETS=playground
				# if !(gem list | grep iruby >/dev/null); then
				# 	printf "\n\033[1;33mInstalling IRuby...\033[0m\n"
				# 	gem install bundler
				# 	# Gemfile
				# 	gem install rubygems-requirements-system
				#   # ruby gems can define system requirements https://github.com/SciRuby/iruby/blob/master/iruby.gemspec; need a way to bypass
				# 	gem install iruby
				# 	gem install pry
				# fi
				# if [[ -n "$update" ]]; then
				# 	printf "\n\033[1;33mUpgrading gems...\033[0m\n"
				# 	gem update
				# fi
				# if !(jupyter-kernelspec list | grep ruby >/dev/null); then
				# 	# iruby uses `jupyter kernelspec install`
				# 	printf "\n\033[1;33mInstalling IRuby kernel...\033[0m\n"
				# 	rbenv exec iruby register
				# elif [[ -n "$update" ]]; then
				# 	printf "\n\033[1;33mForce re-installing IRuby kernel...\033[0m\n"
				# 	rbenv exec iruby register --force
				# fi

				# `nix-instantiate a.nix --add-root ./result` or `nix-store --add-root ./result --realise`
				# printf "\n\033[1;33mForce re-installing IHaskell kernel...\033[0m\n"
				# following the guide, nix package `haskellPackages.ihaskell-charts` is marked broken
				# $${lib.getExe pkgs.ihaskell} install --conf=$${config.xdg.configHome} # --ghclib= --prefix=
			fi

			export JUPYTER_PATH=''${JUPYTER_PATH:+$JUPYTER_PATH:}"$MAMBA_ROOT_PREFIX/envs/$mamba_env_name/share/jupyter:$XDG_DATA_HOME/jupyter"

			app_dir="$XDG_DATA_HOME"/jupyter/lab
			if [[ -n "$install" ]] || [[ -n "$update" ]]; then
				printf "\n\033[1;33mRebuilding JupyterLab...\033[0m\n"
				jupyter lab build --app-dir=$app_dir
			fi

			printf "\n\033[0;32mRun jupyter with kernels:\033[0m\n"
			jupyter-kernelspec list

			if [[ -z "$install" ]] && [[ -z "$update" ]]; then
				if [ -z "$XDG_DOCUMENTS_DIR" ]; then
				  printf "\n\033[0;31m'XDG_DOCUMENTS_DIR' not set, starting jupyter at '$HOME/jupyter'...\033[0m\n"
				fi
				notebook_dir="''${XDG_DOCUMENTS_DIR:-$HOME}/jupyter"
				[ -d "$notebook_dir" ] || mkdir -p "$notebook_dir"
				if [[ -n "$has_mamba" ]] && [[ -d "$MAMBA_ROOT_PREFIX/envs/$mamba_env_name" ]]; then
					# eval "$(micromamba shell hook --shell bash)"
					# micromamba activate --stack "$mamba_env_name"
					eval "$(micromamba shell activate --stack "$mamba_env_name" --shell bash)" # activate an env without init-hook
				fi

				exec jupyter lab \
				  --notebook-dir="$notebook_dir" \
				  --app-dir="$app_dir" \
				  --VoilaConfiguration.enable_nbextensions=True \
				  --ServerApp.use_redirect_file=False || printf "\n\033[0;31mFailed to start jupyter lab\033[0m\n"
			fi
		'';
	};
in {
	home.packages = lib.attrValues packages;
	lib.packages = packages;
}
