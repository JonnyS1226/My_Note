#include <Winsock2.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#pragma comment(lib, "ws2_32.lib")
using namespace std;

int main()
{
	int iResult; //用于接收返回信息
	WORD wVersionRequested;
	WSADATA wsaData;

	wVersionRequested = MAKEWORD(1, 1);

	iResult = WSAStartup(wVersionRequested, &wsaData);
	if (iResult != 0) {
		cout << "start error" << endl;
		return -1;
	}

	if (LOBYTE(wsaData.wVersion) != 1 || HIBYTE(wsaData.wVersion) != 1) {
		cout << "version error" << endl;
		WSACleanup();
		return -1;
	}

	SOCKET sockClient = socket(AF_INET, SOCK_DGRAM, 0);
	if (sockClient == INVALID_SOCKET)
	{
		cout << "create error" << endl;
		return -1;
	}

	SOCKADDR_IN addrSrv;
	addrSrv.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");
	addrSrv.sin_family = AF_INET;
	addrSrv.sin_port = htons(1234);

	char recvBuf[100];
	char sendBuf[100];

	int len = sizeof(SOCKADDR);

	while (1)
	{
		cout << "Please input data:" << endl;
		cin >> sendBuf;

		//发送给服务器消息
		iResult = sendto(sockClient, sendBuf, (int)strlen(sendBuf) + 1, 0, (SOCKADDR*)&addrSrv, len);
		if (iResult == SOCKET_ERROR)
		{
			cout << "sendto error" << endl;
			return -1;
		}

		iResult = recvfrom(sockClient, recvBuf, 100, 0, (SOCKADDR*)&addrSrv, &len);
		if (iResult == SOCKET_ERROR)
		{
			cout << "recvfrom error" << endl;
			return -1;
		}
		cout << recvBuf << endl;
	}
	closesocket(sockClient);
	WSACleanup();
	return 0;
}
