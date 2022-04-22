#!/data/data/com.termux/files/usr/bin/bash
folder="$HOME/.local/share/ubuntu/fs"
binds="$HOME/.local/share/ubuntu/binds"

if [ ! -d "$HOME/.local" ]; then
    mkdir "$HOME/.local"
fi

if [ ! -d "$HOME/.local/share" ]; then
    mkdir "$HOME/.local/share"
fi

if [ ! -d "$HOME/.local/share/ubuntu" ]; then
    mkdir "$HOME/.local/share/ubuntu"
fi

if [ -d "$folder" ]; then
    first=1
    echo "skipping downloading"
fi
targzball="ubuntu.tar.gz"
if [ "$first" != 1 ];then
    if [ ! -f "$targzball" ]; then
        echo "downloading ubuntu-image"
        case `dpkg --print-architecture` in
            aarch64)
                archurl="arm64" ;;
            arm)
                archurl="armhf" ;;
            amd64)
                archurl="amd64" ;;
            x86_64)
                archurl="amd64" ;;	
            i*86)
                archurl="i386" ;;
            x86)
                archurl="i386" ;;
            *)
                echo "unknown architecture"; exit 1 ;;
		esac
	wget "https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-${archurl}.tar.gz" -O $targzball
    fi
    cur=`pwd`
    mkdir -p $folder
    cd $folder
    echo "decompressing ubuntu image"
    proot --link2symlink tar -xf "${cur}/${targzball}" --exclude='dev'||:
#     echo "fixing nameserver, otherwise it can't connect to the internet"
#     echo "nameserver 8.8.8.8" >> etc/resolv.conf
#     echo "nameserver 8.8.4.4" >> etc/resolv.conf
#     cat <<- EOF > "etc/hosts"
# 		# IPv4.
# 		127.0.0.1   localhost.localdomain localhost
# 		# IPv6.
# 		::1         localhost.localdomain localhost ip6-localhost ip6-loopback
# 		fe00::0     ip6-localnet
# 		ff00::0     ip6-mcastprefix
# 		ff02::1     ip6-allnodes
# 		ff02::2     ip6-allrouters
# 		ff02::3     ip6-allhosts
# 	EOF
# 	stubs=()
#     stubs+=('usr/sbin/groupadd')
#     stubs+=('usr/sbin/groupdel')
#     stubs+=('usr/bin/groups')
#     stubs+=('usr/sbin/useradd')
#     stubs+=('usr/sbin/usermod')
#     stubs+=('usr/sbin/userdel')
#     stubs+=('usr/bin/chage')
#     stubs+=('usr/bin/mesg')
#     for f in ${stubs[@]};do
#         echo "Writing stub: $f"
#         echo -e "#!/bin/sh\nexit" > "$f"
#     done
    cd $cur
fi

if [ ! -d "$binds" ]; then
    mkdir "$binds"
fi

bin=start-ubuntu.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" --kill-on-exit"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A $binds)" ]; then
    for f in $binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b $folder/root:/dev/shm"
## uncomment the following line to have access to the home directory of termux
command+=" -b /data/data/com.termux/files:/termux"
## uncomment the following line to mount /sdcard directly to / 
#command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin
echo "removing image for some space"
rm -rf $targzball
echo "You can now launch Ubuntu with the ./${bin} script"
