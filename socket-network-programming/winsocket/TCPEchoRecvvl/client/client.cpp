/*
* 流式套接字回射服务器接收定长数据：client.cpp
* windows10-vs2017
* by sjy
*/
#include<iostream>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<WinSock2.h>
#pragma  comment(lib, "wsock32.lib")
#define  MAXSIZE 100
using namespace std;

int recvn(SOCKET s, char * recvbuf, unsigned int fixedlen);
int recvvl(SOCKET s, char * recvbuf, unsigned int recvbuflen);

int main()
{
	//初始化套结字动态库 
	WSADATA wsaData;
	int retVal = WSAStartup(MAKEWORD(2, 2), &wsaData);
	if (retVal != 0)
	{
		cout << "start error！" << endl;
		system("pause");
		return  -1;
	}
	if (LOBYTE(wsaData.wVersion) != 2 || HIBYTE(wsaData.wVersion) != 2)
	{
		WSACleanup();
		cout << "version error！" << endl;
		system("pause");
		return  -1;
	}
	//建立客户端套接字 
	SOCKET sockclient;
	sockclient = socket(AF_INET, SOCK_STREAM, 0);
	if (sockclient == INVALID_SOCKET)
	{
		WSACleanup();
		cout << "create error！" << endl;
		system("pause");
		return  -1;
	}
	//服务器地址信息  
	struct sockaddr_in saServer;
	saServer.sin_family = AF_INET;
	saServer.sin_port = htons(6000);
	saServer.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");
	//连接服务器  
	retVal = connect(sockclient, (sockaddr*)&saServer, sizeof(saServer));
	if (retVal == SOCKET_ERROR)
	{
		cout << "connect error！" << endl;
		closesocket(sockclient);
		WSACleanup();
		system("pause");
		return  -1;
	}
	else
		cout << "connect successfully！" << endl;

	//向服务器发送数据
	//首先发送定长的消息声明本次传输的消息长度  
	//再发送变长的消息体
	unsigned int slen = 0;
	unsigned int buflen = MAXSIZE;
	char buff[MAXSIZE];  //发送缓存  
	char recvbuff[MAXSIZE]; //接收缓存  
	while (TRUE)
	{
		memset(recvbuff, 0, MAXSIZE);
		cout << "Please input data：";
		cin >> buff;
		if (strcmp(buff, "q") == 0) { 
			cout << "finish input" << endl;
			break;
		}
			
		slen = (unsigned int)strlen(buff);
		// cout << slen << endl;
		slen = htonl(slen);

		//先发长度
		if (send(sockclient, (char*)&slen, sizeof(unsigned int), 0) <= 0)
		{
			printf("发送失败!code:%d\n", WSAGetLastError());
			closesocket(sockclient);
			WSACleanup();
			system("pause");
			return  -1;
		}
		//再发变长消息体
		if (send(sockclient, buff, strlen(buff), 0) <= 0)
		{
			printf("发送失败 !code:%d\n", WSAGetLastError());
			closesocket(sockclient);
			WSACleanup();
			return  -1;
		}

		retVal = recvvl(sockclient, recvbuff, buflen);
		if (retVal == SOCKET_ERROR)
		{
			closesocket(sockclient);
			WSACleanup();
			system("pause");
			return  -1;
		}

		//打印收到的回显字符串  
		cout << recvbuff << endl;
	}
	closesocket(sockclient);
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
			system("pause");
			return  -1;
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
	//printf("reclen:%d\n",reclen);  
	if (iResult != sizeof(unsigned int)) {
		//如果长度字段在接收时没有返回一个整型数据就返回（连接关闭）或-1（发生错误）  
		if (iResult == -1) {
			printf("接收发生错误: %d\n", WSAGetLastError());
			system("pause");
			return  -1;
		}
		else {
			printf("连接关闭\n");
			system("pause");
			return 0;
		}
	}
	//转换网络字节顺序到主机字节顺序  
	reclen = ntohl(reclen);
	if (reclen > recvbuflen) {
		//如果recvbuf没有足够的空间存储变长消息，则接收该消息并丢弃，返回错误  
		while (reclen > 0) {
			iResult = recvn(s, recvbuf, recvbuflen);
			if (iResult != recvbuflen) {
				//如果变长消息在接收时没有返回足够的数据就返回（连接关闭）或-1（发生错误）  
				if (iResult == -1) {
					printf("接收发生错误: %d\n", WSAGetLastError());
					system("pause");
					return  -1;
				}
				else {
					printf("连接关闭\n");
					system("pause");
					return 0;
				}
			}
			reclen -= recvbuflen;
			//处理最后一段数据长度  
			if (reclen < recvbuflen)
				recvbuflen = reclen;
		}
		printf("可变长度的消息超出预分配的接收缓存\r\n");
		system("pause");
		return  -1;
	}
	//接收可变长消息  
	iResult = recvn(s, recvbuf, reclen);
	if (iResult != reclen) {
		//如果消息在接收时没有返回足够的数据就返回（连接关闭）或-1（发生错误）  
		if (iResult == -1) {
			printf("接收发生错误: %d\n", WSAGetLastError());
			system("pause");
			return  -1;
		}
		else {
			printf("连接关闭\n");
			system("pause");
			return 0;
		}
	}
	return iResult;
}

