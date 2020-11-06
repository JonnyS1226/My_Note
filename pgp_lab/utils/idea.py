import utils.rsa as rsa
key_idea = 0x2BD6459F82C5B300952C49104881FF49

# idea对称加密 密钥长度为128bit(16字节)，以每64bit(8字节)为单位进行加密。

def _sub(x):
    """"""
    return (1 << 16)-x


def _reverse(x):
    if x == 0:
        return 0
    return rsa.mod_reverse(x, (1 << 16)+1)


def _mul(x, y):
    assert 0 <= x <= 0xFFFF
    assert 0 <= y <= 0xFFFF

    if x == 0:
        x = 0x10000
    if y == 0:
        y = 0x10000

    r = (x * y) % 0x10001

    if r == 0x10000:
        r = 0

    assert 0 <= r <= 0xFFFF
    return r


def _KA_layer(x1, x2, x3, x4, round_keys):
    assert 0 <= x1 <= 0xFFFF
    assert 0 <= x2 <= 0xFFFF
    assert 0 <= x3 <= 0xFFFF
    assert 0 <= x4 <= 0xFFFF
    z1, z2, z3, z4 = round_keys[0:4]
    assert 0 <= z1 <= 0xFFFF
    assert 0 <= z2 <= 0xFFFF
    assert 0 <= z3 <= 0xFFFF
    assert 0 <= z4 <= 0xFFFF

    y1 = _mul(x1, z1)
    y2 = (x2 + z2) % 0x10000
    y3 = (x3 + z3) % 0x10000
    y4 = _mul(x4, z4)

    return y1, y2, y3, y4


def _MA_layer(y1, y2, y3, y4, round_keys):
    assert 0 <= y1 <= 0xFFFF
    assert 0 <= y2 <= 0xFFFF
    assert 0 <= y3 <= 0xFFFF
    assert 0 <= y4 <= 0xFFFF
    z5, z6 = round_keys[4:6]
    assert 0 <= z5 <= 0xFFFF
    assert 0 <= z6 <= 0xFFFF

    p = y1 ^ y3
    q = y2 ^ y4

    s = _mul(p, z5)
    t = _mul((q + s) % 0x10000, z6)
    u = (s + t) % 0x10000

    x1 = y1 ^ t
    x2 = y2 ^ u
    x3 = y3 ^ t
    x4 = y4 ^ u

    return x1, x2, x3, x4


class IDEA:
    def __init__(self, key):
        self._keys = None
        self._dkeys = None
        self.change_key(key)
        self.generate_key()

    def change_key(self, key):
        assert 0 <= key < (1 << 128)
        modulus = 1 << 128

        sub_keys = []
        for i in range(9 * 6):
            sub_keys.append((key >> (112 - 16 * (i % 8))) % 0x10000)
            if i % 8 == 7:
                key = ((key << 25) | (key >> 103)) % modulus

        keys = []
        for i in range(9):
            round_keys = sub_keys[6 * i: 6 * (i + 1)]
            keys.append(tuple(round_keys))
        self._keys = tuple(keys)

    def generate_key(self):
        self._dkeys = list()
        for i in range(8, 0, -1):
            round_key = list()
            round_key.append(_reverse(self._keys[i][0]))
            if i == 8:
                round_key.append(_sub(self._keys[i][1]))
                round_key.append(_sub(self._keys[i][2]))
            else:
                round_key.append(_sub(self._keys[i][2]))
                round_key.append(_sub(self._keys[i][1]))
            round_key.append(_reverse(self._keys[i][3]))
            round_key.append(self._keys[i-1][4])
            round_key.append(self._keys[i-1][5])
            self._dkeys.append(round_key)
        round_key = list()
        round_key.append(_reverse(self._keys[0][0]))
        round_key.append(_sub(self._keys[0][1]))
        round_key.append(_sub(self._keys[0][2]))
        round_key.append(_reverse(self._keys[0][3]))
        self._dkeys.append(round_key)

    def encrypt(self, plaintext):
        assert 0 <= plaintext < (1 << 64)
        x1 = (plaintext >> 48) & 0xFFFF
        x2 = (plaintext >> 32) & 0xFFFF
        x3 = (plaintext >> 16) & 0xFFFF
        x4 = plaintext & 0xFFFF

        for i in range(8):
            round_keys = self._keys[i]

            y1, y2, y3, y4 = _KA_layer(x1, x2, x3, x4, round_keys)
            x1, x2, x3, x4 = _MA_layer(y1, y2, y3, y4, round_keys)

            x2, x3 = x3, x2

        y1, y2, y3, y4 = _KA_layer(x1, x3, x2, x4, self._keys[8])

        ciphertext = (y1 << 48) | (y2 << 32) | (y3 << 16) | y4
        return ciphertext

    def decrypt(self, ciphertext):
        assert 0 <= ciphertext < (1 << 64)
        x1 = (ciphertext >> 48) & 0xFFFF
        x2 = (ciphertext >> 32) & 0xFFFF
        x3 = (ciphertext >> 16) & 0xFFFF
        x4 = ciphertext & 0xFFFF

        for i in range(8):
            round_keys = self._dkeys[i]

            y1, y2, y3, y4 = _KA_layer(x1, x2, x3, x4, round_keys)
            x1, x2, x3, x4 = _MA_layer(y1, y2, y3, y4, round_keys)

            x2, x3 = x3, x2

        y1, y2, y3, y4 = _KA_layer(x1, x3, x2, x4, self._dkeys[8])

        plaintext = (y1 << 48) | (y2 << 32) | (y3 << 16) | y4
        return plaintext


def encrypt(plain):
    key = key_idea  # 一个数字4位，128位
    my_IDEAe = IDEA(key)
    cipher = my_IDEAe.encrypt(plain)
    return cipher


def decrypt(plain, key):
    my_IDEAd = IDEA(key)
    cipher = my_IDEAd.decrypt(plain)
    return cipher


def main():
    keyy = 0x2BD6459F82C5B300952C49104881FF49  # 一个数字4位，128位
    plain = 0xF129A6601EF62A47
    cipher = 0xEA024714AD5C4D84
    print('key\t\t', hex(keyy))
    print('plaintext\t', hex(plain))
    my_IDEA = IDEA(keyy)
    my_IDEA.generate_key()
    encrypted = my_IDEA.encrypt(plain)
    print('ciphertext\t', hex(encrypted))
    print(hex(my_IDEA.decrypt(encrypted)))


if __name__ == '__main__':
    main()
