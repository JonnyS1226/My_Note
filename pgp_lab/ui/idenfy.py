# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'idenfy.ui'
#
# Created by: PyQt5 UI code generator 5.13.0
#
# WARNING! All changes made in this file will be lost!


from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(384, 263)
        MainWindow.setStyleSheet("QListWidget, QListView, QTreeWidget, QTreeView,QFrame {\n"
"    outline: 0px;\n"
"}\n"
"QLabel{\n"
"color:white;\n"
"background:transparent;\n"
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
"QLineEdit\n"
"{\n"
"border-radius:5px;\n"
"background:#FFFFFF;\n"
"border:1px solid;\n"
"border-color:#6699CC;\n"
"}\n"
"#centralwidget{\n"
"border-image:url(D:/img/login3.jpg) strectch；\n"
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
"\n"
"\n"
"")
        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        self.label = QtWidgets.QLabel(self.centralwidget)
        self.label.setGeometry(QtCore.QRect(70, 50, 61, 41))
        self.label.setObjectName("label")
        self.label_2 = QtWidgets.QLabel(self.centralwidget)
        self.label_2.setGeometry(QtCore.QRect(70, 90, 61, 41))
        self.label_2.setObjectName("label_2")
        self.lineEdit = QtWidgets.QLineEdit(self.centralwidget)
        self.lineEdit.setGeometry(QtCore.QRect(140, 60, 171, 21))
        self.lineEdit.setText("")
        self.lineEdit.setObjectName("lineEdit")
        self.lineEdit_2 = QtWidgets.QLineEdit(self.centralwidget)
        self.lineEdit_2.setGeometry(QtCore.QRect(140, 100, 171, 21))
        self.lineEdit_2.setText("")
        self.lineEdit_2.setObjectName("lineEdit_2")
        self.pushButton = QtWidgets.QPushButton(self.centralwidget)
        self.pushButton.setGeometry(QtCore.QRect(100, 160, 71, 31))
        self.pushButton.setStyleSheet("")
        self.pushButton.setObjectName("pushButton")
        self.pushButton_2 = QtWidgets.QPushButton(self.centralwidget)
        self.pushButton_2.setGeometry(QtCore.QRect(230, 160, 71, 31))
        self.pushButton_2.setStyleSheet("")
        self.pushButton_2.setObjectName("pushButton_2")
        self.label_3 = QtWidgets.QLabel(self.centralwidget)
        self.label_3.setGeometry(QtCore.QRect(70, 130, 231, 16))
        self.label_3.setObjectName("label_3")
        MainWindow.setCentralWidget(self.centralwidget)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "MainWindow"))
        self.label.setText(_translate("MainWindow", "邮箱账号："))
        self.label_2.setText(_translate("MainWindow", "邮箱密码："))
        self.pushButton.setText(_translate("MainWindow", "登录"))
        self.pushButton_2.setText(_translate("MainWindow", "取消"))
        self.label_3.setText(_translate("MainWindow", "* 若账号未注册，会自动注册"))
