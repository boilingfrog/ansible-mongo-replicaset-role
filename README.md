# ansible-mongo-replicaset-role

## 前言

使用ansible搭建的一个精简版的`mongo replicaset`。安装的服务器centos7。  

## 安装思路

1、通过rpm安装mongo的包，然后安装依赖的程序  
2、配置`mongo.service`  
3、配置`mongo.conf`，初始化的mongo是没有账号密码的，所以先初始化一个无需验证的`mongo.conf`。配置好之后，重启服务。   
4、设置登录的账号密码，之后修改`mongo.conf`为需要认证的。重启服务。  
5、初始化副本集，设置开机启动。   

## 项目结构

````
.
├── deploy-mongo.yml
└── roles
    └── mongo
        ├── defaults  // 一些配置信息
        │   └── main.yml
        ├── files  // mongo的安装包
        │   └── rpms
        │       ├── mongodb-org-unstable-mongos-4.1.8-1.el7.x86_64.rpm
        │       ├── mongodb-org-unstable-server-4.1.8-1.el7.x86_64.rpm
        │       ├── mongodb-org-unstable-shell-4.1.8-1.el7.x86_64.rpm
        │       └── mongodb-org-unstable-tools-4.1.8-1.el7.x86_64.rpm
        ├── handlers // notify重启服务的task
        │   └── main.yml
        ├── tasks
        │   ├── auth_initialization.yml
        │   ├── authorization.yml
        │   ├── configure.yml
        │   ├── init_replicaset.yml
        │   ├── install_task.yml
        │   └── main.yml
        └── templates
            ├── mongodb.service.j2
            └── mongod.conf.j2

````

## 运行

本地需要安装`ansible`，之后在`ansible`中的host配置`group`,`ansible`的版本需要在`2.8`之上。  

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
