#!/bin/bash

export $(egrep -v '^#' .env | xargs)
args=("$@")

export TAG_RELEASE=$(date +"%y.%m%d.%S")
export SOLODEV_RELEASE=$TAG_RELEASE
export AWS_PROFILE=develop

init(){
    git submodule init
    git submodule add -f https://github.com/bitcoin/bitcoin.git ./submodules/bitcoin
}


bundle(){
    docker-compose -f docker-compose.bundle.yml up --build
}

ami(){
    cd devops/ami
    rm -Rf files/Bitcoin.zip
    cp ../../dist/bitcoin.zip files/Bitcoin.zip
    ./build.sh config bitcoin-packer.json
}

build(){
    DEBIAN_FRONTEND=noninteractive
    TZ=America/New_York

    apt update
    apt-get install -y build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 libssl-dev libdb-dev libdb++-dev
    apt-get install -y libevent-dev libboost-system-dev libboost-filesystem-dev libboost-test-dev libboost-thread-dev libfmt-dev
    #BerkleyDB for wallet support
    apt-get install -y libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools
    #upnp
    apt-get install -y libminiupnpc-dev
    #ZMQ
    apt-get install -y libzmq3-dev
    #build bitcoin source
    ./autogen.sh
    ./configure --with-incompatible-bdb
    make
    make install
}

cft(){
    export AWS_PROFILE=develop
    cd devops/cloudformation
    cp -f bitcoin-pro-linux.yaml.dst bitcoin-pro-linux.yaml
    AMI_BC=$(jq -r '.builds[0].artifact_id|split(":")[1]' ./bitcoin-manifest.json )
    sed -i "s/{CustomAMI}/$AMI_BC/g" bitcoin-pro-linux.yaml
    aws s3 cp bitcoin-pro-linux.yaml s3://bitcoin-pro/cloudformation/bitcoin-pro-linux.yaml --acl public-read

    BC=1
    if [ $BC == 1 ]; then
        echo "Create Bitcoin Pro"
        aws cloudformation create-stack --disable-rollback --stack-name bc-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
            --parameters file://params/bitcoin-pro-linux.json \
            --template-url https://s3.amazonaws.com/bitcoin-pro/cloudformation/bitcoin-pro-linux.yaml
    fi
}

$*