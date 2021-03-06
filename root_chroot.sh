source $(pwd)/.bashrc
sudo chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools,sources,build}
case $(uname -m) in
x86_64) sudo chown -R root:root $LFS/lib64 ;;
esac
sudo mkdir -pv $LFS/{dev,proc,sys,run,root}
sudo mknod -m 600 $LFS/dev/console c 5 1
sudo mknod -m 666 $LFS/dev/null c 1 3
sudo mount -v --bind /dev $LFS/dev
sudo mount -v --bind /dev/pts $LFS/dev/pts
sudo mount -vt proc proc $LFS/proc
sudo mount -vt sysfs sysfs $LFS/sys
sudo mount -vt tmpfs tmpfs $LFS/run
if [ -h $LFS/dev/shm ]; then
sudo mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi
sudo cp $(pwd)/versioncheck.sh $LFS/root/
sudo cp $(pwd)/dirs.sh $LFS/root/
sudo cp $(pwd)/etcs.sh $LFS/root/
sudo cp $(pwd)/error_setup.sh $LFS/root/
sudo cp $(pwd)/error_Make $LFS/root/Makefile
sudo cp $(pwd)/error_linux.sh $LFS/root/
sudo cp $(pwd)/setup_package.sh $LFS/root/
sudo cp $(pwd)/strip.sh $LFS/root/
sudo cp $(pwd)/setup_setup.sh $LFS/root/
sudo chroot "$LFS" /usr/bin/env -i HOME=/root TERM="$TERM" PS1='(lfs chroot) \u:\w\$ ' PATH=/usr/bin:/usr/sbin /bin/bash --login +h
