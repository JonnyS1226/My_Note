/*
* 流式套接字并发服务器：client.cpp
* windows10-vs2017
* by sjy
*/
#include <iostream>
#include <string>
#include <Winsock2.h>
#pragma comment(lib, "WS2_32")
using namespace std;

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
	//创建套接字
	SOCKET sockClient = socket(AF_INET, SOCK_STREAM, 0);

	SOCKADDR_IN addrSrv;
	addrSrv.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");
	addrSrv.sin_family = AF_INET;
	addrSrv.sin_port = htons(1234);

	if (connect(sockClient, (SOCKADDR*)&addrSrv, sizeof(SOCKADDR)) != 0)
	{
		cout << "connect error！" << endl;;
		WSACleanup();
		return 0;
	}
	char sendBuf[100];

	while (1)
	{
		cout << "Please input data：";
		cin >> sendBuf;
		send(sockClient, sendBuf, strlen(sendBuf)+1, 0);
		if ((strcmp("q", sendBuf) == 0))
		{
			cout << "finish input" << endl;
			break;
		}
		//cout << sendBuf << endl;
		char recvBuf[300];
		recv(sockClient, recvBuf, 300, 0);
		cout << recvBuf << endl;
	}


	closesocket(sockClient);
	WSACleanup();
	return 0;
}