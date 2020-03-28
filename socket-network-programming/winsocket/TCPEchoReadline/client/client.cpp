/*
* 流式套接字回射服务器接收一行数据：client.cpp
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

BOOL recvline(SOCKET S, char* buf)
{
	BOOL retval = true; //返回值
	BOOL bLineEnd = false;//一行读取结束
	int nReadLen = 0; //读入字节数
	int nDataLen = 0; //数据长度

	while (!bLineEnd)
	{
		nReadLen = recv(S, buf, MAXSIZE, 0);
		if (nReadLen == SOCKET_ERROR)
		{
			cout << "连接失败！" << endl;
			retval = false;   // 读取数据失败  
			break;              // 跳出循环  
		}
		if (0 == nReadLen)
		{
			retval = false; //读取数据失败
			break;
		}
		for (int i = 0; i<nReadLen; i++)
		{
			if ('\n' == *(buf + i)) {
				bLineEnd = true;
				retval = true;
				break;
			}

		}
	}
	return retval;
}

int main() {
	SOCKET clientsocket;
	WSADATA wsd;
	SOCKADDR_IN clientaddr;
	char recvbuf[MAXSIZE];
	char sendbuf[MAXSIZE];
	memset(sendbuf, 0, MAXSIZE);
	memset(recvbuf, 0, MAXSIZE);

	int ret;
	ret = WSAStartup(MAKEWORD(2, 2), &wsd);
	if (ret != 0) {
		cout << "start error！" << endl;
		system("pause");
		return 0;
	}
	if (LOBYTE(wsd.wVersion) != 2 || HIBYTE(wsd.wVersion) != 2) {
		cout << "version error！" << endl;
		system("pause");
		return 0;
	}

	clientsocket = socket(AF_INET, SOCK_STREAM, 0);
	if (clientsocket == INVALID_SOCKET) {
		cout << "socket error！" << endl;
		WSACleanup();
		system("pause");
		return 0;
	}

	clientaddr.sin_family = AF_INET;
	clientaddr.sin_addr.s_addr = inet_addr("127.0.0.1");
	clientaddr.sin_port = htons(12345);

	int len = sizeof(SOCKADDR_IN);
	ret = connect(clientsocket, (SOCKADDR*)&clientaddr, sizeof(clientaddr));
	if (ret == SOCKET_ERROR) {
		cout << "connect error！" << endl;
		closesocket(clientsocket);
		WSACleanup();
		return 0;
	}
	while (true) {
		cout << "please input data：";
		int i = 0;
		char c;
		int max = MAXSIZE;
		while ((--max) >0 && (c = getchar()) != EOF && c != '\n')
			sendbuf[i++] = c;

		if (strcmp(sendbuf, "q") == 0) {
			cout << "connect is closed！" << endl;
			break;
		}

		if (c = '\n')
			sendbuf[i] = '\n';

		ret = send(clientsocket, sendbuf, sizeof(sendbuf), 0);
		if (ret == SOCKET_ERROR) {
			cout << "send error！" << endl;
			closesocket(clientsocket);
			WSACleanup();
			return 0;
		}

		if (!recvline(clientsocket, recvbuf)) {
			closesocket(clientsocket);
			WSACleanup();
			return 0;
		}
		cout << recvbuf << endl;
	}
	closesocket(clientsocket);
	WSACleanup();
	return 0;
}

