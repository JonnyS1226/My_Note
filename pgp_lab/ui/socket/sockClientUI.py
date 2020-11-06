import service.socketService.sockClientPGP as client
import utils.socket.socketUtils as socketUtils
from tkinter import *
from tkinter.messagebox import *


class Client():
    def __init__(self):
        self.sock = socketUtils.SocketClient()

    def login(self):
        self.login = Tk()
        self.login.title("发送信息界面")
        self.login.geometry('500x500')  # 界面的大小
        self.login.attributes("-alpha", 1)  # 虚化

        self.login_label1 = Label(self.login, text="请输入信息")
        self.login_label1.place(x=0, y=40)
        self.login_text1 = Text(self.login, width=30, height=30)
        self.login_text1.place(x=70, y=40)

        self.login_button1 = Button(self.login, text="发送", command=self.send)
        self.login_button1.place(x=400, y=40)
        self.login.mainloop()

    def send(self):
        a = self.login_text1.get('0.0', 'end')
        with open('example.txt', 'w') as fp:
            fp.write(a[0:-1])
        client.make_message()
        self.sock.send()
        showinfo('提示', '发送成功')


s = Client()
s.login()

