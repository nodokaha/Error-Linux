source $(pwd)/.bashrc
cd $LFS/build
if [ ! -d $LFS/build/binutils-2.37 ]; then tar xvf $LFS/sources/binutils*.xz; fi
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
