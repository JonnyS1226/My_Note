## 实验任务

* 监听webmail交互数据流，抓取包括用户名，密码，信件主题，内容等信息



## 使用环境

* 操作系统：`Ubuntu18.04`	`aliyun ECS`
* 网络相关设置：IP（172.24.15.149）
* 编译器：`GCC`
* 使用邮箱：http://mail.tom.com
* 文档：markdown语法
* 依赖开发包：`libpcap`，`libnet`，`libnids`



## 使用方法

* 将`islab`文档拷贝至`linux`下，并进入该文件夹目录(`cd /islab`)
* `make`
* `./lab`



## 包结构

```css
├─islab
	├─lab		gcc生成的可执行文件
	├─lab.c		实验源码
	├─MakeFile	makefile
├─实验截图			   
├─171310218邵嘉毅.doc	实验报告
└readme.md			  实验文档说明			  
```