#!/bin/bash
cd /etc/openvpn/easy-rsa
read -p "input your username:" username
./easyrsa build-client-full $username nopass