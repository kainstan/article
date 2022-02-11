# nginx搭建、反向代理、鉴权



### 1、预备工作

这里采用的是docker方式安装，需要下载nginx的docker镜像

```
docker pull nignx
```



### 2、nginx启动方式

启动的时候需要挂在虚拟目录，方便对nginx的配置文件进行管理

```
docker run -d -p 80:80 -p 7722:22 --restart always --name nginx-forward -v /root/docker_dir/nginx/www:/usr/share/nginx/html -v /root/docker_dir/nginx/conf/nginx.conf:/etc/nginx/nginx.conf -v /root/docker_dir/nginx/logs:/var/log/nginx -v /root/docker_dir/nginx/conf/conf.d:/etc/nginx/conf.d nginx
```

`-v`表示要挂载的目录，:前面是宿主机的文件路径，:后面是容器内部文件的真实路径。

`--restart`表示容器故障之后的重启方式，always表示一直都会重启。

`--name`表示镜像启动之后，生成的容器的名称。

命令行最后面的nginx是表示要启动的镜像名称

<font color="#00F5FF">此时nginx已经启动成功，默认80端口会显示nginx的默认首页。如果需要通过不同的域名跳转到不同的页面，需要做反向代理。</font>



### 3、反向代理配置

通过修改nginx挂载到宿主机的配置文件，来配置反向代理

```
# 宿主机里面的文件夹如下，进入conf文件夹进行配置
[root@localhost nginx]# ls
conf  logs  www
# 进入conf文件夹
[root@localhost conf]# ls
conf.d  nginx.conf
```

<font color="red">修改`nignx.conf`文件的时候需要注意，如果反向代理的不止是http协议，还有tcp协议的时候需要分开进行配置处理。</font>

```
# 修改nginx.conf文件
# 在http代码里面的include文件指定一个专属http的配置文件
http {
	...
	include /etc/nginx/conf.d/http/*.conf;
}

# 如果需要反向代理tcp协议的内容，再增加一个stream
stream {
    # tcp forward
    include /etc/nginx/conf.d/tcp/*.conf;
}
```

这样就完成了http反向代理和tcp反向代理的初步配置，接下来在`conf.d`文件夹里面创建http和tcp文件夹

```
# conf文件夹内容如下
[root@localhost conf.d]# ls
default.conf http  tcp
```

<font color="#1E90FF">http协议编写方式：</font>

```
# 进入http文件夹，编辑http.conf文件。例如反向代理test.trip-service.com这个域名
# 浏览器会根据test.trip-service.com转发到54.221.78.73:80这个地址
# 注意：upstream后面的所填写的名称将会变成反向代理的host发送到对方服务器。这里host:test
upstream test {
    server 54.221.78.73:80;
}
server {
    listen 80;
    server_name test.trip-service.com;
    location / {
        proxy_pass http://test;
    }
}
```

<font color="#1E90FF">tcp协议编写方式：</font>

```
# 进入tcp文件夹，编辑tcp.conf文件。例子如下
upstream gitlab_ssh_server {
    server 192.168.153.207:9922;
}
server {
    listen 22;
    proxy_pass gitlab_ssh_server;
}
```



### 4、鉴权

对域名或者域名的某个路径做用户鉴权

4-1、首先需要安装nginx的鉴权工具

```
# 如果是ubuntu系统
apt install apache2-utils
# 如果是centos系统
yum install httpd-tools
```

4-2、生成鉴权账户

```
# 生成的鉴权文件passwd，存放在/usr/local/src/nginx/这个目录里面
htpasswd -c /usr/local/src/nginx/passwd username
# 此时需要输入密码并确认一遍密码
```

4-3、反向代理并鉴权

```
# 根目录是不需要鉴权的，直接可以访问
# /authpath是需要鉴权的

# yourhostname是你需要反向代理的域名
upstream yourhostname {
		# 反向代理指向的位置
    server 127.0.0.1:8001;
}

server {
		# 监听的端口
    listen 8080;
    server_name yourhostname;
    location / {
        proxy_pass http://yourhostname;
    }
    location /authpath {
        auth_basic "auth";
        # auth_basic_user_file鉴权文件位置
        auth_basic_user_file /usr/local/src/nginx/passwd;
        proxy_pass http://yourhostname;
    }
}
```





















