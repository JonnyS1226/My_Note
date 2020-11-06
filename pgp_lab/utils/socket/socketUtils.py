from socket import *

'''socket连接相关'''
class SocketServer():
    def __init__(self):
        self.address = '127.0.0.1'  # 监听哪些网络
        self.port = 12345  # 监听自己的哪个端口
        self.buffsize = 1024  # 接收从客户端发来的数据的缓存区大小
        self.s = socket(AF_INET, SOCK_STREAM)
        self.s.bind((self.address, self.port))
        self.s.listen(1)  # 最大连接数
        self.clientsock, self.clientaddress = self.s.accept()

    def receive_number(self):
        recvdata = self.clientsock.recv(self.buffsize).decode('utf-8')
        return int(recvdata)

    def receive_data(self):
        recvdata = self.clientsock.recv(self.buffsize).decode('utf-8')
        with open('receive.txt', 'w', encoding='utf-8') as fp:
            fp.write(recvdata)


class SocketClient():
    def __init__(self):
        self.file_path = 'send.txt'
        self.address = '127.0.0.1'  # 服务器的ip地址
        self.port = 12345  # 服务器的端口号
        self.buffsize = 1024  # 接收数据的缓存大小
        self.s = socket(AF_INET, SOCK_STREAM)
        self.s.connect((self.address, self.port))

    def send(self):
        with open(self.file_path, encoding='utf-8') as file_obj:
            senddata = file_obj.read()
            self.s.send(senddata.encode())