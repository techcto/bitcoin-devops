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

apt-get install -y cmake libboost-all-dev gcc git libevent-dev make pkgconf python3 sqlite gperf file libfmt-dev byacc 
apt-get install -y build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 libssl-dev libdb-dev libdb++-dev libsqlite3-dev

#build bitcoin source
cmake -B build
cmake --build build
cmake --install build

#Install Service
mkdir -p /run/bitcoind
cp -f /tmp/bitcoin.conf /etc/bitcoin/bitcoin.conf
cp -f /tmp/bitcoind.service /etc/systemd/system/bitcoind.service
systemctl enable bitcoind