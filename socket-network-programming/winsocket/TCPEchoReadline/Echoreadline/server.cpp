/*
* 流式套接字回射服务器接收一行数据：server.cpp
* windows10-vs2017
* by sjy
*/
#include <iostream>
#include <Winsock2.h>
#include "stdio.h"
#include <time.h>
#pragma comment(lib, "WS2_32")
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
			int nErrCode = WSAGetLastError();   // 获取错误代码  
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
	char recvbuf[MAXSIZE];		//缓冲区大小
	char sendbuf[MAXSIZE];		//缓冲区大小
	WSADATA wsd;		//WSADATA变量
	SOCKADDR_IN addr;	//服务器地址
	SOCKADDR_IN Caddr;	//客户端地址
	SOCKET serverSocket;		//服务器套接字

	//初始化套接字动态库
	int iResult;
	iResult = WSAStartup(MAKEWORD(2, 2), &wsd);
	if (iResult != 0) {
		cout << "start error！" << endl;
		return 0;
	}
	if (LOBYTE(wsd.wVersion) != 2 || HIBYTE(wsd.wVersion) != 2) {
		cout << "version error" << endl;
		WSACleanup();
		return 0;
	}

	//创建套接字
	serverSocket = socket(AF_INET, SOCK_STREAM, 0);
	if (serverSocket == INVALID_SOCKET) {
		cout << "socket create error！" << endl;
		WSACleanup();
		return 0;
	}

	//指定服务器地址
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = INADDR_ANY;
	addr.sin_port = htons(12345);

	//绑定
	iResult = bind(serverSocket, (SOCKADDR*)& addr, sizeof(SOCKADDR_IN));
	if (iResult == SOCKET_ERROR) {
		cout << "bind error！" << endl;
		closesocket(serverSocket);
		WSACleanup();
		return 0;
	}

	//监听套接字
	iResult = listen(serverSocket, 3);
	if (iResult == SOCKET_ERROR) {
		cout << "listen error！" << endl;
		closesocket(serverSocket);
		WSACleanup();
		return 0;
	}

	//接受客户端请求
	while (1) {
		cout << "Waiting for the client……" << endl;
		SOCKET clientSocket;		//客户端套接字
		clientSocket = SOCKET_ERROR;
		int len = sizeof(SOCKADDR_IN);
		clientSocket = accept(serverSocket, (SOCKADDR*)&Caddr, &len);
		if (clientSocket == INVALID_SOCKET) {
			cout << "connect error！" << endl;
			return 0;
		}

		//inet_ntoa表示将ip表示为点分十进制形式
		cout << "client connected is：" << inet_ntoa(Caddr.sin_addr) << endl;
		while (1) {
			if (!recvline(clientSocket, recvbuf)) {
				cout << "recv error！" << endl;
				closesocket(clientSocket);
				break;
			}
			cout << "data received：" << recvbuf << endl;
			strcpy_s(sendbuf, "echo:");
			strcat_s(sendbuf, recvbuf);
			cout << "data sent：" << sendbuf << endl;
			iResult = send(clientSocket, sendbuf, strlen(sendbuf), 0);
			if (iResult == SOCKET_ERROR) {
				cout << "send error：" << endl;
				closesocket(clientSocket);
				break;
			}
		}
		closesocket(clientSocket);
	}
	closesocket(serverSocket);
	WSACleanup();

	return 0;
}

