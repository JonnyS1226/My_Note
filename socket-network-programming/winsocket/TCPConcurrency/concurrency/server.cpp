/* 
* 流式套接字并发服务器：server.cpp
* windows10-vs2017
* by sjy
*/
#include <iostream>
#include <Winsock2.h>
#include "stdio.h"
#pragma comment(lib, "WS2_32")
using namespace std;

DWORD WINAPI IOThread(LPVOID lpParam);

int main()
{
	//加载socket库函数
	WORD wVersionRequested;
	WSADATA wsaData;
	int iResult;
	wVersionRequested = MAKEWORD(1, 1);
	iResult = WSAStartup(wVersionRequested, &wsaData);
	if (iResult != 0)
	{
		cout << "start error！" << endl;
		return 0;
	}
	if (LOBYTE(wsaData.wVersion) != 1 ||
		HIBYTE(wsaData.wVersion) != 1)
	{
		cout << "version error！" << endl;
		WSACleanup();
		return 0;
	}
	//创建套接字,设置地址
	SOCKET sockSrv = socket(AF_INET, SOCK_STREAM, 0);
	if (sockSrv == INVALID_SOCKET)
	{
		cout << "create error" << endl;
		WSACleanup();
		return -1;
	}

	SOCKADDR_IN addrSrv;
	addrSrv.sin_addr.S_un.S_addr = htonl(INADDR_ANY);
	addrSrv.sin_family = AF_INET;
	addrSrv.sin_port = htons(1234);

	//绑定地址
	iResult = bind(sockSrv, (SOCKADDR*)&addrSrv, sizeof(SOCKADDR));
	if (iResult == SOCKET_ERROR)
	{
		cout << "bind error" << endl;
		WSACleanup();
		return -1;
	}

	//监听客户端
	iResult = listen(sockSrv, 5);
	if (iResult == SOCKET_ERROR)
	{
		cout << "listen error" << endl;
		WSACleanup();
		return -1;
	}

	//定义从客户端接受的地址信息
	SOCKADDR_IN addrClient;
	int len = sizeof(SOCKADDR);

	HANDLE  hThread;
	cout << "Waiting for client..." << endl;
	SOCKET sockConn;
	while (1)
	{
		sockConn = SOCKET_ERROR;
		sockConn = accept(sockSrv, (SOCKADDR*)&addrClient, &len);
		cout << "client connected:" << inet_ntoa(addrClient.sin_addr) << endl;

		hThread = CreateThread(NULL, 0, IOThread, (LPVOID)sockConn, 0, NULL);
		if (hThread == NULL)
		{
			cout << "new thread error！" << endl;
		}
		else
		{
			cout << "new thread success！" << endl;
		}
	}
	closesocket(sockSrv);
	WSACleanup();
	return 0;
}
DWORD WINAPI IOThread(LPVOID lpParam)
{
	char sendBuf[100];
	char recvBuf[100];
	SOCKET  ClientSocket = (SOCKET)(LPVOID)lpParam;
	while (1)
	{
		recv(ClientSocket, recvBuf, 100, 0);
		cout << "data received :" << recvBuf << endl;
		sprintf(sendBuf, "echo:%s", recvBuf);
		cout << "data sent :" << sendBuf << endl;
		send(ClientSocket, sendBuf, strlen(sendBuf) + 1, 0);
	}
	closesocket(ClientSocket);
	return 0;
}