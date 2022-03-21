{ lib, pkgs, config, ... }: let
	getPkgExe = name: "${config.lib.packages.${name}}/bin/${name}";
	pyenv = getPkgExe "pyenv";
	rbenv = getPkgExe "rbenv";
	plenv = getPkgExe "plenv";
	luaenv = getPkgExe "luaenv";
	mise = getPkgExe "mise";
	micromamba = getPkgExe "micromamba";
	packages = {
		xxenv-install = pkgs.writeShellScriptBin "xxenv-install" ''
			nix-shell "${../files/xxenv-install}" --argstr package "$1" --command "${../files/xxenv-install}/xxenv-install.sh $@"
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
				${luaenv} install $@
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
			export PYENV_ROOT=''${PYENV_ROOT:-${config.home.sessionVariables.PYENV_ROOT}}
			[ $(${pyenv} global) = "system" ] && ${getPkgExe "pyenv-install-latest"}
			if [ ! -d "$PYENV_ROOT/versions/neovim" ]; then
				echo "Installing Python provider..."
				${pyenv} virtualenv $(${pyenv} global 2>/dev/null) neovim
				"$PYENV_ROOT/versions/neovim/bin/pip" install neovim
			fi

			export RBENV_ROOT=''${RBENV_ROOT:-${config.home.sessionVariables.RBENV_ROOT}}
			[ $(${rbenv} global) = "system" ] && ${getPkgExe "rbenv-install-latest"}
			if [ ! -d "$RBENV_ROOT/versions/$(${rbenv} global 2>/dev/null)/gemsets/neovim" ]; then
				echo "Installing Ruby provider..."
				${rbenv} gemset create $(${rbenv} global 2>/dev/null) neovim
				RBENV_GEMSETS=neovim "$RBENV_ROOT/shims/gem" install neovim
				# rbenv-gemset doesn't rehash
				${rbenv} rehash
			fi

			export PLENV_ROOT=''${PLENV_ROOT:-${config.home.sessionVariables.PLENV_ROOT}}
			_ver=$(${plenv} install --list | grep -v - | sed -n 's/^[ \t]*//;s/[ \t]*$//;/[0-9]\+\.[0-9]\+\.[0-9]\+/p' | head -n 1)
			# if [ -d "$PLENV_ROOT/versions/neovim" ] && [ ! -f "$PLENV_ROOT/versions/neovim/bin/perl$_ver" ]; then # not latest version
			# 	echo "Detected latest Perl version: $_ver. (current: $(realpath "$PLENV_ROOT/versions/neovim/bin/perl" | sed "s/^.*perl//"))"
			# 	${plenv} uninstall -f neovim
			# fi
			if [ ! -d "$PLENV_ROOT/versions/neovim" ]; then
				echo "Installing Perl environment..."
				${plenv} install "$_ver" --as neovim -Dusedevel
				PLENV_VERSION=neovim ${plenv} install-cpanm
			fi
			if [ ! -d $PLENV_ROOT/versions/neovim/lib/perl"$(echo "$_ver" | cut -b 1)"/site_perl/"$_ver"/Neovim ]; then
				echo "Installing Perl provider..."
				PLENV_VERSION=neovim ${plenv} install-cpanm
				PLENV_VERSION=neovim "$PLENV_ROOT/shims/cpanm" -n Neovim::Ext
			fi
		'';
		mise-install-all = pkgs.writeShellScriptBin "mise-install-all" ''
			set -e
			if ${mise} ls --global >/dev/null 2>&1 && [ -z "$(${mise} ls --global --missing --no-header)" ]; then
				echo "All mise packages are already installed."
			else
				echo "Installing mise packages..."
				# npm needs bash, so have to include `/usr/bin`
				# mise will only append paths of the tools to be installed. setting $PATH to force use the mise ones.
				__tmp=$(mktemp -d)
				ln -s ${mise} $__tmp # some npm packages needs mise, link to a temp folder
				export PATH=''${MISE_DATA_DIR:-${config.xdg.dataHome}/mise}/shims:/usr/bin:$__tmp
				eval "$(${mise} activate 2>/dev/null)"
				# we're in a script, so need to run the hook manually
				eval "$(${mise} --cd $HOME hook-env -s bash)"
				# https://github.com/asdf-community/asdf-nim creates a `tmp/nim/$ver` folder inside `ASDF_DATA_DIR`
				# although the tool cleans up the folder, the upper levels (`ASDF_DATA_DIR`, `tmp`, `nim`) are not removed.
				ASDF_DATA_DIR=$__tmp ${mise} --cd $HOME install --verbose --yes
				${mise} --cd $HOME upgrade --yes
				${mise} --cd $HOME prune --yes
				${mise} reshim
				# pipx creates venvs with some python version
				# if the version is later deleted, mise won't check if the venv still exists.
				# and the venvs would be linking to a non-existing python.
			fi
		'';
		start-jupyter = pkgs.writeShellScriptBin "start-jupyter" ''
			set -e
			export PYENV_ROOT=''${PYENV_ROOT:-${config.home.sessionVariables.PYENV_ROOT}}
			export XDG_DATA_HOME=''${XDG_DATA_HOME:-${config.xdg.dataHome}}
			export MAMBA_ROOT_PREFIX=''${MAMBA_ROOT_PREFIX:-${config.xdg.dataHome}/conda}
			[ $(${pyenv} global) = "system" ] && ${getPkgExe "pyenv-install-latest"}
			if [ ! -d "$PYENV_ROOT/versions/playground" ]; then
			  ${pyenv} virtualenv $(${pyenv} global) playground
			else
			  echo "Python virtual env OK..."
			fi
			eval "$(${pyenv} init -)"
			eval "$(${pyenv} virtualenv-init -)"
			pyenv activate playground
			pip install -r "${../files/playground.requirements.txt}" | grep -v "Requirement already satisfied" || echo "Pip packages ok..."
			pyenv rehash

			(jupyter-kernelspec list | grep bash >/dev/null) || \
			  (echo "Installing bash kernel..." && python -m bash_kernel.install)

			# (jupyter-kernelspec list | grep sos >/dev/null) || \
			#   (echo "Installing Script of Script..." && python -m sos_notebook.install)

			if [ ! -d "$MAMBA_ROOT_PREFIX/envs/jupyter-kernels" ]; then
			  echo "Install conda environment..."
			  ${micromamba} create -n jupyter-kernels
			  ${micromamba} install --file "${../files/jupyter-kernels.yml}"
			else
			  echo "Conda environment OK..."
			fi

			# `ijavascript` invokes `jupyter kernelspec install`
			if command -v ijsinstall >/dev/null; then
			  (jupyter-kernelspec list | grep javascript >/dev/null) || \
			  (echo "Installing ijavascript..." && ijsinstall)
			else
			  echo "ijsinstall not found... Skipped..."
			fi

			# https://github.com/winnekes/itypescript/blob/master/doc/usage.md
			if command -v its >/dev/null; then
			  (jupyter-kernelspec list | grep typescript >/dev/null) || \
			  (echo "Installing itypescript..." && its --install=local)
			else
			  echo "its not found... Skipped..."
			fi

			# https://github.com/evcxr/evcxr/blob/main/evcxr_jupyter/README.md
			# `evcxr` doesn't recognise `:` in `JUPYTER_PATH`. Let's just install to the default path, `$XDG_DATA_HOME/jupyter`
			if command -v evcxr_jupyter >/dev/null; then
			  (jupyter-kernelspec list | grep rust > /dev/null) || \
			  (echo "Installing evcxr..." && (JUPYTER_PATH=$XDG_DATA_HOME/jupyter evcxr_jupyter --install))
			else
			  echo "evcxr_jupyter not found... Skipped..."
			fi

			# https://github.com/root-project/cling/tree/master/tools/Jupyter
			if ! (pip list | grep clingkernel) > /dev/null; then
			  cp -r "${config.lib.packages.cling.unwrapped}/share/Jupyter/kernel" /tmp/
			  chmod +w -R /tmp/kernel
			  pip install -e /tmp/kernel
			  rm -rf /tmp/kernel
			fi
			for k in "cling-cpp11" "cling-cpp14" "cling-cpp17" "cling-cpp1z"; do
			  (jupyter-kernelspec list | grep $k > /dev/null) || \
				(echo "Installing $k..." && jupyter-kernelspec install --prefix "$XDG_DATA_HOME/.." "${config.lib.packages.cling.unwrapped}/share/Jupyter/kernel/$k")
			  chmod +w -R "$XDG_DATA_HOME/jupyter/kernels/$k"
			done

			# https://julialang.github.io/IJulia.jl/stable/manual/usage/
			if command -v juliaup >/dev/null; then
			  (jupyter-kernelspec list | grep julia-$(juliaup status | grep '\*' | awk '{print $3}' | sed -n 's/^\([0-9]\+\.[0-9]\+\).*/\1/p') >/dev/null) || \
			  (echo "Installing IJulia..." && julia --project=$XDG_DATA_HOME/jupyter/envs/ijulia -E '
				import Pkg; Pkg.add("IJulia")
				import IJulia; IJulia.installkernel("julia", "--project=$(ENV["XDG_DATA_HOME"])/jupyter/envs/ijulia")
			  ')
			else
			  echo "juliaup not found... Skipped..."
			fi

			# https://vatlab.github.io/sos-docs/running.html#Local-installation

			echo "Run jupyter with kernels:"
			jupyter-kernelspec list

			if [ -z "$XDG_DOCUMENTS_DIR" ]; then
			  echo "'XDG_DOCUMENTS_DIR' not set, starting jupyter at '$HOME/Desktop/Documents'..."
			fi
			jupyter_data_path="''${XDG_DOCUMENTS_DIR:-$HOME/Desktop/Documents}/jupyter"
			[ -d "$jupyter_data_path" ] || mkdir -p "$jupyter_data_path"
			# eval "$(${micromamba} shell hook --shell bash)"
			# ${micromamba} activate --stack jupyter-kernels
			eval "$(${micromamba} shell activate --stack jupyter-kernels --shell bash)"

			JUPYTER_PATH=''${JUPYTER_PATH:+$JUPYTER_PATH:}"$MAMBA_ROOT_PREFIX/envs/jupyter-kernels/share/jupyter:$XDG_DATA_HOME/jupyter" \
			exec jupyter lab \
			  --notebook-dir=$jupyter_data_path \
			  --VoilaConfiguration.enable_nbextensions=True \
			  --NotebookApp.use_redirect_file=False || echo "Failed to start jupyter lab"
		'';
	};
in {
	home.packages = lib.attrValues packages;
	lib.packages = packages;
}
