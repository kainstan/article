#!/bin/sh

setuptools() {
  # 安装openvpn以及相应的依赖库
  apt install -y openvpn libssl-dev openssl

  # 安装加密工具
  apt install -y easy-rsa
}

handle_files() {
  cd /etc/openvpn
  mkdir easy-rsa
  cd easy-rsa
  cp -r /usr/share/easy-rsa/* ./
  cp vars.example vars
  echo 'export KEY_NAME="vpnilanni"' >> vars
  ./easyrsa init-pki
  ./easyrsa build-ca nopass
  ./easyrsa build-server-full vpnilanni nopass

  ./easyrsa build-client-full ilanni nopass
  ./easyrsa gen-dh

  cd ..
  cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz ./
  gzip -d server.conf.gz

  cp easy-rsa/pki/ca.crt ./
  cp easy-rsa/pki/issued/vpnilanni.crt ./
  cp easy-rsa/pki/private/vpnilanni.key ./
  cp easy-rsa/pki/dh.pem ./dh2048.pem
}

edit_server_conf(){
  sed -i 's/;proto tcp/proto tcp/g' server.conf
  sed -i 's/proto udp/;proto udp/g' server.conf
  sed -i 's/cert server.crt/cert vpnilanni.crt/g' server.conf
  sed -i 's/key server.key/key vpnilanni.key/g' server.conf
  sed -i 's/server 10.8.0.0 255.255.255.0/server 10.8.16.0 255.255.255.0/g' server.conf
  sed -i 's/;push "redirect-gateway def1 bypass-dhcp"/push "redirect-gateway def1 bypass-dhcp"/g' server.conf
  sed -i 's/;push "dhcp-option DNS 208.67.222.222"/push "dhcp-option DNS 114.114.114.114"/g' server.conf
  sed -i 's/;push "dhcp-option DNS 208.67.220.220"/push "dhcp-option DNS 8.8.8.8"/g' server.conf
  sed -i 's/tls-auth ta.key 0/;tls-auth ta.key 0/g' server.conf
  sed -i 's/;comp-lzo/comp-lzo/g' server.conf
  sed -i 's/;log-append/log-append/g' server.conf
  sed -i 's/explicit-exit-notify 1/;explicit-exit-notify 1/g' server.conf
}

startup_config(){
  nohup openvpn --config /etc/openvpn/server.conf &
  echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
  ptables -t nat -A POSTROUTING -s 10.8.16.0/24 -o eth0 -j MASQUERADE
  iptables-save > /etc/iptables.up.rules
}

# 1，安装相应的工具
setuptools
# 2，处理相应的文件
handle_files
# 3，编辑服务端配置文件
edit_server_conf
# 4，转发文件配置及启动
startup_config
