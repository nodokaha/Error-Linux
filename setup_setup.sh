find /usr/lib /usr/libexec -name \*.la -delete
find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf
userdel -r tester
ln -s /dev/null /etc/systemd/network/99-default.link
cat > /etc/systemd/network/10-ether0.link << "EOF"
[Match]
# Change the MAC address as appropriate for your network device
MACAddress=12:34:45:78:90:AB
[Link]
Name=ether0
EOF
cat > /etc/systemd/network/10-eth-dhcp.network << "EOF"
[Match]
Name=<network-device-name>
[Network]
DHCP=ipv4
[DHCP]
UseDomains=true
EOF
ln -sfv /run/systemd/resolve/resolv.conf /etc/resolv.conf
echo "errorlinux" > /etc/hostname
cat > /etc/hosts << "EOF"
# Begin /etc/hosts
127.0.0.1	localhost
::1		localhost
# 127.0.0.1 localhost.localdomain localhost
# 127.0.1.1 <FQDN> <HOSTNAME>
# <192.168.0.2> <FQDN> <HOSTNAME> [alias1] [alias2] ...
# ::1
# localhost ip6-localhost ip6-loopback
# ff02::1
# ip6-allnodes
# ff02::2
# ip6-allrouters
# End /etc/hosts
EOF
cat > /etc/adjtime << "EOF"
0.0 0 0.0
0
LOCAL
EOF
systemctl disable systemd-timesyncd
cat > /etc/vconsole.conf << "EOF"
KEYMAP=de-latin1
FONT=Lat2-Terminus16
EOF
cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>
# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off
# Enable 8bit input
set meta-flag On
set input-meta On
# Turns off 8th bit stripping
set convert-meta Off
# Keep the 8th bit for display
set output-meta On
# none, visible or audible
set bell-style none
# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word
# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert
# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line
# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line
# End /etc/inputrc
EOF
cat > /etc/shells << "EOF"
# Begin /etc/shells
/bin/sh
/bin/bash
/usr/bin/scsh
# End /etc/shells
EOF
mkdir -p /etc/tmpfiles.d
cp /usr/lib/tmpfiles.d/tmp.conf /etc/tmpfiles.d
mkdir -pv /etc/systemd/coredump.conf.d
cat > /etc/systemd/coredump.conf.d/maxuse.conf << EOF
[Coredump]
MaxUse=5G
EOF
