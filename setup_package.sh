cd /build
tar xvf /sources/libtool*
cd libtool-2.4.6
./configure --prefix=/usr
make
make check
make install
rm -fv /usr/lib/libltdl.a
cd /build
tar xvf /sources/gdbm*
cd gdbm-1.20
./configure --prefix=/usr --disable-static --enable-libgdbm-compat
make
make -k check
make install
cd /build
tar xvf /sources/gperf*
cd gperf-3.1
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
make
make -j1 check
make install
cd /build
tar xvf /sources/expat*
cd expat-2.4.1
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/expat-2.4.1
make
make check
make install
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.4.1
cd /build
tar xvf /sources/inetutils*
cd /inetutils-2.1
./configure --prefix=/usr --bindir=/usr/bin --localstatedir=/var --disable-logger --disable-whois --disable-rcp --disable-rexec --disable-rlogin --disable-rsh --disable-servers
make
make check
make install
mv -v /usr/{,s}bin/ifconfig
cd /build
tar xvf /sources/less*
cd less-590
./configure --prefix=/usr --sysconfdir=/etc
make
make install
cd /build
tar xvf /sources/perl-5.34.0.tar.xz
cd perl-5.34.0
patch -Np1 -i /sources/perl-5.34.0-upstream_fixes-1.patch
export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des -Dprefix=/usr -Dvendorprefix=/usr -Dprivlib=/usr/lib/perl5/5.34/core_perl -Darchlib=/usr/lib/perl5/5.34/core_perl -Dsitelib=/usr/lib/perl5/5.34/site_perl -Dsitearch=/usr/lib/perl5/5.34/site_perl -Dvendorlib=/usr/lib/perl5/5.34/vendor_perl -Dvendorarch=/usr/lib/perl5/5.34/vendor_perl -Dman1dir=/usr/share/man/man1 -Dman3dir=/usr/share/man/man3 -Dpager="/usr/bin/less -isR" -Duseshrplib -Dusethreads
make
make test
make install
unset BUILD_ZLIB BUILD_BZIP2
cd /build
tar xvf /sources/XML-Parser-2.46.tar.gz
cd XML-Parser-2.46
perl Makefile.PL
make
make test
make install
cd /build
tar xvf /sources/intltool*
cd intltool-0.51.0
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make
make check
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
cd /build
tar xvf /sources/autoconf*
cd autoconf-2.71
./configure --prefix=/usr
make
make check
make install
cd /build
tar xvf /sources/automake*
cd automake-1.16.4
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.4
make
make -j4 check
make install
cd /build
tar xvf /sources/kmod*
cd kmod-29
./configure --prefix=/usr --sysconfdir=/etc --with-xz --with-zstd --with-zlib
make
make install
for target in depmod insmod modinfo modprobe rmmod; do
    ln -sfv ../bin/kmod /usr/sbin/$target
