#!/bin/bash
if [ $1 ]; then
    if [ $2 ]; then
       if [ $3 ]; then
        openssl ocsp -issuer $1.pem -VAfile $1.pem  -serial 0x$2 -text -req_text -url http://ocsp.globalsign.com/$3 -header "HOST" "ocsp.globalsign.com" -nonce
#        openssl ocsp -issuer $1.pem -VAfile $1.pem  -serial 0x$2 -text -req_text -url http://ocsp2.globalsign.com/$3 -header "HOST" "ocsp2.globalsign.com" -nonce
       else
      echo "usage showocsp.sh [signer.pem] [Serial number] [OCSP Last URI]"
    fi
    else
      echo "usage showocsp.sh [signer.pem] [Serial number] [OCSP Last URI]"
    fi
else
    echo "usage showocsp.sh [signer.pem] [Serial number] [OCSP Last URI]"
fi
