#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/in_systm.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include "nids.h"
#include<stdlib.h>

#define int_ntoa(x)	inet_ntoa(*((struct in_addr *)&x))
#define MaxL 256
#define NON_NUM '0'

// 包结构
struct packetinfo {
	char s_source[MaxL];	// 源ip
	char s_des[MaxL];		// 目的ip
	char s_sport[MaxL];		// 源端口
	char s_dport[MaxL];		// 目的端口 
	char s_len[MaxL];		// 包长度
} packet;


// 获取next数组，此处规定next[0]=-1
void getNext(char *needle, int* next){
	next[0] = -1;
	next[1] = 0;
	for (int i = 2; i < strlen(needle); i++) {
		int tmp = next[i-1];
		while (tmp != -1){
   			if (needle[i-1] == needle[tmp]){
    			next[i] = tmp + 1;
    			break;
    		} else {
        		tmp = next[tmp];
   			}
    		if (tmp == -1) {
				next[i] = 0;
   			}
	 	}
    }
}

//kmp主体算法，haystack是主串，needle是模式串
char *myKmp(char* haystack, char* needle) {
	int len1 = strlen(haystack);
	int len2 = strlen(needle);
	int *next = (int*)malloc(sizeof(int)*(len2 + 1));
	int ret;
	getNext(needle, next);
	int i = -1;	//指向主串
	int j = -1;	//指向子串
	while (i < len1 && j < len2){
		// 匹配上字符 指针后移
		if (j == -1 || haystack[i] == needle[j]){
			i++;
			j++;
		} else {	
			// 否则取到next位置
			j = next[j];
		}
	}
	if (j >= len2) {
		// 有满足条件的，通过移动指针找到最开始匹配的位置
		ret = i - j;
		for (int i = 0; i < ret; ++i) {
			haystack++;
		}
		return haystack;
	}
	else {
		return NULL;
	}
}

// 匹配信息
char username_filter[MaxL] = "username=";
char password_filter[MaxL] = "password=";
char ip_filter[] = "172.24.15.149";
char subject_filter[MaxL] = "subject=";
char text_filter[MaxL] = "text=";
char from_filter[MaxL] = "from=";
char to_filter[MaxL] = "to=";
char date_filter[MaxL] = "receiveTime=";

char *adres(struct tuple4 addr) {
	static char buf[256];
	strcpy(buf, int_ntoa(addr.saddr));
	sprintf(buf + strlen(buf), ",%i,", addr.source);
	strcat(buf, int_ntoa(addr.daddr));
	sprintf(buf + strlen(buf), ",%i", addr.dest);
	return buf;
}

// 十六进制转数字
int hex2num(char c) {
	if (c >= '0' && c <= '9') return c - '0';
	if (c >= 'a' && c <= 'z') return c - 'a' + 10;
	if (c >= 'A' && c <= 'Z') return c - 'A' + 10;

	printf("unexpected char: %c", c);
	return NON_NUM;
}

// url解码  是urlencode的逆过程
// urlencode是数字和字母不变，空格变为"+"号，其他被编码成"%"加上他们的ascii的十六进制
int URLDecode(const char* str, const int strSize, char* result, const int resultSize) {
	char ch, ch1, ch2;
	int i;
	int j = 0;//record result index

	if ((str == NULL) || (result == NULL) || (strSize <= 0) || (resultSize <= 0)) {
		return 0;
	}

	for (i = 0; (i<strSize) && (j<resultSize); ++i) {
		ch = str[i];
		switch (ch) {
		case '+':
			result[j++] = ' ';
			break;
		case '%':
			if (i + 2<strSize) {
				ch1 = hex2num(str[i + 1]);//高4位
				ch2 = hex2num(str[i + 2]);//低4位
				if ((ch1 != NON_NUM) && (ch2 != NON_NUM))
					result[j++] = (char)((ch1 << 4) | ch2);
				i += 2;
				break;
			}
			else {
				break;
			}
		default:
			result[j++] = ch;
			break;
		}
	}
	result[j] = 0;
	return j;
}

