#!/bin/bash
if [ $1 ]; then
    if [ -d $1 ]; then
        echo "dir $1 exists exiting"
        exit
    else
        mkdir $1
    fi
    openssl genrsa -out $1/$1.key 2048
    openssl req -new -key $1/$1.key -out $1/$1.csr
else
    echo "usage generatessl.sh [domain.tld]"
fi
