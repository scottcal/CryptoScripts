#!/bin/bash

OUTDIR=$HOME/binaries
NIXSRCDIR=$HOME/linux-h2o
OSXSRCDIR=$HOME/mac-h2o
WINSRCDIR=$HOME/win-h2o

#if [ "$2" == "alt" ]; then
#	DEPS=~/h2o/depends
#else
DEPS=$HOME/h2o/depends
#fi


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
#git clone https://github.com/h2ocore/h2o.git linux-h2o
#cd linux-h2o && sh autogen.sh
#cp -rf linux-h2o mac-h2o
#cp -rf linux-h2o win-h2o

getversion()
{
  VER=$(grep -E '#define CLIENT_VERSION_(MAJOR|MINOR|REVISION|BUILD)' $PWD/src/clientversion.h | \
  grep -ohE '[0-9]' | tr -d '[:space:]')
}

buildlinux()
{

chmod 775 -R $NIXSRCDIR
cd $NIXSRCDIR
make clean
git pull
getversion

#sh autogen.sh

# linux GUI 64bit
export CXXFLAGS=-std=c++11
export CXX=clang++
CONFIG_SITE=$DEPS/x86_64-pc-linux-gnu/share/config.site ./configure --prefix=/ --with-gui=qt5 --disable-tests
#make clean
make -j4 V=1 && strip src/qt/h2o-qt && cp src/qt/h2o-qt . && tar czf $OUTDIR/h2o-gui-linux-$VER.tgz h2o-qt && rm h2o-qt
strip src/h2od src/h2o-cli src/h2o-tx && mv src/h2od src/h2o-cli src/h2o-tx .
tar czf $OUTDIR/h2o-linux-cli-$VER.tgz h2od h2o-cli h2o-tx && rm h2od h2o-cli h2o-tx
}

buildmac()
{
cd $NIXSRCDIR
echo "cd $OSXSRCDIR"
#make clean
echo "git pull"
getversion

export CXXFLAGS=-std=c++11
export CXX=clang++
cd $OSXSRCDIR
#./autogen.sh
CONFIG_SITE=$DEPS/x86_64-apple-darwin11/share/config.site ./configure --prefix=/ --with-gui=qt5 --disable-tests
make clean
make -j4
$DEPS/x86_64-apple-darwin11/native/bin/x86_64-apple-darwin11-strip src/h2od src/h2o-cli src/h2o-tx src/qt/h2o-qt
make deploy
zip $OUTDIR/h2o-Core.dmg-$VER.zip h2o-Core.dmg
mv src/h2od src/h2o-cli src/h2o-tx .
tar czf $OUTDIR/h2o-cli-osx-$VER.tgz h2od h2o-cli h2o-tx && rm h2od h2o-cli h2o-tx
}

buildwin32()
{
cd $WINSRCDIR
make clean
git pull
getversion

# 32bit Win 
#PATH=$(echo "$PATH" | sed -e 's/:\/mnt.*//g')
CONFIG_SITE=$DEPS/i686-w64-mingw32/share/config.site ./configure --prefix=/ --with-gui=qt5 --disable-tests
#make clean
make -j4 && i686-w64-mingw32-strip src/qt/h2o-qt.exe && mv src/qt/h2o-qt.exe .
zip $OUTDIR/h2o_x86-qt.exe-$VER.zip h2o-qt.exe && rm h2o-qt.exe
x86_64-w64-mingw32-strip src/h2od.exe src/h2o-cli.exe src/h2o-tx.exe && mv src/h2od.exe src/h2o-cli.exe src/h2o-tx.exe .
zip $OUTDIR/h2o_win_x86-cli-$VER.zip h2od.exe h2o-cli.exe h2o-tx.exe
rm h2od.exe h2o-cli.exe h2o-tx.exe
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
buildmac
buildwin32
