1, Install openvpn

```
# operate like this
sudo apt install -y openvpn libssl-dev openssl
# check
openvpn --version
# install tool
sudo apt install -y easy-rsa
# check
dpkg --list easy-rsa
```

2, Config the key and cert

​	generate easy-rasa directory

```
# enter the openvpn dir and create the env
cd /etc/openvpn
# change root 
sudo su
mkdir easy-rsa && cd easy-rsa
cp -r /usr/share/easy-rsa/* ./
cp vars.example vars
```

​	Eidit the vars file use `vim var`

```
# Easy-RSA 3 parameter settings

# NOTE: If you installed Easy-RSA from your distro's package manager, don't edit
# this file in place -- instead, you should copy the entire easy-rsa directory
# to another location so future upgrades don't wipe out your changes.

# HOW TO USE THIS FILE
#
# vars.example contains built-in examples to Easy-RSA settings. You MUST name
# this file 'vars' if you want it to be used as a configuration file. If you do
# not, it WILL NOT be automatically read when you call easyrsa commands.
#
# It is not necessary to use this config file unless you wish to change
# operational defaults. These defaults should be fine for many uses without the
# need to copy and edit the 'vars' file.
#
# All of the editable settings are shown commented and start with the command
# 'set_var' -- this means any set_var command that is uncommented has been
# modified by the user. If you're happy with a default, there is no need to
# define the value to its default.

# NOTES FOR WINDOWS USERS
#
# Paths for Windows  *MUST* use forward slashes, or optionally double-esscaped
# backslashes (single forward slashes are recommended.) This means your path to
# the openssl binary might look like this:
# "C:/Program Files/OpenSSL-Win32/bin/openssl.exe"

# A little housekeeping: DON'T EDIT THIS SECTION
# 
# Easy-RSA 3.x doesn't source into the environment directly.
# Complain if a user tries to do this:
if [ -z "$EASYRSA_CALLER" ]; then
	echo "You appear to be sourcing an Easy-RSA 'vars' file." >&2
	echo "This is no longer necessary and is disallowed. See the section called" >&2
	echo "'How to use this file' near the top comments for more details." >&2
	return 1
fi

# DO YOUR EDITS BELOW THIS POINT

# This variable is used as the base location of configuration files needed by
# easyrsa.  More specific variables for specific files (e.g., EASYRSA_SSL_CONF)
# may override this default.
#
# The default value of this variable is the location of the easyrsa script
# itself, which is also where the configuration files are located in the
# easy-rsa tree.

#set_var EASYRSA	"${0%/*}"

# If your OpenSSL command is not in the system PATH, you will need to define the
# path to it here. Normally this means a full path to the executable, otherwise
# you could have left it undefined here and the shown default would be used.
#
# Windows users, remember to use paths with forward-slashes (or escaped
# back-slashes.) Windows users should declare the full path to the openssl
# binary here if it is not in their system PATH.

#set_var EASYRSA_OPENSSL	"openssl"
#
# This sample is in Windows syntax -- edit it for your path if not using PATH:
#set_var EASYRSA_OPENSSL	"C:/Program Files/OpenSSL-Win32/bin/openssl.exe"

# Edit this variable to point to your soon-to-be-created key directory.  By
# default, this will be "$PWD/pki" (i.e. the "pki" subdirectory of the
# directory you are currently in).
#
# WARNING: init-pki will do a rm -rf on this directory so make sure you define
# it correctly! (Interactive mode will prompt before acting.)

#set_var EASYRSA_PKI		"$PWD/pki"

# Define X509 DN mode.
# This is used to adjust what elements are included in the Subject field as the DN
# (this is the "Distinguished Name.")
# Note that in cn_only mode the Organizational fields further below aren't used.
#
# Choices are:
#   cn_only  - use just a CN value
#   org      - use the "traditional" Country/Province/City/Org/OU/email/CN format

#set_var EASYRSA_DN	"cn_only"

# Organizational fields (used with 'org' mode and ignored in 'cn_only' mode.)
# These are the default values for fields which will be placed in the
# certificate.  Don't leave any of these fields blank, although interactively
# you may omit any specific field by typing the "." symbol (not valid for
# email.)

#set_var EASYRSA_REQ_COUNTRY	"CN"
#set_var EASYRSA_REQ_PROVINCE	"SH"
#set_var EASYRSA_REQ_CITY	"SH"
#set_var EASYRSA_REQ_ORG	"ilanni"
#set_var EASYRSA_REQ_EMAIL	"ilanni@example.net"
#set_var EASYRSA_REQ_OU		"ilanni"

# Choose a size in bits for your keypairs. The recommended value is 2048.  Using
# 2048-bit keys is considered more than sufficient for many years into the
# future. Larger keysizes will slow down TLS negotiation and make key/DH param
# generation take much longer. Values up to 4096 should be accepted by most
# software. Only used when the crypto alg is rsa (see below.)

#set_var EASYRSA_KEY_SIZE	2048

# The default crypto mode is rsa; ec can enable elliptic curve support.
# Note that not all software supports ECC, so use care when enabling it.
# Choices for crypto alg are: (each in lower-case)
#  * rsa
#  * ec

#set_var EASYRSA_ALGO		rsa

# Define the named curve, used in ec mode only:

#set_var EASYRSA_CURVE		secp384r1

# In how many days should the root CA key expire?

#set_var EASYRSA_CA_EXPIRE	3650

# In how many days should certificates expire?

#set_var EASYRSA_CERT_EXPIRE	1080

# How many days until the next CRL publish date?  Note that the CRL can still be
# parsed after this timeframe passes. It is only used for an expected next
# publication date.

# How many days before its expiration date a certificate is allowed to be
# renewed?
#set_var EASYRSA_CERT_RENEW	30

#set_var EASYRSA_CRL_DAYS	180

# Support deprecated "Netscape" extensions? (choices "yes" or "no".) The default
# is "no" to discourage use of deprecated extensions. If you require this
# feature to use with --ns-cert-type, set this to "yes" here. This support
# should be replaced with the more modern --remote-cert-tls feature.  If you do
# not use --ns-cert-type in your configs, it is safe (and recommended) to leave
# this defined to "no".  When set to "yes", server-signed certs get the
# nsCertType=server attribute, and also get any NS_COMMENT defined below in the
# nsComment field.

#set_var EASYRSA_NS_SUPPORT	"no"

# When NS_SUPPORT is set to "yes", this field is added as the nsComment field.
# Set this blank to omit it. With NS_SUPPORT set to "no" this field is ignored.

#set_var EASYRSA_NS_COMMENT	"Easy-RSA Generated Certificate"

# A temp file used to stage cert extensions during signing. The default should
# be fine for most users; however, some users might want an alternative under a
# RAM-based FS, such as /dev/shm or /tmp on some systems.

#set_var EASYRSA_TEMP_FILE	"$EASYRSA_PKI/extensions.temp"

# !!
# NOTE: ADVANCED OPTIONS BELOW THIS POINT
# PLAY WITH THEM AT YOUR OWN RISK
# !!

# Broken shell command aliases: If you have a largely broken shell that is
# missing any of these POSIX-required commands used by Easy-RSA, you will need
# to define an alias to the proper path for the command.  The symptom will be
# some form of a 'command not found' error from your shell. This means your
# shell is BROKEN, but you can hack around it here if you really need. These
# shown values are not defaults: it is up to you to know what you're doing if
# you touch these.
#
#alias awk="/alt/bin/awk"
#alias cat="/alt/bin/cat"

# X509 extensions directory:
# If you want to customize the X509 extensions used, set the directory to look
# for extensions here. Each cert type you sign must have a matching filename,
# and an optional file named 'COMMON' is included first when present. Note that
# when undefined here, default behaviour is to look in $EASYRSA_PKI first, then
# fallback to $EASYRSA for the 'x509-types' dir.  You may override this
# detection with an explicit dir here.
#
#set_var EASYRSA_EXT_DIR	"$EASYRSA/x509-types"

# OpenSSL config file:
# If you need to use a specific openssl config file, you can reference it here.
# Normally this file is auto-detected from a file named openssl-easyrsa.cnf from the
# EASYRSA_PKI or EASYRSA dir (in that order.) NOTE that this file is Easy-RSA
# specific and you cannot just use a standard config file, so this is an
# advanced feature.

#set_var EASYRSA_SSL_CONF	"$EASYRSA/openssl-easyrsa.cnf"

# Default CN:
# This is best left alone. Interactively you will set this manually, and BATCH
# callers are expected to set this themselves.

#set_var EASYRSA_REQ_CN		"ChangeMe"

# Cryptographic digest to use.
# Do not change this default unless you understand the security implications.
# Valid choices include: md5, sha1, sha256, sha224, sha384, sha512

#set_var EASYRSA_DIGEST		"sha256"

# Batch mode. Leave this disabled unless you intend to call Easy-RSA explicitly
# in batch mode without any user input, confirmation on dangerous operations,
# or most output. Setting this to any non-blank string enables batch mode.

#set_var EASYRSA_BATCH		""

export KEY_NAME="vpnilanni"
```

