#!/bin/bash
if [ $1 ]; then
    if [ -d $1 ]; then
        openssl req -text -in $1/$1.csr
#        for file in $1/*.crt ; do openssl x509 -inform DER -in $file -noout -text ; done
        for file in $1/*.crt ; do openssl x509 -inform DER -in $file -out $file.pem -text ; done
        for file in *.crt.pem ; do mv "$file" "$(basename "$file" .crt.pem).pem" ; done
        for file in $1/*.pem ; do openssl x509 -inform PEM -in $file -noout -text ; done
    fi
else
    echo "usage showsslinfo.sh [domain.tld]"
fi
