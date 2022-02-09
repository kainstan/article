# Windows 10 平台搭建 OpenVPN

 

 

发布于

 

2020-07-22 08:14:45

 

浏览: 2672

## OpenVPN 简介：

OpenVPN是一个用于创建虚拟私人网络加密通道的软件包，最早由James Yonan编写。OpenVPN允许创建的VPN使用公开密钥、电子证书、或者用户名/密码来进行身份验证。

它大量使用了OpenSSL加密库中的SSL/TLS协议函数库。

目前OpenVPN能在Solaris、Linux、OpenBSD、FreeBSD、NetBSD、Mac OS X与Microsoft Windows以及Android和iOS上运行，并包含了许多安全性的功能。它不与IPsec兼容。

## 下载：

> Eastar’s Tips:
> 无论是服务器端还是客户端，使用的是同一个安装程序，仅仅通过配置文件来区别;

官网安装包下载地址（各系统版本）： https://openvpn.net/download-open-vpn/
第三方安装包下载地址（各系统版本）：https://www.techspot.com/downloads/5182-openvpn.html

清华大学镜像地址（Linux版本） https://mirrors-i.tuna.tsinghua.edu.cn/linuxbrew-bottles/bottles/openvpn-2.4.9.x86_64_linux.bottle.tar.gz

源码地址： https://github.com/OpenVPN/openvpn

## 服务端安装部署：

打开安装包进行安装，客户端跟服务器安装方式一样，都需要安装：

