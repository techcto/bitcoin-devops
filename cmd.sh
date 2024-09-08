#!/bin/bash

export $(egrep -v '^#' .env | xargs)
args=("$@")

export TAG_RELEASE=$(date +"%y.%m%d.%S")
export SOLODEV_RELEASE=$TAG_RELEASE
export AWS_PROFILE=develop
DATE=$(date +%d%H%M)

init(){
    git submodule init
    git submodule add -f https://github.com/bitcoin/bitcoin.git ./submodules/bitcoin
}


bundle(){
    docker-compose -f docker-compose.bundle.yml up --build
}

ami(){
    cd devops/ami
    rm -Rf files/Bitcoin.zip bitcoin-manifest.*
    cp ../../dist/bitcoin.zip files/Bitcoin.zip
    ./build.sh config bitcoin-packer.json
}

build(){
    DEBIAN_FRONTEND=noninteractive
    TZ=America/New_York

    #Install Bitcoin
    apt update

    apt-get install -y cmake libboost-all-dev gcc git libevent-dev make pkgconf python3 sqlite gperf file libfmt-dev byacc 
    apt-get install -y build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 libssl-dev libdb-dev libdb++-dev libsqlite3-dev
    
    # #build bitcoin source
    cmake -B build
    cmake --build build
    cmake --install build
}

cft(){
    export AWS_PROFILE=develop
    cd devops/cloudformation
    cp -f bitcoin-pro-linux.yaml.dst bitcoin-pro-linux.yaml
    AMI_BC=$(jq -r '.builds[0].artifact_id|split(":")[1]' ../ami/bitcoin-manifest.json )
    # AMI_BC=ami-074d58f0dd41d56ca
    sed -i "s/{CustomAMI}/$AMI_BC/g" bitcoin-pro-linux.yaml
    sed -i "s/{SOLODEV_RELEASE}/$SOLODEV_RELEASE/g" bitcoin-pro-linux.yaml
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