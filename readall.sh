#for file in *.crt ; do openssl x509 -inform DER -in $file -noout -text ; done
for file in *.crt ; do openssl x509 -inform DER -in $file -out $file.pem -text ; done
for file in *.crt.pem ; do mv "$file" "$(basename "$file" .crt.pem).pem" ; done 
for file in *.pem ; do openssl x509 -inform PEM -in $file -noout -text ; done
for i in *.crl; do openssl crl -inform DER -noout -text -in $i; done
