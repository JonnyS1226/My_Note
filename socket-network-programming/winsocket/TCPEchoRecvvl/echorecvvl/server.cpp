/*
* 流式套接字回射服务器接收定长数据：server.cpp
* windows10-vs2017
* by sjy
*/
#include <stdio.h>
#include <stdlib.h>
#include <winsock2.h>
#include <string.h>
#include <iostream>
#pragma comment(lib, "wsock32.lib")
#define  SERVERPROT 6000  
#define  MAXSIZE 100  

int recvn(SOCKET s, char * recvbuf, unsigned int fixedlen);
int recvvl(SOCKET s, char * recvbuf, unsigned int recvbuflen);
using namespace std;

int main()
{
	//初始化WinSock  
	WSADATA wsaData;
	int iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
	if (iResult != 0)
	{
		cout << "start error！" << endl;
		return  -1;
	}
	if (LOBYTE(wsaData.wVersion) != 2 || HIBYTE(wsaData.wVersion) != 2)
	{
		WSACleanup();
		cout << "WSA版本错误！" << endl;
		return  -1;
	}
	//创建监听套接字  
	SOCKET slisten;
	slisten = socket(AF_INET, SOCK_STREAM, 0);
	if (slisten == INVALID_SOCKET)
	{
		cout << "create error！" << endl;
		WSACleanup();
		return  -1;
	}
	//构建服务器本地地址信息  
	struct sockaddr_in serveraddr;
	serveraddr.sin_family = AF_INET;
	serveraddr.sin_port = htons(SERVERPROT);
	serveraddr.sin_addr.S_un.S_addr = INADDR_ANY;
	//绑定  
	iResult = bind(slisten, (sockaddr*)&serveraddr, sizeof(serveraddr));
	if (iResult == SOCKET_ERROR)
	{
		cout << "bind error！" << endl;
		closesocket(slisten);
		WSACleanup();
		return  -1;
	}
	//监听连接请求  
	iResult = listen(slisten, 5);
	if (iResult == SOCKET_ERROR)
	{
		cout << "listen error！" << endl;
		closesocket(slisten);
		WSACleanup();
		return  -1;
	}
	while (1) {
		cout << "Waiting for client……" << endl;

		//接收客户端连接  
		struct sockaddr_in clientaddr;
		int clientaddrlen = sizeof(clientaddr);
		SOCKET sServer;//连接套接字  
		char buff[MAXSIZE];//接收缓存  
		char sendbuf[MAXSIZE];//发送缓存  
		unsigned int slen = 0; //发送数据长度  
		unsigned int buflen = MAXSIZE;

		sServer = accept(slisten, (struct sockaddr*)&clientaddr, &clientaddrlen);
		if (sServer == INVALID_SOCKET)
		{
			cout << "connect error！" << endl;
			closesocket(slisten);
			WSACleanup();
			return  -1;
		}
		cout << "client connected：" << inet_ntoa(clientaddr.sin_addr) << endl;

		while (TRUE)  //循环接收数据  
		{
			memset(buff, 0, MAXSIZE);
			memset(sendbuf, 0, MAXSIZE);
			iResult = recvvl(sServer, buff, buflen);
			if (iResult == SOCKET_ERROR)
			{
				closesocket(sServer);
				break;
			}
			sprintf_s(sendbuf, "echo:%s", buff);
			cout << sendbuf << endl;
			slen = (unsigned int)strlen(sendbuf);
			slen = htonl(slen);
			iResult = send(sServer, (char*)&slen, sizeof(unsigned int), 0);
			if (iResult == SOCKET_ERROR)
			{
				closesocket(sServer);
				break;
			}
			iResult = send(sServer, sendbuf, strlen(sendbuf), 0);
			if (iResult == SOCKET_ERROR)
			{
				closesocket(sServer);
				break;
			}
		}
		closesocket(sServer);
	}
	closesocket(slisten);
	WSACleanup();
	return 0;
}

//指定长度接收  
int recvn(SOCKET s, char * recvbuf, unsigned int fixedlen)
{
	int iResult;    //存储单次recv操作的返回值  
	int cnt;         //用于统计相对于固定长度，剩余多少字节尚未接收  
	cnt = fixedlen;
	while (cnt > 0) {
		iResult = recv(s, recvbuf, cnt, 0);
		if (iResult < 0) {
			//数据接收出现错误，返回失败  
			printf("接收发生错误: %d\n", WSAGetLastError());
			return -1;
		}
		if (iResult == 0) {
			//对方关闭连接，返回已接收到的小于fixedlen的字节数  
			printf("连接关闭\n");
			return fixedlen - cnt;
		}
		//接收缓存指针向后移动  
		recvbuf += iResult;
		//更新cnt值  
		cnt -= iResult;
	}
	return fixedlen;
}

int recvvl(SOCKET s, char * recvbuf, unsigned int recvbuflen)
{
	int iResult;//存储单次recvn操作的返回值  
	unsigned int reclen; //用于存储报文头部存储的长度信息  
						 //获取接收报文长度信息  
	iResult = recvn(s, (char *)&reclen, sizeof(unsigned int));
	if (iResult != sizeof(unsigned int))
	{
		//如果长度字段在接收时没有返回一个整型数据就返回（连接关闭）或-1（发生错误）  
		if (iResult == -1) {
			printf("接收发生错误: %d\n", WSAGetLastError());
			return -1;
		}
		else {
			printf("连接关闭\n");
			return 0;
		}
	}
	//转换网络字节顺序到主机字节顺序  
	reclen = ntohl(reclen);
	if (reclen > recvbuflen)
	{
		printf("reclen>recvbuflen: %d>%d\n", reclen, recvbuflen);
		//如果recvbuf没有足够的空间存储变长消息，则接收该消息并丢弃，返回错误  
		while (reclen > 0) {
			iResult = recvn(s, recvbuf, recvbuflen);
			if (iResult != recvbuflen) {
				//如果变长消息在接收时没有返回足够的数据就返回（连接关闭）或-1（发生错误）  
				if (iResult == -1) {
					printf("接收发生错误: %d\n", WSAGetLastError());
					return -1;
				}
				else {
					printf("连接关闭\n");
					return 0;
				}
			}
			reclen -= recvbuflen;
			//处理最后一段数据长度  
			if (reclen < recvbuflen)
				recvbuflen = reclen;
		}
		printf("可变长度的消息超出预分配的接收缓存\r\n");
		return -1;
	}
	//接收可变长消息  
	iResult = recvn(s, recvbuf, reclen);
	if (iResult != reclen)
	{
		//如果消息在接收时没有返回足够的数据就返回（连接关闭）或-1（发生错误）  
		if (iResult == -1) {
			printf("接收发生错误: %d\n", WSAGetLastError());
			return  -1;
		}
		else {
			printf("连接关闭\n");
			return 0;
		}
	}
	return iResult;
}
