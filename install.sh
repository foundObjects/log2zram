#!/bin/bash

# set -ex

systemctl -q is-active log2zram  && { echo "ERROR: log2zram service is still running. Please run \"sudo service log2zram stop\" to stop it and uninstall"; exit 1; }
[ "$(id -u)" -eq 0 ] || { echo "You need to be ROOT (sudo can be used)"; exit 1; }
[ -d /usr/local/bin/log2zram ] && { echo "Log2Zram is already installed, uninstall first"; exit 1; }

# save time (if we can) on slow machines/storage loading and parsing apt package lists
( dpkg -l | grep -q "libattr1-dev" ) || \
	apt-get install libattr1-dev -y
[ -d overlayfs-tools ] || \
	git clone https://github.com/kmxz/overlayfs-tools
cd overlayfs-tools
make
cd ..

mkdir -p /usr/local/share/log2zram/
# log2zram install 
install -m 644 log2zram.service /etc/systemd/system/log2zram.service
install -m 755 log2zram /usr/local/bin/log2zram
install -m 644 log2zram.conf /etc/log2zram.conf
install -m 644 uninstall.sh /usr/local/share/log2zram/uninstall.sh
install -m 644 log2zram.logrotate /etc/logrotate.d/00_log2zram
mkdir -p /usr/local/lib/log2zram/
install -m 755 overlayfs-tools/overlay /usr/local/lib/log2zram/overlay
mkdir -p /usr/local/share/log2zram/log
systemctl enable log2zram