​	init pki, generate  `ca.crt vpnilanni.crt vpnilanni.key`

```
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa build-server-full vpnilanni nopass
```

​	generate client  `ilanni.key dh.pem`  and copy the server config, then copy the main things to openvpn diretory

```
./easyrsa build-client-full ilanni nopass
./easyrsa gen-dh

cd ..
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz ./
gzip -d server.conf.gz

cp easy-rsa/pki/ca.crt ./
cp easy-rsa/pki/issued/vpnilanni.crt ./
cp easy-rsa/pki/private/vpnilanni.key ./
cp easy-rsa/pki/dh.pem ./dh2048.pem
```

​	edit the server.conf, use  `vim server.conf `

```
#################################################
# Sample OpenVPN 2.0 config file for            #
# multi-client server.                          #
#                                               #
# This file is for the server side              #
# of a many-clients <-> one-server              #
# OpenVPN configuration.                        #
#                                               #
# OpenVPN also supports                         #
# single-machine <-> single-machine             #
# configurations (See the Examples page         #
# on the web site for more info).               #
#                                               #
# This config should work on Windows            #
# or Linux/BSD systems.  Remember on            #
# Windows to quote pathnames and use            #
# double backslashes, e.g.:                     #
# "C:\\Program Files\\OpenVPN\\config\\foo.key" #
#                                               #
# Comments are preceded with '#' or ';'         #
#################################################

# Which local IP address should OpenVPN
# listen on? (optional)
;local a.b.c.d

# Which TCP/UDP port should OpenVPN listen on?
# If you want to run multiple OpenVPN instances
# on the same machine, use a different port
# number for each one.  You will need to
# open up this port on your firewall.
port 1194

# TCP or UDP server?
proto tcp
;proto udp

# "dev tun" will create a routed IP tunnel,
# "dev tap" will create an ethernet tunnel.
# Use "dev tap0" if you are ethernet bridging
# and have precreated a tap0 virtual interface
# and bridged it with your ethernet interface.
# If you want to control access policies
# over the VPN, you must create firewall
# rules for the the TUN/TAP interface.
# On non-Windows systems, you can give
# an explicit unit number, such as tun0.
# On Windows, use "dev-node" for this.
# On most systems, the VPN will not function
# unless you partially or fully disable
# the firewall for the TUN/TAP interface.
;dev tap
dev tun

# Windows needs the TAP-Win32 adapter name
# from the Network Connections panel if you
# have more than one.  On XP SP2 or higher,
# you may need to selectively disable the
# Windows firewall for the TAP adapter.
# Non-Windows systems usually don't need this.
;dev-node MyTap

# SSL/TLS root certificate (ca), certificate
# (cert), and private key (key).  Each client
# and the server must have their own cert and
# key file.  The server and all clients will
# use the same ca file.
#
# See the "easy-rsa" directory for a series
# of scripts for generating RSA certificates
# and private keys.  Remember to use
# a unique Common Name for the server
# and each of the client certificates.
#
# Any X509 key management system can be used.
# OpenVPN can also use a PKCS #12 formatted key file
# (see "pkcs12" directive in man page).
ca ca.crt
cert vpnilanni.crt
key vpnilanni.key  # This file should be kept secret

# Diffie hellman parameters.
# Generate your own with:
#   openssl dhparam -out dh2048.pem 2048
dh dh2048.pem

# Network topology
# Should be subnet (addressing via IP)
# unless Windows clients v2.0.9 and lower have to
# be supported (then net30, i.e. a /30 per client)
# Defaults to net30 (not recommended)
;topology subnet

# Configure server mode and supply a VPN subnet
# for OpenVPN to draw client addresses from.
# The server will take 10.8.0.1 for itself,
# the rest will be made available to clients.
# Each client will be able to reach the server
# on 10.8.0.1. Comment this line out if you are
# ethernet bridging. See the man page for more info.
server 10.8.0.0 255.255.255.0

# Maintain a record of client <-> virtual IP address
# associations in this file.  If OpenVPN goes down or
# is restarted, reconnecting clients can be assigned
# the same virtual IP address from the pool that was
# previously assigned.
ifconfig-pool-persist /var/log/openvpn/ipp.txt

# Configure server mode for ethernet bridging.
# You must first use your OS's bridging capability
# to bridge the TAP interface with the ethernet
# NIC interface.  Then you must manually set the
# IP/netmask on the bridge interface, here we
# assume 10.8.0.4/255.255.255.0.  Finally we
# must set aside an IP range in this subnet
# (start=10.8.0.50 end=10.8.0.100) to allocate
# to connecting clients.  Leave this line commented
# out unless you are ethernet bridging.
;server-bridge 10.8.0.4 255.255.255.0 10.8.0.50 10.8.0.100

# Configure server mode for ethernet bridging
# using a DHCP-proxy, where clients talk
# to the OpenVPN server-side DHCP server
# to receive their IP address allocation
# and DNS server addresses.  You must first use
# your OS's bridging capability to bridge the TAP
# interface with the ethernet NIC interface.
# Note: this mode only works on clients (such as
# Windows), where the client-side TAP adapter is
# bound to a DHCP client.
;server-bridge

# Push routes to the client to allow it
# to reach other private subnets behind
# the server.  Remember that these
# private subnets will also need
# to know to route the OpenVPN client
# address pool (10.8.0.0/255.255.255.0)
# back to the OpenVPN server.
;push "route 192.168.10.0 255.255.255.0"
;push "route 192.168.20.0 255.255.255.0"

# To assign specific IP addresses to specific
# clients or if a connecting client has a private
# subnet behind it that should also have VPN access,
# use the subdirectory "ccd" for client-specific
# configuration files (see man page for more info).

# EXAMPLE: Suppose the client
# having the certificate common name "Thelonious"
# also has a small subnet behind his connecting
# machine, such as 192.168.40.128/255.255.255.248.
# First, uncomment out these lines:
;client-config-dir ccd
;route 192.168.40.128 255.255.255.248
# Then create a file ccd/Thelonious with this line:
#   iroute 192.168.40.128 255.255.255.248
# This will allow Thelonious' private subnet to
# access the VPN.  This example will only work
# if you are routing, not bridging, i.e. you are
# using "dev tun" and "server" directives.

# EXAMPLE: Suppose you want to give
# Thelonious a fixed VPN IP address of 10.9.0.1.
# First uncomment out these lines:
;client-config-dir ccd
;route 10.9.0.0 255.255.255.252
# Then add this line to ccd/Thelonious:
#   ifconfig-push 10.9.0.1 10.9.0.2

# Suppose that you want to enable different
# firewall access policies for different groups
# of clients.  There are two methods:
# (1) Run multiple OpenVPN daemons, one for each
#     group, and firewall the TUN/TAP interface
#     for each group/daemon appropriately.
# (2) (Advanced) Create a script to dynamically
#     modify the firewall in response to access
#     from different clients.  See man
#     page for more info on learn-address script.
;learn-address ./script

# If enabled, this directive will configure
# all clients to redirect their default
# network gateway through the VPN, causing
# all IP traffic such as web browsing and
# and DNS lookups to go through the VPN
# (The OpenVPN server machine may need to NAT
# or bridge the TUN/TAP interface to the internet
# in order for this to work properly).
push "redirect-gateway def1 bypass-dhcp"
;push "redirect-gateway def1"

# Certain Windows-specific network settings
# can be pushed to clients, such as DNS
# or WINS server addresses.  CAVEAT:
# http://openvpn.net/faq.html#dhcpcaveats
# The addresses below refer to the public
# DNS servers provided by opendns.com.
;push "dhcp-option DNS 208.67.222.222"
;push "dhcp-option DNS 208.67.220.220"
push "dhcp-option DNS 114.114.114.114"
push "dhcp-option DNS 8.8.8.8"

# Uncomment this directive to allow different
# clients to be able to "see" each other.
# By default, clients will only see the server.
# To force clients to only see the server, you
# will also need to appropriately firewall the
# server's TUN/TAP interface.
;client-to-client

# Uncomment this directive if multiple clients
# might connect with the same certificate/key
# files or common names.  This is recommended
# only for testing purposes.  For production use,
# each client should have its own certificate/key
# pair.
#
# IF YOU HAVE NOT GENERATED INDIVIDUAL
# CERTIFICATE/KEY PAIRS FOR EACH CLIENT,
# EACH HAVING ITS OWN UNIQUE "COMMON NAME",
# UNCOMMENT THIS LINE OUT.
;duplicate-cn

# The keepalive directive causes ping-like
# messages to be sent back and forth over
# the link so that each side knows when
# the other side has gone down.
# Ping every 10 seconds, assume that remote
# peer is down if no ping received during
# a 120 second time period.
keepalive 10 120

# For extra security beyond that provided
# by SSL/TLS, create an "HMAC firewall"
# to help block DoS attacks and UDP port flooding.
#
# Generate with:
#   openvpn --genkey --secret ta.key
#
# The server and each client must have
# a copy of this key.
# The second parameter should be '0'
# on the server and '1' on the clients.
;tls-auth ta.key 0 # This file is secret

# Select a cryptographic cipher.
# This config item must be copied to
# the client config file as well.
# Note that v2.4 client/server will automatically
# negotiate AES-256-GCM in TLS mode.
# See also the ncp-cipher option in the manpage
cipher AES-256-CBC

# Enable compression on the VPN link and push the
# option to the client (v2.4+ only, for earlier
# versions see below)
;compress lz4-v2
;push "compress lz4-v2"

# For compression compatible with older clients use comp-lzo
# If you enable it here, you must also
# enable it in the client config file.
comp-lzo

# The maximum number of concurrently connected
# clients we want to allow.
;max-clients 100

# It's a good idea to reduce the OpenVPN
# daemon's privileges after initialization.
#
# You can uncomment this out on
# non-Windows systems.
;user nobody
;group nogroup

# The persist options will try to avoid
# accessing certain resources on restart
# that may no longer be accessible because
# of the privilege downgrade.
persist-key
persist-tun

# Output a short status file showing
# current connections, truncated
# and rewritten every minute.
status /var/log/openvpn/openvpn-status.log

# By default, log messages will go to the syslog (or
# on Windows, if running as a service, they will go to
# the "\Program Files\OpenVPN\log" directory).
# Use log or log-append to override this default.
# "log" will truncate the log file on OpenVPN startup,
# while "log-append" will append to it.  Use one
# or the other (but not both).
;log         /var/log/openvpn/openvpn.log
log-append  /var/log/openvpn/openvpn.log

# Set the appropriate level of log
# file verbosity.
#
# 0 is silent, except for fatal errors
# 4 is reasonable for general usage
# 5 and 6 can help to debug connection problems
# 9 is extremely verbose
verb 3

# Silence repeating messages.  At most 20
# sequential messages of the same message
# category will be output to the log.
;mute 20

# Notify the client that when the server restarts so it
# can automatically reconnect.
;explicit-exit-notify 1
```

