#include <stdio.h>
#include <winsock2.h>
#include <string.h>
#include <iostream>
#pragma comment(lib, "ws2_32.lib") 
using namespace std;

int main(int argc, char* argv[])
{
	WSADATA wsaData;
	WORD sockVersion = MAKEWORD(2, 2);
	char recvData[255] = "";
	char sendData[1024] = "";
	char number[3] = "";
	int size = 0;	//缓冲区大小
	int receive = 0;	//接收到包数
	int cnt = 0;	//记录尝试接收的包个数
	if (WSAStartup(sockVersion, &wsaData) != 0)
	{
		cout << "start error" << endl;
		system("pause");
		return 0;
	}

	SOCKET sockSrv = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (sockSrv == INVALID_SOCKET)
	{
		cout << "create error !" << endl;
		system("pause");
		return 0;
	}

	sockaddr_in serAddr;
	serAddr.sin_family = AF_INET;
	serAddr.sin_port = htons(6000);
	serAddr.sin_addr.S_un.S_addr = INADDR_ANY;
	if (bind(sockSrv, (sockaddr *)&serAddr, sizeof(serAddr)) == SOCKET_ERROR)
	{
		cout << "bind error !" << endl;
		closesocket(sockSrv);
		system("pause");
		return 0;
	}

	sockaddr_in addrClient;

	int nAddrLen = sizeof(addrClient);
	int ret = recvfrom(sockSrv, number, 3, 0, (sockaddr *)&addrClient, &nAddrLen);
	if (ret > 0)
	{
		recvData[ret] = 0x00;
		printf("客户为：%s \r\n", inet_ntoa(addrClient.sin_addr));
	}
	cout << "客户发送报文个数为： " << number << endl;

	//获得系统默认的缓冲区大小
	int len = sizeof(size);

	//字符串转换为整型
	int n = atoi(number);
	cout << "设置服务器端的接收缓冲区字节数" << endl;
	cin >> size;

	//套接字选项中设置接收缓冲区大小
	if (setsockopt(sockSrv, SOL_SOCKET, SO_RCVBUF, (const char *)&size, len) < 0)
	{
		cout << "设置套接字信息失败" << endl;
		return -1;
	}
	if (getsockopt(sockSrv, SOL_SOCKET, SO_RCVBUF, (char *)&size, &len) < 0)
	{
		cout << "获取套接字信息失败" << endl;
		return -1;
	}
	cout << "设置后的系统接收缓存大小: " << size << endl;

	int time; int tlen = sizeof(time);
	cout << "设置服务端的超时时间（ms）" << endl;
	cin >> time;

	//套接字选项中设置超时时间
	if (setsockopt(sockSrv, SOL_SOCKET, SO_RCVTIMEO, (const char *)&time, tlen) < 0)
	{
		cout << "设置套接字信息失败" << endl;
		return -1;
	}
	if (getsockopt(sockSrv, SOL_SOCKET, SO_RCVTIMEO, (char *)&time, &tlen) < 0)
	{
		cout << "获取套接字信息失败" << endl;
		return -1;
	}
	cout << "设置后的系统接收超时时间: " << time << endl;

	int sleepTime;
	cout << "请输入接收后延迟时间：";
	cin >> sleepTime;
	cout << "设置参数完成，等待接收................" << endl;

	while (1)
	{
		int ret = recvfrom(sockSrv, recvData, size, 0, (sockaddr *)&addrClient, &nAddrLen);
		cnt++;
		//大于0代表成功接收
		if (ret>0){
			receive++;
			cout << "第" << receive << "个包接收成功" << endl;
		}
		//所有包都尝试接收了
		if (cnt == n)
			break;
		Sleep(sleepTime);
	}

	//结果输出部分
	cout << "一共包个数：" << n << endl;
	cout << "收到包个数为" << receive << endl;
	float t = 1 - ((float)receive / (float)n);
	cout << "丢包率" << t << endl;
	closesocket(sockSrv);
	WSACleanup();
	system("pause");
	return 0;
}

