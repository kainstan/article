#! /bin/bash
cd /etc/openvpn/easy-rsa
read -p "input your username:" username
./easyrsa build-client-full $username nopass

cd ~/cert || mkdir -p ~/cert
mkdir $username
cp /etc/openvpn/easy-rsa/pki/issued/$username.crt ~/cert/$username
cp /etc/openvpn/easy-rsa/pki/private/$username.key ~/cert/$username
cp /etc/openvpn/easy-rsa/pki/ca.crt ~/cert/$username