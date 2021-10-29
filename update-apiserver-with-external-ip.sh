#!/bin/bash

set -e

if [[ $# -ne 1 ]]
then
  echo "Usage: $0 <APIServer External IP>"
  echo "Run this script under the directory where apiserver.crt exists (e.g. /etc/kubernetes/pki)"
  exit
fi

for f in apiserver.crt ca.crt ca.key
do
  [[ ! -f "$f" ]] && echo "./$f not found" && exit 1
done

ip=$1

[[ $(openssl x509 -in apiserver.crt -noout -ext "subjectAltName" | grep -c "Address:$ip") -gt 0 ]] && echo "External IP $ip already exists in apiserver.crt" && exit 0

tmpdir=/tmp/_apiserver
mkdir -p "$tmpdir"
echo "Backing up apiserver.crt and apiserver.key to $tmpdir ..."
cp -f apiserver.crt apiserver.key "$tmpdir"

echo "Generating new apiserver.crt and apiserver.key ..."
openssl genrsa -out apiserver.key 4096
openssl req -new -key apiserver.key -subj "/CN=kube-apiserver" -out apiserver.csr
# generate .ext file, refer to https://www.openssl.org/docs/man1.0.2/man5/x509v3_config.html
{
  echo "keyUsage=critical,digitalSignature,keyEncipherment"
  echo "extendedKeyUsage=serverAuth"
  echo "basicConstraints=critical,CA:FALSE"
  echo "authorityKeyIdentifier=keyid"
  echo "subjectAltName=$(openssl x509 -in apiserver.crt -noout -ext "subjectAltName" | grep -v "Subject Alternative Name" | sed 's/ Address//g' | sed 's/, /,/g' | sed 's/,IP:<invalid>//g' | awk '{$1=$1;print}'),IP:$ip"
} > apiserver.ext
openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out apiserver.crt -days 365 -extfile apiserver.ext

echo "Generate succeeded"
echo "Make sure to run this script on all masters"

echo "Do you want to restart all kube-apiserver pods? [yes/no]"
read -r ans
[[ $ans != "yes" ]] && exit 0

echo "Restart kube-apiserver ..."
for apiserver in $(kubectl -n kube-system get pod | awk '{print $1}' | grep "^kube-apiserver")
do
  kubectl -n kube-system delete pod $apiserver
done

echo "Please wait a while for the new apiserver pods to start"
echo "Done"

exit 0

