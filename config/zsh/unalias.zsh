[[ ! -f $ADOTDIR/aliases_to_keep ]] && return 0
local aliases_to_keep=$(cat $ADOTDIR/aliases_to_keep)
aliases_to_keep=(${(@s: :)aliases_to_keep})
# echo ${(k)aliases_to_keep}
for a in ${(k)aliases}; do
	if [[ -n "$a" ]] && ! (($aliases_to_keep[(Ie)$a])); then
		# echo "unalias $a"
		unalias $a
	fi
done
