FROM ubuntu:22.04
COPY ./bitcoin.conf /root/.bitcoin/bitcoin.conf
COPY . /bitcoin
WORKDIR /bitcoin
#shared libraries and dependencies

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

RUN apt update
RUN apt-get install -y build-essential cmake pkg-config python3 libevent-dev libboost-dev libsqlite3-dev
#BerkleyDB for wallet support
RUN apt-get install -y libminiupnpc-dev libnatpmp-dev
#ZMQ
RUN apt-get install -y libzmq3-dev
RUN apt-get install -y systemtap-sdt-dev
RUN apt-get install -y sqtbase5-dev qttools5-dev qttools5-dev-tools
RUN apt-get install -y libqrencode-dev
#build bitcoin source
RUN cmake -B build
RUN cmake --build build
RUN cmake --install build

#open service port
EXPOSE 9666 19666
CMD ["bitcoind", "--printtoconsole"]