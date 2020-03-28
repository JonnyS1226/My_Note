
#include <iostream>
#include <queue>
#include <string>
#include <sstream>
using namespace std;

class Process* processes[20]; // pid表
class Resource* resources[20]; // rid表
vector<class Process*> readyList[3];	//进程就绪队列
vector<class Process*> blockList;		//进程阻塞队列
const char* priority_names[] = { "INIT","USER","SYSTEM" };
const char* status_names[] = { "READY","BLOCK","RUNNING" };
Process* pRunning = nullptr;	//当前运行进程

void scheduler();	//调度函数
void createResource(string inputParam);	//资源创建函数，初始化用到
void cr(string inputParam);				//进程创建函数

class Process {
public:
	string pName;
	struct PCB { 
		int pid;
		struct usedR {
			Resource* rs;
			int occupation;
		};
		vector<usedR*> usedResource; // 要使用的资源
		enum PCB_STATUS {
			READY, BLOCK, RUNNING
		} status;
		int blockRID = -1; //申请资源时导致阻塞的rid
		class Process* parent; 
		vector<class Process*> child; 
		enum PCB_PRIORITY {
			INIT, USER, SYSTEM
		} priority;
	} *pcb;
	Process(string pName, int pid) {
		this->pName = pName;
		this->pcb = new PCB;
		this->pcb->pid = pid;
		this->pcb->status = PCB::PCB_STATUS::READY;
		this->pcb->parent = nullptr;
		this->pcb->priority = PCB::PCB_PRIORITY::USER;
	}

};

class Resource {
public:
	string resource_name;
	struct RCB { // Resource Control Block
		int rid;
		int totalResource; 
		int available;
		struct struc_wt {
			Process* ps;
			int occupation;
		};
		vector<struc_wt*> waiting_list;	//等待该资源的进程队列
	} *rcb;
	Resource(string name, int rid, int totalResource) {
		this->resource_name = name;
		this->rcb = new RCB;
		this->rcb->rid = rid;
		this->rcb->totalResource = totalResource;
		this->rcb->available = totalResource;
	}
	~Resource() {
		delete(this->rcb);
		this->rcb = nullptr;
	}
};

vector<string> split(string& s, char delim) {
	vector<string> result;
	stringstream ss(s);
	string item;
	while (getline(ss, item, delim)) {
		result.push_back(item);
	}
	return result;
}

string get_param(string command) {
	if (command.find(' ') == -1) return "";
	return command.substr(command.find(' ') + 1);
}

void init() {
	createResource("R1 3");
	createResource("R2 3");
	createResource("R3 3");
	cr("init 0");
	cout << "初始化完成，已有init进程在运行" << endl << endl;
}

//时间到期
void to() {
	pRunning->pcb->status = Process::PCB::PCB_STATUS::READY;
	readyList[pRunning->pcb->priority].push_back(pRunning);
	pRunning = nullptr;
	scheduler();
}


void cr(string inputParam) {
	vector<string> splits = split(inputParam, ' ');
	int pr = stoi(splits[1]);
	Process::PCB::PCB_PRIORITY priority;
	switch (pr) {
	case 0:
		priority = Process::PCB::PCB_PRIORITY::INIT;
		break;
	case 1:
		priority = Process::PCB::PCB_PRIORITY::USER;
		break;
	case 2:
		priority = Process::PCB::PCB_PRIORITY::SYSTEM;
		break;
	default:
		cout << "优先级在0-2之间" << endl;
		return;
	}
	int pid = -1;
	if (splits.size() == 3) {
		pid = stoi(splits[2]);
		if (processes[pid]) {
			cout << "进程pid已存在" << endl;
			return;
		}
	}
	else {
		for (int i = 0; i < 20; i++) {
			if (!processes[i]) {
				pid = i;
				break;
			}
		}
	}
	Process* newProcess = new Process(splits[0], pid);
	newProcess->pcb->parent = pRunning;
	newProcess->pcb->status = Process::PCB::PCB_STATUS::READY;
	newProcess->pcb->priority = priority;
	if (pRunning) {
		pRunning->pcb->child.push_back(newProcess);			//新进程是当前运行进程的子进程
	}
	readyList[pr].push_back(newProcess);
	processes[pid] = newProcess;
	cout << "创建成功：进程名：" << splits[0] << "， pid：" << pid << "" << endl;
	scheduler();
	return;
}

