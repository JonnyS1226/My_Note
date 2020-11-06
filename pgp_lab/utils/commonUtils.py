'''其他一些工具函数'''
def test_bits(number):
    num = 0
    if number == 0:
        return 1
    while number > 0:
        number = number >> 1
        num += 1
    # print(number, num)
    if num % 8 == 0:
        return num // 8
    else:
        return (num // 8)+1


def read_data(filename):
    text = []
    with open(filename, 'rb') as fp:
        while True:
            data = fp.read(8)
            if len(data) == 0:
                break
            if len(data) < 8:
                data_ulong = int.from_bytes(data, byteorder='big', signed=False)
                number = len(data)
                data_ulong = data_ulong << (64-8*number)
                text.append(data_ulong)
                break
            else:
                data_ulong = int.from_bytes(data, byteorder='big', signed=False)
                text.append(data_ulong)
    return text


def write_data(filename, text):
    with open(filename, 'wb') as fp:
        for i in range(0, len(text)):
            if text[i] >> 63 & 1:
                data = text[i]
                data = data.to_bytes(9, byteorder='big', signed=True)
                data = data[1:]
            else:
                data = text[i]
                data = data.to_bytes(8, byteorder='big', signed=True)
            fp.write(data)


def read_data_zero(filename):
    text = []
    zero_length = 0
    with open(filename, 'rb') as fp:
        while True:
            data = fp.read(8)
            if len(data) == 0:
                break
            data_ulong = int.from_bytes(data, byteorder='big', signed=False)
            text.append(data_ulong)
            if len(data) < 8:
                zero_length = len(data)
                break
    return text, zero_length


def write_data_zero(filename, text, zero_length):
    with open(filename, 'wb') as fp:
        for i in range(0, len(text)):
            if i == len(text)-1:
                if text[i] >> 63 & 1:
                    data = text[i]
                    data = data.to_bytes(9, byteorder='big', signed=True)
                    data = data[1:]
                else:
                    data = text[i]
                    zero_length = test_bits(data)
                    if data >> (zero_length*8-1) & 1:
                        data = data.to_bytes(zero_length+1, byteorder='big', signed=True)
                        data = data[1:]
                    else:
                        data = data.to_bytes(zero_length, byteorder='big', signed=True)
            else:
                if text[i] >> 63 & 1:
                    data = text[i]
                    data = data.to_bytes(9, byteorder='big', signed=True)
                    data = data[1:]
                else:
                    data = text[i]
                    data = data.to_bytes(8, byteorder='big', signed=True)
            fp.write(data)

