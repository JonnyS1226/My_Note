/*
* 流式套接字回射服务器：client.cpp
* windows10-vs2017
* by sjy
*/


#include "stdafx.h"
#include <iostream>
#include <string>
#include <Winsock2.h>
#pragma comment(lib, "WS2_32")
using namespace std;

int main()
{
	WORD w_version;
	WSADATA wsaData;
	int iResult;	//用于接收信息

	//初始化
	w_version = MAKEWORD(1, 1);
	iResult = WSAStartup(w_version, &wsaData);
	if (iResult != 0)
	{
		cout << "Start Error！" << endl;
		return 0;
	}
	if (LOBYTE(wsaData.wVersion) != 1 ||
		HIBYTE(wsaData.wVersion) != 1)
	{
		cout << "Version Error！" << endl;
		WSACleanup();
		return 0;
	}

	//创建套接字，设置地址
	SOCKET sock_conn = socket(AF_INET, SOCK_STREAM, 0);
	SOCKADDR_IN addrSrv;
	addrSrv.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");  //连接服务器ip地址
	addrSrv.sin_family = AF_INET;
	addrSrv.sin_port = htons(1234);  //分配端口

	//尝试连接
	if (connect(sock_conn, (SOCKADDR*)&addrSrv, sizeof(SOCKADDR)) != 0)
	{
		cout << "Connect Error！" << endl;;
		WSACleanup();
		return 0;
	}
	char sendBuf[100];	//发送缓冲区

	//发送数据和回射接收数据
	while (1)
	{
		cout << "please input data：";
		cin >> sendBuf;
		iResult = send(sock_conn, sendBuf, 100, 0);
		if (iResult == SOCKET_ERROR)
		{
			cout << WSAGetLastError() << "Send Data Error!" << endl;
			return -1;
		}

		//退出输入
		if ((strcmp("q", sendBuf) == 0))
		{
			cout << "finish input" << endl;
			iResult = shutdown(sock_conn, SD_SEND);
			if (iResult == SOCKET_ERROR)
			{
				cout << WSAGetLastError() << "Shutdown Error!" << endl;
			}
			return 0;
		}
		cout << "the string sent: " << sendBuf << endl;

		//接收回射
		char recvBuf[100];
		iResult = recv(sock_conn, recvBuf, 300, 0);
		if (iResult > 0)
		{
			cout << recvBuf << endl;
		}
		else
		{

			if (iResult == 0)
			{
				cout << "Server is closed!" << endl;
			}
			else
			{
				cout << WSAGetLastError() << "Recv Error!" << endl;
				return -1;
			}
			break;
		}

		//清空缓存
		memset(recvBuf, 0, 100);
		memset(sendBuf, 0, 100);
	}

	//关闭连接
	closesocket(sock_conn);
	WSACleanup();
	return 0;
}