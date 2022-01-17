source .bashrc
mkdir -v $LFS/build
cd $LFS/build
tar xvf $LFS/sources/binutils*
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
