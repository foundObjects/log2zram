#!/bin/bash
#set -ex

[ "$(id -u)" -eq 0 ] ||
  {
    echo "You need to be ROOT (sudo can be used)"
    exit 1
  }

systemctl -q is-active log2zram > /dev/null 2>&1 && systemctl stop log2zram
systemctl -q is-enabled log2zram > /dev/null 2>&1 && systemctl disable log2zram
rm /etc/systemd/system/log2zram.service
rm /usr/local/bin/log2zram
rm /etc/default/log2zram
rm /etc/logrotate.d/00_log2zram
rm -f /var/run/log2zram.device
echo "log2zram is uninstalled, removing the uninstaller in progress"
rm -rf /usr/local/share/log2zram /usr/local/lib/log2zram
echo "##### Reboot isn't needed #####"
