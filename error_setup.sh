touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664 /var/log/lastlog
chmod -v 600 /var/log/btmp
ln -s gthr-posix.h libgcc/gthr-default.h
cd /build
if [ ! -d gcc-11.2.0 ]; then
    tar xvf /sources/gcc*
fi
cd gcc-11.2.0
mkdir -v build
cd build
../libstdc++-v3/configure CXXFLAGS="-g -O2 -D_GNU_SOURCE" --prefix=/usr --disable-multilib --disable-nls --host=$(uname -m)-error-linux-gnu --disable-libstdcxx-pch
make -j$(nproc)
make install
cd /build
tar xvf /sources/gettext*
cd gettext-0.21
./configure --disable-shared
make
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin/
cd /build
tar xvf /sources/bison*
cd bison-3.7.6
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.7.6
make
make install
cd /build
tar xvf /sources/perl*.xz
cd perl-5.34.0
sh Configure -des -Dprefix=/usr -Dvendorprefix=/usr -Dprivlib=/usr/lib/perl5/5.34/core_perl -Darchlib=/usr/lib/perl5/5.34/core_perl -Dsitelib=/usr/lib/perl5/5.34/site_perl -Dsitearch=/usr/lib/perl5/5.34/site_perl -Dvendorlib=/usr/lib/perl5/5.34/vendor_perl -Dvendorarch=/usr/lib/perl5/5.34/vendor_perl
make
make install
cd /build
tar xvf /sources/Python*
cd Python-3.9.6
./configure --prefix=/usr --enable-shared --without-ensurepip
make
make install
cd /build
tar xvf /sources/texinfo*
cd texinfo-6.8
sed -e 's/__attribute_nonnull__/__nonnull/' -i gnulib/lib/malloc/dynarray-skeleton.c
./configure --prefix=/usr
make
make install
cd /build
tar xvf /sources/util-linux*
cd util-linux-2.37.2
mkdir -pv /var/lib/hwclock
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime --libdir=/usr/lib --docdir=/usr/share/doc/util-linux-2.37.2 --disable-chfn-chsh --disable-login --disable-nologin --disable-su --disable-setpriv --disable-runuser --disable-pylibmount --disable-static --without-python runstatedir=/run
make
make install
find /usr/{lib,libexec} -name \*.la -delete
rm -rf /tools
echo "If you create backup, please exit!"
