#------------------------------------------------------------------------------
# Shell Prompt
#------------------------------------------------------------------------------
# Current format: [TIME USER@HOST PWD]$
# TIME:
#       Green           == machine load is low
#       Bright Red      == machine load is medium
#       Red             == machine load is high
#       ALERT           == machine load is very high
# USER:
#       Red             == root
#       Bright Red      == SU to user
#       Bright Blue     == normal user
# HOST:
#       Bright Cyan     == Local session
#       Green           == secured remote connection (via ssh)
#       ALERT           == unsecured remote connection
# PWD:
#       Green           == more than 10% free disk space
#       Bright Red      == less than 10% free disk space
#       ALERT           == less than 5% free disk space
#       Red             == current user does not have write privileges
#       Cyan            == current filesystem is size zero (like /proc)
# $:
#       Bright Blue     == no background or suspended jobs in this shell
#       Bright Cyan     == at least on background job in this shell
#       Bright Red      == at least on suspended job in this shell

# Normal colors
AF_COLOR_BLACK='\e[0;30m'
AF_COLOR_RED='\e[0;31m'
AF_COLOR_GREEN='\e[0;32m'
AF_COLOR_YELLOW='\e[0;33m'
AF_COLOR_BLUE='\e[0;34m'
AF_COLOR_MAGENTA='\e[0;35m'
AF_COLOR_CYAN='\e[0;36m'
AF_COLOR_WHITE='\e[0;37m'

# Bold colors
AF_COLOR_BOLD_BLACK='\e[1;30m'
AF_COLOR_BOLD_RED='\e[1;31m'
AF_COLOR_BOLD_GREEN='\e[1;32m'
AF_COLOR_BOLD_YELLOW='\e[1;33m'
AF_COLOR_BOLD_BLUE='\e[1;34m'
AF_COLOR_BOLD_MAGENTA='\e[1;35m'
AF_COLOR_BOLD_CYAN='\e[1;36m'
AF_COLOR_BOLD_WHITE='\e[1;37m'

# Background colors
AB_COLOR_BLACK='\e[40m'
AB_COLOR_RED='\e[41m'
AB_COLOR_GREEN='\e[42m'
AB_COLOR_YELLOW='\e[43m'
AB_COLOR_BLUE='\e[44m'
AB_COLOR_MAGENTA='\e[45m'
AB_COLOR_CYAN='\e[46m'
AB_COLOR_WHITE='\e[47m'

COLOR_RESET='\e[0m'
COLOR_ALERT=${AF_COLOR_BOLD_WHITE}${AB_COLOR_RED}

# Test connection type:
function connection_color() {
	if [[ -n "${SSH_CONNECTION}" ]]; then
		# Connected on remote machine, via SSH (good)
		echo -en $AF_COLOR_GREEN
	elif [[ "${DISPLAY%%:0*}" != "" ]]; then
		# Connected on remote machine, not via SSH (bad)
		echo -en $COLOR_ALERT
	else
		# Connected on local machine
		echo -en $AF_COLOR_GREEN
	fi
}

# Test user type
function user_color() {
	if [[ "${USER}" == "root" ]]; then
		# User is root
		echo -en $AF_COLOR_RED
	elif [[ "${USER}" != "$(logname)" ]]; then
		# User is not login user
		echo -en $AF_COLOR_BOLD_RED
	else
		# User is normal
		echo -en $AF_COLOR_GREEN
	fi
}

function disk_color() {
	if [[ ! -w "${PWD}" ]]; then
		# No write permissions in the current directory
		echo -en $AF_COLOR_RED
	elif [[ -s "${PWD}" ]]; then
		local used=$(command df -P "${PWD}" | awk 'END { print $5 } { sub(/%/,"") }')

		if [[ ${used} -gt 95 ]]; then
			echo -en $COLOR_ALERT
		elif [[ ${used} -gt 90 ]]; then
			echo -en $AF_COLOR_BOLD_RED
		else
			echo -en $AF_COLOR_GREEN
		fi
	else
		echo -en $AF_COLOR_CYAN
	fi
} # disk_color

# Construct the prompt
PROMPT_COMMAND="history -a"
case ${TERM} in
	xterm*)
		# User@Host (with connection type info)
		PS1="\[\$(user_color)\]\u\[${COLOR_RESET}\]@\[\$(connection_color)\]\h\[${COLOR_RESET}\] "
		# PWD (with disk space info)
		PS1=${PS1}"\[\$(disk_color)\]\w\[${COLOR_RESET}\] "
		if $(is-supported "__git_ps1") ; then
			# git info (needs bash-completion)
			PS1=${PS1}'$(__git_ps1 "\[${AF_COLOR_YELLOW}\](%s)\[${COLOR_RESET}\] ")'
		fi
		# Prompt (with 'job' info)
		PS1=${PS1}"\n$ "
		# Set title of the current xterm
		PS1=${PS1}"\[\e]0;[\u@\h] \w\a\]"
		;;
	*)
		PS1="(\u@\h \w)\n> "
		;;
esac
