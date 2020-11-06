package utils

import "fmt"

/**
数据库操作工具
 */

// 用户结构体
type User struct {
	Id       int    `db:"id"`
	Username string `db:"username"`
	OTP      string `db:"current_otp"`
	N        int    `db:"total_n"`
	Index    int    `db:"current_index"`
	Salt 	 string	`db:"salt"`
}

// 根据username查user
func SelectUser(username string) (int, User) {
	user := new(User)
	row := MysqlDb.QueryRow("select * from users where username=?",username)
	if err :=row.Scan(&user.Id, &user.Username, &user.OTP, &user.N, &user.Index, &user.Salt); err != nil{
		return 0, *user
	}
	return 1, *user
}

// 插入user
func InsertUser(user *User) error{
	ret, err := MysqlDb.Exec("insert into `users`(username,current_otp,total_n,current_index,salt) values(?,?,?,?,?)",
		user.Username, user.OTP, user.N, user.Index, user.Salt)
	if err != nil {
		fmt.Println(err)
		return err
	}
	//更新主键id
	lastInsertID,_ := ret.LastInsertId()
	user.Id = int(lastInsertID)
	return nil
}

// 更新index
func UpdateIndex(index int, id int) {
	_, _ = MysqlDb.Exec("update users set current_index=? where id=?", index, id)
}

// 更新otp
func UpdateOTP(otp string, id int) {
	_, _ = MysqlDb.Exec("update users set current_otp=? where id=?", otp, id)
}



