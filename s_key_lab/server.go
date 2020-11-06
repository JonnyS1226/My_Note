package main

import (
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"net/url"
	"strconv"
	"time"
	"utils"
)

/**
S/KEY服务器
 */

type RegisterHandler struct {}
type LoginHandler struct {}
type CheckHandler struct {}

// 全局变量存n次hash(S)
var otp string

// 注册服务器监听函数
func (h *RegisterHandler) ServeHTTP(w http.ResponseWriter, r *http.Request)  {
	// 获取注册用户传来的数据
	body, _ := ioutil.ReadAll(r.Body)
	mp, _ := url.ParseQuery(string(body))
	if mp["type"][0] != "register" {
		fmt.Fprintf(w, "%s", "unknown error")
		return
	}
	n, _ := strconv.Atoi(mp["maxNum"][0])
	// 生成盐，并加盐hash
	salt := utils.GetSeed(5)
	// 对S进行n次hash，得到初始口令，存入user
	otp = utils.NMD5(utils.GetS(mp["plainPassword"][0], salt), n)
	user := utils.User{
		Id:       0,
		Username: mp["username"][0],
		OTP:      otp,
		N:        n,
		Index:    n,
		Salt:     salt,
	}
	// 开始注册
	res, _ := utils.SelectUser(user.Username)
	if res == 1 {
		fmt.Println("已存在该用户")
		fmt.Fprintf(w, "%s", "exist")
	} else {
		err := utils.InsertUser(&user)
		if err == nil {
			fmt.Fprintf(w, "%s", "success")
			msg := time.Now().Format("2006-01-02 15:04:05") + ":  用户"+
				string(user.Username) + " 成功注册"
			utils.MyLog(msg)
		} else {
			fmt.Fprintf(w, "%s", "failure")
			msg := time.Now().Format("2006-01-02 15:04:05") + ":  用户"+
				string(user.Username) + " 注册失败"
			utils.MyLog(msg)
		}
	}
}

// 登录服务器监听函数
func (h *LoginHandler) ServeHTTP(w http.ResponseWriter, r *http.Request)  {
	body, _ := ioutil.ReadAll(r.Body)
	mp, _ := url.ParseQuery(string(body))
	// 接收认证请求，发送seed和序列号
	if mp["type"][0] != "login" {
		fmt.Fprintf(w, "%s", "unknown error")
		return
	}
	res, user := utils.SelectUser(mp["username"][0])
	if res == 0 {
		fmt.Fprintf(w, "%s", "register first")
		return
	} else {
		user.Index -= 1
		if user.Index == 0 {
			// 重新约定
			fmt.Fprintf(w, "%s", "rearrange")
			utils.UpdateIndex(user.N, user.Id)
			utils.UpdateOTP(otp, user.Id)
			msg := time.Now().Format("2006-01-02 15:04:05") + ":  重新与用户"+
				string(user.Username) + " 约定口令序列"
			utils.MyLog(msg)
		}
		responseData := new(utils.ResponseData)
		responseData.Seed = user.Salt
		responseData.SeqNum = user.Index
		responseData_json, _ := json.Marshal(responseData)
		io.WriteString(w, string(responseData_json))
		msg := time.Now().Format("2006-01-02 15:04:05") + ":  "+
			" 成功向用户" + string(user.Username) + "发送种子"
		utils.MyLog(msg)
	}
}

// 校验密码
func (h *CheckHandler) ServeHTTP(w http.ResponseWriter, r *http.Request)  {
	// 接收登录数据
	body, _ := ioutil.ReadAll(r.Body)
	mp, _ := url.ParseQuery(string(body))
	_, user := utils.SelectUser(mp["username"][0])
	if utils.NMD5(mp["otp"][0], 1) == user.OTP {
		fmt.Fprintf(w, "%s", "login success")
		utils.UpdateOTP(mp["otp"][0], user.Id)
		utils.UpdateIndex(user.Index-1, user.Id)
		msg := time.Now().Format("2006-01-02 15:04:05") + ":  用户"+
			string(user.Username) + " 登录成功"
		utils.MyLog(msg)
	} else {
		fmt.Fprintf(w, "%s", "login failure")
		msg := time.Now().Format("2006-01-02 15:04:05") + ":  用户"+
			string(user.Username) + " 登录失败"
		utils.MyLog(msg)
	}
}

func main() {
	register := RegisterHandler{}
	login := LoginHandler{}
	check := CheckHandler{}
	server := http.Server{
		Addr: "127.0.0.1:8080",
	}
	http.Handle("/register", &register)
	http.Handle("/login", &login)
	http.Handle("/check", &check)
	fmt.Println("服务器已启动...")
	server.ListenAndServe()
}
