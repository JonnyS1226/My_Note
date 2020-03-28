#include<stdio.h>
#include<iostream>
#include<time.h>
#include<iomanip>
#include<string>
#include<queue>
#include<string.h>

using namespace std;
#define maxPart 30

struct wait {
	int pid;
	int apply;
};

//全局变量分配pid
int p = 0;
queue<struct wait> blocklist;
int partNum[maxPart] = { 0 };
int partSize[maxPart] = { 0 };
int partAddr[maxPart] = { 0 };
int partState[maxPart] = { 0 };
int partLen = 10;

//上述数组的初始化
void ds_init() {
	for (int i = 0; i < partLen; i++)
	{
		partNum[i] = i;
	}
}

//初始化内存分区
void mm_init()
{
	srand(time(NULL));
	partAddr[0] = 0;
	for (int i = 0; i < partLen; i++)
	{
		//随机分配1-128内存
		partSize[i] = rand() % 127 + 1;
		partAddr[i + 1] = partAddr[i] + partSize[i];
	}
	//随机分配是否被占用
	srand(time(NULL));
	for (int i = 0; i < rand() % partLen; i++)
	{
		partState[rand() % partLen] = 1;
	}
}

void mm_show(string param) {
	cout << "         -------------------------------------------------------" << endl;
	cout <<setw(15) << "分区号" << setw(15) << "大小(KB)" << setw(15) << "起始地址" << setw(15) << "状态" << endl;
	cout << "         -------------------------------------------------------" << endl;
	char descState[10];
	if (param == "all") {
		for (int i = 0; i < partLen; i++)
		{
			if (partState[i] == 0)
				strcpy(descState, "未分配");
			else
			{
				strcpy(descState, "已分配");
			}
			cout << setw(15) << partNum[i] << setw(15) << partSize[i] << setw(15) << partAddr[i] << setw(15) << descState << endl;
			cout << "         -------------------------------------------------------" << endl;
		}
	}
	else if(param == "yes")
	{
		for (int i = 0; i < partLen; i++)
		{
			if (partState[i] == 0)
			{
				strcpy(descState, "未分配");
				cout << setw(15) << partNum[i] << setw(15) << partSize[i] << setw(15) << partAddr[i] << setw(15) << descState << endl;
				cout << "         -------------------------------------------------------" << endl;
			}
		}
	}
	else if (param == "no")
	{
		for (int i = 0; i < partLen; i++)
		{
			if (partState[i] == 1)
			{
				strcpy(descState, "已分配");
				cout << setw(15) << partNum[i] << setw(15) << partSize[i] << setw(15) << partAddr[i] << setw(15) << descState << endl;
				cout << "         -------------------------------------------------------" << endl;
			}
		}
	}
}

void show_fra() {
	int cntFragment = 0;
	for (int i = 0; i < partLen; i++)
	{
		if (partState[i] == 0 && partSize[i] <= 5)
		{
			cntFragment++;
		}
	}
	cout << "此时碎片（size<=5）个数：" << cntFragment << endl;
}

void mm_cut(int i, int n) {
	//从第i块分割出大小为n的块
	for (int k = partLen; k > i + 1; k--)
	{
		partSize[k] = partSize[k - 1];
		partAddr[k] = partAddr[k - 1];
		partNum[k] = partNum[k - 1] + 1;
		partState[k] = partState[k - 1];
	}
	partSize[i + 1] = partSize[i] - n;
	partAddr[i + 1] = partAddr[i] + n;
	partState[i + 1] = 0;
	partNum[i + 1] = i + 1;
	partSize[i] = n;
	partLen++;
}


//申请n个大小的空间
void mm_request(int n, string method){
	if (method == "FF" || method == "ff")
	{
		int cntFF = 0;
		int i = 0;
		for (i = 0; i < partLen; i++)
		{
			if(partState[i] == 0)
				cntFF++;
			if ((partSize[i] >= n) && (partState[i] == 0))
			{
				partState[i] = 1;
				cout << "分配内存成功,查找次数" << cntFF << endl;
				if (partSize[i] > n)
					mm_cut(i, n);
				show_fra();
				break;
			}
		}
		if (i == partLen)
		{
			cout << "分配内存失败" << endl;
			struct wait process;
			process.pid = p++;
			process.apply = n;
			blocklist.push(process);
			cout << "申请资源大小为" << n << "的进程(pid=" << process.pid << ")已被阻塞" << endl;
		}
			
	}
	if (method == "BF" || method == "bf")
	{
		int minSize = -1;
		int mini;
		int cntBF = 1;
		//找到最小的满足条件的
		for (int i = 0; i < partLen; i++)
		{
			if (n <= partSize[i] && partState[i] == 0)
			{
				minSize = partSize[i];
				mini = i;
			}
		}
		for (int i = 0; i < partLen; i++)
		{
			if (partSize[i] < minSize && partState[i] == 0 && partSize[i] > n)
			{
				minSize = partSize[i];
				mini = i;
			}
		}
		if (minSize == -1)
		{
			cout << "分配内存失败" << endl;
			struct wait process;
			process.pid = p++;
			process.apply = n;
			blocklist.push(process);
			cout << "申请资源大小为" << n << "的进程(pid=" << process.pid << ")已被阻塞" << endl;
		}
		else
		{
			for (int i = 0; i<partLen; i++)           //计算比较次数
			{
				if (partSize[i] < minSize &&partState[i] == 0)
					cntBF++;
			}

			if (n < partSize[mini])
				mm_cut(mini, n);
			partState[mini] = 1;
			cout << "分配内存成功，查找次数: " << cntBF << endl;
			show_fra();
		}
	}
	if (method == "WF" || method == "wf")
	{
		int cntWF = 1;
		int maxSize = -1;
		int maxi = 0;
		//找到最大的满足条件的,即maxi对应的
		for (int i = 0; i < partLen; i++)
		{
			if (n <= partSize[i] && partState[i] == 0)
			{
				maxSize = partSize[i];
				maxi = i;
			}
		}
		for (int i = 0; i < partLen; i++)
		{
			if (partSize[i] > maxSize && partState[i] == 0 && partSize[i] >= n)
			{
				maxSize = partSize[i];
				maxi = i;
			}
		}
		if (maxSize == -1)
		{
			cout << "分配失败" << endl;
			struct wait process;
			process.pid = p++;
			process.apply = n;
			blocklist.push(process);
			cout << "申请资源大小为" << n << "的进程(pid=" << process.pid << ")已被阻塞" << endl;
		}
		else
		{
			for (int i = 0; i<partLen; i++)           //计算比较次数
			{
				if (partSize[i] > maxSize &&partState[i] == 0)
					cntWF++;
			}

			if (n < partSize[maxi])
				mm_cut(maxi, n);
			partState[maxi] = 1;
			cout << "分配内存成功,查找次数" << cntWF << endl;
			show_fra();
		}
	}
}


