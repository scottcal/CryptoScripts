#!/bin/bash

GenerateKey()
{
	KEYNAME=$1
	PEMFILE=$1.pem
	TXTFILE=$1.txt
	KEYFILE=$1.key
	PUBFILE=$1.pub
	
	echo -e "\n### Generating key for '$KEYNAME'"
	
	openssl ecparam -genkey -name prime256v1 -out $PEMFILE
	openssl ec -in $PEMFILE -noout -text 1>$TXTFILE 2>/dev/null
	
	cat $TXTFILE|tail -7|head -n 5|tr -d ': \n'  >$PUBFILE
	cat $TXTFILE|tail -11|head -n 3|tr -d ': \n' >$KEYFILE
	
	rm -f $TXTFILE
	
	echo "--- $KEYNAME Public  key: $(cat $PUBFILE)"
	echo "--- $KEYNAME Private key: $(cat $KEYFILE)"
}

cd $(dirname $0)
DEST_DIR="$(date +%Y%m%d_%H%M%S)"

mkdir $DEST_DIR
cd $DEST_DIR

GenerateKey "mainnet_alert"
GenerateKey "mainnet_spork"

GenerateKey "testnet_alert"
GenerateKey "testnet_spork"

cd ..