void req(string inputParam) {
	cout << "************************************************" << endl;
		if (pRunning == nullptr) {
			cout << "No process is running." << endl;
			return;
		}
		vector<string> splits = split(inputParam, ' ');
		int tmp = splits.size();
		int units = 0;
		switch (tmp) {
		case 1:
			units = 1;
			break;
		case 2:
			units = stoi(splits[1]);
			break;
		}

		int rid = stoi(splits[0]);
		Resource* rs = resources[rid];
		int idx = -1, resourceHave = 0;
		for (auto _rs : pRunning->pcb->usedResource) {
			idx++;
			if (_rs->rs->rcb->rid == rid) {
				resourceHave = _rs->occupation;
				break;
			}
		}
		if (units + resourceHave > rs->rcb->totalResource) {
			cout << "资源数不够" << endl;
			return;
		}

		//分配资源
		if (units <= rs->rcb->available) {
			rs->rcb->available -= units;
			if (resourceHave == 0) {
				Process::PCB::usedR* struc = new Process::PCB::usedR;
				struc->occupation = units;
				struc->rs = rs;
				pRunning->pcb->usedResource.push_back(struc);
			}
			else {
				pRunning->pcb->usedResource[idx]->occupation += units;
			}
			cout << "进程 " << pRunning->pName << "(pid:" << pRunning->pcb->pid
				<< ") 现在有： " << units + resourceHave << " " << rs->resource_name << "(rid:" << rs->rcb->rid << ")" << endl;
		}
		else {
			//资源不够分则阻塞
			pRunning->pcb->status = Process::PCB::PCB_STATUS::BLOCK;
			pRunning->pcb->blockRID = rid;
			Resource::RCB::struc_wt* wt = new Resource::RCB::struc_wt;
			wt->occupation = units;
			wt->ps = pRunning;
			rs->rcb->waiting_list.push_back(wt);
			cout << "进程 " << pRunning->pName << "(pid:" << pRunning->pcb->pid << ") 已被阻塞" << endl;
			pRunning = nullptr; 
		}
		scheduler();
		cout << "************************************************" << endl;
}

void list(string inputParam) {
	cout << "************************************************" << endl;
	if (inputParam == "block") {
		bool found = false;
		for (int i = 0; i < 20; i++) {
			if (!resources[i]) continue;
			if (resources[i]->rcb->waiting_list.size()) {
				cout << "(rid:" << resources[i]->rcb->rid << ", name:" << resources[i]->resource_name
					<< ", " << resources[i]->rcb->available << "/" << resources[i]->rcb->totalResource << ")" << endl;
				for (auto rs : resources[i]->rcb->waiting_list) {
					cout << " --- [pid:" << rs->ps->pcb->pid << ", name:" << rs->ps->pName << ", need:" << rs->occupation << "]";
				}
				cout << endl;
				found = true;
			}
		}
		if (!found) cout << "没有进程被阻塞" << endl;
	}
	if (inputParam == "ready") {
		cout << "Ready List:" << endl;
		for (int i = 2;i >= 0; i--) {
			cout << "priority: " << i;
			for (auto ps : readyList[i]) {
				cout << " --- [pid:" << ps->pcb->pid << ", name:" << ps->pName << "]";
			}
			cout << endl;
		}
	}
	if (inputParam == "resource") {
		cout << "Resources:" << endl;
		for (int i = 0; i < 20; i++) {
			if (!resources[i]) continue;
			cout << "{  rid:" << resources[i]->rcb->rid << ", name:" << resources[i]->resource_name
				<< ", totalResource:" << resources[i]->rcb->totalResource << ", available:" << resources[i]->rcb->available << "  }" << endl;
		}
	}
	cout << "************************************************" << endl;
	return;
}
//创建资源及资源初始化
void createResource(string inputParam) { 
	vector<string> splits = split(inputParam, ' ');
	int tmp = splits.size();
	string name;
	int number = 0, rid = -1;
	switch (tmp) {
	case 3:
		rid = stoi(splits[2]);
		if (rid < 0 || rid >= 20) {
			cout << "Invalid rid." << endl;
			return;
		}
	case 2:
		for (int i = 0; i < 20; i++) {
			if (resources[i] == nullptr) {
				rid = i;
				break;
			}
		}
	default: break;
	}
	name = splits[0];
	number = stoi(splits[1]);
	Resource* rs = new Resource(name, rid, number);
	resources[rid] = rs;
	cout << "Resource `" << name << "` has been created. (rid:" << rid << ")" << endl;
	scheduler();
}

