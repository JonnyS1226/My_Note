#encoding:utf-8
import pymysql
from dao.dbConfig import localSourceConfig as localConfig
import service.send
import service.receive
import rsa
import random
import hashlib

class MailDB:
    def __init__(self,config=localConfig):
        self.db = pymysql.connect(host=config['host'],port=config['port'],user=config['user'],
                                      passwd=config['passwd'],db=config['db'],charset=config['charset'],
                                      cursorclass=config['cursorclass'])
        self.cursor = self.db.cursor()
        self.cursor.execute("SELECT VERSION()")
        data = self.cursor.fetchone()
        print("Database version : %s " % data['VERSION()'])

    def search(self, username):
        self.cursor.execute("select * from email where `to`=%s order by `time` desc", (username))
        data = self.cursor.fetchall()
        print(data)
        service.receive.rece(data)
        return data

    def insertMail(self, fromUsername, toUsername, subject, content):
        # 对subject和content PGP加密
        crypt_subject, crypt_content = service.send.sed(subject,content)
        self.cursor.execute("insert into email(`from`, `to`, subject, content) values(%s, %s, %s, %s)",
                            (fromUsername, toUsername, crypt_subject, crypt_content))
        self.db.commit()
        return True

    def searchRows(self, username):
        self.cursor.execute("select count(*) from email where `to`=%s", (username))
        data = self.cursor.fetchall()
        return data

    def searchUser(self, username):
        self.cursor.execute("select * from `user` where `username`=%s", username)
        data = self.cursor.fetchall()
        print(data)
        return data

    def login(self, username, password):
        self.cursor.execute("select * from `user` where `username`=%s", (username))
        data = self.cursor.fetchall()
        password = password + data[0]['salt']
        hash = hashlib.md5()
        hash.update(password.encode("utf8"))
        password = hash.hexdigest()
        self.cursor.execute("select * from `user` where `username`=%s and password=%s", (username, password))
        data = self.cursor.fetchall()
        return data

    def insertUser(self, username, password):
        s_key_public, s_key_private = rsa.newkeys(64)
        e_key_public, e_key_private = rsa.newkeys(64)
        s_key_public = str(s_key_public.n)
        e_key_public = str(e_key_public.n)
        s_key_private = str(s_key_private.d)
        e_key_private = str(e_key_private.d)
        salt = random.sample('zyxwvutsrqponmlkjihgfedcba',5)
        salt = "".join(salt)
        password = password + "".join(salt)
        hash = hashlib.md5()
        hash.update(password.encode("utf8"))
        password = str(hash.hexdigest())
        print(password, username, salt)
        self.cursor.execute("insert into `user`(username, password,s_key_public, e_key_public,salt) values(%s, %s,%s,%s, %s)",
                            (username,password,s_key_public, e_key_public, salt))
        self.db.commit()
        self.cursor.execute("insert into `user_private`(username, s_key_private, e_key_private) values (%s, %s, %s)",
                            (username, s_key_private, e_key_private))
        self.db.commit()
        return True

    def searchPK(self, username):
        self.cursor.execute("select s_key_public, e_key_public from user where username=%s", username)
        data = self.cursor.fetchall()
        return data

    def searchSK(self, username):
        self.cursor.execute("select s_key_private, e_key_private from user_private where username=%s", username)
        data = self.cursor.fetchall()
        return data

