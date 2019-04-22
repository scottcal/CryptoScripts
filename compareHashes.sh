#!/bin/bash

#compare two wallets and to find the hashes that do not match
#for now wallets must be on the same machine running different RPC ports. May add curl support later.
PORT1=30008
PORT2=30007

#enter the last block you want to check
LASTBLOCK=67610
#starting block
BLOCK=67156

#coins binary prefix
PREFIX="blastx"

#loop until last block where there is no diff or the  difference in hash is discovered
while [ $BLOCK -le $LASTBLOCK ]
do
	echo "Comparing block $BLOCK"
	HASH1=$($PREFIX-cli --rpcport=$PORT1 getblockhash $BLOCK)
	HASH2=$($PREFIX-cli --rpcport=$PORT2 getblockhash $BLOCK)	
	
	#debug print hashes
	#echo "Hash 1 is: $HASH1"
	#echo "Hash 2 is: $HASH2"

	if [ $HASH1 != $HASH2 ]
	then
		break
	fi
	
	#go to next block
	((BLOCK++))

done

if [ $HASH1 != $HASH2 ]
then
	echo "The difference is on block $BLOCK"
	echo "Hash1 is: $HASH1 "
	echo "Hash2 is: $HASH2 "
else
	echo -e "\n***There is no difference***"
fi

#echo diff <(blastx-cli --rpcport=$PORT1 getblockhash $BLOCK) <(blastx-cli --rpcport=$PORT2 getblockhash $BLOCK
