#!/bin/bash

OUTDIR=$HOME/binaries/salvage
NIXSRCDIR=$HOME/linux-salvage
OSXSRCDIR=$HOME/mac-salvage
WINSRCDIR=$HOME/win-salvage
DEPS_MAC=$HOME/depends/gali-depends
DEPS=$HOME/depends/gali-depends

#build depends stuff first

# git init depends && cd depends
# git remote add origin https://github.com/bitcoin/bitcoin.git
# git config core.sparsecheckout true
# echo "depends/*" >> .git/info/sparse-checkout
# git pull --depth=1 origin master

#Linux
#make -j4

# OS X
#mkdir SDKs && cd SDKs && wget https://github.com/phracker/MacOSX-SDKs/releases/download/10.13/MacOSX10.9.sdk.tar.xz && tar xf MacOSX10.9.sdk.tar.xz && rm MacOSX10.9.sdk.tar.xz
# make HOST=x86_64-apple-darwin11 DARWIN_SDK_PATH=$PWD/SDKs/MacOSX10.9.sdk -j4

#32 bit windows
#make HOST=i686-w64-mingw32 -j4

#create (3) source directories for your coin
#git clone https://github.com/salvagecore/salvage.git linux-salvage
#cd linux-salvage && sh autogen.sh
#cp -rf linux-salvage mac-salvage
#cp -rf linux-salvage win-salvage

getversion()
{
#  VER=$(grep -E '#define CLIENT_VERSION_(MAJOR|MINOR|REVISION|BUILD)' $PWD/src/clientversion.h | \
  VER=$(grep -E 'define\(_CLIENT_VERSION_(MAJOR|MINOR|REVISION|BUILD)' $PWD/configure.ac | \
  grep -ohE '[0-9]' | tr -d '[:space:]')
}

autogen()
{

echo 'autogening'
if [ ! -f $1/configure ]; then
        sh autogen.sh
fi
}

buildlinux()
{
# linux GUI 64bit

WRKDIR=$NIXSRCDIR
chmod 775 -R $WRKDIR
cd $WRKDIR
#echo "git pull"

autogen $WRKDIR
make clean
getversion

CONFIG_SITE=$DEPS/x86_64-pc-linux-gnu/share/config.site ./configure --disable-tests --enable-cxx --disable-shared --with-pic --disable-hardening
make -j8 V=1 && strip src/qt/salvage-qt && cp src/qt/salvage-qt . && tar czf $OUTDIR/salvage-gui-linux-$VER.tgz salvage-qt && rm salvage-qt
strip src/salvaged src/salvage-cli src/salvage-tx && mv src/salvaged src/salvage-cli src/salvage-tx .
tar czf $OUTDIR/salvage-linux-cli-$VER.tgz salvaged salvage-cli salvage-tx && rm salvaged salvage-cli salvage-tx
}

buildmac()
{

WRKDIR=$OSXSRCDIR
chmod 775 -R $WRKDIR
cd $WRKDIR
make clean
#echo "git pull"

getversion
autogen $WRKDIR

CONFIG_SITE=$DEPS_MAC/x86_64-apple-darwin11/share/config.site ./configure --prefix=/ --with-gui=qt5 --disable-tests
make -j8
make deploy
zip $OUTDIR/Salvage-Core.dmg-$VER.zip Salvage-Core.dmg
mv src/salvaged src/salvage-cli src/salvage-tx .
tar czf $OUTDIR/salvage-cli-osx-$VER.tgz salvaged salvage-cli salvage-tx && rm salvaged salvage-cli salvage-tx
}

buildwin32()
{
WRKDIR=$WINSRCDIR
chmod 775 -R $WRKDIR
cd $WRKDIR
#make clean
#git pull
getversion
autogen $WRKDIR

# 32bit Win 
#PATH=$(echo "$PATH" | sed -e 's/:\/mnt.*//g')
CONFIG_SITE=$DEPS/i686-w64-mingw32/share/config.site ./configure --prefix=/ --with-gui=qt5 --disable-tests 
make clean
make -j8 && i686-w64-mingw32-strip src/qt/salvage-qt.exe && mv src/qt/salvage-qt.exe .
zip $OUTDIR/salvage_x86-qt.exe-$VER.zip salvage-qt.exe && rm salvage-qt.exe
x86_64-w64-mingw32-strip src/salvaged.exe src/salvage-cli.exe src/salvage-tx.exe && mv src/salvaged.exe src/salvage-cli.exe src/salvage-tx.exe .
zip $OUTDIR/salvage_win_x86-cli-$VER.zip salvaged.exe salvage-cli.exe salvage-tx.exe
rm salvaged.exe salvage-cli.exe salvage-tx.exe
}

if [ "$1" == "l" ]; then
  buildlinux
  exit 0
fi

if [ "$1" == "m" ]; then
  buildmac
  exit 0
fi

if [ "$1" == "w32" ]; then
  buildwin32
  exit 0
fi

buildlinux
echo "LINUX BUILD COMPLETED \n"

buildmac
echo "MAC BUILD COMPLETED \n"

buildwin32
echo "WINDOWZ BUILD COMPLETED \n"