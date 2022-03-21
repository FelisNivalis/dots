{ config, pkgs, inputs, overrideSrc, ... }: let
	unwrapped = (overrideSrc pkgs.neovim.unwrapped inputs.neovim-src);
	wrapped = pkgs.runCommand "neovim" {
		buildInputs = [ pkgs.makeWrapper ];
	} ''
		mkdir -p $out/bin
		makeWrapper ${unwrapped}/bin/nvim $out/bin/nvim \
			--run ${config.lib.packages.nvim-install-env}/bin/nvim-install-env
	''; # https://nixos.wiki/wiki/Nix_Cookbook
in {
	home.packages = [ wrapped ];
}
