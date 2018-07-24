#!/bin/bash

usesystemd=0
##---Check if root use may need sudo in some spots
if [ $(id -u) -ne 0 ]
then
  SUDO='sudo'
else
  SUDO=''
fi

##---Try to stop h2o service
h2o-cli stop
echo "Trying to stop h2o service..."
sleep 6

#might be using systemd
if pgrep -x "h2od" > /dev/null
then
    $SUDO systemctl stop h2o
    echo "Trying to stop h2o service... again"
    sleep 6
    if ! pgrep -x "h2od" > /dev/null
    then
        usesystemd=1
    fi
fi

if pgrep -x "h2od" > /dev/null
then
    printf "\nCannot stop masternode."
    printf "\nPlease shutdown H2O masternode before installing."
    printf "\nUse the command h2o-cli stop \n\n"
    exit 0
fi

##---Download new H2O Wallet and uncompress
echo "Downloading upgraded h2o wallet..."
wget https://github.com/h2ocore/h2o/releases/download/v0.12.1.7/Linux64-H2O-cli-01217.tgz
tar -zxf Linux64-H2O-cli-01217.tgz
rm Linux64-H2O-cli-01217.tgz

##---Check that files exist
f1="h2od"
f2="h2o-cli"
f3="h2o-tx"

if [ ! -f $f1 ]; then
    echo "{$f1} not found!"
    echo "Stopping...."
    exit 0
fi
if [ ! -f $f2 ]; then
    echo "{$f2} not found!"
    echo "Stopping...."
    exit 0   
fi
if [ ! -f $f3 ]; then
    echo "{$f3} not found!"
    echo "Stopping...."
    exit 0
fi

##---Check directory for current h2o binaries and move to that directory
mvpath=$(which h2od | sed "s/h2od//g")

echo "Moving {$f1} {$f2} {$f3} to $mvpath..."

$SUDO mv $f1 $f2 $f3 $mvpath

##---Restart H2O Masternode
echo "Trying to restart masternode..."
if  [ "$usesystemd" -eq "1" ];
then
    $SUDO systemctl start h2o
else
    h2od
fi

#sleep 10

if ! pgrep -x "h2od" > /dev/null
then
    echo "Could not restart H2O masternode :'("
    exit 0
fi

echo "Checking version..."
sleep 6
##---Check for success for failure of upgrade
if  h2o-cli getinfo | grep -m 1 '"protocolversion": 70209,'
then
        echo "H2O Mastenode has been successfully uppdated"
else
        echo "H2O masternode Install failed :'( "
fi
printf "\n\nUse h2o-cli mnsync status\n"
echo "and h2o-cli masternode status"
echo "to verify masternode is active"