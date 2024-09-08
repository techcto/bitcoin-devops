echo "Install Bitcoin"
unzip /tmp/Bitcoin.zip -d /tmp/Bitcoin
rm -Rf /tmp/Bitcoin.zip
ls -al /tmp/Bitcoin

rm -Rf /bitcoin
mv /tmp/Bitcoin /bitcoin
cd /bitcoin
chmod -Rf 2770 /bitcoin
ls -al /bitcoin

DEBIAN_FRONTEND=noninteractive
TZ=America/New_York

adduser bitcoin
usermod -aG sudo bitcoin
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
mkdir /etc/bitcoin && sudo chown -R bitcoin:bitcoin /etc/bitcoin

#Install Bitcoin
apt update
apt-get install -y cmake boost gcc git libevent make pkgconf python3 sqlite gperf file
apt-get install -y build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 libssl-dev libdb-dev libdb++-dev libsqbit3-dev
apt-get install -y libevent-dev libboost-system-dev libboost-filesystem-dev libboost-test-dev libboost-thread-dev libfmt-dev
#BerkleyDB for wallet support
apt-get install -y libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools
#upnp
apt-get install -y libminiupnpc-dev
#ZMQ
apt-get install -y libzmq3-dev
#build bitcoin source
cd depends
make -j2
cd ..
./autogen.sh
./configure --with-incompatible-bdb
make
make install

#Install Service
cp -f /tmp/bitcoin.conf /etc/bitcoin/bitcoin.conf
cp -f /tmp/bitcoind.service /etc/systemd/system/bitcoind.service
systemctl enable bitcoind