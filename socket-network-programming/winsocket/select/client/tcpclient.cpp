#include<stdio.h>
#include<stdlib.h>
#include<WinSock2.h>
#include<iostream>

#pragma comment(lib, "Ws2_32.lib")
using namespace std;



int main()
{
	int iResult;
	char sendbuf[100];
	char recvbuf[100];
	WORD wVersionRequested;
	WSADATA wsaData;
	wVersionRequested = MAKEWORD(2, 2);
	iResult = WSAStartup(wVersionRequested, &wsaData);

	SOCKET clientSocket = socket(AF_INET, SOCK_STREAM, 0);
	SOCKADDR_IN addrSrv;
	addrSrv.sin_family = AF_INET;
	addrSrv.sin_port = htons(10000);
	addrSrv.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");

	connect(clientSocket, (struct sockaddr*)&addrSrv, sizeof(clientSocket));

	while (true)
	{
		cout << "please input data: " << endl;
		cin >> sendbuf;
		send(clientSocket, sendbuf, sizeof(sendbuf), 0);
		sprintf(recvbuf, "echo: %s", sendbuf);
		recv(clientSocket, recvbuf, sizeof(recvbuf), 0);
		cout << recvbuf << endl;
	}

	closesocket(clientSocket);
	WSACleanup();
	return 0;

}