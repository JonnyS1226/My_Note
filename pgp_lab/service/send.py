import utils.idea as idea
import utils.base64 as base64
import utils.md5 as md5
import utils.rsa as rsa
import utils.commonUtils as commonUtils
import zipfile
import os
import base64



def divide(number, num):
    sig = []
    while number > 0:
        tmp = number & (1 << num)-1
        sig.append(tmp)
        number = number >> num
    return sig


def zip_ya(start_dir):
    start_dir = start_dir  # 要压缩的文件夹路径
    file_news = start_dir + '.zip'  # 压缩后文件夹的名字

    z = zipfile.ZipFile(file_news, 'w', zipfile.ZIP_DEFLATED)
    for dir_path, dir_names, file_names in os.walk(start_dir):
        f_path = dir_path.replace(start_dir, '')  # 这一句很重要，不replace的话，就从根目录开始复制
        f_path = f_path and f_path + os.sep or ''  # 实现当前文件夹以及包含的所有文件的压缩
        for filename in file_names:
            z.write(os.path.join(dir_path, filename), f_path + filename)
    z.close()
    return file_news


def int_list2str(input_int_list):
    local_string = ''
    local_int_list = list(input_int_list)
    for li in local_int_list:
        tmp = ''
        while li > 0:
            char = li & 0xffff
            tmp = chr(char) + tmp
            li = li >> 16
        local_string += tmp
    return local_string


def make_message1(text):
    # 从源文件读入数据
    with open('example.txt', 'w') as fp:
        fp.write(text[0:-1])
    r, zero_length = commonUtils.read_data_zero('example.txt')  # 一个列表，每个元素是一个64位的整数，最后一个数可能小于64位
    string = int_list2str(r)
    # 计算哈希值
    hash_value = md5.cal_hash(string)  # 这里需要做一个转换，使位数符合要求
    # 对哈希值签名
    signature = rsa.rsa(1, hash_value)  # 一个数值，位数小于256位
    sig_list = divide(signature, 64)
    # 将签名放到明文后面
    for i in sig_list:
        r.append(i)
    # 写入文件并压缩
    file = os.getcwd() + '\plain'
    commonUtils.write_data(os.getcwd() + '\plain\plain.txt', r)
    zip_ya(file)

    # 从压缩文件中读出并加密
    r = commonUtils.read_data('plain.zip')
    cipher = []
    for i in r:
        cipher.append(idea.encrypt(i))  # 一个数组，每个元素是加密后的64位的数
        print(hex(i))
    # 将密钥加密
    key = rsa.rsa(3, idea.key_idea)
    key_list = divide(key, 64)
    for i in key_list:  # r中的每个元素都是小于64位的
        cipher.append(i)

    # base64编码
    final_str = base64.encode_list(cipher)
    with open('send.txt', 'w') as fp:
        fp.write(final_str)

    print("密文" + final_str)

    return final_str

def make_message2(text):
    with open('example2.txt', 'w') as fp:
        fp.write(text[0:-1])
    # 从源文件读入数据
    r, zero_length = commonUtils.read_data_zero('example2.txt')  # 一个列表，每个元素是一个64位的整数，最后一个数可能小于64位
    string = int_list2str(r)
    # 计算哈希值
    hash_value = md5.cal_hash(string)  # 这里需要做一个转换，使位数符合要求
    # 对哈希值签名
    signature = rsa.rsa(1, hash_value)  # 一个数值，位数小于256位
    sig_list = divide(signature, 64)
    # 将签名放到明文后面
    for i in sig_list:
        r.append(i)
    # 写入文件并压缩
    file = os.getcwd() + '\plain2'
    commonUtils.write_data(os.getcwd() + '\plain\plain2.txt', r)
    zip_ya(file)

    # 从压缩文件中读出并加密
    r = commonUtils.read_data('plain2.zip')
    cipher = []
    for i in r:
        cipher.append(idea.encrypt(i))  # 一个数组，每个元素是加密后的64位的数
        print(hex(i))
    # 将密钥加密
    key = rsa.rsa(3, idea.key_idea)
    key_list = divide(key, 64)
    for i in key_list:  # r中的每个元素都是小于64位的
        cipher.append(i)

    # base64编码
    final_str = base64.encode_list(cipher)
    with open('send2.txt', 'w') as fp:
        fp.write(final_str)

    print("密文" + final_str)

    return final_str


def sed(subject, content):

    bytes = subject.encode("utf-8")
    crypt_subject = base64.b64encode(bytes)
    bytes = content.encode("utf-8")
    crypt_content = base64.b64encode(bytes)
    return crypt_subject, crypt_content


