#!/bin/bash
        for file in *.pem ; do openssl x509 -inform PEM -in $file -noout -issuer -serial ; done
        for file in *.pem ; do openssl x509 -inform PEM -in $file -noout -text | grep "CA Issuers" ; done
        for file in *.pem ; do openssl x509 -inform PEM -in $file -noout -text | grep "CA Issuers" > ca.txt ; done
        awk '{print $4}' ca.txt  
        sed -i -- 's/CA Issuers - URI://g' ca.txt
        wget -i ca.txt 
        for file in *.crt ; do openssl x509 -inform DER -in $file -out $file.pem ; done
        for file in *.crt.pem ; do mv "$file" "$(basename "$file" .crt.pem).pem" ; done
#fi
