#!/usr/bin/env bash
_cmd=$1
_CMD=$(echo "$_cmd" | tr '[:lower:]' '[:upper:]')
shift
read -p "Running \`$_cmd install $*\`, continue? (y/n) " -n 1 -r
echo ""
if [[ ! "$REPLY" =~ ^[yY]$ ]]; then
	exit 1
fi
$_cmd install "$@"
for i in "$@"; do
	dir=$(eval "echo \$${_CMD}_ROOT")/versions/$i/bin
	for file in $(ls -A "$dir"); do
		bin="$dir/$file"
		if [ -f "$bin" ] && ldd "$bin" 1>/dev/null 2>&1; then
			echo "Patching $bin..."
			patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 "$bin"
			patchelf --set-rpath "\$ORIGIN/../lib" "$bin"
			patchelf --shrink-rpath "$bin"
		else
			echo "Skipping non-dynamic executable: $bin..."
		fi
	done
done
