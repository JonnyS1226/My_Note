#include<stdio.h>
#include<iostream>
#include<vector>
#include<math.h>
#include<algorithm>    
#include<time.h>
#include<string>
#include<string.h>
using namespace std;

int *inputList;
vector<int> fcfsList;
vector<int> sstfList;
vector<int> scanList;
int trackNum;
int nowLocation;

void init(string choice)
{
	cout << "****************** 生成磁道号 **********************：" << endl;

	if (choice == "manual")
	{
		cout << "请输入一共的磁道个数：" << endl;
		cin >> trackNum;
		inputList = new int[trackNum];
		cout << "依次输入磁道号（1-200）：" << endl;
		for (int i = 0; i < trackNum; i++)
		{
			cin >> inputList[i];
		}
		cout << "手动输入的磁道序列为：" << endl;
		for (int i = 0; i < trackNum; i++)
		{
			cout << inputList[i] << "\t";
		}
		cout << endl;
		cout << "输入当前磁头位置（1-200）：" << endl;
		cin >> nowLocation;
	}
	else if (choice == "auto")
	{
		cout << "请输入一共的磁道个数：" << endl;
		cin >> trackNum;
		inputList = new int[trackNum];
		srand(time(NULL));
		for (int i = 0; i < trackNum; i++)
		{
			inputList[i] = rand() % 200 + 1;
		}
		nowLocation = rand() % 200 + 1;
		cout << "随机产生的磁道序列为：" << endl;
		for (int i = 0; i < trackNum; i++)
		{
			cout << inputList[i] << "\t";
		}
		cout << endl;
		cout << "当前磁头为： " << nowLocation << endl;
	}
}

float fcfs() {
	cout << endl;
	cout << "****************** fcfs 算法 **********************" << endl;
	float fcfsMoveNum = 0;
	float avgNum = 0;
	for (int i = 0; i < trackNum; i++)
	{
		fcfsList.push_back(inputList[i]);
	}
	cout << "该算法的寻道序列为：" << endl;
	for (int i = 0; i < fcfsList.size(); i++)
	{
		cout << fcfsList[i] << "\t";
	}
	cout << endl;
	for (int i = 0; i < fcfsList.size(); i++)
	{
		fcfsMoveNum += abs(fcfsList[i] - nowLocation);
		nowLocation = fcfsList[i];
	}
	cout << "该算法的总移臂距离为：" << int(fcfsMoveNum) << endl;
	cout << "该算法的平均移臂距离为：" << float(fcfsMoveNum / trackNum) << endl;
	fcfsList.swap(vector<int>());
	return float(fcfsMoveNum / trackNum);

}


float sstf() {
	cout << endl;
	cout << "****************** sstf 算法 **********************" << endl;
	
	float sstfMoveNum = 0;
	int nextLocationNum = nowLocation;
	int tmpMin = 200;
	int delta;
	int nextLocation = 0;
	int *flag;
	flag = new int[trackNum];
	while (sstfList.size() != trackNum)
	{
		for(int i = 0; i < trackNum; i++)
		{
			if (flag[i] != 1)
			{
				delta = abs(nextLocationNum - inputList[i]);
				if (delta < tmpMin)
				{
					tmpMin = delta;
					nextLocation = i;
				}
			}
		}
		sstfList.push_back(inputList[nextLocation]);
		flag[nextLocation] = 1;
		nextLocationNum = inputList[nextLocation];
		tmpMin = 200;
	}
	cout << "该算法的寻道序列为：" << endl;
	for (int i = 0; i < sstfList.size(); i++)
	{
		cout << sstfList[i] << "\t";
	}
	cout << endl;
	for (int i = 0; i < sstfList.size(); i++)
	{
		sstfMoveNum += abs(sstfList[i] - nowLocation);
		nowLocation = sstfList[i];
	}
	cout << "该算法的总移臂距离为：" << int(sstfMoveNum) << endl;
	cout << "该算法的平均移臂距离为：" << float(sstfMoveNum / trackNum) << endl;
	sstfList.swap(vector<int>());
	return float(sstfMoveNum / trackNum);

}


