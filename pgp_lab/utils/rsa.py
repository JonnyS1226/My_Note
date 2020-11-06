import random
prime_list = [23, 37, 97, 17, 41, 61]
sig_n = 0x7df31163c6b5723f14862f04843bb2fd7affe6412cbcc640feb146f3437a1d51
sig_pub = 0x6949e8de6272337dc7e9642ab23519fca09432f39ccd27e868848c2314dab075
sig_pri = 0x7275fd00a88da6a08e21ae262361e187bb3e32499f37cf6f8148b9445291b149
key_n = 0x448cbdb3e167fd099e52b31f065ff17dadcc108581cc6ae75cd9a16b6a2cf165
key_pub = 0x2db1e79e8962443a9a2beb421fcbbed50257b57e256ae0d41e07b7355c03c90b
key_pri = 0x22f447849e5ea5c0502eb494e4174b3daf653aae2b484ef0e92dcdc693e34223

def quick_pow(a, b, n):
    """快速幂"""
    if b == 1:
        return a
    if b & 1 == 0:
        c = quick_pow(a, b//2, n)
        return c*c % n
    else:
        c = quick_pow(a, b//2, n)
        return c*c*a % n


def encrypt(plain_text, public_key, mod_n):
    return quick_pow(plain_text, public_key, mod_n)


def decrypt(plain_text, private_key, mod_n):
    return quick_pow(plain_text, private_key, mod_n)


def RM_prime(input_number):
    """判断gcd(e, fai n) == 1"""
    n = input_number
    input_number -= 1
    k = 0
    while input_number & 1 == 0:
        input_number = input_number >> 1
        k += 1
    flag = False
    for a in prime_list:
        b = quick_pow(a, input_number, n)
        if abs(b) == 1:
            flag = True
        for i in range(k-1):
            b = quick_pow(b, 2, n)
            if abs(b) == 1:
                flag = True
        if flag is False:
            return False
        flag = False
    return True


def generate():
    """产生一个e"""
    prime = random.randint(1 << 126, 1 << 128)
    while True:
        if RM_prime(prime) is True:
            break
        else:
            prime = random.randint(1 << 126, 1 << 128)
    return prime


def gcd(a, b):
    if b == 0:
        return a
    g = gcd(b, a % b)
    return g


def ex_gcd(a, b, arr):
    """扩展欧几里得"""
    if b == 0:
        arr[0] = 1
        arr[1] = 0
        return a
    g = ex_gcd(b, a % b, arr)
    t = arr[0]
    arr[0] = arr[1]
    arr[1] = t - int(a / b) * arr[1]
    return g


def mod_reverse(a, n):
    arr = [0, 1]
    ex_gcd(a, n, arr)
    return (arr[0] % n + n) % n


def RSA(plain_text):
    q = generate()
    p = generate()
    while p == q:
        p = generate()
    n = (p-1) * (q-1)
    d = random.randint(1 << 63, n)
    while gcd(n, d) != 1:
        d = random.randint(1 << 63, n)
    e = mod_reverse(d, n)
    mod_n = q * p

    print('The public key is ', hex(mod_n), hex(e))
    print('The private key is ', hex(p), hex(q), hex(d))

    cipher = encrypt(plain_text, d, mod_n)
    plain = decrypt(cipher, e, mod_n)
    print("cipher : ", cipher)
    print("plain : ", plain)


def rsa(mode, plain):
    if mode == 1:  # 私钥签名
        signature = encrypt(plain, sig_pri, sig_n)
        return signature
    elif mode == 2:  # 公钥验证
        value = decrypt(plain, sig_pub, sig_n)
        return value
    elif mode == 3:  # 公钥加密
        cipher = encrypt(plain, key_pub, key_n)
        return cipher
    elif mode == 4:  # 私钥解密
        plain = decrypt(plain, key_pri, key_n)
        return plain

print()