done
ln -sfv kmod /usr/bin/lsmod
cd /build
tar xvf /sources/elfutils*
cd elfutils-0.185
./configure --prefix=/usr --disable-debuginfod --enable-libdebuginfod=dummy
make
make check
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a
cd /build
tar xvf /sources/libffi*
cd libffi-3.4.2
./configure --prefix=/usr --disable-static --with-gcc-arch=native --disable-exec-static-tramp
make
make check
make install
cd /build
tar xvf /sources/openssl*
cd openssl-1.1.1l
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic
make
make test
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1l
cp -vfr doc/* /usr/share/doc/openssl-1.1.1l
cd /build
tar xvf /sources/Python-3.9.6.tar.xz
cd Python-3.9.6
./configure --prefix=/usr --enable-shared --with-system-expat --with-system-ffi --with-ensurepip=yes --enable-optimizations
make
make install
install -v -dm755 /usr/share/doc/python-3.9.6/html
tar --strip-components=1 --no-same-owner --no-same-permissions -C /usr/share/doc/python-3.9.6/html -xvf /sources/python-3.9.6-docs-html.tar.bz2
cd /build
tar xvf /sources/ninja*
cd nina-1.10.2
sed -i '/int Guess/a int
j = 0; char* jobs = getenv( "NINJAJOBS" ); if ( jobs != NULL ) j = atoi( jobs ); if ( j > 0 ) return j;' src/ninja.cc
python3 configure.py --bootstrap
./ninja ninja_test
./ninja_test --gtest_filter=-SubprocessTest.SetWithLots
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion /usr/share/zsh/site-functions/_ninja
cd /build
tar xvf /sources/meson*
cd meson-0.59.1
python3 setup.py build
python3 setup.py install --root=dest
cp -rv dest/* /
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson
cd /build
tar xvf /sources/coreutils-8.32.tar.xz
cd coreutils-8.32
patch -Np1 -i /sources/coreutils-8.32-i18n-1.patch
autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr --enable-no-install-program=kill,uptime
make
make NON_ROOT_USERNAME=tester check-root
echo "dummy:x:102:tester" >> /etc/group
chown -Rv tester
su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
sed -i '/dummy/d' /etc/group
make install
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
cd /build
tar xvf /sources/check*
cd check-0.15.2
./configure --prefix=/usr --disable-static
make
make check
make docdir=/usr/share/doc/check-0.15.2 install
cd /build
tar xvf /sources/diffutils*
cd diffutils-3.8
./configure --prefix=/usr
make
make check
make install
cd /build
tar xvf /sources/gawk*
cd gawk-5.1.0
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make
make check
make install
mkdir -v /usr/share/doc/gawk-5.1.0
cp -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.1.0
cd /build
tar xvf /sources/findutils*
cd findutils-4.8.0
./configure --prefix=/usr --localstatedir=/var/lib/locate
make
chown -Rv tester .
su tester -c "PATH=$PATH make check"
make install
cd /build
tar xvf /sources/groff*
cd groff-1.22.4
PAGE=A4 ./configure --prefix=/usr
make -j1
make install
cd /build
tar xvf /sources/grub*
cd grub-2.06
./configure --prefix=/usr --sysconfdir=/etc --disable-efiemu --disable-werror
make
make install
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
cd /build
tar xvf /sources/gzip*
cd gzip-1.10
./configure --prefix=/usr
make
make check
make install
cd /build
tar xvf /sources/iproute*
cd iproute2-5.13.0
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
sed -i 's/.m_ipt.o//' tc/Makefile
make
make SBINDIR=/usr/sbin install
mkdir -v /usr/share/doc/iproute2-5.13.0
cp -v COPYING README* /usr/share/doc/iproute2-5.13.0
cd /build
tar xvf /sources/kbd-2.4.0.tar.xz
cd kbd-2.4.0
patch -Np1 -i /sources/kbd-2.4.0-backspace-1.patch
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make
make check
make install
mkdir -v /usr/share/doc/kbd-2.4.0
cp -R -v docs/doc/* /usr/share/doc/kbd-2.4.0
cd /build
tar xvf /sources/libpipeline*
cd libpipeline-1.5.3
./configure --prefix=/usr
make
make check
make install
cd /build
tar xvf /sources/make*
cd make-4.3
./configure --prefix=/usr
make
make check
make install
cd /build
tar xvf /sources/patch*
cd patch-2.7.6
./configure --prefix=/usr
make
make check
make install
cd /build
tar xvf /sources/tar*
cd tar-1.34
FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
make
make check
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.34
cd /build
tar xvf /sources/texinfo*
cd texinfo-6.8
./configure --prefix=/usr
sed -e 's/__attribute_nonnull__/__nonnull/' -i gnulib/lib/malloc/dynarray-skeleton.c
make
make check
make install
make TEXMF=/usr/share/texmf install-tex
pushd /usr/share/info
rm -v dir
for f in *
do install-info $f dir 2>/dev/null
done
popd
cd /build
tar xvf /sources/MarkupSafe-2.0.1.tar.gz
cd MarkupSafe-2.0.1
python3 setup.py build
python3 setup.py install --optimize=1
cd /build
tar xvf /sources/Jinja*
cd Jinja2-3.0.1
python3 setup.py install --optimize=1
cd /build
tar xvf /sources/systemd-249.tar.gz
cd systemd-249
patch -Np1 -i /sources/systemd-249-upstream_fixes-1.patch
sed -i -e 's/GROUP="render"/GROUP="video"/' -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in
mkdir -p build
cd build
LANG=en_US.UTF-8 meson --prefix=/usr --sysconfdir=/etc --localstatedir=/var --buildtype=release -Dblkid=true -Ddefault-dnssec=no -Dfirstboot=false -Dinstall-tests=false -Dldconfig=false -Dsysusers=false -Db_lto=false -Drpmmacrosdir=no -Dhomed=false -Duserdb=false -Dman=false -Dmode=release -Ddocdir=/usr/share/doc/systemd-249 ..
LANG=en_US.UTF-8 ninja
LANG=en_US.UTF-8 ninja install
tar -xf /sources/systemd-man-pages-249.tar.xz --strip-components=1 -C /usr/share/man
rm -rf /usr/lib/pam.d
systemd-machine-id-setup
systemctl preset-all
systemctl disable systemd-time-wait-sync.service
cd /build
tar xvf /sources/dbus*
cd dbus-1.12.20
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --disable-doxygen-docs --disable-xml-docs --docdir=/usr/share/doc/dbus-1.12.20 --with-console-auth-dir=/run/console --with-system-pid-file=/run/dbus/pid --with-system-socket=/run/dbus/system_bus_socket
make
make install
ln -sfv /etc/machine-id /var/lib/dbus
cd /build
tar xvf /sources/man-db-2.9.4.tar.xz
cd man-db-2.9.4
./configure --prefix=/usr --docdir=/usr/share/doc/man-db-2.9.4 --sysconfdir=/etc --disable-setuid --enable-cache-owner=bin --with-browser=/usr/bin/lynx --with-vgrind=/usr/bin/vgrind --with-grap=/usr/bin/grap
make
make check
make install
cd /build
tar xvf /sources/procps-ng*
cd procps-ng-3.3.17
./configure --prefix=/usr --docdir=/usr/share/doc/procps-ng-3.3.17 --disable-static --disable-kill --with-systemd
make
make check
make install
cd /build
tar xvf /sources/util-linux*
cd util-linux-2.37.2
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime --libdir=/usr/lib --docdir=/usr/share/doc/util-linux-2.37.2  --disable-chfn-chsh  --disable-login --disable-nologin --disable-su --disable-setpriv --disable-runuser --disable-pylibmount --disable-static --without-python runstatedir=/run
make
rm tests/ts/lsns/ioctl_ns
chown -Rv tester .
su tester -c "make -k check"
make install
cd /build
tar xvf /sources/e2fsprogs*
cd e2fsprogs-1.46.4
mkdir -v build
cd build
../configure --prefix=/usr --sysconfdir=/etc --enable-elf-shlibs --disable-libblkid --disable-libuuid --disable-uuidd --disable-fsck
make
make check
make install
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
makeinfo -o
doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
rm -rf /tmp/*