//默认先向右的scan
float scan() {
	cout << endl;
	cout << "****************** scan 算法 **********************" << endl;
	float scanMoveNum = 0;
	int storeLocation = nowLocation;
	int *tmpList;
	tmpList = new int[trackNum];
	for (int i = 0; i < trackNum; i++)
	{
		tmpList[i] = inputList[i];
	}
	sort(tmpList, tmpList + trackNum);
	int min = tmpList[0];
	int max = tmpList[trackNum - 1];
	int p = 0;
	if (nowLocation <= min)
	{
		for (int i = 0; i < trackNum; i++)
		{
			scanList.push_back(tmpList[i]);
		}
	}
	else if (nowLocation >= max)
	{
		for (int i = trackNum - 1; i >= 0; i--)
		{
			scanList.push_back(tmpList[i]);
		}
	}
	else if(nowLocation > min && nowLocation < max)
	{
		while (tmpList[p + 1] <= nowLocation )
		{
			p++;
		}
		for (int i = p + 1; i < trackNum; i++)
			scanList.push_back(tmpList[i]);
		for (int i = p; i >= 0; i--)
			scanList.push_back(tmpList[i]);
	}
	cout << "该算法的寻道序列为：" << endl;
	for (int i = 0; i < scanList.size(); i++)
	{
		cout << scanList[i] << "\t";
	}
	cout << endl;
	for (int i = 0; i < scanList.size(); i++)
	{
		scanMoveNum += abs(scanList[i] - nowLocation);
		nowLocation = scanList[i];
	}
	cout << "该算法的总移臂距离为：" << int(scanMoveNum) << endl;
	cout << "该算法的平均移臂距离为：" << float(scanMoveNum / trackNum) << endl;
	scanList.swap(vector<int>());
	return float(scanMoveNum / trackNum);
}

void compare() {
	float avgFCFS;
	float avgSSTF;
	float avgSCAN;
	
	string cmd = "auto";
	for (int i = 0; i < 3; i++)
	{
		cout << "随机初始化" << endl;
		init(cmd);
		int storeLocation = nowLocation;
		cout << endl;
		nowLocation = storeLocation;
		avgFCFS = fcfs();
		nowLocation = storeLocation;
		avgSSTF = sstf();
		nowLocation = storeLocation;
		avgSCAN = scan();
		cout << endl;
	}
	cout << "三种算法连续试验三次，平均移臂距离为：" << endl;
	cout << "FCFS算法：           " << avgFCFS << endl;
	cout << "SSTF算法：           " << avgSSTF << endl;
	cout << "SCAN算法：           " << avgSCAN << endl;
}
void help() {
	cout << endl;
	cout << "************************ help ********************************" << endl;
	cout << "1. init		           手动模式（手动初始化，手动选择算法）" << endl;
	cout << "2. fcfs/sstf/scan	   手动模式下选择三种调度算法		       " << endl;
	cout << "3. auto			   全自动模式（自动初始化，并测试三种算法）" << endl;
	cout << "4. help			   展示指令帮助界面                        " << endl;
	cout << "4. quit			   退出                                    " << endl;
	cout << "************************ help ********************************" << endl;
	cout << endl;
}

void shell() {
	while (true)
	{
		help();
		cout << "shell>";
		string cmd1;
		int cmd2;
		int cmd3;
		int cmd4;
		cin >> cmd1;
		if (cmd1 == "init")
		{
			init("manual");
		}
		else if (cmd1 == "fcfs")
		{
			fcfs();
		}
		else if (cmd1 == "sstf")
		{
			sstf();
		}
		else if (cmd1 == "scan")
		{
			scan();
		}
		else if (cmd1 == "auto")
		{
			compare();
		}
		else if (cmd1 == "help")
		{
			help();
		}
		else if (cmd1 == "quit")
		{
			break;
		}
		else
		{
			cout << "输入有误!" << endl;
			help();
		}
	}
}

int main() {
	shell();
}