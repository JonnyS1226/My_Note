#encoding: utf-8

import pymysql
import cfg.config as config
from datetime import datetime, timedelta
"""
数据库类
"""


def create_conn(db_uri: dict):
    connection = pymysql.connect(
        host=db_uri["host"],
        user=db_uri["username"],
        password=db_uri["password"],
        database=db_uri["database"],
        charset=db_uri["charset"],
        cursorclass=pymysql.cursors.DictCursor
    )
    return connection


def insert(db_uri, val):
    connection = create_conn(db_uri)
    with connection:
        with connection.cursor() as cursor:
            sql = "insert into word_list(`word`, `meaning`) values (%s, %s)"
            cursor.executemany(sql, val)
        connection.commit()


def insert_similar(db_uri, val):
    connection = create_conn(db_uri)
    with connection:
        with connection.cursor() as cursor:
            sql = "insert into word_similar(`word`, `meaning`, `set_number`) values (%s, %s, %s)"
            cursor.executemany(sql, val)
        connection.commit()


def search_similar(db_uri):
    connection = create_conn(db_uri)
    with connection:
        with connection.cursor() as cursor:
            sql = "select `word`, `meaning`, `set_number` from word_similar"
            cursor.execute(sql)
            results = cursor.fetchall()
            # print(results)
    return results


def search_all(db_uri):
    connection = create_conn(db_uri)
    with connection:
        with connection.cursor() as cursor:
            sql = "select `word`, `meaning` from word_list"
            cursor.execute(sql)
            results = cursor.fetchall()
            # print(results)
    return results


def search_this_week(db_uri):
    connection = create_conn(db_uri)
    with connection:
        with connection.cursor() as cursor:
            time_now = datetime.now()
            time_last = time_now - timedelta(7)
            time_filter_last = datetime.combine(time_last.date(), datetime.min.time())
            sql = "select `word`, `meaning` from word_list where `insert_time` >= %s"
            cursor.execute(sql, (time_filter_last, ))
            results = cursor.fetchall()
            # print(results)
    return results


if __name__ == '__main__':
    # word_list = []
    # option = input()
    # if option == "similar":
    #     inp = input()
    #     while inp != "*":
    #         inp_three = inp.split(" ")
    #         word = (inp_three[0], inp_three[1], inp_three[2])
    #         word_list.append(word)
    #         print(word_list)
    #         inp = input()
    #     insert_similar(config.db_uri, word_list)
    # elif option == "normal":
    #     inp = input()
    #     while inp != "*":
    #         inp_two = inp.split(" ")
    #         word = (inp_two[0], inp_two[1])
    #         word_list.append(word)
    #         print(word_list)
    #         inp = input()
    #     insert(config.db_uri, word_list)
    print(search_similar(config.db_uri))

