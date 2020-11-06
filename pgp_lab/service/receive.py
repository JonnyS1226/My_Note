import utils.idea as idea
import utils.base64 as base64
import utils.md5 as md5
import utils.rsa as rsa
import utils.commonUtils as commonUtils
import zipfile
import base64
from Crypto.Cipher import AES
key = '1234567890123456'
mode = AES.MODE_CBC

def un_zip(file_name):
    zip_file = zipfile.ZipFile(file_name)
    for names in zip_file.namelist():
        zip_file.extract(names)  # 加入到某个文件夹中 zip_file.extract(names,file_name.split(".")[0])
    zip_file.close()


def int_list2str(input_int_list):
    string = ''
    local_int_list = list(input_int_list)
    for li in local_int_list:
        tmp = ''
        while li > 0:
            char = li & 0xffff
            tmp = chr(char) + tmp
            li = li >> 16
        string += tmp
    return string


def receive_message1(zero_length, data):
    # base64解码
    int_list = base64.decode_string(data)

    # 从文件中恢复出密钥
    key = (int_list[-1] << 192) + (int_list[-2] << 128) + (int_list[-3] << 64) + int_list[-4]
    key = rsa.rsa(4, key)
    # 对明文解密
    plain_list = []
    for i in range(len(int_list) - 4):
        plain = idea.decrypt(int_list[i], key)  # IDEA解密
        plain_list.append(plain)

    # 写文件
    # for i in plain_list:
        # print(hex(i))
    commonUtils.write_data('pplain.zip', plain_list)  # 这里可以直接用write因为zip文件对末尾的0不敏感
    # 文件解压
    un_zip('pplain.zip')
    # 读出txt
    plain = commonUtils.read_data('plain.txt')
    # 从文件中恢复出签名和明文
    sig = (plain[-1] << 192) + (plain[-2] << 128) + (plain[-3] << 64) + plain[-4]
    # 输出明文
    commonUtils.write_data_zero('raw.txt', plain[:-4], zero_length)  # 这里需要用zero因为要去掉高位的0
    # 计算明文的哈希值
    plain_str = int_list2str(plain[:-4])
    hash_value = md5.cal_hash(plain_str)  # 这里需要做一个转换，使位数符合要求
    # 对签名验证，完整性验证
    sig2hash = rsa.rsa(2, sig)
    if sig2hash != hash_value:
        return -1
    else:
        with open('raw.txt', 'r') as fp:
            message = fp.read()
            message = message.strip('\0')
            print(message)
            return message


def receive_message2(zero_length, data):
    # base64解码
    int_list = base64.decode_string(data)

    # 从文件中恢复出密钥
    key = (int_list[-1] << 192) + (int_list[-2] << 128) + (int_list[-3] << 64) + int_list[-4]
    key = rsa.rsa(4, key)
    # 对明文解密
    plain_list = []
    for i in range(len(int_list) - 4):
        plain = idea.decrypt(int_list[i], key)  # IDEA解密
        plain_list.append(plain)

    # 写文件
    # for i in plain_list:
        # print(hex(i))
    commonUtils.write_data('pplain2.zip', plain_list)  # 这里可以直接用write因为zip文件对末尾的0不敏感
    # 文件解压
    un_zip('pplain2.zip')
    # 读出txt
    plain = commonUtils.read_data('plain.txt')
    # 从文件中恢复出签名和明文
    sig = (plain[-1] << 192) + (plain[-2] << 128) + (plain[-3] << 64) + plain[-4]
    # 输出明文
    commonUtils.write_data_zero('raw2.txt', plain[:-4], zero_length)  # 这里需要用zero因为要去掉高位的0
    # 计算明文的哈希值
    plain_str = int_list2str(plain[:-4])
    hash_value = md5.cal_hash(plain_str)  # 这里需要做一个转换，使位数符合要求
    # 对签名验证，完整性验证
    sig2hash = rsa.rsa(2, sig)
    if sig2hash != hash_value:
        return -1
    else:
        with open('raw2.txt', 'r') as fp:
            message = fp.read()
            message = message.strip('\0')
            print(message)
            return message
def add_to_16(par):
    par = par.encode() #先将字符串类型数据转换成字节型数据
    while len(par) % 16 != 0: #对字节型数据进行长度判断
        par += b'\x00' #如果字节型数据长度不是16倍整数就进行 补充
    return par

def rece(data):
    for i in range(len(data)):
        data[i]['subject'] = base64.b64decode(data[i]['subject']).decode('utf-8')
        print(data[i]['subject'])
        data[i]['content'] = base64.b64decode(data[i]['content']).decode('utf-8')
        print(data[i]['content'])

