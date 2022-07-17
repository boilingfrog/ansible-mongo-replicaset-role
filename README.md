<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [ansible-mongo-replicaset-role](#ansible-mongo-replicaset-role)
  - [前言](#%E5%89%8D%E8%A8%80)
  - [安装思路](#%E5%AE%89%E8%A3%85%E6%80%9D%E8%B7%AF)
  - [项目结构](#%E9%A1%B9%E7%9B%AE%E7%BB%93%E6%9E%84)
  - [运行](#%E8%BF%90%E8%A1%8C)
    - [1、使用本机安装的 ansible](#1%E4%BD%BF%E7%94%A8%E6%9C%AC%E6%9C%BA%E5%AE%89%E8%A3%85%E7%9A%84-ansible)
      - [异常报错](#%E5%BC%82%E5%B8%B8%E6%8A%A5%E9%94%99)
    - [2、使用 docker 安装](#2%E4%BD%BF%E7%94%A8-docker-%E5%AE%89%E8%A3%85)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

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
├── playbooks
│   ├── deploy-mongo.yml
│   └── roles
│       └── mongo
│           ├── defaults // 一些配置信息
│           │   └── main.yml
│           ├── files // mongo的安装包
│           │   └── rpms
│           │       ├── mongodb-org-unstable-mongos-4.1.8-1.el7.x86_64.rpm
│           │       ├── mongodb-org-unstable-server-4.1.8-1.el7.x86_64.rpm
│           │       ├── mongodb-org-unstable-shell-4.1.8-1.el7.x86_64.rpm
│           │       └── mongodb-org-unstable-tools-4.1.8-1.el7.x86_64.rpm
│           ├── handlers // notify重启服务的task
│           │   └── main.yml
│           ├── tasks
│           │   ├── auth_initialization.yml
│           │   ├── authorization.yml
│           │   ├── configure.yml
│           │   ├── init_replicaset.yml
│           │   ├── install_task.yml
│           │   └── main.yml
│           └── templates
│               ├── mongod.conf.j2
│               └── mongodb.service.j2
````

## 运行  

### 1、使用本机安装的 ansible 

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
ansible-playbook ./playbooks/deploy-mongo.yml  
````

执行

```
PLAY [mongo] *******************************************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************************************
ok: [192.168.56.104]
ok: [192.168.56.105]
ok: [192.168.56.106]

TASK [mongo : prepare dir] *****************************************************************************************************************************************************
ok: [192.168.56.104] => (item=/test/mongo)
ok: [192.168.56.106] => (item=/test/mongo)
ok: [192.168.56.105] => (item=/test/mongo)

TASK [mongo : 复制 rpm 安装包] ******************************************************************************************************************************************************
ok: [192.168.56.105] => (item=mongodb-org-unstable-tools-4.1.8-1.el7.x86_64.rpm)
ok: [192.168.56.104] => (item=mongodb-org-unstable-tools-4.1.8-1.el7.x86_64.rpm)
ok: [192.168.56.106] => (item=mongodb-org-unstable-tools-4.1.8-1.el7.x86_64.rpm)
ok: [192.168.56.105] => (item=mongodb-org-unstable-mongos-4.1.8-1.el7.x86_64.rpm)
ok: [192.168.56.106] => (item=mongodb-org-unstable-mongos-4.1.8-1.el7.x86_64.rpm)
ok: [192.168.56.104] => (item=mongodb-org-unstable-mongos-4.1.8-1.el7.x86_64.rpm)
ok: [192.168.56.104] => (item=mongodb-org-unstable-shell-4.1.8-1.el7.x86_64.rpm)
ok: [192.168.56.105] => (item=mongodb-org-unstable-shell-4.1.8-1.el7.x86_64.rpm)
ok: [192.168.56.106] => (item=mongodb-org-unstable-shell-4.1.8-1.el7.x86_64.rpm)
ok: [192.168.56.105] => (item=mongodb-org-unstable-server-4.1.8-1.el7.x86_64.rpm)
ok: [192.168.56.104] => (item=mongodb-org-unstable-server-4.1.8-1.el7.x86_64.rpm)
ok: [192.168.56.106] => (item=mongodb-org-unstable-server-4.1.8-1.el7.x86_64.rpm)
......
......

TASK [启动 mongo] ****************************************************************************************************************************************************************
changed: [192.168.56.104]
changed: [192.168.56.106]
changed: [192.168.56.105]

PLAY RECAP *********************************************************************************************************************************************************************
192.168.56.104             : ok=28   changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.56.105             : ok=25   changed=6    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   
192.168.56.106             : ok=25   changed=6    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0  
```

查看副本集
````
mongo -u test -p 123456789

rs.status()
{
	"set" : "mongos",
	"date" : ISODate("2020-08-19T01:06:55.748Z"),
	"myState" : 1,
	"term" : NumberLong(2),
	"syncingTo" : "",
	"syncSourceHost" : "",
	"syncSourceId" : -1,
	"heartbeatIntervalMillis" : NumberLong(2000),
	"optimes" : {
		"lastCommittedOpTime" : {
			"ts" : Timestamp(1597799214, 1),
			"t" : NumberLong(2)
		},
		"readConcernMajorityOpTime" : {
			"ts" : Timestamp(1597799214, 1),
			"t" : NumberLong(2)
		},
		"appliedOpTime" : {
			"ts" : Timestamp(1597799214, 1),
			"t" : NumberLong(2)
		},
		"durableOpTime" : {
			"ts" : Timestamp(1597799214, 1),
			"t" : NumberLong(2)
		}
	},
	"lastStableRecoveryTimestamp" : Timestamp(1597799170, 1),
	"lastStableCheckpointTimestamp" : Timestamp(1597799170, 1),
	"members" : [
		{
			"_id" : 0,
			"name" : "192.168.56.104:27017",
			"health" : 1,
			"state" : 1,
			"stateStr" : "PRIMARY",
			"uptime" : 25,
			"optime" : {
				"ts" : Timestamp(1597799214, 1),
				"t" : NumberLong(2)
			},
			"optimeDate" : ISODate("2020-08-19T01:06:54Z"),
			"syncingTo" : "",
			"syncSourceHost" : "",
			"syncSourceId" : -1,
			"infoMessage" : "could not find member to sync from",
			"electionTime" : Timestamp(1597799202, 1),
			"electionDate" : ISODate("2020-08-19T01:06:42Z"),
			"configVersion" : 1,
			"self" : true,
			"lastHeartbeatMessage" : ""
		},
		{
			"_id" : 1,
			"name" : "192.168.56.105:27017",
			"health" : 1,
			"state" : 2,
			"stateStr" : "SECONDARY",
			"uptime" : 22,
			"optime" : {
				"ts" : Timestamp(1597799214, 1),
				"t" : NumberLong(2)
			},
			"optimeDurable" : {
				"ts" : Timestamp(1597799214, 1),
				"t" : NumberLong(2)
			},
			"optimeDate" : ISODate("2020-08-19T01:06:54Z"),
			"optimeDurableDate" : ISODate("2020-08-19T01:06:54Z"),
			"lastHeartbeat" : ISODate("2020-08-19T01:06:54.177Z"),
			"lastHeartbeatRecv" : ISODate("2020-08-19T01:06:55.147Z"),
			"pingMs" : NumberLong(1),
			"lastHeartbeatMessage" : "",
			"syncingTo" : "192.168.56.104:27017",
			"syncSourceHost" : "192.168.56.104:27017",
			"syncSourceId" : 0,
			"infoMessage" : "",
			"configVersion" : 1
		},
		{
			"_id" : 2,
			"name" : "192.168.56.106:27017",
			"health" : 1,
			"state" : 2,
			"stateStr" : "SECONDARY",
			"uptime" : 22,
			"optime" : {
				"ts" : Timestamp(1597799214, 1),
				"t" : NumberLong(2)
			},
			"optimeDurable" : {
				"ts" : Timestamp(1597799214, 1),
				"t" : NumberLong(2)
			},
			"optimeDate" : ISODate("2020-08-19T01:06:54Z"),
			"optimeDurableDate" : ISODate("2020-08-19T01:06:54Z"),
			"lastHeartbeat" : ISODate("2020-08-19T01:06:54.177Z"),
			"lastHeartbeatRecv" : ISODate("2020-08-19T01:06:54.993Z"),
			"pingMs" : NumberLong(0),
			"lastHeartbeatMessage" : "",
			"syncingTo" : "192.168.56.104:27017",
			"syncSourceHost" : "192.168.56.104:27017",
			"syncSourceId" : 0,
			"infoMessage" : "",
			"configVersion" : 1
		}
	],
	"ok" : 1,
	"$clusterTime" : {
		"clusterTime" : Timestamp(1597799214, 1),
		"signature" : {
			"hash" : BinData(0,"DOXez6PTTqpY34sHPHuxKeT2iIE="),
			"keyId" : NumberLong("6862494794178887682")
		}
	},
	"operationTime" : Timestamp(1597799214, 1)
}
````

#### 异常报错

```
FAILED! => {"changed": false, "msg": "Unable to authenticate with MongoDB: check_compatibility() takes exactly 2 arguments (3 given)"}
```

升级ansible依赖的python版本  

报错版本`python2.7`,更换版本`2.7.10`，解决上面报错  

### 2、使用 docker 安装

优点，本机只需要安装 docker 即可，统一的 ansible 版本和 python 版本，避免版本不一致造成的安装问题。

1、在 `./targets/dev/.ssh` 放入自己的私钥； 

2、在 `./targets/dev/.host` 配置自己的服务器信息；  

3、执行 `./run jumper dev` 进入到 ansible 脚本的镜像中；  

4、执行对应的 playbooks 脚本，`bash-5.0# ansible-playbook ./playbooks/deploy-mongo.yml `。  

<img src="/img/ansible-deploy.jpg"  alt="asnible" />    
