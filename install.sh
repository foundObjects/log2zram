#!/bin/bash
set -ex

[ "$(id -u)" -eq 0 ] ||
  {
    echo "You need to be ROOT (sudo can be used)"
    exit 1
  }
( systemctl -q is-active log2zram ) &&
  {
    echo 'ERROR: log2zram service is still running.'
    echo 'Please run "sudo service log2zram stop" to stop it and then uninstall' \
      'before re-installing.'
    exit 1
  }
[ -e /usr/local/bin/log2zram ] &&
  {
    echo "log2zram is already installed, uninstall first"
    exit 1
  }

# save time (if we can) on slow machines/storage loading and parsing apt package lists
( dpkg -l | grep -q "libattr1-dev" ) || apt-get install libattr1-dev -y
# only pull if neccessary, otherwise use local copy if available
[ -d overlayfs-tools ] || git clone https://github.com/kmxz/overlayfs-tools
cd overlayfs-tools
make
cd ..

# log2zram install
mkdir -p /usr/local/share/log2zram/ /usr/local/lib/log2zram/
install -m 644 log2zram.service /etc/systemd/system/log2zram.service
install -m 755 log2zram /usr/local/bin/log2zram
install -m 644 log2zram.conf /etc/default/log2zram
install -m 644 uninstall.sh /usr/local/share/log2zram/uninstall.sh
install -m 644 log2zram.logrotate /etc/logrotate.d/00_log2zram
install -m 755 overlayfs-tools/overlay /usr/local/lib/log2zram/overlay
systemctl enable log2zram