![null](https://www.softool.cn/uploads/blog/202007/attach_162407fef34b8910.png)



接受(I Agree)下一步：

![null](https://www.softool.cn/uploads/blog/202007/attach_1624080207ea6820.png)



下面选项默认不勾选，我们需要勾选证书生成程序 ，不然安装完无法命令行制作证书操作：

![null](https://www.softool.cn/uploads/blog/202007/attach_1624082d0741e0a8.png)



选择安装目录：

> Eastar’s Tips:
> 如果默认安装C盘，后续操作会简单一些;
> 如果选择安装D盘，需要记下此路径，后面需要调整HOME值;



![null](https://www.softool.cn/uploads/blog/202007/attach_16240832171c358c.png)



安装完成：

![null](https://www.softool.cn/uploads/blog/202007/attach_162408381888fc10.png)



![null](https://www.softool.cn/uploads/blog/202007/attach_1624083a59f4f940.png)



安装完成后系统会多出一张网卡 TAP的 本地连接：

![null](https://www.softool.cn/uploads/blog/202007/attach_1624085fc9079ef8.png)



要想 客户端 能够通过 服务端 上网需要调整 服务端的物理网卡 共享：

> Eastar’s Tips:
> 在物理网卡上右键选择属性，共享选项卡中勾选“允许其他网络用户通过此计算机的 Internet 连接来连接”;
> 家庭网络连接的下拉列表中选择上面TAP对应的连接名称;



![null](https://www.softool.cn/uploads/blog/202007/attach_162408ca4bbb1680.png)



## 生成配置:

OpenVPN支持基于加密证书的双向认证。
在OpenVPN中，`不管是服务器还是客户端，所有的证书和私钥都需要由服务器端生成`，客户端要先获得服务器端分配给它的加密证书和密钥才能成功连接。
**客户端只需要安装好软件，然后复制服务端生成的配置到客户端即可**。

所以直接打开 cmd ，进入 OpenVPN 的安装目录:

```bash
D:\software\development\OpenVPN\easy-rsa
```



![null](https://www.softool.cn/uploads/blog/202007/attach_16243b0daeb00604.png)



#### 然后在服务器端运行以下命令：

1. 运行 DOS 命令，初始化执行环境。

> 下面的第1条批处理执行前，建议考虑以下因素：
> 由于 init-config 会把 vars.bat.sample 复制为 var.bat，所以可以根据自己需要先修改 vars.bat.sample 模板文件中的一些变量；

vars.bat.sample 部分默认值为：

```
set HOME=%ProgramFiles%OpenVPNeasy-rsa
set KEY_COUNTRY=US
set KEY_PROVINCE=CA
set KEY_CITY=SanFrancisco
set KEY_ORG=FortFunston
set KEY_EMAIL=mail@domain.com
```

修改为：

```
set HOME=D:Program FilesOPENVPNeasy-rsa #(此路径就是上面安装时，自己选择的安装路径)
set KEY_COUNTRY=CN                         #(国家)
set KEY_PROVINCE=ShangHai                 #(省份)
set KEY_CITY=ShangHai                      #(城市)
set KEY_ORG=softool.cn                     #(组织)
set KEY_EMAIL=kefu@softool.cn              #(邮件地址)
上面#开始的是注释，请不要写到 vars.bat.sample 文件中。
```

执行命令：

```
init-config     #init-config 默认会执行当前目录下的 init-config.bat，以下同理。 功能：把 vars.bat.sample 复制为 var.bat
vars            #vars.bat 用来设置一些变量，主要就是配置文件中修改的那部分
clean-all         #如果之前有keys目录,会先删除D:Program FileOpenVPNeasy-rsakeys目录，再把 index.txt 和 serial 文件放进来
```



![null](https://www.softool.cn/uploads/blog/202007/attach_1626b0f80a622b00.png)



1. 创建CA根证书：

> 注：
> build-ca # 生成根证书;
> build-dh.bat # 生成 dh2048.pem 文件，Server 使用 TLS(OpenSSL) 必须要有的文件;

```
D:Program FilesOpenVPNeasy-rsa>build-ca
#此处的错误待研究:
Can't load D:Program FilesOPENVPNeasy-rsa/.rnd into RNG
5712:error:2406F079:random number generator:RAND_load_file:Cannot open file:crypto/rand/randfile.c:98:Filename=D:Program FilesOPENVPNeasy-rsa/.rnd
Generating a RSA private key
.............................................++++
............................++++
writing new private key to 'keysca.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
#下面我直接回车默认，因为我在 init-config 之前，已经修改了 vars.bat.sample 文件。
Country Name (2 letter code) [CN]:
State or Province Name (full name) [ShangHai]:
Locality Name (eg, city) [ShangHai]:
Organization Name (eg, company) [softool.cn]:
Organizational Unit Name (eg, section) [changeme]:
Common Name (eg, your name or your server's hostname) [changeme]:CA
Name [changeme]:
Email Address [kefu@softool.cn]:


D:Program FilesOpenVPNeasy-rsa>build-dh
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time
...............................................................................................+...............................................+..............................................++*++*++*++*

D:Program FilesOpenVPNeasy-rsa>openvpn --genkey --secret ./keys/ta.key
```

> 注：
> build-ca 的时候需要输入一些注册信息。在输入信息的时候，如果你不输入任何信息，就表示采用默认值(前面[]中的内容就是默认值)

1. 创建 服务器端 证书：

   ```
   build-key-server server  #生成服务端密钥和证书
   ```

   

   ![null](https://www.softool.cn/uploads/blog/202007/attach_1624410f8cb9f9a8.png)

   

   > 注：
   > builid-key-server 后面指定的参数名 server 指的是生成的证书和密钥文件的名称（E.g server.key、server.csr 和 server.crt，这些文件保存在 keys 目录中），你可以按照自己的需要进行修改，不过后面的 Common Name 也应保持一致；
   > 如果需要生成多个服务端的密钥和证书则继续 build-key-server server02 … … ；

2. 创建 客户端 证书：

   ```
   build-key client
   ```

   

   ![null](https://www.softool.cn/uploads/blog/202007/attach_1624419284d489dc.png)

   

   > 注：
   > 和build-key-server一样要输入一堆东西，注意的是 Common Name 不能与执行 build-key-server 时输入的一样；
   > 如果需要生成其他的客户端密钥和证书，可以继续 build-key client02 … … ;

## 服务端的配置

1. 首先，在 OpenVPN 安装目录(D:Program FilesOpenVPNconfig)下创建 server.ovpn ;
   server.ovpn 模板文件如下，可根据需要调整：
```
# server.ovpn demo
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
;local 192.168.0.100

# Which TCP/UDP port should OpenVPN listen on?
# If you want to run multiple OpenVPN instances
# on the same machine, use a different port
# number for each one.  You will need to
# open up this port on your firewall.
;port 1194
port 10101

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
# 此处有个巨大的坑，要使用和客户端一致的tun

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
cert server.crt
key server.key  # This file should be kept secret

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
;server 192.168.188.0 255.255.255.0

# Maintain a record of client <-> virtual IP address
# associations in this file.  If OpenVPN goes down or
# is restarted, reconnecting clients can be assigned
# the same virtual IP address from the pool that was
# previously assigned.
ifconfig-pool-persist ipp.txt

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
;push "route 10.8.0.0 255.255.255.0"
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
;push "redirect-gateway def1 bypass-dhcp"
;push "redirect-gateway def1 bypass-dhcp"
# 如果需要路由所有地区的流量，需要打开这个选项，打开转发。同时需要改注册表和开启服务，路由服务
push "redirect-gateway def1"

# Certain Windows-specific network settings
# can be pushed to clients, such as DNS
# or WINS server addresses.  CAVEAT:
# http://openvpn.net/faq.html#dhcpcaveats
# The addresses below refer to the public
# DNS servers provided by opendns.com.
;push "dhcp-option DNS 208.67.222.222"
;push "dhcp-option DNS 208.67.220.220"
;push "dhcp-option DNS 114.114.114.114"
;push "dhcp-option DNS 223.5.5.5"

# Uncomment this directive to allow different
# clients to be able to "see" each other.
# By default, clients will only see the server.
# To force clients to only see the server, you
# will also need to appropriately firewall the
# server's TUN/TAP interface.
client-to-client

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
tls-auth ta.key 0 # This file is secret

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
;group nobody

# The persist options will try to avoid
# accessing certain resources on restart
# that may no longer be accessible because
# of the privilege downgrade.
persist-key
persist-tun

# Output a short status file showing
# current connections, truncated
# and rewritten every minute.
status openvpn-status.log

# By default, log messages will go to the syslog (or
# on Windows, if running as a service, they will go to
# the "\Program Files\OpenVPN\log" directory).
# Use log or log-append to override this default.
# "log" will truncate the log file on OpenVPN startup,
# while "log-append" will append to it.  Use one
# or the other (but not both).
;log         openvpn.log
;log-append  openvpn.log

# Set the appropriate level of log
# file verbosity.
#
# 0 is silent, except for fatal errors
# 4 is reasonable for general usage
# 5 and 6 can help to debug connection problems
# 9 is extremely verbose
verb 4

# Silence repeating messages.  At most 20
# sequential messages of the same message
# category will be output to the log.
;mute 20

# Notify the client that when the server restarts so it
# can automatically reconnect.
;explicit-exit-notify 1
explicit-exit-notify 0
```
```
# local 用于监听本机（作为服务器端）已安装网卡对应的IP地址，该命令是可选的，如果不设置，则默认监听本机的所有IP地址；
local 192.168.3.1

# 如果你想在同一台计算机上运行多个 OpenVPN 实例，你可以使用不同的端口号来区分它们，同时需要在防火墙上开放这些端口；
# 如果是用 http 代理连接，建议使用默认值 1194 ，如果使用 https 代理，建议使用大家常用值 443
port 1194

# 通过 TCP 协议连接
proto tcp
# 如果想使用 UDP 协议：
# proto udp

# win 下必须设为 tap ，将会创建一个以太网隧道；
# tap 处理二层，tun 处理三层，虽然 tun 两端ip是同一个子网，但是其二层却不是，广播是无法进行的，但是 tap 可以传输广播；
# 由于windows的虚拟网卡驱动的特殊性，为了让windows也能进入vpn，OpenVPN和虚拟网卡驱动作了特殊且复杂的处理。
# 怎么理解 tun 设备建立的是“点对点”链路，因为tun隧道是三层隧道，没有二层链路，更不必说二层广播链路了，我们知道数据链路层有两种通信方式，一种是点对点的方式，比如ppp协议，另一种是广播的方式，比如以太网，tun设备建立的隧道只有两个端点，隧道中封装的是IP数据报，虽然也需要arp协议来定位隧道对端tun设备的mac，然而如果有n台机器同时连接进一个虚拟网络并且属于同一个网段的话，其它机器是不会收到这个arp报文的，因为根本就没有二层链路帮忙广播转发这个arp报文
dev tap

# 设置 服务器端 模式，并提供一个 VPN 子网，以便于从中为 客户端 分配IP地址，假设 服务器端 自己占用了 192.168.0.1，所以其他的将提供 客户端 使用；
# 如果你使用的是 以太网桥接 模式，请注释掉该行;
# ★★★ 当客户端连接到此处的服务端时，为 客户端的以太网适配器分配的IPv4地址从此处指定的网段中指定一个;
server 192.168.0.0 255.255.255.0

# 设置 SSL/TLS 根证书(CA)、证书(cert)和私钥(key)。
# 每个 客户端 和 服务器端 都需要它们各自的证书和私钥文件。
# 服务器端和所有的客户端都将使用相同的CA证书文件。
#
# 通过 easy-rsa 目录下的一系列脚本可以生成所需的证书和私钥。
# 记住，服务器端和每个客户端的证书必须使用唯一的 Common Name。
#
# 你也可以使用遵循X509标准的任何密钥管理系统来生成证书和私钥。
# OpenVPN 也支持使用一个PKCS #12格式的密钥文件(详情查看站点手册页面的”pkcs12″指令)
ca ca.crt
cert server.crt
# 该文件应该保密
key server.key
# 指定 迪菲·赫尔曼参数，你可以使用如下名称命令生成你的参数：
# openssl dhparam -out dh2048.pem 2048
# 如果你使用的是1024位密钥，使用1024替换其中的2048。
dh dh2048.pem

# 指定用于记录客户端和虚拟IP地址的关联关系的文件。
# 当重启OpenVPN时，再次连接的客户端将分配到与上一次分配相同的虚拟IP地址
ifconfig-pool-persist ipp.txt

# 该指令仅针对以太网桥接模式。
# 首先，你必须使用操作系统的桥接能力将以太网网卡接口和TAP接口进行桥接。
# 然后，你需要手动设置桥接接口的IP地址、子网掩码；
# 在这里，我们假设为10.8.0.4和255.255.255.0。
# 最后，我们必须指定子网的一个IP范围(例如从10.8.0.50开始，到10.8.0.100结束)，以便于分配给连接的客户端。
# 如果你不是以太网桥接模式，直接注释掉这行指令即可。
;server-bridge 10.8.0.4 255.255.255.0 10.8.0.50 10.8.0.100

# 该指令仅针对使用DHCP代理的以太网桥接模式，
# 此时客户端将请求服务器端的DHCP服务器，从而获得分配给它的IP地址和DNS服务器地址。
#
# 在此之前，你也需要先将以太网网卡接口和TAP接口进行桥接。
# 注意：该指令仅用于OpenVPN客户端，并且该客户端的TAP适配器需要绑定到一个DHCP客户端上。
;server-bridge

# 推送 路由信息 到 客户端 ，以允许 客户端 能够连接到 服务器 背后的其他私有子网(简而言之，就是允许 客户端 访问 VPN服务器 自身所在的其他局域网)；
# 记住，这些私有子网也要将 OpenVPN客户端 的地址池(10.8.0.0/255.255.255.0)反馈回 OpenVPN服务器。
# ★★★ 为客户端 指定路由表：
;push "route 172.31.3.0 255.255.255.0"
;push "route 172.31.5.0 255.255.255.0"

# 如果启用该指令，所有 客户端的默认网关 都将重定向到VPN，这将导致诸如web浏览器、DNS查询等所有客户端流量都经过VPN。
# (为确保能正常工作，OpenVPN服务器所在计算机可能需要在 TUN/TAP 接口与以太网之间使用NAT或桥接技术进行连接)
;push "redirect-gateway def1 bypass-dhcp"

# 某些具体的 Windows网络设置 可以被推送到客户端，例如DNS或WINS服务器地址。
# 下列地址来自 opendns.com 提供的 Public DNS 服务器。
## 下面2句：客户端连接到此处的服务端时，会给 客户端的以太网适配器 的DNS服务器设置为此处指定的IP
push "dhcp-option DNS 114.114.114.114"
push "dhcp-option DNS 223.5.5.5"

# keepalive指令将导致类似于ping命令的消息被来回发送，以便于服务器端和客户端知道对方何时被关闭。
# 每10秒钟ping一次，如果120秒内都没有收到对方的回复，则表示远程连接已经关闭。
keepalive 10 120

tls-auth ta.key 0

# 选择一个密码加密算法。
# 该配置项也必须复制到每个客户端配置文件中。
;cipher BF-CBC # Blowfish (默认)
;cipher AES-128-CBC # AES
;cipher DES-EDE3-CBC # Triple-DES
cipher AES-256-CBC

# 在VPN连接上启用压缩。
# 如果你在此处启用了该指令，那么也应该在每个客户端配置文件中启用它。
comp-lzo

# 去掉该指令的注释将允许不同的客户端之间相互”可见”(允许客户端之间互相访问)。
# 默认情况下，客户端只能”看见”服务器。为了确保客户端只能看见服务器，你还可以在服务器端的TUN/TAP接口上设置适当的防火墙规则。
client-to-client

# 持久化选项可以尽量避免访问那些在重启之后由于用户权限降低而无法访问的某些资源。
persist-key
persist-tun

# 输出一个简短的状态文件，用于显示当前的连接状态，该文件每分钟都会清空并重写一次。
status openvpn-status.log

# 为日志文件设置适当的冗余级别(0~9)。冗余级别越高，输出的信息越详细。
#
# 0 表示静默运行，只记录致命错误。
# 4 表示合理的常规用法。
# 5 和 6 可以帮助调试连接错误。
# 9 表示极度冗余，输出非常详细的日志信息。
# 这个地方如果写的值过高，会造成连接不上，一直报日志信息（选9就不会成功，选4差不多）
verb 3


explicit-exit-notify 1
```

> push route表示推送的具体路由，就是这些路由是走VPN，其他流量还是走默认网关，然后就可以启动服务了。
> 把 D:Program FilesOpenVPNeasy-rsakeys 目录下的ca.crt、ca.key、server01.crt、server01.csr、server01.key、dh2048.pem、ta.key 复制到 D:Program FilesOpenVPNconfig 目录下。
> 据说某些运营商封锁了UDP的数据链路，所以建议 openVPN 采用TCP协议连接；

## 客户端的配置

把配置文件 client.ovpn 放到客户端机器的 D:Program FilesOpenVPNconfig 目录下，并且把服务器 D:Program FilesOpenVPNeasy-rsakeys 目录下的

client01.crt、client01.csr、client01.key、ca.key、ca.crt、ta.key 文件一起复制到客户端D:Program FilesOpenVPNconfig目录下 （以上文件为服务端生成，客户端需要在服务端拷贝这7个文件过来）。

client.ovpn的配置如下：

```
client.ovpn demo
##############################################
# Sample client-side OpenVPN 2.0 config file #
# for connecting to multi-client server.     #
#                                            #
# This configuration can be used by multiple #
# clients, however each client should have   #
# its own cert and key files.                #
#                                            #
# On Windows, you might want to rename this  #
# file so it has a .ovpn extension           #
##############################################

# Specify that we are a client and that we
# will be pulling certain config file directives
# from the server.
client

# Use the same setting as you are using on
# the server.
# On most systems, the VPN will not function
# unless you partially or fully disable
# the firewall for the TUN/TAP interface.
;dev tap
dev tun

# Windows needs the TAP-Win32 adapter name
# from the Network Connections panel
# if you have more than one.  On XP SP2,
# you may need to disable the firewall
# for the TAP adapter.
;dev-node MyTap

# Are we connecting to a TCP or
# UDP server?  Use the same setting as
# on the server.
proto tcp
;proto udp

# The hostname/IP and port of the server.
# You can have multiple remote entries
# to load balance between the servers.
remote 214a390i04.iok.la 10101
;remote my-server-2 1194

# Choose a random host from the remote
# list for load-balancing.  Otherwise
# try hosts in the order specified.
;remote-random

# Keep trying indefinitely to resolve the
# host name of the OpenVPN server.  Very useful
# on machines which are not permanently connected
# to the internet such as laptops.
resolv-retry infinite

# Most clients don't need to bind to
# a specific local port number.
nobind

# Downgrade privileges after initialization (non-Windows only)
user nobody
group nobody

# Try to preserve some state across restarts.
persist-key
persist-tun

# If you are connecting through an
# HTTP proxy to reach the actual OpenVPN
# server, put the proxy server/IP and
# port number here.  See the man page
# if your proxy server requires
# authentication.
;http-proxy-retry # retry on connection failures
;http-proxy [proxy server] [proxy port #]

# Wireless networks often produce a lot
# of duplicate packets.  Set this flag
# to silence duplicate packet warnings.
;mute-replay-warnings

# SSL/TLS parms.
# See the server config file for more
# description.  It's best to use
# a separate .crt/.key file pair
# for each client.  A single ca
# file can be used for all clients.
ca ca.crt
cert client.crt
key client.key

# Verify server certificate by checking that the
# certicate has the correct key usage set.
# This is an important precaution to protect against
# a potential attack discussed here:
#  http://openvpn.net/howto.html#mitm
#
# To use this feature, you will need to generate
# your server certificates with the keyUsage set to
#   digitalSignature, keyEncipherment
# and the extendedKeyUsage to
#   serverAuth
# EasyRSA can do this for you.
remote-cert-tls server

ns-cert-type server
# If a tls-auth key is used on the server
# then every client must also have the key.
tls-auth ta.key 1

# Select a cryptographic cipher.
# If the cipher option is used on the server
# then you must also specify it here.
# Note that v2.4 client/server will automatically
# negotiate AES-256-GCM in TLS mode.
# See also the ncp-cipher option in the manpage
cipher AES-256-CBC

# Enable compression on the VPN link.
# Don't enable this unless it is also
# enabled in the server config file.
comp-lzo

# Set log file verbosity.
verb 4

# Silence repeating messages
;mute 20
route 10.8.0.0 255.255.255.0
```

```
client
dev tun
proto tcp

remote 服务端IP 1194
;remote my-server-2 1194

;remote-random

resolv-retry infinite
nobind
user nobody
group nobody
;route 192.168.0.0 255.255.252.0
persist-key
persist-tun

;http-proxy-retry # retry on connection failures
;http-proxy [proxy server] [proxy port #]

ca ca.crt
cert client.crt
key client.key

ns-cert-type server
tls-auth ta.key 1
comp-lzo
# Set log file verbosity.
verb 4
```

###	注意

可能出现客户端无法ping通服务端，这可能是服务端有防火墙做了拦截等问题，处理方法如下：

- 使用高级安全性打开Windows防火墙
- 单击左侧的入站规则
- 单击右侧的“新建规则”
- 单击自定义规则
- 指定程序或保留所有程序
- 指定端口或保留为所有端口
- 单击远程IP下的“这些IP地址”
- 单击“此IP地址范围”
- 输入“192.168.211.0”至“192.168.255.255”
- 关闭并单击“下一步”，然后单击“允许连接”
- 命名并完成



来源：

- https://www.wumingx.com/others/openvpn-win.html
- [https://mengniuge.com](https://mengniuge.com/)
- [https://juejin.im](https://juejin.im/)