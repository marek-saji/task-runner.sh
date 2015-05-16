#!/bin/bash

NAME="$1"

for STEP in $( seq 1 5 )
do
    if (( STEP - 1 ))
    then
        HASH=$( echo ${NAME} ${STEP} | md5sum )
        sleep $(( 0x${HASH:0:1} / 3 ))
    fi
    FN=$(( ( STEP % 3 ) % 2 + 1 ))
    echo "I am ${NAME} for the #${STEP} time" 1>&${FN}
done
