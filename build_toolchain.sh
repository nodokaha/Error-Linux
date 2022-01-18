source $(pwd)/.bashrc
mkdir -v $LFS/build
cd $LFS/build
tar xvf $LFS/sources/binutils*.xz
mkdir -p binutils-2.37/build
cd binutils-2.37/build
../configure --prefix=$LFS/tools --with-sysroot=$LFS --target=$LFS_TGT --disable-nls --disable-werror
make -j$(nproc)
make install -j1
cd $LFS/build
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
mkdir build
cd build
../configure --target=$LFS_TGT --prefix=$LFS/tools --with-glibc-version=2.11 --with-sysroot=$LFS --with-newlib --without-headers --enable-initfini-array --disable-nls --disable-shared --disable-multilib --disable-decimal-float --disable-threads --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --disable-libstdcxx --enable-languages=c,c++
make -j$(nproc)
make install
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
cd $LFS/build
tar xvf $LFS/sources/linux*
cd linux-5.13.12
make mrproper
make headers
find usr/include -name '.*' -delete
rm usr/include/Makefile
cp -rv usr/include $LFS/usr

