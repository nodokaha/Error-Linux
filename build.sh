su - lfs
source .bash_profile
source .bashrc
mkdir -v $LFS/build
cd $LFS/build
tar xvf $LFS/sources/binutils*
mkdir binutils*/build
cd binutils*/build
../configure --prefix=$LFS/tools \
--with-sysroot=$LFS \
--target=$LFS_TGT
\
--disable-nls
\
--disable-werror
