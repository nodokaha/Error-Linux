rm -rf /build/*
cd /build
tar xvf /sources/man-pages*
cd man-pages-5.13
make prefix=/usr install
cd /build
tar xvf /sources/iana-etc*
cd iana-etc-20210611
cp services protocols /etc/
cd /build
tar xvf /sources/glibc-2.34.tar.xz
cd glibc-2.34
sed -e '/NOTIFY_REMOVED)/s/)/ \&\& data.attr != NULL)/' -i sysdeps/unix/sysv/linux/mq_notify.c
patch -Np1 -i /sources/glibc-2.34-fhs-1.patch
mkdir -v build
cd build
echo "rootsbindir=/usr/sbin" > configparms
../configure --prefix=/usr --disable-werror --enable-kernel=3.2 --enable-stack-protector=strong --with-headers=/usr/include libc_cv_slibdir=/usr/lib
make
make check
touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make install
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd
cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd
install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
install -v -Dm644 ../nscd/nscd.service /usr/lib/systemd/system/nscd.service
mkdir -pv /usr/lib/locale
localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f ISO-8859-1 en_GB
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_ES -f ISO-8859-15 es_ES@euro
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i is_IS -f ISO-8859-1 is_IS
localedef -i is_IS -f UTF-8 is_IS.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f ISO-8859-15 it_IT@euro
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i se_NO -f UTF-8 se_NO.UTF-8
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8
make localedata/install-locales
localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS 2> /dev/null || true
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf
passwd: files
group: files
shadow: files
hosts: files dns
networks: files
protocols: files
services: files
ethers: files
rpc: files
# End /etc/nsswitch.conf
EOF
tar -xf /sources/tzdata2021a.tar.gz
ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}
for tz in etcetera southamerica northamerica europe africa antarctica asia australasia backward; do
    zic -L /dev/null -d $ZONEINFO ${tz}
    zic -L /dev/null -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done
cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO
cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF
cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf
EOF
mkdir -pv /etc/ld.so.conf.d
cd /build
tar xvf /sources/zlib*
cd zlib-1.2.12
./configure --prefix=/usr
make
make check
make install
rm -fv /usr/lib/libz.a
cd /build
tar xvf /sources/bzip2-1.0.8.tar.gz
cd bzip2-1.0.8
patch -Np1 -i /sources/bzip2-1.0.8-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make
make PREFIX=/usr install
cp -av libbz2.so.* /usr/lib
ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so
cp -v bzip2-shared /usr/bin/bzip2
for i in /usr/bin/{bzcat,bunzip2}; do
    ln -sfv bzip2 $i
done
rm -fv /usr/lib/libbz2.a
cd /build
tar xvf /sources/xz*
cd xz-5.2.5
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/xz-5.2.5
make
make check
make install
cd /build
tar xvf /sources/zstd*
cd zstd-1.5.0
make
make check
make prefix=/usr install
rm -v /usr/lib/libzstd.a
cd /build
tar xvf /sources/file*
cd file-5.40
./configure --prefix=/usr
make
make check
make install
cd /build
tar xvf /sources/readline*
cd readline-8.1
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
./configure --prefix=/usr --disable-static --with-curses --docdir=/usr/share/doc/readline-8.1
make SHLIB_LIBS="-lncursesw"
make SHLIB_LIBS="-lncursesw" install
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.1
cd /build
tar xvf /sources/m4*
cd m4-1.4.19
./configure --prefix=/usr
make
make check
make install
cd /build
tar xvf /sources/bc*
cd bc-5.0.0
CC=gcc ./configure --prefix=/usr -G -O2
make
make test
make install
cd /build
tar xvf /sources/flex*
cd flex-2.6.4
./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.4 --disable-static
make
make check
make install
ln -sv flex /usr/bin/lex
cd /build
tar xvf /sources/tcl8.6.11-src.tar.gz
cd tcl8.6.11-src
tar -xf /sources/tcl8.6.11-html.tar.gz --strip-components=1
SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr --mandir=/usr/share/man $([ "$(uname -m)" = x86_64 ] && echo --enable-64bit)
make
sed -e "s|$SRCDIR/unix|/usr/lib|" -e "s|$SRCDIR|/usr/include|" -i tclConfig.sh
sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.2|/usr/lib/tdbc1.1.2|" -e "s|$SRCDIR/pkgs/tdbc1.1.2/generic|/usr/include|" -e "s|$SRCDIR/pkgs/tdbc1.1.2/library|/usr/lib/tcl8.6|" -e "s|$SRCDIR/pkgs/tdbc1.1.2|/usr/include|" -i pkgs/tdbc1.1.2/tdbcConfig.sh
sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.1|/usr/lib/itcl4.2.1|" -e "s|$SRCDIR/pkgs/itcl4.2.1/generic|/usr/include|" -e "s|$SRCDIR/pkgs/itcl4.2.1|/usr/include|" -i pkgs/itcl4.2.1/itclConfig.sh
unset SRCDIR
make test
make install
chmod -v u+w /usr/lib/libtcl8.6.so
make install-private-headers
ln -sfv tclsh8.6 /usr/bin/tclsh
mv /usr/share/man/man3/{Thread,Tcl_Thread}.3
cd /build
tar xvf /sources/expect*
cd expect-5.45.4
./configure --prefix=/usr --with-tcl=/usr/lib --enable-shared --mandir=/usr/share/man --with-tclinclude=/usr/include
make
make test
make install
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
d /build
tar xvf /sources/dejagnu*
cd dejagnu-1.6.3
mkdir -v build
cd build
../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext -o doc/dejagnu.txt ../doc/dejagnu.texi
make install
install -v -dm755 /usr/share/doc/dejagnu-1.6.3
install -v -m644 doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
make check
cd /build
tar xvf /sources/binutils-2.37.tar.xz
cd binutils-2.37
patch -Np1 -i /sources/binutils-2.37-upstream_fix-1.patch
sed -i '63d' etc/texi2pod.pl
find -name \*.1 -delete
mkdir -v build
cd build
../configure --prefix=/usr --enable-gold --enable-ld=default --enable-plugins --enable-shared --disable-werror --enable-64-bit-bfd --with-system-zlib
make tooldir=/usr
make -k check
make tooldir=/usr install -j1
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a
cd /build
tar xvf /sources/gmp*
cd gmp-6.2.1
./configure --prefix=/usr --enable-cxx --disable-static --docdir=/usr/share/doc/gmp-6.2.1
make
make html
make check 2>&1 | tee gmp-check-log
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
make install
make install-html
cd /build
tar xvf /sources/mpfr*
cd mpfr-4.1.0
./configure --prefix=/usr --disable-static --enable-thread-safe --docdir=/usr/share/doc/mpfr-4.1.0
make
make html
make check
make install
make install-html
cd /build
tar xvf /sources/mpc*
cd mpc-1.2.1
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/mpc-1.2.1
make
make html
make check
make install
make install-html
cd /build
tar xvf /sources/attr*
cd attr-2.5.1
./configure --prefix=/usr --disable-static --sysconfdir=/etc --docdir=/usr/share/doc/attr-2.5.1
make
make check
make install
cd /build
tar xvf /sources/acl*
cd acl-2.3.1
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/acl-2.3.1
make
make install
cd /build
tar xvf /sources/libcap*
cd libcap-2.53
sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib
make test
make prefix=/usr lib=lib install
chmod -v 755 /usr/lib/lib{cap,psx}.so.2.53
cd /build
tar xvf /sources/shadow*
cd shadow-4.9
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /' {} \;
sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' -e 's:/var/spool/mail:/var/mail:' -e '/PATH=/{s@/sbin:@@;s@/bin:@@}' -i etc/login.defs
sed -e "224s/rounds/min_rounds/" -i libmisc/salt.c
touch /usr/bin/passwd
./configure --sysconfdir=/etc --with-group-name-max-length=32
make
make exec_prefix=/usr install
make -C man install-man
mkdir -p /etc/default
useradd -D --gid 999
pwconv
grpconv
sed -i 's/yes/no/' /etc/default/useradd
cd /build
tar xvf /sources/gcc*
cd gcc-11.2.0
sed -e '/static.*SIGSTKSZ/d' -e 's/return kAltStackSize/return SIGSTKSZ * 4/' -i libsanitizer/sanitizer_common/sanitizer_posix_libcdep.cpp
case $(uname -m) in
    x86_64)
	sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
	;;
esac
mkdir -v build
cd build
../configure --prefix=/usr LD=ld --enable-languages=c,c++ --disable-multilib --disable-bootstrap --with-system-zlib
make
ulimit -s 32768
chown -Rv tester .
su tester -c "PATH=$PATH make -k check"
../contrib/test_summary
make install
rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/11.2.0/include-fixed/bits/
chown -v -R root:root /usr/lib/gcc/*linux-gnu/11.2.0/include{,-fixed}
ln -svr /usr/bin/cpp /usr/lib
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/11.2.0/liblto_plugin.so /usr/lib/bfd-plugins/
echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
grep -B4 '^ /usr/include' dummy.log
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " dummy.log
grep found dummy.log
rm -v dummy.c a.out dummy.log
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
cd /build
tar xvf /sources/pkg-config*
cd pkg-config-0.29.2
./configure --prefix=/usr --with-internal-glib --disable-host-tool --docdir=/usr/share/doc/pkg-config-0.29.2
make
make check
make install
cd /build
tar xvf /sources/ncurses*
cd ncurses-6.2
./configure --prefix=/usr --mandir=/usr/share/man --with-shared --without-debug --without-normal --enable-pc-files --enable-widec
make
make install
for lib in ncurses form panel menu ; do
    rm -vf /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc /usr/lib/pkgconfig/${lib}.pc
done
rm -vf /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so /usr/lib/libcurses.so
rm -fv /usr/lib/libncurses++w.a
mkdir -v /usr/share/doc/ncurses-6.2
cp -v -R doc/* /usr/share/doc/ncurses-6.2
make distclean
./configure --prefix=/usr --with-shared --without-normal --without-debug --without-cxx-binding --with-abi-version=5
make sources libs
cp -av lib/lib*.so.5* /usr/lib
cd /build
tar xvf /sources/sed*
cd sed-4.8
./configure --prefix=/usr
make
make html
chown -Rv tester .
su tester -c "PATH=$PATH make check"
make install
install -d -m755 /usr/share/doc/sed-4.8
install -m644 doc/sed.html /usr/share/doc/sed-4.8
cd /build
tar xvf /sources/psmisc*
cd psmisc-23.4
./configure --prefix=/usr
make
make install
cd /build
tar xvf /sources/gettext*
cd gettext-0.21
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/gettext-0.21
make
make check
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so
cd /build
tar xvf /sources/bison*
cd bison-3.7.6
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.7.6
make
make check
make install
cd /build
tar xvf /sources/grep*
cd grep-3.7
./configure --prefix=/usr
make
make check
make install
cd /build
tar xvf /sources/bash*
cd bash-5.1.8
./configure --prefix=/usr --docdir=/usr/share/doc/bash-5.1.8 --without-bash-malloc --with-installed-readline
make
chown -Rv tester .
su -s /usr/bin/expect tester << EOF
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF
make install
cd /root
rm error_setup.sh
rm error_linux.sh
rm etcs.sh
rm dirs.sh
sed -e "1,2s/error_setup//" -i Makefile
exec /bin/bash --login +h
