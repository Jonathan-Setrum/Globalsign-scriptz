#!/bin/bash
if [ $1 ]; then
    if [ $2 ]; then
    zip -r -e $1.zip $1 -P $2
    fi
else
    echo "usage passwordssl.sh [domain.tld] [password]"
fi
