/*
* 时间同步服务器设计：server.cpp
* author: sjy
*/

#include <stdio.h>
#include <stdlib.h>
#include <winsock2.h>
#include <time.h>
#include <string.h>
#include <iostream>

using namespace std;

#pragma comment(lib, "ws2_32.lib")  //引入动态链接库

#define ListenQ 1024		//监听队列
#define	RecvBufLen 4096		//接收缓冲区
#define ServerPort 13131	//时间同步服务器端口

int main()
{
	time_t t;	//时间类型，其实是长整型
	char sendBuf[100];	//发送缓冲区
	char recvBuf[RecvBufLen];	//接收缓冲区
	int iResult;	//接收信息用
	
	//初始化windows Socket DLL 版本协议号
	WORD w_version = MAKEWORD(2, 2);
	WSADATA wsaData;
	iResult = WSAStartup(w_version, &wsaData);
	if (iResult != 0)
	{
		cout << WSAGetLastError() << "WSAStartup Error!" << endl;
		return -1;
	}
	if (LOBYTE(wsaData.wVersion) != 2 || HIBYTE(wsaData.wVersion) != 2)
	{
		cout << WSAGetLastError() << "Version Error!" << endl;
		WSACleanup();
		return -1;
	}

	//创建套接字,监听和连接套接字
	SOCKET sock_conn = socket(AF_INET, SOCK_STREAM, 0);
	SOCKET sock_listen = socket(AF_INET, SOCK_STREAM, 0);
	if (sock_listen == INVALID_SOCKET)
	{
		cout << WSAGetLastError() << "Socket Error";
		WSACleanup();
		return -1;
	}

	//设置地址
	sockaddr_in addrSrv;
	memset(&addrSrv, 0, sizeof(addrSrv));
	addrSrv.sin_family = AF_INET;
	addrSrv.sin_port = htons(ServerPort);	//Host to Network Short
	addrSrv.sin_addr.S_un.S_addr = htonl(INADDR_ANY); //Host to Network Long，INADDR_ANY代表0.0.0.0 通配

	//为监听套接字绑定地址
	iResult = bind(sock_listen, (struct sockaddr *)&addrSrv, sizeof(addrSrv));
	if (iResult == SOCKET_ERROR)
	{
		cout << WSAGetLastError() << "Bind Error" << endl;
		closesocket(sock_listen);
		WSACleanup();
		return -1;
	}
	
	//监听客户端
	iResult = listen(sock_listen, ListenQ);
	if (iResult == SOCKET_ERROR)
	{
		cout << WSAGetLastError() << "Listen Error!" << endl;
		closesocket(sock_listen);
		WSACleanup();
		return -1;
	}

	//循环服务器处理用户连接请求
	while (true)
	{
		//连接accept
		sock_conn = accept(sock_listen, NULL, NULL);
		if (sock_conn == INVALID_SOCKET)
		{
			cout << WSAGetLastError() << "Accept Error!" << endl;
			closesocket(sock_conn);
			WSACleanup();
			return -1;
		}

		//获取时间
		t = time(NULL);
		time(&t);
		memset(sendBuf, 0, sizeof(sendBuf)); //清空发送缓冲区，准备发送
		strcpy(sendBuf, ctime(&t)); //把时间转换为字符串格式
		cout << "time:" << sendBuf << endl;

		//发送时间
		iResult = send(sock_conn, sendBuf, (int)strlen(sendBuf), 0);
		if (iResult == SOCKET_ERROR)
		{
			cout << WSAGetLastError() << "Send Error!" << endl;
			closesocket(sock_conn);
			WSACleanup();
			return -1;
		}
		cout << "send time information to client successfully" << endl;

		//关闭发送通道，不再发送数据
		iResult = shutdown(sock_conn, SD_SEND);
		if (iResult == SOCKET_ERROR)
		{
			cout << WSAGetLastError() << "Shutdown Error!" << endl;
			closesocket(sock_conn);
			WSACleanup();
			return -1;
		}


		//释放连接套接字
		closesocket(sock_conn);
		cout << "Server close" << endl;


		//释放监听套接字
		closesocket(sock_listen);
		WSACleanup();
		return 0;
	}
}