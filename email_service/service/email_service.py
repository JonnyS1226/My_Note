# encoding: utf-8
import cfg.config as config
import mapper.db_utils as db_utils
import yagmail
from datetime import datetime, timedelta
import jinja2
import os

"""
邮件发送类
"""
HEFEN_D = os.path.abspath(os.path.dirname(__file__))


def send_weekly_email():
    email_sender = yagmail.SMTP(
        config.EMAIL_SENDER_NAME, password=config.EMAIL_SENDER_TOKEN,
        host=config.SMTP_SERVER)
    end_date = datetime.now()
    start_date = (end_date - timedelta(7)).date()
    end_date = end_date.date()
    words_all_init = db_utils.search_all(config.db_uri)
    words_init = db_utils.search_this_week(config.db_uri)

    words_similar = db_utils.search_similar(config.db_uri)
    mp = dict()
    for item in words_similar:
        key = item["set_number"]
        if mp.get(key) == None:
            mp[key] = [{
                "word": item["word"],
                "meaning": item["meaning"]
            }]
        else:
            mp[item["set_number"]].append({
                "word": item["word"],
                "meaning": item["meaning"]
            })
    print(mp)
    words_similar_str = []
    for k, v in mp.items():
        cnt = 0
        tmp = ""
        for item in v:
            tmp = tmp + item["word"] + ": " + item["meaning"] + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
            if cnt == 4:
                tmp += "<br>"
                cnt = 0
            cnt = cnt + 1
        words_similar_str.append(tmp)
    # print(words_similar_str)

    words = []
    words_all = []
    for i in range(0, len(words_init) - 1, 2):
        tmp = {
            "word1": words_init[i]["word"],
            "meaning1": words_init[i]["meaning"],
            "word2": words_init[i + 1]["word"],
            "meaning2": words_init[i + 1]["meaning"]
        }
        words.append(tmp)
    if len(words_init) % 2 == 1:
        words.append({
            "word1": words_init[len(words_init) - 1]["word"],
            "meaning1": words_init[len(words_init) - 1]["meaning"],
            "word2": "",
            "meaning2": ""
        })

    for i in range(0, len(words_all_init) - 1, 2):
        tmp = {
            "word1": words_all_init[i]["word"],
            "meaning1": words_all_init[i]["meaning"],
            "word2": words_all_init[i + 1]["word"],
            "meaning2": words_all_init[i + 1]["meaning"]
        }
        words_all.append(tmp)
    if len(words_all_init) % 2 == 1:
        words_all.append({
            "word1": words_all_init[len(words_all_init) - 1]["word"],
            "meaning1": words_all_init[len(words_all_init) - 1]["meaning"],
            "word2": "",
            "meaning2": ""
        })

    info = {
        "start_date": start_date,
        "end_date": end_date,
        "words": words,
        "words_all": words_all,
        "words_similar": words_similar_str
    }
    # content = render_mail(info)
    tm = jinja2.Template(open('../template/email_template_compress.html', encoding="utf-8").read())
    content = tm.render(info)
    email_sender.send(config.EMAIL_RECEIVER, '本周单词~', content)
    print("email_service send time: %s", datetime.now())


if __name__ == '__main__':
    send_weekly_email()
