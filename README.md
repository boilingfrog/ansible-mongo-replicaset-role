# ansible-mongo-replicaset-role

## 前言

使用ansible搭建的一个精简版的`mongo replicaset`。安装的服务器centos7。  

## 安装思路

1、通过rpm安装mongo的包，然后安装依赖的程序  
2、配置`mongo.service`  
3、配置`mongo.conf`，初始化的mongo是没有账号密码的，所以先初始化一个无需验证的`mongo.conf`。然后配置登录的账号密码。
之后在配置`mongo.conf`为需要认证。重启。  
4、初始化副本集，设置开机启动。  

## 运行

本地需要安装ansible，之后在ansible中的host配置group

````
[mongo_master]
192.168.56.104 MONGO_MASTER=true

[mongo_replicas]
192.168.56.105
192.168.56.106

[mongo:children]
mongo_master
mongo_replicas
````

运行  

````
ansible-playbook deploy-mongo.yml  
````
