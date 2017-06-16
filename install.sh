#!/bin/bash

# Copy bash_profile and bashrc
for bash_file in ./bash/{bash_profile,bashrc} ; do
	if [[ -f ~/.$(basename $bash_file) ]] ; then
		rm -f ~/.$(basename $bash_file)
	fi

	cp $bash_file ~/.$(basename $bash_file)
done
unset bash_file

# Create the profile.d and bashrc.d directories
for dir in {.profile.d,.bashrc.d} ; do
	if [[ -d ~/$dir ]] ; then
		rm -rf ~/$dir
	fi

	mkdir -p ~/$dir
	chmod 750 ~/$dir
done
unset dir

# Copy scripts to ~/.profile.d
for script in ./bash/profile.d/*.sh ; do
	if [[ -r "$script" ]]; then
		cp $script ~/.profile.d/$(basename $script)
	fi
done
unset -v script

# Copy scripts to ~/.bashrc.d
for script in ./bash/bashrc.d/*.sh ; do
	if [[ -r "$script" ]]; then
		cp $script ~/.bashrc.d/$(basename $script)
	fi
done
unset -v script
