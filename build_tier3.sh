source $(pwd)/.bashrc
cd $LFS/build
tar xvf $LFS/sources/file*
cd file-5.40
mkdir build
pushd build
../configure --disable-bzlib --disable-libseccomp --disable-xzlib --disable-zlib
make
popd
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install
cd $LFS/build
tar xvf $LFS/sources/findutils*
cd findutils-4.8.0
./configure --prefix=/usr --localstatedir=/var/lib/locate --host=$LFS_TGT --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
cd $LFS/build
tar xvf $LFS/sources/gawk*
cd gawk-5.1.0
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
make
make DESTDIR=$LFS install
cd $LFS/build
tar xvf $LFS/sources/grep*
cd grep-3.7
./configure --prefix=/usr --host=$LFS_TGT
make
make DESTDIR=$LFS install
cd $LFS/build
tar xvf $LFS/sources/gzip*
cd gzip-1.10
./configure --prefix=/usr --host=$LFS_TGT
make
make DESTDIR=$LFS install
cd $LFS/build
tar xvf $LFS/sources/make*
cd make-4.3
./configure --prefix=/usr --without-guile --host=$LFS_TGT --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
cd $LFS/build
tar xvf $LFS/sources/patch*
cd patch-2.7.6
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
cd $LFS/build
tar xvf $LFS/sources/sed*
cd sed-4.8
./configure --prefix=/usr --host=$LFS_TGT
make
make DESTDIR=$LFS install
cd $LFS/build
tar xvf $LFS/sources/tar*
cd tar-1.34
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
cd $LFS/build
tar xvf $LFS/sources/xz*
cd xz-5.2.5
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) --disable-static --docdir=/usr/share/doc/xz-5.2.5
make
make DESTDIR=$LFS install
