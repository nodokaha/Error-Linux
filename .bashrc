set +h
umask 022
LFS=$(pwd)/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-error-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