void http_data_parse(char content[]) {
	if (myKmp(content, password_filter) || myKmp(content, subject_filter) || myKmp(content, text_filter)){
		// 原本传输过程中分隔符
		const char s[2] = "&";
		// 用于存储按照&分割后的字段集合
		char *token;
		char obj[3000] = { 0 };
		printf("**************提取信息开始******************\n");
		printf("源地址(ip,port)   : %s:%s\n", packet.s_source, packet.s_sport);
		printf("目的地址(ip,port) : %s:%s\n", packet.s_des, packet.s_dport);
		printf("数据包长度	      : %s\n", packet.s_len);

		unsigned int len = strlen(content);
		int resultSize = URLDecode(content, len, obj, 3000);
		// 按照'&'进行分割，分割出token字段集合
		token = strtok(obj, s);
		// 继续获取其他的子字符串，并且对token字段集合进行字符串匹配
		while (token != NULL) {
			if (myKmp(token, username_filter)) {
				printf("用户名:	%s\n", myKmp(token, username_filter));
			}
			if (myKmp(token, password_filter)) {
				printf("密码:	%s\n", myKmp(token, password_filter));
			}
			if (myKmp(token, date_filter)) {
				printf("时间:	%s\n", myKmp(token, date_filter));
			}
			if (myKmp(token, subject_filter)) {
				printf("主题:	%s\n", myKmp(token, subject_filter));
			}
			if (myKmp(token, text_filter)) {
				printf("正文:	%s\n", myKmp(token, text_filter));
			}
			if (myKmp(token, from_filter)) {
				printf("发送人:	%s\n", myKmp(token, from_filter));
			}
			if (myKmp(token, to_filter)) {
				printf("收件人:	%s\n", myKmp(token, to_filter));
			}
			token = strtok(NULL, s);
		}
		// 获取抓包时间
		time_t the_time;
		(void*)time(&the_time);
		printf("抓包/发信时间: %s\n", ctime(&the_time));
		printf("**************提取信息结束******************\n");
	}
}

void tcp_callback(struct tcp_stream *a_tcp, void** this_time_not_needed)
{
	static int num;
	char content[65535];
	struct tuple4 ip_and_port = a_tcp->addr;
	if (a_tcp->nids_state == NIDS_JUST_EST) {
		// HTTP port
		if (ip_and_port.dest != 80) {
			return;
		}
		a_tcp->client.collect++;
		a_tcp->server.collect++;
	}
	else if (a_tcp->nids_state == NIDS_DATA) {
		struct half_stream *hlf;
		if (a_tcp->server.count_new) {
			hlf = &a_tcp->server;
		}
		else if (a_tcp->client.count_new) {
			hlf = &a_tcp->client;
		}
		sprintf(packet.s_source, "%s", inet_ntoa(*((struct in_addr *)&(ip_and_port.saddr))));
		sprintf(packet.s_des, "%s", inet_ntoa(*((struct in_addr *)&(ip_and_port.daddr))));
		sprintf(packet.s_sport, "%i", ip_and_port.source);
		sprintf(packet.s_dport, "%i", ip_and_port.dest);
		sprintf(packet.s_len, "%d", hlf->count_new);
		if (!strcmp(packet.s_source, ip_filter)) {			// 过滤IP
			memcpy(content, hlf->data, hlf->count_new);
			content[hlf->count_new] = '\0';
			http_data_parse(content);
		}
	}
	return;
}

int main() {
	// 绑定网卡 和 校验和
	nids_params.device = "eth0";
	struct nids_chksum_ctl temp;
	temp.netaddr = 0;
	temp.mask = 0;
	temp.action = 1;
	nids_register_chksum_ctl(&temp, 1);
	if (!nids_init()) {
		printf("错误！ 错误信息: %s\n", nids_errbuf);
	} else {
		printf("开始监听!\n");
		nids_register_tcp(tcp_callback);
		nids_run();
	}
	return 0;
}
