#include<Winsock2.h>
#include<iostream>
#include <windows.h>
#pragma comment (lib,"ws2_32.lib")
using namespace std;

int port = 10000;

DWORD WINAPI IOThread(LPVOID lpParam) {
	//由于udp无连接，每一次的新线程都要重新绑定
	cout << endl;
	char recvbuf[576];		//接收缓冲区大小
	char sendbuf[576];		//发送缓冲区大小
	SOCKADDR_IN sinaddr;
	SOCKET  clientSocket;	//客户端套接字
	clientSocket = socket(AF_INET, SOCK_DGRAM, 0);
	if (clientSocket == SOCKET_ERROR) {
		cout << "create socket error" << endl;
		closesocket(clientSocket);
		return 0;
	}

	//设置地址，其中端口是主函数中不断递增设置的端口号
	sinaddr.sin_family = AF_INET;
	sinaddr.sin_addr.s_addr = INADDR_ANY;
	sinaddr.sin_port = htons(port);
	cout << "分配端口号为： " << port << endl;

	int len = sizeof(SOCKADDR_IN);

	//绑定套接字
	int iResult = bind(clientSocket, (SOCKADDR*)&sinaddr, sizeof(SOCKADDR_IN));
	if (iResult == SOCKET_ERROR) {
		cout << "bind error" << endl;
		closesocket(clientSocket);
		system("pause");
		return 0;
	}

	while (1) {
		//新线程，也是先接收再发送
		iResult = recvfrom(clientSocket, recvbuf, sizeof(recvbuf), 0, (SOCKADDR*)&sinaddr, &len);
		if (iResult == SOCKET_ERROR) {
			cout << "recvfrom error" << endl;
			break;
		}
		cout << "data received:" <<recvbuf << endl;

		sprintf_s(sendbuf, "echo : %s", recvbuf);
		iResult = sendto(clientSocket, sendbuf, strlen(sendbuf) + 1, 0, (SOCKADDR*)&sinaddr, len);
		if (iResult == SOCKET_ERROR) {
			cout << "sendtoerror" << endl;
			break;
		}
		cout << "data sent:" << sendbuf << endl;
	}
	closesocket(clientSocket);
	system("pause");
	return 0;
}

int main() {
	WSADATA wsd;
	SOCKET sockSrv;
	//SOCKET datasocket;
	SOCKADDR_IN addrSrv;
	char recvbuf[576];
	char sendbuf[576];
	HANDLE  hThread;	//新线程
	int result;
	result = WSAStartup(MAKEWORD(2, 2), &wsd);
	if (result != 0) {
		cout << "start error！" << endl;
		system("pause");
		return 0;
	}
	if (LOBYTE(wsd.wVersion) != 2 || HIBYTE(wsd.wVersion) != 2) {
		cout << "version error！" << endl;
		WSACleanup();
		system("pause");
		return 0;
	}

	//创建套接字
	sockSrv = socket(AF_INET, SOCK_DGRAM, 0);
	if (sockSrv == SOCKET_ERROR) {
		cout << "创建套接字失败！" << endl;
		WSACleanup();
		system("pause");
		return 0;
	}

	//指定地址
	addrSrv.sin_family = AF_INET;
	addrSrv.sin_addr.s_addr = INADDR_ANY;
	addrSrv.sin_port = htons(10000);

	//绑定套接字
	result = bind(sockSrv, (SOCKADDR*)&addrSrv, sizeof(SOCKADDR_IN));
	if (result == SOCKET_ERROR) {
		cout << "bind error！" << endl;
		closesocket(sockSrv);
		WSACleanup();
		system("pause");
		return 0;
	}

	SOCKADDR_IN addrClt;
	int len = sizeof(SOCKADDR_IN);
	char temp[1000];

	while (true) {
		cout << "waiting for the data" << endl;
		//服务器先recv一次，得到连接信息，来分配端口
		int recvs = recvfrom(sockSrv, recvbuf, sizeof(recvbuf), 0, (SOCKADDR*)&addrClt, &len);
		if (recvs == SOCKET_ERROR) {
			cout << "recvfrom error" << endl;
			closesocket(sockSrv);
		}

		//分配端口
		port++;
		sprintf_s(sendbuf, "%d", port);
		int sed = sendto(sockSrv, sendbuf, strlen(sendbuf) + 1, 0, (SOCKADDR*)&addrClt, len);
		if (sed == SOCKET_ERROR) {
			cout << "send error" << endl;
			closesocket(sockSrv);
		}
		//新线程的创建
		hThread = CreateThread(NULL, 0, IOThread, (LPVOID)sockSrv, 0, NULL);
		if (hThread == NULL)
		{
			cout << "new thread error！" << endl;
		}
		else
		{
			cout << "new thread success！" << endl;
		}
		Sleep(1000);
	}
	closesocket(sockSrv);
	WSACleanup();
	system("pause");
	return 0;
}