//释放资源
void release(Process* ps, int rid, int units) {
	cout << "************************************************" << endl;
	int occupation = 0, idx = 0;
	for (auto struc : ps->pcb->usedResource) {
		if (struc->rs->rcb->rid == rid) {
			occupation = struc->occupation;
			if (units < 1 || units > occupation) {
				cout << "Only 1~" << occupation << " unit(s) can be released." << endl;
				return;
			}
			struc->occupation -= units;
			resources[rid]->rcb->available += units;
			cout << "资源 " << resources[rid]->resource_name << "(rid:" << rid << ") 回收了 " << units << " (" << resources[rid]->rcb->available<< resources[rid]->rcb->totalResource << ")." << endl;
			if (resources[rid]->rcb->waiting_list.size() != 0) {
				Resource::RCB::struc_wt* wt = resources[rid]->rcb->waiting_list.front();
				auto ps = wt->ps;
				if (wt->occupation <= resources[rid]->rcb->available) {
					resources[rid]->rcb->available -= wt->occupation;
					ps->pcb->status = Process::PCB::PCB_STATUS::READY;
					ps->pcb->blockRID = -1;
					Process::PCB::usedR* struc2 = new Process::PCB::usedR;
					struc2->occupation = wt->occupation;
					struc2->rs = resources[rid];
					ps->pcb->usedResource.push_back(struc2);
					readyList[ps->pcb->priority].push_back(ps);
					wt->occupation = 0;
					wt->ps = nullptr;
					delete(wt);
					resources[rid]->rcb->waiting_list.erase(resources[rid]->rcb->waiting_list.begin());
					cout << "Process " << ps->pcb->pid << " `" << ps->pName << "`has been changed to READY" << endl;
				}
			}
			if (struc->occupation == 0) {
				struc->occupation = 0;
				struc->rs = nullptr;
				delete(struc);
				ps->pcb->usedResource.erase(ps->pcb->usedResource.begin() + idx);
			}
			break;
		}
		idx++;
	}
	cout << "************************************************" << endl;
}

void rel(string inputParam) {
	cout << "************************************************" << endl;
	if (pRunning == nullptr) {
		cout << "No process is running." << endl;
		return;
	}
	vector<string> splits = split(inputParam, ' ');
	int tmp = splits.size();
	int units = 0;
	switch (tmp) {
	case 1:
		units = 1;
		break;
	case 2:
		units = stoi(splits[1]);
		break;
	default:break;
	}
	int rid = stoi(splits[0]);
	release(pRunning, rid, units);
	scheduler();
	cout << "************************************************" << endl;
	return;
}

void kill_tree(int pid) {
	Process* ps = processes[pid];
	while (ps->pcb->child.size() != 0) {
		Process* next_ps = ps->pcb->child[0];
		kill_tree(next_ps->pcb->pid);
		ps->pcb->child.erase(ps->pcb->child.begin());
	}
	if (ps->pcb->child.size() == 0) {
		while (ps->pcb->usedResource.size() != 0) {
			release(ps, ps->pcb->usedResource.at(0)->rs->rcb->rid, ps->pcb->usedResource.at(0)->occupation);
		}
		Resource* rs = resources[ps->pcb->blockRID];
		switch (ps->pcb->status) {
		case Process::PCB::PCB_STATUS::BLOCK:
			for (int i = 0; i < rs->rcb->waiting_list.size(); i++) {
				if (rs->rcb->waiting_list[i]->ps == ps) {
					rs->rcb->waiting_list[i]->occupation = 0;
					rs->rcb->waiting_list[i]->ps = nullptr;
					delete(rs->rcb->waiting_list[i]);
					rs->rcb->waiting_list.erase(rs->rcb->waiting_list.begin() + i);
					break;
				}
			}
			break;
		case Process::PCB::PCB_STATUS::READY:
			for (int i = 0; i < readyList[ps->pcb->priority].size(); i++) {
				if (readyList[ps->pcb->priority][i] == ps) {
					readyList[ps->pcb->priority].erase(readyList[ps->pcb->priority].begin() + i);
					break;
				}
			}
			break;
		case Process::PCB::PCB_STATUS::RUNNING:
			pRunning = nullptr;
			break;
		}
		cout << processes[pid]->pName << "(pid:" << pid << ") has been killed." << endl;
		delete(processes[pid]);
		processes[pid] = nullptr;
	}
}

