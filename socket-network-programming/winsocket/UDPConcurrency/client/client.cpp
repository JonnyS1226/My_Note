#include <Winsock2.h>
#include <stdio.h>
#pragma comment(lib, "ws2_32.lib")
#include<iostream>
using namespace std;

int main()
{
	WORD wVersionRequested;
	WSADATA wsaData;
	int err;

	wVersionRequested = MAKEWORD(2, 2);

	err = WSAStartup(wVersionRequested, &wsaData);
	if (err != 0) {
		return -1;
	}

	if (LOBYTE(wsaData.wVersion) != 2 ||
		HIBYTE(wsaData.wVersion) != 2) {
		WSACleanup();
		return -1;
	}

	SOCKET sockClient = socket(AF_INET, SOCK_DGRAM, 0);

	SOCKADDR_IN addrSrv;
	addrSrv.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");
	addrSrv.sin_family = AF_INET;
	addrSrv.sin_port = htons(10000);

	char recvBuf[576];
	char sendBuf[576];
	char tempBuf[1024];

	int len = sizeof(SOCKADDR_IN);
 
	cout << "Please input any key to get port：" << endl;
	cin >> sendBuf;
	int iResult = sendto(sockClient, sendBuf, strlen(sendBuf) + 1, 0, (SOCKADDR*)&addrSrv, len);
	if (iResult == SOCKET_ERROR) {
		cout << "sendto error" << endl;
		closesocket(sockClient);
		WSACleanup();
		return 0;
	}
	//接收服务器分配给客户的端口
	int rec = recvfrom(sockClient, recvBuf, sizeof(recvBuf), 0, (SOCKADDR*)&addrSrv, &len);
	if (rec == SOCKET_ERROR) {
		cout << "recvfrom error" << endl;
		closesocket(sockClient);
		WSACleanup();
		return 0;
	}
	
	//设置端口
	cout << endl;
	string adr = recvBuf;
	int port = atoi(adr.c_str());			//字符串转整型
	SOCKADDR_IN addrs;
	addrs.sin_family = AF_INET;
	addrs.sin_port = htons(port);
	addrs.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");

//	cout << "服务器IP:" << inet_ntoa(addrs.sin_addr) << endl;
	cout << "服务器端口:" << ntohs(addrs.sin_port) << endl;
	ZeroMemory(sendBuf, sizeof(recvBuf));
	ZeroMemory(sendBuf, sizeof(sendBuf));
	while (1)
	{
		printf("please input data:\n");
		cin >> sendBuf;
		if (sendBuf[0] == 'q') {
			cout << "finish input！" << endl;
			break;
		}
		int sed = sendto(sockClient, sendBuf, strlen(sendBuf) + 1, 0, (SOCKADDR*)&addrs, len);
		if (sed == SOCKET_ERROR) {
			cout << "sendto error" << endl;
			break;
		}
		int rec = recvfrom(sockClient, recvBuf, 100, 0, (SOCKADDR*)&addrs, &len);
		if (rec == SOCKET_ERROR) {
			cout << "recvfrom error" << endl;
			break;
		}
		cout << recvBuf << endl;
	}
	closesocket(sockClient);
	WSACleanup();
	system("pause");
	return 0;
}