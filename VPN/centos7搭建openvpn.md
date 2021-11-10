# 如何在 CentOS 7 上设置和配置 OpenVPN 服务器



### 介绍

一个[虚拟专用网](https://en.wikipedia.org/wiki/Virtual_private_network)（VPN）可以让你，如果你是在专用网络上穿越不受信任的网络。当您连接到不受信任的网络（例如酒店或咖啡店的 WiFi）时，它可以让您自由地通过智能手机或笔记本电脑安全可靠地访问互联网。

与[HTTPS 连接](https://en.wikipedia.org/wiki/HTTP_Secure)结合使用时，此设置可让您确保无线登录和交易的安全。您可以绕过地域限制和审查，并从不受信任的网络中屏蔽您的位置和任何未加密的 HTTP 流量。

[OpenVPN](https://openvpn.net/)是一个功能齐全的开源安全套接层 (SSL) VPN 解决方案，适用于各种配置。在本教程中，您将在 CentOS 7 服务器上设置 OpenVPN，然后将其配置为可从客户端计算机访问。

**注意：**如果您打算在 DigitalOcean Droplet 上设置 OpenVPN 服务器，请注意，与许多托管服务提供商一样，我们会对超额带宽收费。因此，请注意您的服务器处理的流量。有关更多信息，请参阅[此页面](https://www.digitalocean.com/docs/accounts/billing/bandwidth/)。

## 先决条件

要学习本教程，您需要：

- 一台带有 sudo 非 root 用户的 CentOS 7 服务器和使用 firewalld 设置的防火墙，您可以通过我们的[CentOS 7 初始服务器设置](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-centos-7)指南和[新 CentOS 7 服务器](https://www.digitalocean.com/community/tutorials/additional-recommended-steps-for-new-centos-7-servers)的[附加推荐步骤来实现](https://www.digitalocean.com/community/tutorials/additional-recommended-steps-for-new-centos-7-servers)。
- 解析为可用于证书的服务器的域或子域。要进行设置，您首先需要[注册一个域名](https://www.digitalocean.com/community/tutorials/how-to-point-to-digitalocean-nameservers-from-common-domain-registrars)，然后[通过 DigitalOcean 控制面板添加 DNS 记录](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-host-name-with-digitalocean)。请注意，只需添加一条 A 记录即可满足本教程的要求。
- 您将用于连接到 OpenVPN 服务器的客户端计算机。出于本教程的目的，建议您使用本地计算机作为 OpenVPN 客户端。

有了这些先决条件，您就可以开始在 CentOS 7 上设置和配置 OpenVPN 服务器了。

## 步骤 1 — 安装 OpenVPN

首先，我们将在服务器上安装 OpenVPN。我们还将安装 Easy RSA，这是一个公共密钥基础设施管理工具，它将帮助我们建立一个内部证书颁发机构 (CA) 以与我们的 VPN 一起使用。稍后我们还将使用 Easy RSA 生成我们的 SSL 密钥对，以保护 VPN 连接。

以非 root sudo 用户身份登录服务器，并更新软件包列表以确保您拥有所有最新版本。

```bash
sudo yum update -y
```

Extra Packages for Enterprise Linux (EPEL) 存储库是由 Fedora 项目管理的附加存储库，其中包含非标准但流行的软件包。OpenVPN 在默认 CentOS 存储库中不可用，但在 EPEL 中可用，因此请安装 EPEL：

```bash
sudo yum install epel-release -y
```

然后再次更新您的软件包列表：

```bash
sudo yum update -y
```

接下来，安装 OpenVPN 和`wget`，我们将使用它来安装 Easy RSA：

```bash
sudo yum install -y openvpn wget
```

使用`wget`，下载 Easy RSA。出于本教程的目的，我们建议使用 easy-rsa-2，因为此版本有更多可用文档。您可以在项目的[发布页面](https://github.com/OpenVPN/easy-rsa-old/releases)上找到最新版本的 easy-rsa-2 的下载链接：

```bash
wget -O /tmp/easyrsa https://github.com/OpenVPN/easy-rsa-old/archive/2.3.3.tar.gz
```

接下来，使用以下命令提取压缩文件`tar`：

```bash
tar xfz /tmp/easyrsa
```

这将在您的服务器上创建一个名为. 在下面创建一个新的子目录并将其命名为：`easy-rsa-old-2.3.3``/etc/openvpn``easy-rsa`

```bash
sudo mkdir /etc/openvpn/easy-rsa
```

将提取的 Easy RSA 文件复制到新目录：

```bash
sudo cp -rf easy-rsa-old-2.3.3/easy-rsa/2.0/* /etc/openvpn/easy-rsa
```

然后将目录的所有者更改为您的非 root sudo 用户：

```bash
sudo chown sammy /etc/openvpn/easy-rsa/
```

一旦安装了这些程序并将其移动到系统上的正确位置，下一步就是自定义 OpenVPN 的服务器端配置。

## 第 2 步 - 配置 OpenVPN

与许多其他广泛使用的开源工具一样，您可以使用数十种配置选项。在本节中，我们将提供有关如何设置基本 OpenVPN 服务器配置的说明。

OpenVPN 在其文档目录中有几个示例配置文件。首先，复制示例`server.conf`文件作为您自己的配置文件的起点。

```bash
sudo cp /usr/share/doc/openvpn-2.4.4/sample/sample-config-files/server.conf /etc/openvpn
```

使用您选择的文本编辑器打开新文件进行编辑。我们将在我们的示例中使用 nano，`yum install nano`如果您的服务器上还没有它，您可以使用命令下载它：

```bash
sudo nano /etc/openvpn/server.conf
```

在这个文件中有几行我们需要更改，其中大部分只需要通过删除`;`该行开头的分号 , 来取消注释。这些行的功能，以及本教程中没有提到的其他行，在每行上面的评论中都有深入的解释。

首先，找到并取消注释包含`push "redirect-gateway def1 bypass-dhcp"`. 这样做将告诉您的客户端通过您的 OpenVPN 服务器重定向其所有流量。请注意，启用此功能可能会导致与其他网络服务（如 SSH）的连接问题：

/etc/openvpn/server.conf

```bash
push "redirect-gateway def1 bypass-dhcp"
```

因为您的客户端将无法使用您的 ISP 提供的默认 DNS 服务器（因为其流量将被重新路由），所以您需要告诉它可以使用哪些 DNS 服务器连接到 OpenVPN。您可以选择不同的 DNS 服务器，但这里我们将使用 Google 的公共 DNS 服务器，它们的 IP 为`8.8.8.8`和`8.8.4.4`。

通过取消注释这两`push "dhcp-option DNS ..."`行并更新 IP 地址来设置：

/etc/openvpn/server.conf

```bash
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 114.114.114.114"
```

我们希望 OpenVPN 在启动后无特权运行，因此我们需要告诉它以用户和**nobody**组运行。要启用此功能，请取消注释`user nobody`和`group nobody`行：

/etc/openvpn/server.conf

```bash
user nobody
group nobody
```

接下来，取消注释该`topology subnet`行。这与`server 10.8.0.0 255.255.255.0`它下面的行一起，将您的 OpenVPN 安装配置为用作子网，并告诉客户端机器它应该使用哪个 IP 地址。在这种情况下，服务器将成为`10.8.0.1`，第一个客户端将成为`10.8.0.2`：

/etc/openvpn/server.conf

```bash
topology subnet
```

还建议您将以下行添加到服务器配置文件中。这会双重检查所有传入的客户端证书是否确实来自客户端，从而强化我们将在后面的步骤中建立的安全参数：

##### 不建议加这个，否则可能造成通信证书验证错误

/etc/openvpn/server.conf

```bash
remote-cert-eku "TLS Web Client Authentication"
```

最后，OpenVPN 强烈建议用户启用 TLS 身份验证，这是一种加密协议，可确保通过计算机网络进行安全通信。为此，您需要生成一个静态加密密钥（在我们的示例中命名为`myvpn.tlsauth`，但您可以选择任何您喜欢的名称）。在创建此密钥之前，请在包含`tls-auth ta.key 0`分号的配置文件中注释该行。然后，添加到它下面的行：`tls-crypt myvpn.tlsauth`

/etc/openvpn/server.conf

```bash
;tls-auth ta.key 0
tls-crypt myvpn.tlsauth
```

保存并退出 OpenVPN 服务器配置文件（在 nano 中，按`CTRL - X`, `Y`，然后`ENTER`执行此操作），然后使用以下命令生成静态加密密钥：

```bash
sudo openvpn --genkey --secret /etc/openvpn/myvpn.tlsauth
```

现在您的服务器已配置，您可以继续设置安全连接到 VPN 连接所需的 SSL 密钥和证书。

## 步骤 3 — 生成密钥和证书

Easy RSA 使用随程序安装的一组脚本来生成密钥和证书。为了避免每次需要生成证书时都重新配置，您可以修改 Easy RSA 的配置来定义它将用于证书字段的默认值，包括您的国家、城市和首选电子邮件地址。

我们将通过创建一个目录来开始生成密钥和证书的过程，Easy RSA 将在其中存储您生成的任何密钥和证书：

```bash
sudo mkdir /etc/openvpn/easy-rsa/keys
```

默认证书变量在 中的`vars`文件中设置`/etc/openvpn/easy-rsa`，因此打开该文件进行编辑：

```bash
sudo nano /etc/openvpn/easy-rsa/vars
```

滚动到文件底部并更改开头的值`export KEY_`以匹配您的信息。最重要的是：

- `KEY_CN`：在这里，输入解析到您的服务器的域或子域。
- `KEY_NAME`: 你应该`server`在这里输入。如果您输入其他内容，您还必须更新引用`server.key`和的配置文件`server.crt`。

您可能想要更改的此文件中的其他变量是：

- `KEY_COUNTRY`：对于此变量，请输入您居住国家/地区的两个字母缩写。
- `KEY_PROVINCE`：这应该是您居住州的名称或缩写。
- `KEY_CITY`：在这里，输入您居住的城市的名称。
- `KEY_ORG`：这应该是您的组织或公司的名称。
- `KEY_EMAIL`：输入要连接到安全证书的电子邮件地址。
- `KEY_OU`：这应该是您所属的“组织单位”的名称，通常是您的部门或团队的名称。

在特定用例之外，可以安全地忽略其余变量。进行更改后，文件应如下所示：

/etc/openvpn/easy-rsa/vars

```bash
. . .

# These are the default values for fields
# which will be placed in the certificate.
# Don't leave any of these fields blank.
export KEY_COUNTRY="US"
export KEY_PROVINCE="NY"
export KEY_CITY="New York"
export KEY_ORG="DigitalOcean"
export KEY_EMAIL="sammy@example.com"
export KEY_EMAIL=sammy@example.com
export KEY_CN=openvpn.example.com
export KEY_NAME="server"
export KEY_OU="Community"
. . .
```

保存并关闭文件。

要开始生成密钥和证书，请进入`easy-rsa`目录和`source`您在`vars`文件中设置的新变量：

```bash
cd /etc/openvpn/easy-rsa
source ./vars
```

运行 Easy RSA 的`clean-all`脚本以删除文件夹中已有的所有密钥和证书并生成证书颁发机构：

```bash
./clean-all
```

接下来，使用`build-ca`脚本构建证书颁发机构。系统会提示您输入证书字段的值，但如果您`vars`之前在文件中设置了变量，则所有选项都将设置为默认值。您可以按`ENTER`接受每一项的默认值：

```bash
./build-ca
```

此脚本生成一个名为`ca.key`. 这是用于签署服务器和客户端证书的私钥。如果丢失，您将无法再信任来自该证书颁发机构的任何证书，并且如果任何人能够访问此文件，他们就可以在您不知情的情况下签署新证书并访问您的 VPN。为此，OpenVPN 建议`ca.key`尽可能将其存储在可以离线的位置，并且仅在创建新证书时才应激活。

接下来，使用`build-key-server`脚本为服务器创建密钥和证书：

```bash
./build-key-server server
```

与构建 CA 一样，您将看到已设置为默认值的值，以便您可以按`ENTER`这些提示进行操作。此外，系统会提示您输入质询密码和可选的公司名称。如果您输入质询密码，当从您的客户端连接到 VPN 时，系统会要求您输入密码。如果您不想设置挑战密码，只需将此行留空并按`ENTER`。最后，输入`Y`以提交更改。

创建服务器密钥和证书的最后一部分是生成 Diffie-Hellman 密钥交换文件。使用`build-dh`脚本执行此操作：

```bash
./build-dh
```

这可能需要几分钟才能完成。

服务器生成密钥交换文件后，将服务器密钥和证书从`keys`目录复制到`openvpn`目录中：

```bash
cd /etc/openvpn/easy-rsa/keys
sudo cp dh2048.pem ca.crt server.crt server.key /etc/openvpn
```

每个客户端还需要一个证书，以便 OpenVPN 服务器对其进行身份验证。这些密钥和证书将在服务器上创建，然后您必须将它们复制到您的客户端，我们将在稍后的步骤中进行。建议您为要连接到 VPN 的每个客户端生成单独的密钥和证书。

因为我们在这里只设置一个客户端，所以我们将其命名为`client`，但如果您愿意，可以将其更改为更具描述性的名称：

```bash
cd /etc/openvpn/easy-rsa
./build-key client
```

最后，将版本化的 OpenSSL 配置文件 , 复制到无版本`openssl-1.0.0.cnf`名称`openssl.cnf`. 如果不这样做可能会导致错误，其中 OpenSSL 无法加载配置，因为它无法检测其版本：

```bash
cp /etc/openvpn/easy-rsa/openssl-1.0.0.cnf /etc/openvpn/easy-rsa/openssl.cnf
```

现在已经为您的服务器和客户端生成了所有必要的密钥和证书，您可以继续设置两台机器之间的路由。

## 第 4 步 - 路由

到目前为止，您已经在服务器上安装了 OpenVPN，对其进行了配置，并生成了客户端访问 VPN 所需的密钥和证书。但是，您尚未向 OpenVPN 提供有关从客户端发送传入 Web 流量的位置的任何说明。您可以通过建立一些防火墙规则和路由配置来规定服务器应如何处理客户端流量。

假设您遵循了本教程开始时的先决条件，您应该已经在服务器上安装并运行了 firewalld。要允许 OpenVPN 通过防火墙，您需要知道您的活动 firewalld 区域是什么。使用以下命令找到它：

```bash
sudo firewall-cmd --get-active-zones
```

```
Output
trusted
  Interfaces: tun0
```

接下来，将该`openvpn`服务添加到您的活动区域内 firewalld 允许的服务列表中，然后通过再次运行该命令来使该设置永久化，但`--permanent`添加了选项：

```bash
sudo firewall-cmd --zone=trusted --add-service openvpn
sudo firewall-cmd --zone=trusted --add-service openvpn --permanent
```

您可以使用以下命令检查服务是否已正确添加：

```bash
sudo firewall-cmd --list-services --zone=trusted
```

```
Output
openvpn
```

这里还需要在防火墙加上openvpn服务，否则客户端连不上服务端

```bash
firewall-cmd --add-service openvpn
firewall-cmd --permanent --add-service openvpn
firewall-cmd --list-services
```

接下来，向当前运行时实例添加一个伪装，然后再次添加它，并`--permanent`选择将伪装添加到所有未来实例：

```bash
sudo firewall-cmd --add-masquerade
sudo firewall-cmd --permanent --add-masquerade
```

您可以使用以下命令检查伪装是否正确添加：

```bash
sudo firewall-cmd --query-masquerade
```

```
Output
yes
```

接下来，将路由转发到您的 OpenVPN 子网。您可以通过首先创建一个变量（`SHARK`在我们的示例中）来表示您的服务器使用的主要网络接口，然后使用该变量永久添加路由规则：

```bash
# 这个好像没啥用，下次不用试一试
SHARK=$(ip route get 8.8.8.8 | awk 'NR==1 {print $(NF-2)}')
sudo firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.8.0.0/24 -o $SHARK -j MASQUERADE
```

请务必通过重新加载 firewalld 对防火墙规则实施这些更改：

```bash
sudo firewall-cmd --reload
```

接下来，启用 IP 转发。这会将所有网络流量从您的客户端路由到您服务器的 IP 地址，并且您客户端的公共 IP 地址将被有效隐藏。

打开`sysctl.conf`编辑：

```bash
sudo nano /etc/sysctl.conf
```

然后在文件顶部添加以下行：

/etc/sysctl.conf

```bash
net.ipv4.ip_forward = 1
```

**另外需要进行路由转发设置，否则，不能上网**

```
# 需要先进行安装这个服务，不然重启无效
yum -y install iptables-services
systemctl start iptables.service
systemctl enable iptables.service
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables-save
systemctl restart iptables
```

最后重启网络服务使IP转发生效：

```bash
sudo systemctl restart network.service
```

路由和防火墙规则到位后，我们可以在服务器上启动 OpenVPN 服务。

## 第 5 步 - 启动 OpenVPN

OpenVPN 使用`systemctl`. 我们会将 OpenVPN 配置为在启动时启动，因此只要您的服务器正在运行，您就可以随时连接到您的 VPN。为此，请通过将其添加到以下来启用 OpenVPN 服务器`systemctl`：

```bash
sudo systemctl -f enable openvpn@server.service
```

然后启动OpenVPN服务：

```bash
sudo systemctl start openvpn@server.service
```

使用以下命令仔细检查 OpenVPN 服务是否处于活动状态。您应该`active (running)`在输出中看到：

```bash
sudo systemctl status openvpn@server.service
```

```
Output
● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server
   Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)
   Active: **active (running)** since Wed 2018-03-14 15:20:11 EDT; 7s ago
 Main PID: 2824 (openvpn)
   Status: "Initialization Sequence Completed"
   CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
           └─2824 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf
. . .
```

我们现在已经完成了 OpenVPN 的服务器端配置。接下来，您将配置您的客户端机器并连接到 OpenVPN 服务器。

## 第 6 步 - 配置客户端

无论您的客户端计算机的操作系统是什么，都需要本地保存的 CA 证书副本和步骤 3 中生成的客户端密钥和证书，以及您在步骤 2 结束时生成的静态加密密钥。

**在您的服务器上**找到以下文件。如果您使用唯一的描述性名称生成多个客户端密钥，则密钥和证书名称将不同。在本文中，我们使用了`client`.

```
/etc/openvpn/easy-rsa/keys/ca.crt
/etc/openvpn/easy-rsa/keys/client.crt
/etc/openvpn/easy-rsa/keys/client.key
/etc/openvpn/myvpn.tlsauth
```

将这些文件复制到您的**客户端机器上**。您可以使用[SFTP](https://www.digitalocean.com/community/tutorials/how-to-use-sftp-to-securely-transfer-files-with-a-remote-server)或您喜欢的方法。您甚至可以在文本编辑器中打开文件，然后将内容复制并粘贴到客户端计算机上的新文件中。无论您使用哪种方法，请务必记下这些文件的保存位置。

接下来，创建一个`client.ovpn` **在您的客户端机器上**调用的文件。这是 OpenVPN 客户端的配置文件，告诉它如何连接到服务器：

```bash
sudo vim client.ovpn
```

然后将以下行添加到`client.ovpn`. 请注意，其中许多行反映了我们取消注释或添加到`server.conf`文件中的行，或者默认情况下已经在其中的行：

客户端.ovpn

```bash
client
tls-client
ca /path/to/ca.crt
cert /path/to/client.crt
key /path/to/client.key
tls-crypt /path/to/myvpn.tlsauth
remote-cert-eku "TLS Web Client Authentication"  # 客户端不建议加这个选项，会导致tls证书验证错误
proto udp
remote your_server_ip 1194 udp
dev tun
topology subnet
pull
user nobody
group nobody
```

添加这些行时，请注意以下几点：

- 您需要更改第一行以反映您在密钥和证书中为客户端提供的名称；在我们的例子中，这只是`client`
- 您还需要将 IP 地址从更新`your_server_ip`为您服务器的 IP 地址；端口`1194`可以保持不变
- 确保您的密钥和证书文件的路径正确

## 需要注意的几点：

### 1，需要删掉下面这些加密选项（服务端和客户端都需要进行删除）

```
# server 不要添加下面这个内容，否则容易出现tls验证错误
remote-cert-eku "TLS Web Client Authentication"

# client 删除
remote-cert-eku "TLS Web Client Authentication"
```





原文地址：https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-an-openvpn-server-on-centos-7