void mm_release(int i) {
	int flag = 0;
	if (partState[i + 1] == 0 && i < partLen - 1)
	{
		partSize[i] = partSize[i] + partSize[i + 1];
		partState[i] = 0;
		for (int k = i + 1; k < partLen - 1; k++)
		{
			partAddr[k] = partAddr[k + 1];
			partSize[k] = partSize[k + 1];
			partNum[k] = partNum[k + 1] - 1;
			partState[k] = partState[k + 1];
		}
		partLen--;
		flag++;
	}
	if (partState[i - 1] == 0 && i > 0)
	{
		partSize[i - 1] += partSize[i];
		for (int k = i; k < partLen - 1; k++)
		{
			partAddr[k] = partAddr[k + 1];
			partSize[k] = partSize[k + 1];
			partNum[k] = partNum[k + 1] - 1;
			partState[k] = partState[k + 1];
		}
		partLen--;
		flag++;
	}
	int tmp = 0;
	if (!blocklist.empty())
	{
		if (partSize[i] >= blocklist.front().apply)
		{
			tmp = i;
		}
		if (partSize[i - 1] >= blocklist.front().apply)
		{
			tmp = i - 1;
		}
		if (tmp != 0)
		{
			mm_cut(tmp, blocklist.front().apply);
			partState[tmp] = 1;
			cout << "等待队列中第一个申请" << blocklist.front().apply << "大小的资源的进程(pid=" << blocklist.front().pid << ")已得到资源，不再等待" << endl;
			if (!blocklist.empty())
				blocklist.pop();
		}
	}

	if (flag == 0)
		cout << "回收内存失败" << endl;
	else
		cout << "回收内存成功" << endl;
}

void show_blocklist()
{
	if (blocklist.empty())
		cout << "队列为空" << endl;
	else
	{
		for (int i = 0; i < blocklist.size() - 1; i++)
		{
			struct wait tempProcess = blocklist.front();
			cout << "pid:" << tempProcess.pid << " 申请资源大小:" << tempProcess.apply << "	 ----->>  ";
			if (!blocklist.empty())
				blocklist.pop();
			blocklist.push(tempProcess);
		}
		if (!blocklist.empty()) {
			struct wait tempProcess = blocklist.front();
			cout << "pid:" << tempProcess.pid << " 申请资源大小:" << tempProcess.apply << endl;
			if (!blocklist.empty())
				blocklist.pop();
			blocklist.push(tempProcess);
		}
	}
}

void show_help() {
	cout << endl;
	cout << "****************** 	show	help	******************************" << endl;
	cout << "help                   ---   显示指令帮助" << endl;
	cout << "show [all/yes/no]      ---   显示分区表/空闲分区表/已分配分区表" << endl;
	cout << "req unit [FF/BF/WF]    ---   用FF/BF/WF算法，申请分配unit大小的资源" << endl;
	cout << "rel [partid]           ---   释放指定分区号的资源，使之变为未分配" << endl;
	cout << "blocklist              ---   显示当前因为未申请到资源而产生的阻塞队列" << endl;
	cout << "quit                   ---   退出									  " << endl;
	cout << "*********************************************************************" << endl;
	cout << endl;
}


void shell() {
	while (1)
	{
		cout << "shell>";
		string cmd1;
		int cmd2;
		string cmd3;
		cin >> cmd1;
		if (cmd1 == "")
		{
			continue;
		}
		if (cmd1 == "show")
		{
			cin >> cmd3;
			mm_show(cmd3);
		}
		else if (cmd1 == "req")
		{
			cin >> cmd2;
			cin >> cmd3;
			mm_request(cmd2, cmd3);
		}
		else if (cmd1 == "rel")
		{
			cin >> cmd2;
			mm_release(cmd2);
		}
		else if(cmd1 == "blocklist")
		{
			show_blocklist();
		}
		else if (cmd1 == "help")
		{
			show_help();
		}
		else if (cmd1 == "quit")
		{
			break;
		}
		else
		{
			cout << "input error" << endl;
			show_help();
		}
	}
}

void init() {
	ds_init();
	mm_init();
	show_help();
}

int main()
{
	init();
	shell();
	return 0;
}