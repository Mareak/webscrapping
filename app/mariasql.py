import os
import mysql.connector as mariadb
from datetime import datetime 

mariadb_connection = mariadb.connect(host="mariadb",user=os.environ["MYSQL_USER"], password=os.environ["MYSQL_PASSWORD"], database=os.environ["MYSQL_DATABASE"])
cursor = mariadb_connection.cursor()

def create_table():
    try:
      cursor.execute("CREATE TABLE visit (ip VARCHAR(255), datetime VARCHAR(255))")
    except:
      return
    mariadb_connection.commit()
    return True


def insert_table(ip_add):
    create_table()
    
    cursor.execute("SELECT * from visit")
    result = cursor.fetchall()
    for all in result:
      if ip_add in all:
        return

    now = datetime.now()
    dt_string = now.strftime("%d/%m/%Y %H:%M:%S")
    sql = "INSERT INTO visit (ip, datetime) VALUES (%s, %s)"
    val = (ip_add, dt_string)
    cursor.execute(sql, val)
    mariadb_connection.commit()
    return True
