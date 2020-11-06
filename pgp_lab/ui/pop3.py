# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'pop3.ui'
#
# Created by: PyQt5 UI code generator 5.13.0
#
# WARNING! All changes made in this file will be lost!


from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(551, 716)
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
        self.tableWidget = QtWidgets.QTableWidget(self.centralwidget)
        self.tableWidget.setGeometry(QtCore.QRect(30, 70, 501, 231))
        self.tableWidget.setObjectName("tableWidget")
        self.tableWidget.setColumnCount(5)
        self.tableWidget.setRowCount(0)
        item = QtWidgets.QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(0, item)
        item = QtWidgets.QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(1, item)
        item = QtWidgets.QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(2, item)
        item = QtWidgets.QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(3, item)
        item = QtWidgets.QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(4, item)
        self.tableWidget.horizontalHeader().setDefaultSectionSize(150)
        self.label = QtWidgets.QLabel(self.centralwidget)
        self.label.setGeometry(QtCore.QRect(30, 30, 61, 21))
        self.label.setObjectName("label")
        self.pushButton = QtWidgets.QPushButton(self.centralwidget)
        self.pushButton.setGeometry(QtCore.QRect(360, 20, 81, 31))
        self.pushButton.setObjectName("pushButton")
        self.pushButton_2 = QtWidgets.QPushButton(self.centralwidget)
        self.pushButton_2.setGeometry(QtCore.QRect(110, 20, 81, 31))
        self.pushButton_2.setObjectName("pushButton_2")
        self.pushButton_3 = QtWidgets.QPushButton(self.centralwidget)
        self.pushButton_3.setGeometry(QtCore.QRect(454, 20, 81, 31))
        self.pushButton_3.setObjectName("pushButton_3")
        self.label_2 = QtWidgets.QLabel(self.centralwidget)
        self.label_2.setGeometry(QtCore.QRect(50, 320, 41, 21))
        self.label_2.setObjectName("label_2")
        self.lineEdit = QtWidgets.QLineEdit(self.centralwidget)
        self.lineEdit.setGeometry(QtCore.QRect(90, 320, 441, 21))
        self.lineEdit.setObjectName("lineEdit")
        self.label_3 = QtWidgets.QLabel(self.centralwidget)
        self.label_3.setGeometry(QtCore.QRect(40, 360, 51, 21))
        self.label_3.setObjectName("label_3")
        self.lineEdit_2 = QtWidgets.QLineEdit(self.centralwidget)
        self.lineEdit_2.setGeometry(QtCore.QRect(90, 360, 441, 21))
        self.lineEdit_2.setObjectName("lineEdit_2")
        self.label_4 = QtWidgets.QLabel(self.centralwidget)
        self.label_4.setGeometry(QtCore.QRect(30, 440, 61, 21))
        self.label_4.setObjectName("label_4")
        self.lineEdit_3 = QtWidgets.QLineEdit(self.centralwidget)
        self.lineEdit_3.setGeometry(QtCore.QRect(90, 440, 441, 21))
        self.lineEdit_3.setObjectName("lineEdit_3")
        self.label_5 = QtWidgets.QLabel(self.centralwidget)
        self.label_5.setGeometry(QtCore.QRect(50, 480, 41, 21))
        self.label_5.setObjectName("label_5")
        self.textEdit = QtWidgets.QTextEdit(self.centralwidget)
        self.textEdit.setGeometry(QtCore.QRect(90, 480, 441, 131))
        self.textEdit.setObjectName("textEdit")
        self.pushButton_4 = QtWidgets.QPushButton(self.centralwidget)
        self.pushButton_4.setGeometry(QtCore.QRect(230, 20, 81, 31))
        self.pushButton_4.setObjectName("pushButton_4")
        self.label_6 = QtWidgets.QLabel(self.centralwidget)
        self.label_6.setGeometry(QtCore.QRect(50, 400, 41, 21))
        self.label_6.setObjectName("label_6")
        self.lineEdit_4 = QtWidgets.QLineEdit(self.centralwidget)
        self.lineEdit_4.setGeometry(QtCore.QRect(90, 400, 441, 21))
        self.lineEdit_4.setObjectName("lineEdit_4")
        MainWindow.setCentralWidget(self.centralwidget)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "MainWindow"))
        item = self.tableWidget.horizontalHeaderItem(0)
        item.setText(_translate("MainWindow", "标题"))
        item = self.tableWidget.horizontalHeaderItem(1)
        item.setText(_translate("MainWindow", "发送者"))
        item = self.tableWidget.horizontalHeaderItem(2)
        item.setText(_translate("MainWindow", "时间"))
        item = self.tableWidget.horizontalHeaderItem(3)
        item.setText(_translate("MainWindow", "发送邮箱"))
        item = self.tableWidget.horizontalHeaderItem(4)
        item.setText(_translate("MainWindow", "内容"))
        self.label.setText(_translate("MainWindow", "收信箱："))
        self.pushButton.setText(_translate("MainWindow", "登录"))
        self.pushButton_2.setText(_translate("MainWindow", "发送邮件"))
        self.pushButton_3.setText(_translate("MainWindow", "退出"))
        self.label_2.setText(_translate("MainWindow", "标题："))
        self.label_3.setText(_translate("MainWindow", "发送者："))
        self.label_4.setText(_translate("MainWindow", "发送邮箱："))
        self.label_5.setText(_translate("MainWindow", "正文："))
        self.pushButton_4.setText(_translate("MainWindow", "刷新信箱"))
        self.label_6.setText(_translate("MainWindow", "时间："))
