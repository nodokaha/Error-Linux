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
cd $LFS/build
if [ ! -d $LFS/build/binutils-2.37 ]; then tar xvf $LFS/sources/binutils*; fi
cd binutils-2.37
mkdir -v build
cd build
../configure --prefix=/usr --build=$(../config.guess) --host=$LFS_TGT --disable-nls --enable-shared --disable-werror --enable-64-bit-bfd
make
make DESTDIR=$LFS install -j1
install -vm755 libctf/.libs/libctf.so.0.0.0 $LFS/usr/lib
cd $LFS/build
if [ ! -d $LFS/build/gcc-11.2.0 ]; then
tar xvf $LFS/sources/gcc*
tar xvf $LFS/sources/mpfr*
tar xvf $LFS/sources/gmp*
tar xvf $LFS/sources/mpc*
cd gcc-11.2.0
mv -v ../mpfr-4.1.0 ./mpfr
mv -v ../gmp-6.2.1 ./gmp
mv -v ../mpc-1.2.1 ./mpc
case $(uname -m) in
x86_64)
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
;;
esac
cd ..
; fi
cd gcc-11.2.0
mkdir -v build
cd build
mkdir -pv $LFS_TGT/libgcc
ln -s ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h
../configure --build=$(../config.guess) --host=$LFS_TGT --prefix=/usr CC_FOR_TARGET=$LFS_TGT-gcc --with-build-sysroot=$LFS --enable-initfini-array --disable-nls --disable-multilib --disable-decimal-float --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --disable-libstdcxx --enable-languages=c,c++
make
make DESTDIR=$LFS install
ln -sv gcc $LFS/usr/bin/cc
