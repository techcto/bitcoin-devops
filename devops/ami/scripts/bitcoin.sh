#!/bin/bash

args=("$@")

sync(){
    echo "Upload Blockchain to S3"
    cd /root/.bitcoin/blocks
    tar -czvf blocks.tar.gz *
    aws s3 cp blocks.tar.gz s3://bitcoin-pro/blocks.tar.gz
    rm -Rf blocks.tar.gz
}

restore(){
    cd /root/.bitcoin/blocks
    aws s3 cp s3://bitcoin-pro/blocks.tar.gz blocks.tar.gz
	tar -xzvf blocks.tar.gz
    rm -Rf blocks.tar.gz
}

$*