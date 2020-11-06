# -*- coding: utf-8 -*
import os
import socket
import hashlib
import tkinter.messagebox
from tkinter import *
from urllib import request, parse, error
import json

# 访问服务器的url
url = 'http://127.0.0.1:8080'
N = 0
def md5_n(S, n):
    '''n次md5哈希'''
    while n > 0:
        n = n - 1
        hash = hashlib.md5()
        hash.update(S.encode("utf8"))
        S = hash.hexdigest()
    return S
def getS(password, seed):
    '''计算S/KEY中的S'''
    hash = hashlib.md5()
    hash.update((password+seed).encode("utf8"))
    str = hash.hexdigest()
    b = bytes.fromhex(str)
    ans = ""    # 存放结果
    tmp = ""    # 存放异或后的二进制流字符串
    for i in range(8):
        tmp = tmp + hex(b[i] ^ b[i+8])
    list = tmp.split("0x")
    # 进行异或，补位
    for i in range(9):
        if len(list[i]) == 1 :
            list[i] = '0' + list[i]
        ans = ans + list[i]
    return ans

class Login(Frame):
    def __init__(self):
        # 登录界面部分
        self.frame=Frame()
        self.frame.pack()
        self.lab1 = Label(self.frame,text = "用户名:")
        self.lab1.grid(row=0,column=0)
        self.lab2 = Label(self.frame,text="密码:")
        self.lab2.grid(row=2,column=0)
        self.text1 = Entry(self.frame)
        self.text1.grid(row=0, column=2)
        self.text2 = Entry(self.frame, show="*")
        self.text2.grid(row=2, column=2)
        self.button1 = Button(self.frame, text="登录", command=lambda : self.Log(url))
        self.button1.grid(row=6, column=0)
        self.button2 = Button(self.frame, text="前往注册", command=self.goToRegister)
        self.button2.grid(row=6, column=1)
        self.button3=Button(self.frame, text="退出", command=self.frame.quit)
        self.button3.grid(row=6, column=4)

    def goToRegister(self):
        self.frame.forget()
        Register()

    def Log(self, url):
        '''登录'''
        username = self.text1.get()
        password = self.text2.get()
        if username == '' or password == '':
            tkinter.messagebox.showinfo("提示", "用户名或密码不能为空")
            return
        # 发送认证请求
        info = []
        info.append(('type', 'login'))
        info.append(('username', username))
        data = bytes(parse.urlencode(info), encoding='utf8')
        with request.urlopen(url + "/login", data=data) as rsp:
            msg = rsp.read().decode('utf8')
            if msg.find("register first") != -1:
                tkinter.messagebox.showinfo("提示", "该账号还未注册，请先注册")
                return
            elif msg.find("unknown error") != -1:
                tkinter.messagebox.showinfo("提示", "未知错误")
                return
            elif msg.find("rearrange") != -1:
                tkinter.messagebox.showinfo("提示", "口令序列使用完毕，已按照既定N重新约定口令，请重新尝试")
                return
            else:
                tkinter.messagebox.showinfo("提示", "接收种子成功，准备登录")
                res = json.loads(msg)
                # 计算本次口令，并进行登录
                otp = md5_n(getS(password, res["Seed"]), res["SeqNum"])
                info.append(("otp", otp))
                data = bytes(parse.urlencode(info), encoding='utf8')
                with request.urlopen(url + "/check", data=data) as rsp:
                    msg = rsp.read().decode('utf8')
                    if msg.find("login success") != -1:
                        tkinter.messagebox.showinfo("提示", "登录成功！")
                    if msg.find("login failure") != -1:
                        tkinter.messagebox.showinfo("提示", "登陆失败，密码错误")


class Register(Frame):
    def __init__(self):
        # 注册界面部分
        self.frame1 = Frame()
        self.frame1.pack()
        self.lab1 = Label(self.frame1,text = "用户名:")
        self.lab1.grid(row=0,column=0)
        self.lab2 = Label(self.frame1,text="密码:")
        self.lab2.grid(row=2,column=0)
        self.lab2 = Label(self.frame1,text="口令序列最大迭代值N:")
        self.lab2.grid(row=4,column=0)
        self.text1 = Entry(self.frame1)
        self.text1.grid(row=0, column=2)
        self.text2 = Entry(self.frame1, show="*")
        self.text2.grid(row=2, column=2)
        self.text3 = Entry(self.frame1)
        self.text3.grid(row=4, column=2)
        self.button1 = Button(self.frame1, text="返回登录", command=self.goToLogin)
        self.button1.grid(row=6, column=0)
        self.button2 = Button(self.frame1, text="注册", command=lambda : self.register(url))
        self.button2.grid(row=6, column=1)
        self.button3=Button(self.frame1, text="退出", command=self.frame1.quit)
        self.button3.grid(row=6, column=4)

    def goToLogin(self):
        self.frame1.forget()
        Login()

    def register(self, url):
        '''注册和协商'''
        username = self.text1.get()
        password = self.text2.get()
        if username == '' or password == '':
            tkinter.messagebox.showinfo("提示", "用户名或密码不能为空")
            return
        if len(password) < 8:
            tkinter.messagebox.showinfo("提示", "密码长度不能小于8位")
            return
        N = self.text3.get()
        if N == '' :
            tkinter.messagebox.showinfo("提示", "请输入最大迭代值N")
            return
        try:
            N = int(N)
        except:
            tkinter.messagebox.showinfo("提示", "迭代值请输入数字")
            return

        # 构造data
        info = []
        info.append(('type', 'register'))
        info.append(('username', username))
        info.append(('plainPassword', password))
        info.append(('maxNum', N))
        print(info)
        data = bytes(parse.urlencode(info), encoding='utf8')
        # 发送注册请求
        with request.urlopen(url + '/register', data=data) as rsp:
            msg = rsp.read().decode('utf8')
            if msg.find('success') != -1:
                tkinter.messagebox.showinfo('提示', "注册成功")
            elif msg.find('exist') != -1:
                tkinter.messagebox.showinfo('提示', "用户名已存在")
            elif msg.find('failure') != -1:
                tkinter.messagebox.showinfo('提示', '注册失败，其它错误')




if __name__ == '__main__':
    root = Tk()
    root.geometry('400x200+300+100')
    root.title("S/KEY登录注册")
    app = Login()
    root.mainloop()
