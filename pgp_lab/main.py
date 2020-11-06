import ui.idenfy as idenfy
import ui.pop3  as pop3
import ui.smtp as smtp
import sys
from PyQt5.QtWidgets import QMessageBox,QLineEdit,QApplication,QMainWindow,QAbstractItemView,QTableWidgetItem
import _thread
import poplib
import base64
from email.parser import Parser
from email.header import decode_header
from email.utils import parseaddr
import datetime
import smtplib
from email.mime.text import MIMEText
from email.utils import formataddr
from dao.dbOpearte import MailDB

app = QApplication(sys.argv)

is_Idenfy = False

user = {
    'username': None,
    'password': None
}


class Email_Server(object):
    def __init__(self,user_dic):
        # print(user_dic)
        self.user_mail = user_dic['user']
        self.password = user_dic['pass']
        self.pop_server = user_dic['pop3'] # pop.163.com
        self.Connect_Server()



mail_Server = None


class Send_email(QMainWindow):
    def __init__(self):
        QMainWindow.__init__(self)
        self.send_ui = smtp.Ui_MainWindow()
        self.send_ui.setupUi(self)
        self.send_ui.pushButton_2.clicked.connect(self.close)
        self.send_ui.pushButton.clicked.connect(self.Send)

    def Send(self):
        global mail_Server
        try:
            recv_mail = self.send_ui.lineEdit_5.text()
            send_title = self.send_ui.lineEdit_6.text()
            send_text = self.send_ui.textEdit.toPlainText()
        except:
            QMessageBox.about(self, "Message", "填写完整信息")
        maildb = MailDB()
        retval = maildb.insertMail(user['username'], recv_mail, send_title, send_text)
        if retval:
            QMessageBox.about(self, "Message", "发送成功！")
            self.close()
        else:
            QMessageBox.critical(self, "失败", "pop验证失败", QMessageBox.Yes | QMessageBox.No, QMessageBox.Yes)




sendUi = None

class mainWin(QMainWindow):
    def __init__(self):
        QMainWindow.__init__(self)
        self.main_ui = pop3.Ui_MainWindow()
        self.main_ui.setupUi(self)
        self.main_ui.pushButton_2.clicked.connect(self.Send)
        self.main_ui.pushButton_4.clicked.connect(self.Update)
        self.main_ui.tableWidget.setSelectionBehavior(QAbstractItemView.SelectRows)
        self.main_ui.tableWidget.itemClicked.connect(self.itemclick)
        self.main_ui.textEdit.document().setMaximumBlockCount(100)

    def itemclick(self):
        now_current_row = self.main_ui.tableWidget.currentIndex().row()
        print(now_current_row)
        rowtitle = self.main_ui.tableWidget.item(now_current_row,0).text()
        # print(rowdata)
        rowsender = self.main_ui.tableWidget.item(now_current_row,1).text()
        etime = self.main_ui.tableWidget.item(now_current_row,2).text()
        rowaddr = self.main_ui.tableWidget.item(now_current_row,3).text()
        contents = self.main_ui.tableWidget.item(now_current_row,4).text()
        self.main_ui.textEdit.clear()
        self.main_ui.lineEdit.clear()
        self.main_ui.lineEdit_2.clear()
        self.main_ui.lineEdit_3.clear()
        self.main_ui.lineEdit_4.clear()
        _thread.start_new_thread(self.Dis_mail_data, (rowtitle,rowsender,rowaddr,contents,etime))

    def Dis_mail_data(self, title, sender, addr, cont,etime):
        self.main_ui.lineEdit.setText(title)
        self.main_ui.lineEdit_2.setText(sender)
        self.main_ui.lineEdit_3.setText(addr)
        self.main_ui.lineEdit_4.setText(etime)
        # print(len(cont))
        if len(cont) > 5000:
            self.main_ui.textEdit.append(" ")
        else:
            self.main_ui.textEdit.append(cont)


    def Update(self):
        global is_Idenfy,mail_Server
        if not is_Idenfy:
            QMessageBox.about(self, "Message", "请先登录")
        else:
            _thread.start_new_thread(self.Upthread, ())

    def Upthread(self):
        '''ok:  查看邮件'''
        # global user
        #清空列表
        allrownum = self.main_ui.tableWidget.rowCount()
        for i in range(allrownum):
            self.main_ui.tableWidget.removeRow(0)
        # 获取邮箱邮件数
        # mail_count = mail_Server.Get_Email_Count()
        maildb = MailDB()
        mail_count = maildb.searchRows(user['username'])
        mail_count = mail_count[0]['count(*)']
        # 获取最新10条邮件
        for i in range(0, mail_count):
            data = maildb.search(user['username'])
            _thread.start_new_thread(self.Display, (data[i]['subject'],data[i]['from'],data[i]['to'],data[i]['content'],data[i]['time'],))

    def Display(self,title,name,addr,content,etime):
        rrow = self.main_ui.tableWidget.rowCount()
        self.main_ui.tableWidget.insertRow(rrow)
        self.main_ui.tableWidget.setItem(rrow, 0, QTableWidgetItem(title))
        self.main_ui.tableWidget.setItem(rrow, 1, QTableWidgetItem(name))
        self.main_ui.tableWidget.setItem(rrow, 2, QTableWidgetItem(str(etime)))
        self.main_ui.tableWidget.setItem(rrow, 3, QTableWidgetItem(addr))
        self.main_ui.tableWidget.setItem(rrow, 4, QTableWidgetItem(content))

    def Send(self):
        global is_Idenfy,user,sendUi
        if not is_Idenfy:
            QMessageBox.about(self, "Message", "请先登录")
        else:
            sendUi = Send_email()
            sendUi.send_ui.label_8.setText(user['username'])
            sendUi.show()


class loginWin(QMainWindow):
    def __init__(self):
        QMainWindow.__init__(self)
        self.login_ui = idenfy.Ui_MainWindow()
        self.login_ui.setupUi(self)
        self.login_ui.pushButton_2.clicked.connect(self.close)
        self.login_ui.pushButton.clicked.connect(self.Login)
        self.login_ui.lineEdit_2.setEchoMode(QLineEdit.Password)

    def Login(self):
        print("login....")
        global user,mail_Server, is_Idenfy
        user['username'] = str(self.login_ui.lineEdit.text())
        user['password'] = str(self.login_ui.lineEdit_2.text())
        maildb = MailDB()
        data = maildb.searchUser(user['username'])
        # print(data)
        if user['password'] != '':
            if data == ():
                # 注册
                maildb.insertUser(user['username'], user['password'])
                QMessageBox().information(None, "注册成功", "即将登录！")
            else:
                data = maildb.login(user['username'], user['password'])
                if data == ():
                    QMessageBox().information(None, "连接失败", "密码错误！")
                else:
                    print("连接成功.......")
                    QMessageBox().information(None, "连接成功", "验证成功！")
        else:
            QMessageBox().information(None, "验证失败", "密码不能为空！")
        self.close()
        is_Idenfy = True



if __name__ == '__main__':
    ui = mainWin()
    loginui = loginWin()
    ui.main_ui.pushButton.clicked.connect(loginui.show)
    ui.main_ui.pushButton_3.clicked.connect(QApplication.quit)
    ui.show()
    sys.exit(app.exec_())