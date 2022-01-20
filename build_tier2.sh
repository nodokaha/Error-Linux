source $(pwd)/.bashrc
cd $LFS/build
if [ ! -d $LFS/build/gcc-11.2.0 ]; then tar xvf $LFS/sources/gcc*; fi
cd gcc-11.2.0
mkdir -v build
cd build
../libstdc++-v3/configure --host=$LFS_TGT --build=$(../config.guess) --prefix=/usr --disable-multilib --disable-nls --disable-libstdcxx-pch --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/11.2.0
make
make DESTDIR=$LFS install
cd $LFS/build
tar xvf $LFS/sources/m4*
cd m4-1.4.19
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
cd $LFS/build
tar xvf $LFS/sources/ncurses*
cd ncurses-6.2
sed -i s/mawk// configure
mkdir build
pushd build
../configure
make -C include
make -C progs tic
popd
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess) --mandir=/usr/share/man --with-manpage-format=normal --with-shared --without-debug --without-ada --without-normal --enable-widec
make
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
cd $LFS/build
tar xvf $LFS/sources/bash*
cd bash-5.1.8
./configure --prefix=/usr --build=$(support/config.guess) --host=$LFS_TGT --without-bash-malloc
make
make DESTDIR=$LFS install
ln -sv bash $LFS/bin/sh
cd $LFS/build
tar xvf $LFS/sources/coreutils*.xz
cd coreutils-8.32
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) --enable-install-program=hostname --enable-no-install-program=kill,uptime
make
make DESTDIR=$LFS install
mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8 
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8
cd $LFS/build
tar xvf $LFS/sources/diffutils*
cd diffutils-3.8
./configure --prefix=/usr --host=$LFS_TGT
make
make DESTDIR=$LFS install
