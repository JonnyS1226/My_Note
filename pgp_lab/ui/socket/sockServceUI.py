import service.socketService.sockServcerPGP as server
import utils.socket.socketUtils as socketUtils
from tkinter import *
from tkinter.messagebox import *


class Server():
    def __init__(self):
        self.length = 8
        self.sock = socketUtils.SocketServer()

    def login(self):
        self.login = Tk()
        self.login.title("接收信息界面")
        self.login.geometry('500x500')  # 界面的大小
        self.login.attributes("-alpha", 1)  # 虚化

        self.login_label1 = Label(self.login, text="信息")
        self.login_label1.place(x=0, y=40)
        self.login_text1 = Text(self.login, width=30, height=30)
        self.login_text1.place(x=70, y=40)

        self.login_button1 = Button(self.login, text="接收", command=self.receive)
        self.login_button1.place(x=400, y=40)
        self.login.mainloop()

    def receive(self):
        self.sock.receive_data()
        a = server.receive_message(self.length)
        if a == -1:
            showinfo('警告', '身份验证失败')
        elif a == 0:
            showinfo('提示', '身份验证成功')
            with open('raw.txt', 'r') as fp:
                message = fp.read()
                message = message.strip('\0')
                print(message)
                self.login_text1.insert(INSERT, message+'\n')


s = Server()
s.login()
