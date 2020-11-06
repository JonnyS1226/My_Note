# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'smtp.ui'
#
# Created by: PyQt5 UI code generator 5.13.0
#
# WARNING! All changes made in this file will be lost!


from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(500, 405)
        MainWindow.setStyleSheet("QListWidget, QListView, QTreeWidget, QTreeView,QFrame {\n"
"    outline: 0px;\n"
"}\n"
"#head\n"
"{\n"
"background:white;\n"
"border-radius:30px;\n"
"}\n"
"#head_2\n"
"{\n"
"background:#CCFFCC;\n"
"border:1px solid;\n"
"border-color:#CCFFCC;\n"
"border-radius:60px;\n"
"}\n"
"#Search\n"
"{\n"
"border-radius:5px;\n"
"background:#293846;\n"
"border:0.5px solid;\n"
"border-color:white;\n"
"\n"
"}\n"
"QListWidget::item\n"
"{\n"
"height:60;\n"
"background-color:#293846;\n"
"}\n"
"#frame\n"
"{\n"
"background-color:#2f4050\n"
"\n"
"}\n"
"/*被选中时的背景颜色和左边框颜色*/\n"
"QListWidget::item:selected {\n"
"    background: rgb(52, 52, 52);\n"
"    border-left: 2px solid rgb(9, 187, 7);\n"
"}\n"
"/*鼠标悬停颜色*/\n"
"HistoryPanel::item:hover {\n"
"    background: rgb(52, 52, 52);\n"
"}\n"
"/*右侧的层叠窗口的背景颜色*/\n"
"QStackedWidget {\n"
"    background: white;\n"
"}\n"
"/*模拟的页面*/\n"
"#frame > QLabel\n"
"{\n"
"color:white;\n"
"}\n"
"#frame_2\n"
"{\n"
"background-color:#CCFFCC;\n"
"}\n"
"#page_2 > QLineEdit,QDateEdit\n"
"{\n"
"border-radius:5px;\n"
"background:#FFFFFF;\n"
"border:1px solid;\n"
"border-color:#6699CC;\n"
"}\n"
"QLineEdit,QTextEdit\n"
"{\n"
"border-radius:5px;\n"
"background:#FFFFFF;\n"
"border:1px solid;\n"
"border-color:#6699CC;\n"
"}\n"
"QPushButton{\n"
"background:rgb(138, 255, 252);\n"
"border-radius:15px;\n"
"}\n"
"QPushButton:hover{\n"
"background:rgb(248, 255, 180);\n"
"border-radius:15px;\n"
"background:#49ebff;\n"
"}\n"
"background-color:rgb(255, 249, 246)\n"
"\n"
"")
        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        self.label_3 = QtWidgets.QLabel(self.centralwidget)
        self.label_3.setGeometry(QtCore.QRect(70, 10, 81, 41))
        self.label_3.setObjectName("label_3")
        self.label_5 = QtWidgets.QLabel(self.centralwidget)
        self.label_5.setGeometry(QtCore.QRect(70, 50, 81, 41))
        self.label_5.setObjectName("label_5")
        self.lineEdit_5 = QtWidgets.QLineEdit(self.centralwidget)
        self.lineEdit_5.setGeometry(QtCore.QRect(160, 60, 321, 21))
        self.lineEdit_5.setObjectName("lineEdit_5")
        self.label_6 = QtWidgets.QLabel(self.centralwidget)
        self.label_6.setGeometry(QtCore.QRect(70, 90, 71, 41))
        self.label_6.setObjectName("label_6")
        self.lineEdit_6 = QtWidgets.QLineEdit(self.centralwidget)
        self.lineEdit_6.setGeometry(QtCore.QRect(160, 100, 321, 21))
        self.lineEdit_6.setObjectName("lineEdit_6")
        self.label_7 = QtWidgets.QLabel(self.centralwidget)
        self.label_7.setGeometry(QtCore.QRect(70, 130, 61, 41))
        self.label_7.setObjectName("label_7")
        self.textEdit = QtWidgets.QTextEdit(self.centralwidget)
        self.textEdit.setGeometry(QtCore.QRect(160, 140, 321, 191))
        self.textEdit.setObjectName("textEdit")
        self.pushButton = QtWidgets.QPushButton(self.centralwidget)
        self.pushButton.setGeometry(QtCore.QRect(130, 350, 81, 31))
        self.pushButton.setObjectName("pushButton")
        self.pushButton_2 = QtWidgets.QPushButton(self.centralwidget)
        self.pushButton_2.setGeometry(QtCore.QRect(290, 350, 81, 31))
        self.pushButton_2.setObjectName("pushButton_2")
        self.label_8 = QtWidgets.QLabel(self.centralwidget)
        self.label_8.setGeometry(QtCore.QRect(160, 10, 211, 41))
        self.label_8.setObjectName("label_8")
        MainWindow.setCentralWidget(self.centralwidget)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "MainWindow"))
        self.label_3.setText(_translate("MainWindow", "发件人邮箱："))
        self.label_5.setText(_translate("MainWindow", "收件人邮箱："))
        self.label_6.setText(_translate("MainWindow", "邮件主题："))
        self.label_7.setText(_translate("MainWindow", "邮件正文："))
        self.pushButton.setText(_translate("MainWindow", "发送"))
        self.pushButton_2.setText(_translate("MainWindow", "取消"))
        self.label_8.setText(_translate("MainWindow", "TextLabel"))
