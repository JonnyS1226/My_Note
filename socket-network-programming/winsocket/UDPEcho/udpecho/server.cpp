#include <Winsock2.h>
#include <stdio.h>
#include<stdlib.h>
#pragma comment(lib, "ws2_32.lib")
#include<iostream>
using namespace std;

int main()
{
	WORD wVersionRequested;
	WSADATA wsaData;
	int iResult;

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
	SOCKET sockSrv = socket(AF_INET, SOCK_DGRAM, 0);
	if (sockSrv == INVALID_SOCKET)
	{
		cout << "create error" << endl;
		return -1;
	}

	SOCKADDR_IN addrSrv;
	addrSrv.sin_addr.S_un.S_addr = htonl(INADDR_ANY);
	addrSrv.sin_family = AF_INET;
	addrSrv.sin_port = htons(1234);

	bind(sockSrv, (SOCKADDR*)&addrSrv, sizeof(SOCKADDR));

	char recvBuf[100];
	char sendBuf[100];

	SOCKADDR_IN addrClient;
	int len = sizeof(SOCKADDR);

	while (1)
	{
		//调用成功后，会将本次的来源地址写入addrClient中
		iResult = recvfrom(sockSrv, recvBuf, 100, 0, (SOCKADDR*)&addrClient, &len);
		if (iResult == SOCKET_ERROR)
		{
			cout << "recvfrom error" << endl;
			return -1;
		}

		//cout << "client: " << inet_ntoa(addrClient.sin_addr) << endl;
		cout << "data received:" << recvBuf << endl;
		sprintf(sendBuf, "echo:%s", recvBuf);

		cout << "data sent:" << sendBuf << endl;
		iResult = sendto(sockSrv, sendBuf, strlen(sendBuf) + 1, 0, (SOCKADDR*)&addrClient, len);
		if (iResult == SOCKET_ERROR)
		{
			cout << "sendto error" << endl;
			return -1;
		}

		if (strcmp("q", recvBuf) == 0)
		{
			cout << "finish" << endl;
			break;
		}
	}
	closesocket(sockSrv);
	WSACleanup();
	system("pause");
	return 0;
}
