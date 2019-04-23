#!/bin/bash
#Compares the hashes of a local wallet against a local wallet.

min() {
    printf "%s\n" "${@:2}" | sort "$1" | head -n1
}

#Declare the local wallet cli command, get blockhash and getblockcount cmds 
CLI="/usr/local/bin/blastx-cli -conf=/home/miner/.blastx01/blastx.conf"
CLI_GETBLOCKHASH="${CLI} getblockhash"
CLI_GETBLOCKCOUNT="${CLI} getblockcount"


CURL="/usr/bin/curl --silent"
#Declare the API/Explorer address and  getblockhash and getblockcount cmds 
API="${CURL} http://explorer.blastexchange.com/api"
API_GETBLOCKHASH="${API}/getblockhash?index="
API_GETBLOCKCOUNT="${API}/getblockcount"

#get the counts via cli and curl
CLI_COUNT=$( $CLI_GETBLOCKCOUNT )
API_COUNT=$( $API_GETBLOCKCOUNT )


START_BLOCK=$( min -g $CLI_COUNT $API_COUNT )
BLOCK=$START_BLOCK
END_BLOCK=1

#echo "CLI Count = ${CLI_COUNT}"
#echo "API Count = ${API_COUNT}"
#echo "Start Block = ${START_BLOCK}"
#echo ""

SPLITTED=0

while [ $BLOCK -gt $END_BLOCK ]
do
	CLI_HASH=$( ${CLI_GETBLOCKHASH} ${BLOCK} )
	API_HASH=$( ${API_GETBLOCKHASH}${BLOCK} )
	#API_HASH=$( ${API_GETBLOCKHASH}69180 )	# script debug

	echo "#${BLOCK} ${CLI_HASH} ${API_HASH}"

	if [ $CLI_HASH == $API_HASH ]
	then
		break
	fi

	SPLITTED=1

	((BLOCK--))
done

echo ""

if [ $SPLITTED == 1 ]
then
	BAD_BLOCK=$(($BLOCK + 1))
	BAD_HASH=$( ${CLI_GETBLOCKHASH} ${BAD_BLOCK} )
	
	echo "SPLIT CHAIN FOUND AT BLOCK # ${BAD_BLOCK} = ${BAD_HASH}"
	exit 1
else
	echo "No split chain found"
	exit 0
fi
