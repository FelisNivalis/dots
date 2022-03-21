# Configuration file for jupyter-server.
import os
import pathlib

c = get_config()  # noqa

base_dir = pathlib.Path(f"{os.environ["XDG_DATA_HOME"]}/nvim/mason/packages")

c.LanguageServerManager.extra_node_roots = [
    base_dir / d
    for d in os.listdir(base_dir)
    if (base_dir / d / "node_modules").exists()
]
