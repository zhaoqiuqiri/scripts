set -x
mkdir -p tmp && GO_MODULE_ON=GO111MODULE=on GOPROXY=https://goproxy.cn,direct go run ./tools/build-swagger/main.go && cp -f ./tmp/swagger.json ~/go/src/github.com/stoneshi-yunify/share/ks-store/swagger.json && cd ~/go/src/github.com/stoneshi-yunify/share && git add ./ks-store/swagger.json && git commit -s -m "update swagger.json" && git push && echo "done"
