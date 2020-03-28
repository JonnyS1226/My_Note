/*
* 流式套接字回射服务器接收定长数据：client.cpp
* windows10-vs2017
* by sjy
*/
#include<iostream>
#include<WinSock2.h>
#include<stdio.h>
#include <stdlib.h>
#include <string.h>
#pragma  comment(lib,"wsock32.lib")
#define MAXSIZE 100
using namespace std;

BOOL recvn(SOCKET S, char* buf, unsigned int fixedlen)
{
	BOOL retval = true; //返回值
	int iResult; //存储单次recv操作的返回值
	int cnt; //统计未接收字节数
	cnt = fixedlen;
	ZeroMemory(buf, MAXSIZE);
	while (cnt>0)
	{
		iResult = recv(S, buf, cnt, 0);
		if (iResult == SOCKET_ERROR)
		{
			cout << "连接失败！" << endl;
			return -1;
			break;              // 跳出循环  
		}
		if (0 == iResult)
		{
			cout << "对方关闭连接！" << endl;
			return fixedlen - cnt;
		}
		buf += iResult;
		cnt -= iResult;
	}
	return fixedlen;
}


int main() {
	SOCKET clientsocket;
	WSADATA wsd;
	SOCKADDR_IN clientaddr;
	char recvbuf[MAXSIZE];
	char sendbuf[MAXSIZE];
	memset(sendbuf, 0, MAXSIZE);
	memset(recvbuf, 0, MAXSIZE);

	int iResult;
	iResult = WSAStartup(MAKEWORD(2, 2), &wsd);
	if (iResult != 0) {
		cout << "start error！" << endl;
		system("pause");
		return 0;
	}
	if (LOBYTE(wsd.wVersion) != 2 || HIBYTE(wsd.wVersion) != 2) {
		cout << "version error！" << endl;
		system("pause");
		return 0;
	}

	//创建套接字
	clientsocket = socket(AF_INET, SOCK_STREAM, 0);
	if (clientsocket == INVALID_SOCKET) {
		cout << "socket create error！" << endl;
		WSACleanup();
		system("pause");
		return 0;
	}

	//设置地址
	clientaddr.sin_family = AF_INET;
	clientaddr.sin_addr.s_addr = inet_addr("127.0.0.1");
	clientaddr.sin_port = htons(1234);

	//connect三次握手
	int len = sizeof(SOCKADDR_IN);
	iResult = connect(clientsocket, (SOCKADDR*)&clientaddr, sizeof(clientaddr));
	if (iResult == SOCKET_ERROR) {
		cout << "connect error！" << endl;
		closesocket(clientsocket);
		WSACleanup();
		system("pause");
		return 0;
	}
	while (true) {
		cout << "Please input data：";

		if (strcmp(sendbuf, "q") == 0) {
			cout << "finish input！" << endl;
			break;
		}
		cin >> sendbuf;
		iResult = send(clientsocket, sendbuf, sizeof(sendbuf), 0);
		if (iResult == SOCKET_ERROR) {
			cout << "send error！" << endl;
			closesocket(clientsocket);
			WSACleanup();
			system("pause");
			return 0;
		}

		recvn(clientsocket, recvbuf, 50);
		cout << recvbuf << endl;
	}
	closesocket(clientsocket);
	WSACleanup();
	return 0;
}

