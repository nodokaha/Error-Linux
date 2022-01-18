#!/bin/bash
mkdir -p lfs/sources
export LFS=$(pwd)/lfs
chmod -v a+wt $LFS/sources
pushd $LFS/sources
md5sum -c ../../md5sums
popd
cd $LFS
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}
for i in bin lib sbin; do
if [ ! -d $i ]; then ln -sv usr/$i $LFS/$i; fi
done
case $(uname -m) in
x86_64) mkdir -pv $LFS/lib64 ;;
esac
mkdir -pv $LFS/tools
cd $LFS
cd ..
