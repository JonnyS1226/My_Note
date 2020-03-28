#include<stdlib.h>
#include<stdio.h>
#include<iostream>
#include<WinSock2.h>

#pragma comment(lib, "ws2_32.lib")

using namespace std;

int main()
{
	int iResult;
	char sendbuf[100];
	char recvbuf[100];
	WORD wVersionRequested;
	WSADATA wsa;
	wVersionRequested = MAKEWORD(2, 2);
	iResult = WSAStartup(wVersionRequested, &wsa);

	SOCKET clientSocket = socket(AF_INET, SOCK_DGRAM, 0);
	SOCKADDR_IN addrSrv;
	addrSrv.sin_family = AF_INET;
	addrSrv.sin_port = htons(11000);
	addrSrv.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");

	SOCKADDR_IN addrClient;
	int len = sizeof(SOCKADDR_IN);
	while (true)
	{
		cout << "please input data :" << endl;
		cin >> sendbuf;
		sendto(clientSocket, sendbuf, sizeof(sendbuf), 0, (struct sockaddr*)&addrSrv, len);
		sprintf(recvbuf, "echo: %s", sendbuf);
		recvfrom(clientSocket, recvbuf, sizeof(recvbuf), 0, (struct sockaddr*)&addrClient, &len);
		cout << recvbuf << endl;
	}
	closesocket(clientSocket);
	WSACleanup();
	return 0;

}