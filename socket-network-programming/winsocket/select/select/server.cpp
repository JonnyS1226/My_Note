#include<winsock2.h>
#include<stdio.h>
#include<iostream>
#pragma comment(lib, "Ws2_32.lib")
using namespace std;

#define tcpPort 10000
#define udpPort 11000

int main()
{
	WORD wVersionRequested;
	WSADATA wsaData;
	int iResult;
	HANDLE hThread;
	char recvBuf[100];
	char sendBuf[100];
	//预先创建tcp连接套接字
	SOCKET tcpConnSock = INVALID_SOCKET;

	//初始化动态链接库
	wVersionRequested = MAKEWORD(1, 1);
	iResult = WSAStartup(wVersionRequested, &wsaData);
	if (iResult != 0)
	{
		cout << "start error" << endl;
		return -1;
	}
	if (LOBYTE(wsaData.wVersion) != 1 || HIBYTE(wsaData.wVersion) != 1)
	{
		cout << "version error" << endl;
		WSACleanup();
		return -1;
	}

	//tcp用于监听的套接字
	SOCKET tcpServerSock = socket(AF_INET, SOCK_STREAM, 0);
	if (tcpServerSock == INVALID_SOCKET)
	{
		cout << "SOCKET tcp error" << endl;
		WSACleanup();
		return -1;
	}

	//设置地址 为tcp
	SOCKADDR_IN addrSrvTCP;
	addrSrvTCP.sin_family = AF_INET;
	addrSrvTCP.sin_port = htonl(tcpPort);
	addrSrvTCP.sin_addr.S_un.S_addr = htonl(INADDR_ANY);
	int lenSrv = sizeof(SOCKADDR_IN);

	//绑定地址 tcp
	iResult = bind(tcpServerSock, (struct sockaddr*)&addrSrvTCP, sizeof(addrSrvTCP));

	//监听 tcp
	iResult = listen(tcpServerSock, 5);

	//创建udp套接字
	SOCKET udpServerSock = socket(AF_INET, SOCK_DGRAM, 0);

	//设置地址 为udp
	SOCKADDR_IN addrSrvUDP;
	addrSrvUDP.sin_addr.S_un.S_addr = htonl(INADDR_ANY);
	addrSrvUDP.sin_family = AF_INET;
	addrSrvUDP.sin_port = htonl(udpPort);
	iResult = bind(udpServerSock, (struct sockaddr*)&addrSrvUDP, sizeof(addrSrvUDP));

	cout << "tcp端口为" << tcpPort << endl;
	cout << "udp端口为" << udpPort << endl;
	
	//构建套接字组
	fd_set fdRead, fdSocket;
	FD_ZERO(&fdSocket);
	FD_SET(tcpServerSock, &fdSocket);
	FD_SET(udpServerSock, &fdSocket);

	//开始接收
	while (true)
	{
		fdRead = fdSocket;
		//阻塞模式，超时时间也可以设置为NULL
		iResult = select(0, &fdRead, NULL, NULL, NULL);
		//正常则返回一个大于0的数，这个数是发生网络事件的套接字总和
		if (iResult > 0)
		{
			//有网络事件发生，确定有哪些套接字有未决的IO，并进一步处理
			for (int i = 0; i < (int)fdSocket.fd_count; i++)
			{
				if (FD_ISSET(fdSocket.fd_array[i], &fdRead))
				{
					//tcp监听套接字有连接请求
					if (fdSocket.fd_array[i] == tcpServerSock)
					{
						if (fdSocket.fd_count < FD_SETSIZE)
						{
							tcpConnSock = accept(tcpServerSock, (struct sockaddr*)&addrSrvTCP, &lenSrv);

							//把tcp连接套接字再次加入套接字组
							FD_SET(tcpConnSock, &fdSocket);
							cout << "收到新的连接请求：" << inet_ntoa(addrSrvTCP.sin_addr);
						}
						else
						{
							cout << "连接数量过多" << endl;
							continue;
						}
					}
					//有tcp连接套接字发生事件
					else if (fdSocket.fd_array[i] == tcpConnSock)
					{
						cout << "tcp连接。服务器为" << inet_ntoa(addrSrvTCP.sin_addr) << endl;
						memset(recvBuf, 0, 100);
						iResult = recv(fdSocket.fd_array[i], recvBuf, 100, 0);
						//处理不同返回值
						//大于0成功接收
						if (iResult > 0)
						{
							cout << recvBuf << endl;
							sprintf(sendBuf, "echo: %s", recvBuf);
							cout << sendBuf << endl;
							iResult = send(fdSocket.fd_array[i], sendBuf, 100, 0);
						}
						//等于0连接关闭
						else if (iResult == 0)
						{
							cout << "连接关闭中......" << endl;
							closesocket(fdSocket.fd_array[i]);
							FD_CLR(fdSocket.fd_array[i], &fdSocket);
						}
						//小于0接受失败
						else
						{
							cout << "recv error" << endl;
							closesocket(fdSocket.fd_array[i]);
							FD_CLR(fdSocket.fd_array[i], &fdSocket);
						}
					}
					//udp传输
					else
					{
						memset(recvBuf, 0, 100);
						cout << "udp数据。服务器为 " << inet_ntoa(addrSrvTCP.sin_addr) << endl;
						recvfrom(udpServerSock, recvBuf, 100, 0, (struct sockaddr*)&addrSrvUDP, &lenSrv);
						sprintf(sendBuf, "echo:%s", recvBuf);
						sendto(udpServerSock, sendBuf, 100, 0, (struct sockaddr*)&addrSrvUDP, lenSrv);
					}
				}
				else
				{
					cout << "select error" << endl;
					break;
				}
			}
		}
		closesocket(tcpConnSock);
		closesocket(tcpServerSock);
		closesocket(udpServerSock);
		WSACleanup();
		return 0;
	}
}