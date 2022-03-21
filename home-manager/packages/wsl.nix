{ lib, config, pkgs, system, inputs, ... }: rec {
  home = {
    activation = {
      copySSH-WSL = lib.hm.dag.entryAfter ["writeBoundary"] ''
		if [ ! -f "${config.home.homeDirectory}"/.ssh/id_rsa ]; then
			echo "Copying ssh keys..."
			[ ! -d "${config.home.homeDirectory}/.ssh" ] && mkdir "${config.home.homeDirectory}"/.ssh
			WIN_USER="$(echo "$(cmd.exe /c echo %USERNAME%)" | tr -d '[:space:]')"
			cp /mnt/c/Users/$WIN_USER/.ssh/id_rsa "${config.home.homeDirectory}"/.ssh
			chmod 0400 "${config.home.homeDirectory}"/.ssh/id_rsa
			cp /mnt/c/Users/$WIN_USER/.ssh/id_rsa.pub "${config.home.homeDirectory}"/.ssh
			chmod 0444 "${config.home.homeDirectory}"/.ssh/id_rsa.pub
		fi
      '';
	  copyX-WSL = lib.hm.dag.entryAfter ["writeBoundary"] ''
		if [ ! -f "${config.xdg.configHome}"/.Xauthority ]; then
			echo "Copying X authority file..."
			[ ! -d "${config.xdg.configHome}" ] && mkdir -p "${config.xdg.configHome}"
			cp -r /mnt/c/Users/$WIN_USER/.Xauthority "${config.xdg.configHome}"
			chmod 0600 "${config.xdg.configHome}"/.Xauthority
		fi
	  '';
	  linkFirefox-WSL = let
	  	binHome = config.home.sessionVariables.XDG_BIN_HOME;
	  in lib.hm.dag.entryAfter ["writeBoundary"] ''
		if [ ! -f "${binHome}"/firefox.exe ]; then
			echo "Linking firefox executable..."
			[ ! -d "${binHome}" ] && mkdir -p "${binHome}"
			ln -s "/mnt/c/Program Files/Mozilla Firefox/firefox.exe" "${binHome}"/firefox.exe
		fi
	  '';
    };
  };
}
