start-jupyter() {
  __start-jupyter-cleanup() {
    echo "Cleanup..."
    micromamba deactivate || true
    source deactivate || true
    trap - INT TERM
  }
  trap __start-jupyter-cleanup INT TERM

  pyenv-install-if-not-exists
  if [ ! -d "$PYENV_ROOT/versions/playground" ]; then
    local latest
    latest=$(pyenv latest 3)
    if ! (pyenv versions | grep $latest) >/dev/null; then
      echo "Install Python $latest..."
      pyenv-install $latest
    fi
    pyenv virtualenv $latest playground
  else
    echo "Python virtual env OK..."
  fi
  pyenv activate playground
  pip install -r "%files%/playground.requirements.txt" | grep -v "Requirement already satisfied" || echo "Pip packages ok..."

  (jupyter-kernelspec list | grep bash >/dev/null) || \
    (echo "Installing bash kernel..." && python -m bash_kernel.install)

  # (jupyter-kernelspec list | grep sos >/dev/null) || \
  #   (echo "Installing Script of Script..." && python -m sos_notebook.install)

  if [ ! -d "$MAMBA_ROOT_PREFIX/envs/jupyter-kernels" ]; then
    echo "Install conda environment..."
    micromamba create -n jupyter-kernels
    micromamba install --file "%files%/jupyter-kernels.yml"
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
    cp -r "%cling%/share/Jupyter/kernel" /tmp/
    chmod +w -R /tmp/kernel
    pip install -e /tmp/kernel
    rm -rf /tmp/kernel
  fi
  for k in "cling-cpp11" "cling-cpp14" "cling-cpp17" "cling-cpp1z"; do
    (jupyter-kernelspec list | grep $k > /dev/null) || \
      (echo "Installing $k..." && jupyter-kernelspec install --prefix "$XDG_DATA_HOME/.." "%cling%/share/Jupyter/kernel/$k")
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

  local jupyter_data_path
  if [ -z "$XDG_DOCUMENTS_DIR" ]; then
    echo "'XDG_DOCUMENTS_DIR' not set, starting jupyter at '$HOME/Desktop/Documents'..."
  fi
  jupyter_data_path="${XDG_DOCUMENTS_DIR:-$HOME/Desktop/Documents}/jupyter"
  [ -d "$jupyter_data_path" ] || mkdir -p "$jupyter_data_path"
  micromamba activate --stack jupyter-kernels

  JUPYTER_PATH=${JUPYTER_PATH:+$JUPYTER_PATH:}"$MAMBA_ROOT_PREFIX/envs/jupyter-kernels/share/jupyter:$XDG_DATA_HOME/jupyter" \
  jupyter lab \
    --notebook-dir=$jupyter_data_path \
    --VoilaConfiguration.enable_nbextensions=True \
    --NotebookApp.use_redirect_file=False || echo "Failed to start jupyter lab"
  __start-jupyter-cleanup
}
