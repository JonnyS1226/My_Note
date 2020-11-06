#### 环境

本实验使用Python+Golang+mysql的方式
编译环境是 python3.7  golang1.4

#### 测试方式

1. 运行sql脚本，设置好相关数据库环境
2. 运行时，首先先安装golang编译环境，然后运行server.go（注意/utils下的自己编写的go文件要放入依赖）
3. 运行client.py
4. 即可开始交互测试

#### 包结构：

```
|-utils
	|-commonUtils.go     server.go依赖的工具函数
	|-dbConnection.go    server.go依赖的数据库连接函数，若自己测试需要更改其中相关用户信息等
	|-dbUtils.go         server.go依赖的数据库操作函数
|-server.go              golang编写的服务器主程序
|-client.py              python编写的客户端主程序以及所需要的工具函数
|-log.log                自动生成的日志文件
|-s_key_lab.sql          本实验使用到的sql脚本
|-readme.txt             本实验程序使用说明
```

