#!/bin/sh

## ANSI Colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"

#Get username
username=$(whoami)

## Reset terminal colors
reset_color() {
	printf '\033[37m'
}

## Script Termination
exit_on_signal_SIGINT() {
    { printf "${RED}\n\n%s\n\n" "[!] Program Interrupted." 2>&1; reset_color; }
    exit 0
}

exit_on_signal_SIGTERM() {
    { printf "${RED}\n\n%s\n\n" "[!] Program Terminated." 2>&1; reset_color; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Show usages
usage() {
	echo -e ${ORANGE}"Usages : $(basename $0) --install | --uninstall \n"
}

## Packages
_pkgs=("zsh" "pcmanfm" "i3-gaps" "polybar" "picom-jonaburg-git" "rofi" "htop" "flameshot" "kitty" "gnome-system-monitor" "i3lock-fancy-git" "nitrogen" "neofetch" "v4l2loopback-dkms")

## Setup OMZ
setup_omz() {
	# backup previous
	echo -e ${RED}"\n[*] Setting up OMZ configs..."
	omz_files=(.oh-my-zsh .zshrc)
	for file in "${omz_files[@]}"; do
		echo -e ${CYAN}"\n[*] Backing up $file..."
		if [[ -f "$HOME/$file" || -d "$HOME/$file" ]]; then
			{ reset_color; mv -u ${HOME}/${file}{,.old}; }
		else
			echo -e ${MAGENTA}"\n[!] $file Doesn't Exist."			
		fi
	done
	# installing omz
	echo -e ${CYAN}"\n[*] Installing Oh-my-zsh... \n"
	{ reset_color; git clone https://github.com/robbyrussell/oh-my-zsh.git --depth 1 $HOME/.oh-my-zsh; }
	cp $HOME/.oh-my-zsh/templates/zshrc.zsh-template $HOME/.zshrc
	sed -i -e 's/ZSH_THEME=.*/ZSH_THEME="sorin"/g' $HOME/.zshrc
	sed -i -e 's|# export PATH=.*|export PATH=$HOME/.local/bin:$PATH|g' $HOME/.zshrc
	# ZSH theme
	cat > $HOME/.oh-my-zsh/custom/themes/sorin.zsh-theme <<- _EOF_
		# Default OMZ theme

		if [[ "\$USER" == "root" ]]; then
		  PROMPT="%(?:%{\$fg_bold[red]%}%{\$fg_bold[yellow]%}%{\$fg_bold[red]%} :%{\$fg_bold[red]%} )"
		  PROMPT+='%{\$fg[cyan]%}  %c%{\$reset_color%} \$(git_prompt_info)'
		else
		  PROMPT="%(?:%{\$fg_bold[red]%}%{\$fg_bold[green]%}%{\$fg_bold[yellow]%} :%{\$fg_bold[red]%} )"
		  PROMPT+='%{\$fg[cyan]%}  %c%{\$reset_color%} \$(git_prompt_info)'
		fi

		ZSH_THEME_GIT_PROMPT_PREFIX="%{\$fg_bold[blue]%}  git:(%{\$fg[red]%}"
		ZSH_THEME_GIT_PROMPT_SUFFIX="%{\$reset_color%} "
		ZSH_THEME_GIT_PROMPT_DIRTY="%{\$fg[blue]%}) %{\$fg[yellow]%}✗"
		ZSH_THEME_GIT_PROMPT_CLEAN="%{\$fg[blue]%})"
	_EOF_
	
	cat >> $HOME/.zshrc <<- _EOF_
		neofetch
	_EOF_

	chsh -s /bin/zsh $username
}

## Configuration
setup_config() {
    # Installing Packages
    for package in "${_pkgs[@]}"; do
		{ reset_color; }
	    if [[ "$(which $package)" == "" ]]; then
            echo -e ${GREEN}"\n[*] Installing Package ${ORANGE}$package \n"
			yay -S --noconfirm $package
        else
            echo "${ORANGE}$package Already Installed"
		fi
	done

    # Setting Wallpaper
    mkdir $HOME/.config/nitrogen

    cat >> $HOME/.config/nitrogen/bg-saved.cfg <<- _EOF_
	[xin_-1]
    file=/home/$username/.local/share/backgrounds/Default.png
    mode=2
    bgcolor=#000000
	_EOF_

	cat >> $HOME/.config/nitrogen/nitrogen.cfg <<- _EOF_
    [nitrogen]
    view=icon
    recurse=true
    sort=alpha
    icon_caps=false
    dirs=/home/$username/.local/share/backgrounds;/home/$username/.local/share/backgrounds;
	_EOF_
    # Setting Wallpaper

	# Copy config files
	configs=($(ls -A $(pwd)))
	echo -e ${RED}"\n[*] Copying config files... "
	for _config in "${configs[@]}"; do
		echo -e ${CYAN}"\n[*] Copying $_config..."
		{ reset_color; rm -rf $(pwd)/.git; cp -rf $(pwd)/$_config $HOME; }
	done
    
    # Icon Theme
	sudo cp -r $(pwd)/usr/share/icons/Paper-Mono-Dark /usr/share/icons/

	cat >> $HOME/.gtkrc-2.0 <<- _EOF_
    include "/home/$username/.gtkrc-2.0.mine"
    gtk-theme-name="Plata-Blue-Noir-Compact"
    gtk-icon-theme-name="Paper-Mono-Dark"
    gtk-font-name="Noto Sans 11"
    gtk-cursor-theme-name="Adwaita"
    gtk-cursor-theme-size=14
    gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
    gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
    gtk-button-images=0
    gtk-menu-images=0
    gtk-enable-event-sounds=1
    gtk-enable-input-feedback-sounds=1
    gtk-xft-antialias=1
    gtk-xft-hinting=1
    gtk-xft-hintstyle="hintmedium"
    gtk-xft-rgba="rgb"
	_EOF_

    mkdir $HOME/.config/gtk-3.0

	cat >> $HOME/.config/gtk-3.0/bookmarks<<- _EOF_
    file:///home/$username/Documents Documents
    file:///home/$username/Music Music
    file:///home/$username/Videos Videos
    file:///home/$username/Pictures Pictures
    file:///home/$username/Downloads Downloads
	_EOF_
}

## Finish Installation
post_msg() {
	echo -e ${GREEN}"\n[*] ${RED}Gorkido Dots ${GREEN}Installed Successfully.\n"
	{ reset_color; exit 0; }
}

## Uninstall Gorkido Dots
uninstall_td() {
	# remove pkgs
	echo -e ${RED}"\n[*] Unistalling Gorkido Dots..."
	for package in "${_pkgs[@]}"; do
		echo -e ${GREEN}"\n[*] Removing Packages ${ORANGE}$package \n"
		{ reset_color; yay -Rns --noconfirm $package; }
	done
	
	# delete files
	echo -e ${CYAN}"\n[*] Deleting config files...\n"
	_homefiles=(.fehbg .icons .mpd .ncmpcpp .fonts .gtkrc-2.0 .mutt .themes .oh-my-zsh)
	_configfiles=(pcmanfm gtk-3.0 gtk-2.0 i3 polybar rofi picom neofetch kitty htop)
	_localfiles=(bin 'share/backgrounds')
	for i in "${_homefiles[@]}"; do
		if [[ -f "$HOME/$i" || -d "$HOME/$i" ]]; then
			{ reset_color; rm -rf $HOME/$i; }
		else
			echo -e ${MAGENTA}"\n[!] $file Doesn't Exist.\n"
		fi
	done
	for j in "${_configfiles[@]}"; do
		if [[ -f "$HOME/.config/$j" || -d "$HOME/.config/$j" ]]; then
			{ reset_color; rm -rf $HOME/.config/$j; }
		else
			echo -e ${MAGENTA}"\n[!] $file Doesn't Exist.\n"			
		fi
	done
	for k in "${_localfiles[@]}"; do
		if [[ -f "$HOME/.local/$k" || -d "$HOME/.local/$k" ]]; then
			{ reset_color; rm -rf $HOME/.local/$k; }
		else
			echo -e ${MAGENTA}"\n[!] $file Doesn't Exist.\n"			
		fi
	done

    chsh -s /bin/bash $username

	echo -e ${RED}"\n[*] Gorkido Dots Unistalled Successfully.\n"
}

OBS_Virtual_Cam() {
    ModFolders=(/etc/modprobe.d /etc/modules-load.d)
	mkdir $ModFolders
    sudo cp $(pwd)/etc/modprobe.d/v4l2loopback.conf /etc/modprobe.d/
    sudo cp $(pwd)/etc/modules-load.d/v4l2loopback.conf /etc/modules-load.d/
    echo -e ${GREEN}"\n[*] OBS Virtual Cam Configured.\n"
}

## Install Gorkido Dots
install_td() {
	setup_config
    setup_omz
	OBS_Virtual_Cam
	post_msg
}

## Main
if [[ "$1" == "--install" ]]; then
	install_td
elif [[ "$1" == "--uninstall" ]]; then
	uninstall_td
else
	{ usage; reset_color; exit 0; }
fi