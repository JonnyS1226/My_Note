#include<stdio.h>
#include<iostream>
#include<string.h>
#include<string>
#include<iomanip>
using namespace std;

int *Available;	//可利用资源矢量
int **Max;	//最大需求矩阵
int **Allocation;	//分配矩阵
int **Need;	//需求矩阵
int *securitySequence;
int *securityPid;
int *pid;
int *rid;

int resourceTypeNum;
int processNum;


void show();
bool securityJudge();

void init() {
	cout << "输入进程数：" << endl;
	cin >> processNum;
	securitySequence = new int[processNum];
	securityPid = new int[processNum];
	for (int i = 0; i < processNum; i++)
	{
		securitySequence[i] = 0;
		securityPid[i] = -1;
	}
	cout << "输入资源种类数：" << endl;
	cin >> resourceTypeNum;
	Available = new int[resourceTypeNum];
	cout << "依次输入每种资源的可用个数Available：" << endl;
	for (int i = 0; i < resourceTypeNum; i++)
	{
		cin >> Available[i];
	}
	//为每个进程初始化其max，allocation矩阵
	Max = new int*[processNum];
	Allocation = new int*[processNum];
	Need = new int*[processNum];
	for (int i = 0; i < processNum; i++)
	{
		Max[i] = new int[resourceTypeNum];
		Allocation[i] = new int[resourceTypeNum];
		Need[i] = new int[resourceTypeNum];
	}
	//初始化Allocation
	cout << "输入已分配矩阵Allocation：" << endl;
	for (int i = 0; i < processNum; i++)
		for (int j = 0; j < resourceTypeNum; j++)
			cin >> Allocation[i][j];

	cout << "输入最大需求矩阵Max：" << endl;
	for (int i = 0; i < processNum; i++)
	{
		for (int j = 0; j < resourceTypeNum; j++)
		{
			cin >> Max[i][j];
		}
	}
	//初始化Need矩阵
	for (int i = 0; i < processNum; i++)
	{
		for (int j = 0; j < resourceTypeNum; j++)
		{
			Need[i][j] = Max[i][j] - Allocation[i][j];
		}
	}
	//initShow();
	show();
}


void show() {
	cout << "最大需求矩阵Max : " << endl;
	for (int i = 0; i < processNum; i++)
	{
		cout << "  |";
		for (int j = 0; j < resourceTypeNum; j++)
		{
			cout << "   " << Max[i][j];
		}
		cout << "  |";
		cout << endl;
	}
	cout << endl;
	cout << "分配矩阵Allocation : " << endl;
	for (int i = 0; i < processNum; i++)
	{
		cout << "  |";
		for (int j = 0; j < resourceTypeNum; j++)
		{
			cout << "   " << Allocation[i][j];
		}
		cout << "  |";
		cout << endl;
	}
	cout << endl;
	cout << "需求矩阵Need : " << endl;
	for (int i = 0; i < processNum; i++)
	{
		cout << "  |";
		for (int j = 0; j < resourceTypeNum; j++)
		{
			cout << "   " << Need[i][j];
		}
		cout << "  |";
		cout << endl;
	}
	cout << endl;

	cout << "可利用资源矢量：" << endl;
	for (int i = 0; i < resourceTypeNum; i++)
	{
		cout << "  " << Available[i];
	}
	cout << endl; 
}


bool securityJudge()
{
	for (int i = 0; i < processNum; i++)
	{
		securitySequence[i] = 0;
		securityPid[i] = -1;
	}
	int *tmpAvail = new int[resourceTypeNum];
	for (int i = 0; i < resourceTypeNum; i++)
		tmpAvail[i] = Available[i];
	int flag = 0;
	//外层循环控制依次判断，使安全序列满
	for (int i = 0; i < processNum; i++)
	{
		//内层循环：依次判断每个进程，即各行
		for (int j = 0; j < processNum; j++)
		{
			if (securitySequence[j] == 0)
			{
				//这层循环判断某一Need行是否小于Available向量
				for (int k = 0; k < resourceTypeNum; k++)
				{
					if (Need[j][k] <= tmpAvail[k])
					{
						flag++;
					}
				}
				//符合条件，进安全序列
				if (flag == resourceTypeNum)
				{
					securitySequence[j] = 1;
					securityPid[i] = j;
					//进序列后，释放资源
					for (int k = 0; k < resourceTypeNum; k++)
						tmpAvail[k] += Allocation[j][k];
					flag = 0;
					break;
				}
				flag = 0;
			}
		}
	}

	for (int i = 0; i< processNum; i++)
	{

		if (securitySequence[i] == 0)
		{
			return false;
		}
	}
	cout << "安全序列为：{ ";
	for (int i = 0; i < processNum - 1; i++)
	{
		cout << securityPid[i] << ", ";
	}
	cout << securityPid[processNum - 1] << " } " << endl;
	return true;

}

//Pi表示进程i，Rj表示申请资源j，k表示申请数量
void request(int Pi, int Rj, int k ){
	if (Need[Pi][Rj] < k)
	{
		cout << "申请失败，因为所需要资源数超过进程宣布的最大值" << endl;
	}
	else
	{
		if (k > Available[Rj])
		{
			cout << "申请失败，因为尚无足够资源" << endl;
		}
		else
		{
			Available[Rj] -= k;
			Allocation[Pi][Rj] += k;
			Need[Pi][Rj] -= k;
			if (securityJudge())
			{
				cout << "申请资源成功" << endl;
			}
			else
			{
				Available[Rj] += k;
				Allocation[Pi][Rj] -= k;
				Need[Pi][Rj] += k;
				cout << "申请资源失败，因为申请后不满足安全序列" << endl;
			}
		}
	}
}


void help() {
	cout << "******************** help *********************** " << endl;
	cout << "request Pi, Rj, k   Pi进程申请Rj资源k个" << endl;
	cout << "help                展示帮助界面       " << endl;
	cout << "security            直接调用安全算法，查看安全序列" << endl;
	cout << "show                展示当前所有矩阵情况 " << endl;
	cout << "quit                退出                 " << endl;
	cout << "******************** help *********************** " << endl;
}

void shell() {
	while (1) 
	{
		cout << "shell>";
		string cmd1;
		int cmd2;
		int cmd3;
		int cmd4;
		cin >> cmd1;
		if (cmd1 == "request")
		{
			cin >> cmd2;
			cin >> cmd3;
			cin >> cmd4;
			request(cmd2, cmd3, cmd4);
			show();
		}
		else if (cmd1 == "show")
		{
			show();
		}
		else if (cmd1 == "help")
		{
			help();
		}
		else if (cmd1 == "quit")
		{
			break;
		}
		else if(cmd1 == "security")
		{
			securityJudge();
		}
		else
		{
			cout << "输入有误!" << endl;
			help();
		}
	}
}


int main() {
	init();
	shell();
	show();
	return 0;

}