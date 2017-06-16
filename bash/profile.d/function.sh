# Executable
is-executable() {
	local BIN=$(command -v "$1" 2>/dev/null)

	if [[ ! $BIN == "" && -x $BIN ]] ; then
		true;
	else 
		false;
	fi
}

# Add to path
prepend-path() {
	[[ -d $1 ]] && PATH="$1:$PATH"
}

# Get x-server
function get_xserver() {
	case $TERM in
		xterm)
			XSERVER=$(who am i | awk '{ print $NF }' | tr -d ')''(' )
			XSERVER=${XSERVER%%:*}
			;;
	esac
}

is-supported() {
	if [[ $# -eq 1 ]] ; then
		if eval "$1" > /dev/null 2>&1 ; then
			true;
		else
			false;
		fi
	else
		if eval "$1" > /dev/null 2>&1 ; then
			echo -n "$2"
		else
			echo -n "$3"
		fi
	fi
}
