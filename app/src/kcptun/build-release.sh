#!/bin/bash

BUILD_DIR=$(dirname "$0")/build
mkdir -p $BUILD_DIR
cd $BUILD_DIR

sum="sha1sum"

export GO111MODULE=on
echo "Setting GO111MODULE to" $GO111MODULE

if ! hash sha1sum 2>/dev/null; then
	if ! hash shasum 2>/dev/null; then
		echo "I can't see 'sha1sum' or 'shasum'"
		echo "Please install one of them!"
		exit
	fi
	sum="shasum"
fi

UPX=false
if hash upx 2>/dev/null; then
	UPX=true
fi

VERSION=`date -u +%Y%m%d`
LDFLAGS="-X main.VERSION=$VERSION -s -w"
GCFLAGS=""

# AMD64
OSES=(linux darwin windows freebsd)
ARCHS=(amd64 386)

REPO="github.com/zyf0330/kcptun"

# Get go
#go get -u $REPO
#go get -u ./...


for os in ${OSES[@]}; do
	suffix=""
	if [ "$os" == "windows" ]
	then
		suffix=".exe"
	fi
	env CGO_ENABLED=0 GOOS=$os GOARCH=amd64 go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o client_${os}_amd64${suffix} $REPO/client
	env CGO_ENABLED=0 GOOS=$os GOARCH=amd64 go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o server_${os}_amd64${suffix} $REPO/server
	if $UPX; then upx -9 client_${os}_amd64${suffix} server_${os}_amd64${suffix};fi
	tar -zcf kcptun-${os}-amd64-$VERSION.tar.gz client_${os}_amd64${suffix} server_${os}_amd64${suffix}
	$sum kcptun-${os}-amd64-$VERSION.tar.gz
done

# 386
OSES=(linux windows)
for os in ${OSES[@]}; do
	suffix=""
	if [ "$os" == "windows" ]
	then
		suffix=".exe"
	fi
	env CGO_ENABLED=0 GOOS=$os GOARCH=386 go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o client_${os}_386${suffix} $REPO/client
	env CGO_ENABLED=0 GOOS=$os GOARCH=386 go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o server_${os}_386${suffix} $REPO/server
	if $UPX; then upx -9 client_${os}_386${suffix} server_${os}_386${suffix};fi
	tar -zcf kcptun-${os}-386-$VERSION.tar.gz client_${os}_386${suffix} server_${os}_386${suffix}
	$sum kcptun-${os}-386-$VERSION.tar.gz
done

#Apple M1 device
env CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o server_darwin_arm64 $REPO/server
env CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o client_darwin_arm64 $REPO/client
tar -zcf kcptun-darwin-arm64-$VERSION.tar.gz client_darwin_arm64 server_darwin_arm64
$sum kcptun-darwin-arm64-$VERSION.tar.gz

# ARM
ARMS=(5 6 7)
for v in ${ARMS[@]}; do
	env CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=$v go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o client_linux_arm$v $REPO/client
	env CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=$v go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o server_linux_arm$v $REPO/server
if $UPX; then upx -9 client_linux_arm$v server_linux_arm$v;fi
tar -zcf kcptun-linux-arm$v-$VERSION.tar.gz client_linux_arm$v server_linux_arm$v
$sum kcptun-linux-arm$v-$VERSION.tar.gz
done

# ARM64
env CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o client_linux_arm64  $REPO/client
env CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o server_linux_arm64  $REPO/server
if $UPX; then upx -9 client_linux_arm64 server_linux_arm64*;fi
tar -zcf kcptun-linux-arm64-$VERSION.tar.gz client_linux_arm64 server_linux_arm64
$sum kcptun-linux-arm64-$VERSION.tar.gz

#MIPS32LE
env CGO_ENABLED=0 GOOS=linux GOARCH=mipsle GOMIPS=softfloat go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o client_linux_mipsle $REPO/client
env CGO_ENABLED=0 GOOS=linux GOARCH=mipsle GOMIPS=softfloat go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o server_linux_mipsle $REPO/server
env CGO_ENABLED=0 GOOS=linux GOARCH=mips GOMIPS=softfloat go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o client_linux_mips $REPO/client
env CGO_ENABLED=0 GOOS=linux GOARCH=mips GOMIPS=softfloat go build -mod=vendor -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o server_linux_mips $REPO/server

if $UPX; then upx -9 client_linux_mips* server_linux_mips*;fi
tar -zcf kcptun-linux-mipsle-$VERSION.tar.gz client_linux_mipsle server_linux_mipsle
tar -zcf kcptun-linux-mips-$VERSION.tar.gz client_linux_mips server_linux_mips
$sum kcptun-linux-mipsle-$VERSION.tar.gz
$sum kcptun-linux-mips-$VERSION.tar.gz
