curl -L 'http://139.198.15.193:30880/login' \
  -H 'Connection: keep-alive' \
  -H 'Pragma: no-cache' \
  -H 'Cache-Control: no-cache' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36' \
  -H 'content-type: application/json' \
  -H 'Accept: */*' \
  -H 'Origin: http://139.198.15.193:30880' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  -H 'Cookie: referer=/dashboard; lang=en' \
  --data-binary '{"username":"admin@kubesphere.io","encrypt":"MDEwMTAxMTEwMDAx@]^chjbLWc]JB"}' \
  --compressed \
  --insecure \
  --cookie-jar /tmp/ks-console-cookie

curl 'http://139.198.15.193:30880/kapis/clusters/host/resources.kubesphere.io/v1alpha3/persistentvolumeclaims?sortBy=createTime&limit=10' \
  -H 'Connection: keep-alive' \
  -H 'Pragma: no-cache' \
  -H 'Cache-Control: no-cache' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36' \
  -H 'content-type: application/json' \
  -H 'Accept: */*' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  --compressed \
  --insecure \
  --cookie /tmp/ks-console-cookie

curl 'http://139.198.15.193:30880/kapis/clusters/host/resources.kubesphere.io/v1alpha3/persistentvolumeclaims?sortBy=createTime&limit=10' \
  -H 'Connection: keep-alive' \
  -H 'Pragma: no-cache' \
  -H 'Cache-Control: no-cache' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36' \
  -H 'content-type: application/json' \
  -H 'Accept: */*' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  --compressed \
  --insecure \
  --cookie /tmp/ks-console-cookie
  