void de(string inputParam) {
	vector<string> splits = split(inputParam, ' ');
	cout << "************************************************" << endl;
	int pid = stoi(splits[0]);
	if (processes[pid]->pcb->parent) {	
		for (int i = 0; i < processes[pid]->pcb->parent->pcb->child.size(); i++) {
			if (processes[pid]->pcb->parent->pcb->child[i]->pcb->pid == pid) {
				processes[pid]->pcb->parent->pcb->child.erase(processes[pid]->pcb->parent->pcb->child.begin() + i);
				break;				
			}
		}
	}
	kill_tree(pid);
	scheduler();
	cout << "************************************************" << endl;
	return;
}

void show(string inputParam) {
		vector<string> splits = split(inputParam, ' ');
		int tmp = splits.size();
		int pid = -1;
		switch (tmp) {
		case 0:
			pid = pRunning->pcb->pid;
			break;
		case 1:
			pid = stoi(splits[0]);
			break;
		default:
			break;
		}
		cout << "************************************************" << endl;
		cout << "name:     " << processes[pid]->pName << endl;
		cout << "pid:      "  << pid << endl;
		if (processes[pid]->pcb->parent == nullptr) {
			cout << "parent:   none      " << endl;
		}
		else {
			cout << "parent: " << processes[pid]->pcb->parent->pName << "(pid:" << processes[pid]->pcb->parent->pcb->pid << ")" << endl;
		}
		if (processes[pid]->pcb->child.size()) {
			cout << "child: ";
			for (auto ps : processes[pid]->pcb->child) {
				cout << ps->pName << "(pid:" << ps->pcb->pid << ") ";
			}
			cout << endl;
		}
		else {
			cout << "child:    none" << endl;
		}
		cout << "status: " << status_names[processes[pid]->pcb->status] << endl;
		if (processes[pid]->pcb->status == Process::PCB::PCB_STATUS::BLOCK) {
			cout << "blocked on: " << resources[processes[pid]->pcb->blockRID]->resource_name << "(rid:" << processes[pid]->pcb->blockRID << ")" << endl;
		}
		if (processes[pid]->pcb->usedResource.size()) {
			cout << "resources occupied:" << endl;
			for (auto rs : processes[pid]->pcb->usedResource) {
				cout << "(name:" << rs->rs->resource_name << ", rid:" << rs->rs->rcb->rid << ", occupation:" << rs->occupation << ")" << endl;
			}
	}
	cout << "************************************************" << endl;
	return;
}

void scheduler() {
	for (int i = 2;i >= 0; i--) {
		if (readyList[i].size()) {
			Process* next = readyList[i][0];
			if (pRunning == nullptr) {
				goto preempt;
			}
			//判断优先级
			else if (next->pcb->priority > pRunning->pcb->priority) {
				pRunning->pcb->status = Process::PCB::PCB_STATUS::READY;
				readyList[pRunning->pcb->priority].push_back(pRunning); 
				goto preempt;
			}
			return;
		preempt:
			pRunning = next;
			pRunning->pcb->status = Process::PCB::PCB_STATUS::RUNNING;
			readyList[i].erase(readyList[i].begin());
			goto end;
			break;
		}
	}
end:
	if (pRunning)
		cout << "Process [pid:" << pRunning->pcb->pid << ", name:" << pRunning->pName << "] is running." << endl;
}

int getInputCmd()
{
	string input;
	while (true) {
		cout << "> ";
		getline(cin, input);
		if (input == "") continue;
		if (input == "exit") {
			return 1;
		}
		if (input == "to") {
			to();
			continue;
		}
		vector<string> splits = split(input, ' ');
		if (splits.at(0) == "cr") {
			cr(get_param(input));
			continue;
		}
		if (splits.at(0) == "list") {
			list(get_param(input));
			continue;
		}
		if (splits.at(0) == "req") {
			req(get_param(input));
			continue;
		}
		if (splits.at(0) == "rel") {
			rel(get_param(input));
			continue;
		}
		if (splits.at(0) == "de") {
			de(get_param(input));
			continue;
		}
		if (splits.at(0) == "show") {
			show(get_param(input));
			continue;
		}
	}
	return 0;
}

int main()
{
	init();
	while (!getInputCmd());
	return 0;
}
