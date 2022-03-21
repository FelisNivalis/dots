#!/usr/bin/bash
set -e
eval "$(conda shell.bash hook)"
if (conda env list | grep jupyter-kernels) >/dev/null; then
	conda activate --stack jupyter-kernels
fi
jupyter lab \
	--notebook-dir=$HOME/my/Documents/jupyter \
	--VoilaConfiguration.enable_nbextensions=True \
	--NotebookApp.use_redirect_file=False
