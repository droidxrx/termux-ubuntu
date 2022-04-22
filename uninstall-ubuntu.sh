#!/data/data/com.termux/files/usr/bin/bash

echo "Starting to uninstall, please be patient..."

cur=`pwd`
if [ -d "$HOME/.local" ]; then
    if [ -d "$HOME/.local/share" ]; then
        if [ -d "$HOME/.local/share/ubuntu" ]; then
            cd $HOME/.local/share
            chmod 777 -R ubuntu
            rm -rf ubuntu
        fi
    fi
fi
cd $cur
rm -rf uninstall-ubuntu.sh

echo "Done"
