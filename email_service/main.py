#encoding: utf-8

import time
from datetime import datetime
import schedule
import service.email_service as job

if __name__ == '__main__':
    schedule.every().monday.at("17:00").do(job.send_weekly_email)
    # schedule.every().tuesday.at("10:56").do(job.send_weekly_email)
    while True:
        schedule.run_pending()
        time.sleep(1)

