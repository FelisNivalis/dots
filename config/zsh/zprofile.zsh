if [[ ! -e "$BYOBU_CONFIG_DIR/.welcome-displayed" ]] || [[ -e "$BYOBU_CONFIG_DIR/disable-autolaunch" ]]; then
	echo "enabling byobu..."
	[ -f "$BYOBU_CONFIG_DIR/disable-autolaunch" ] && rm "$BYOBU_CONFIG_DIR/disable-autolaunch"
	touch "$BYOBU_CONFIG_DIR/.welcome-displayed"
	# byobu-enable
fi
_byobu_sourced=1 . /usr/bin/byobu-launch 2>/dev/null || true
