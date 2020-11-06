package utils

import (
	"crypto/md5"
	"encoding/hex"
	"fmt"
	"math/rand"
	"os"
	"time"
)
/**
一些如加密，产生随机串的工具
 */

// 注册时返回数据json格式
type ResponseData struct {
	Seed string
	SeqNum int
}

// 获取随机seed
func GetSeed(length int) string{
	str := "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	bytes := []byte(str)
	ans := []byte{}
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	for i := 0; i < length; i++ {
		ans = append(ans, bytes[r.Intn(len(bytes))])
	}
	return string(ans)
}

// n次MD5
func NMD5(text string, n int) string{
	s := text
	for i := 0; i < n; i++ {
		ctx := md5.New()
		ctx.Write([]byte(s))
		s = hex.EncodeToString(ctx.Sum(nil))
	}
	return s
}

// 得到S/KEY中的S
func GetS(password string, salt string) string {
	// 生成盐，并加盐hash
	str := NMD5(password+salt, 1)
	b, _ := hex.DecodeString(str)
	var S []byte
	// 再把16字节结果分为8字节长度的两部分，异或，得到8字节的字符串S
	for i := 0; i < 8; i++ {
		S = append(S, b[i] ^ b[i+8])
	}
	// 对S进行n次hash，得到初始口令，存入mysql
	return hex.EncodeToString(S)
}

// 写日志方法
func MyLog(msg string)  {
	f, err := os.OpenFile("log.log", os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0666)
	if err != nil {
		fmt.Println(err)
	}
	_, err = f.Write([]byte(msg + "\n"))
	if err != nil {
		fmt.Println(err)
	}
	f.Close()
}