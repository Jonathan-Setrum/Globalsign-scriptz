#!/bin/bash
if [ $1 ]; then
   openssl s_client -state -nbio -showcerts -connect "$1":443 -debug -tls1 2>&1 > $1.txt
# HTTPS FTPS SMTPS 465 587 IMAPS 993 POP3S 995 
   else
   echo "usage recon.sh [domain.tld]"
fi
  
