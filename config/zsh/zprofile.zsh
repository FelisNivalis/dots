# start multiplexer before most things, so won't execute twice
case $MULTIPLEXER in
	byobu)
		if [ ! -f "$HOME/.no-byobu-launch" ]; then
			if [ ! -e "$BYOBU_CONFIG_DIR/.welcome-displayed" ] || [ -e "$BYOBU_CONFIG_DIR/disable-autolaunch" ]; then
				echo "enabling byobu..."
				[ -f "$BYOBU_CONFIG_DIR/disable-autolaunch" ] && rm "$BYOBU_CONFIG_DIR/disable-autolaunch"
				touch "$BYOBU_CONFIG_DIR/.welcome-displayed"
				# byobu-enable
			fi
			_byobu_sourced=1 . /usr/bin/byobu-launch 2>/dev/null || true
		fi
		;;
	zellij)
		if [[ -z "$ZELLIJ" ]]; then
			# here mise not ready yet.
			zellij="$XDG_DATA_HOME/mise/installs/cargo-zellij/latest/bin/zellij"
			# Welcome session persists after attaching to existing session
			# https://github.com/zellij-org/zellij/issues/4426
			if [[ -f "$zellij" ]]; then
				if [[ "$("$zellij" ls | grep -v EXITED | wc -l)" -ge 1 ]]; then
					"$zellij"
				else
					"$zellij" attach -c # quit when >= 2 live sessions
				fi
			else
				echo "File \`$zellij\` does not exist."
			fi
			unset zellij
			exit
		else
			echo "Inside Zellij."
		fi
		;;
esac
