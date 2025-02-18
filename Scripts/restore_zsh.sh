#!/bin/bash
#|---/ /+-------------------------------+---/ /|#
#|--/ /-| Script to install zsh plugins |--/ /-|#
#|-/ /--| Prasanth Rangan               |-/ /--|#
#|/ /---+-------------------------------+/ /---|#

source global_fn.sh
if [ $? -ne 0 ] ; then
    echo "Error: unable to source global_fn.sh, please execute from $(dirname "$(realpath "$0")")..."
    exit 1
fi

# set variables
Zsh_rc="${ZDOTDIR:-$HOME}/.zshrc"
Zsh_Path="/usr/share/oh-my-zsh"
Zsh_Plugins="$Zsh_Path/custom/plugins"
Fix_Completion=""

# generate plugins from list
while read r_plugin
do
    z_plugin=$(echo $r_plugin | awk -F '/' '{print $NF}')
    if [ "${r_plugin:0:4}" == "http" ] && [ ! -d $Zsh_Plugins/$z_plugin ] ; then
        sudo git clone $r_plugin $Zsh_Plugins/$z_plugin
    fi
    if [ "$z_plugin" == "zsh-completions" ] && [ `grep 'fpath+=.*plugins/zsh-completions/src' $Zsh_rc | wc -l` -eq 0 ]; then
        Fix_Completion='\nfpath+=${ZSH_CUSTOM:-${ZSH:-/usr/share/oh-my-zsh}/custom}/plugins/zsh-completions/src'
    else
        w_plugin=`echo $w_plugin ${z_plugin}`
    fi
done < <(cut -d '#' -f 1 restore_zsh.lst | sed 's/ //g')

# update plugin array in zshrc
echo "intalling zsh plugins --> ${w_plugin}"
sed -i "/^plugins=/c\plugins=($w_plugin)$Fix_Completion" $Zsh_rc