3,  Startup openvpn server (notice: I shuold add the system startup, when the memory is full that I should reboot the machine.)

```
# by the same token, you can use supervisor to man
# use the method, it will run in the background
nohup openvpn --config /etc/openvpn/server.conf &
# check and you will found 0.0.0.0:1194
ss -tnal
```

4, Forward the flow (do this you can route all flow use the openvpn server)

```
# Notice: if you need route the flow you can do like this, or please ignore.
# modified the sysctl.conf and make net.ipv4.ip_forward=1
sudo vim /etc/sysctl.conf
# 这个地方需要注意一下，在阿里云上可能需要使用如下指令，因为公网地址没有对应的网卡，可按照下面括号填写。
（ptables -t nat -A POSTROUTING -s 10.8.16.0/24 -o eth0 -j MASQUERADE）
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o enp6s0 -j MASQUERADE
sudo iptables-save > /etc/iptables.up.rules

# 此时需要注意防火墙可能没有对你所添加的端口以及协议开放，会导致客户端连接不上服务端。
# 最简单的方法就是关闭防火墙，但是也会存在相应的风险。
# 关闭防火墙
sudo ufw disable 
# 开启防火墙
sudo ufw enable
# 防火墙状态
sudo ufw status
```

5, Copy the openvpn client files, edit the client.ovpn, and startup the openvpn client (that's you need  `name.crt name.key name.ovpn ca.crt`)

```
cd easy-rsa/pki
# copy these to your client computer
scp ca.crt nil@your_server_ip:/home/deep/openvpn/
scp private/ilanni.key nil@your_server_ip:/home/deep/openvpn/
scp issued/ilanni.crt nil@your_server_ip:/home/deep/openvpn/
```

​	edit the client.ovpn

```
client
dev tun
proto tcp 
remote 214a390i04.iok.la 11194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert ilanni.crt
key ilanni.key
comp-lzo
verb 3
```



If you want append the client users, you can follow like this.

```
# 1.generate name.crt name.key
./easyrsa build-client-full your_like_name nopass
# 2.cp ca.crt  this file is in the server diretory
# 3.cp name,ovpn  this file you can reference from above or copy from other users, if you copy from other, you should remenber modify the content which write other user's name that is crt and key.
```









