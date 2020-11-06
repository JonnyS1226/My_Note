package utils

import (
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"time"
)

/**
数据库连接
 */

var MysqlDb *sql.DB
var MysqlDbErr error

// 数据源参数
const (
	USER_NAME = "root"
	PASS_WORD = "1933794630aa"
	HOST      = "localhost"
	PORT      = "3306"
	DATABASE  = "s_key_lab"
	CHARSET   = "utf8"
)

// 初始化链接
func init() {
	source := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=%s", USER_NAME, PASS_WORD, HOST, PORT, DATABASE, CHARSET)
	MysqlDb, MysqlDbErr = sql.Open("mysql", source)
	if MysqlDbErr != nil {
		panic("DataSource error: " + MysqlDbErr.Error())
	}
	// 最大连接数
	MysqlDb.SetMaxOpenConns(100)
	// 闲置连接数
	MysqlDb.SetMaxIdleConns(20)
	// 最大连接周期
	MysqlDb.SetConnMaxLifetime(100 * time.Second)
	if MysqlDbErr = MysqlDb.Ping(); nil != MysqlDbErr {
		panic("Connection error: " + MysqlDbErr.Error())
	}
}

