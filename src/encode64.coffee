do (window = window) ->
  ENCODE_MAP = [
    '0', '1', '2', '3', '4', '5', '6', '7'
    '8', '9', ':', ';', 'A', 'B', 'C', 'D'
    'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'
    'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T'
    'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b'
    'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'
    'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r'
    's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
  ]

  DECODE_MAP =
    '0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7
    '8': 8, '9': 9, ':':10, ';':11, 'A':12, 'B':13, 'C':14, 'D':15
    'E':16, 'F':17, 'G':18, 'H':19, 'I':20, 'J':21, 'K':22, 'L':23
    'M':24, 'N':25, 'O':26, 'P':27, 'Q':28, 'R':29, 'S':30, 'T':31
    'U':32, 'V':33, 'W':34, 'X':35, 'Y':36, 'Z':37, 'a':38, 'b':39
    'c':40, 'd':41, 'e':42, 'f':43, 'g':44, 'h':45, 'i':46, 'j':47
    'k':48, 'l':49, 'm':50, 'n':51, 'o':52, 'p':53, 'q':54, 'r':55
    's':56, 't':57, 'u':58, 'v':59, 'w':60, 'x':61, 'y':62, 'z':63

  POW_10 = [
    1.0
    10.0
    100.0
    1000.0
    10000.0
    100000.0
    1000000.0
    10000000.0
  ]

  # low level encoding/decoding
  encode = (num, len) ->
    code = ''
    if num?
      for i in [0...len]
        code = ENCODE_MAP[num & 0x3F] + code
        num >>= 6
    else
      code += '_' for i in [0...len]
    code

  decode = (str, offs, len) ->
    num = 0
    for i in [offs ... offs + len]
      n = DECODE_MAP[str[i]]
      return if n == undefined
      num = (num << 6) + n
    num

  # encoding/decoding for various numbers
  encodeSigned = (n, len) ->
    n = n + (1 << len * 6 - 1) if n?
    encode n, len

  encodeFloat = (f, len, dec) ->
    f = Math.floor(f * POW_10[dec]) if f?
    encode f, len

  encodeSignedFloat = (f, len, dec) ->
    f = Math.floor(f * POW_10[dec]) + (1 << len * 6 - 1) if f?
    encode f, len

  decodeSigned = (str, offs, len) ->
    n = decode(str, offs, len)
    return if n == undefined
    n - (1 << len * 6 - 1)

  decodeFloat = (str, offs, len, dec) ->
    n = decode(str, offs, len)
    return if n == undefined
    n / POW_10[dec]

  decodeSignedFloat = (str, offs, len, dec) ->
    n = decodeSigned(str, offs, len)
    return if n == undefined
    n / POW_10[dec]

  # sequencial decoding with format spec
  dataSize = (fmt) ->
    len = 0
    len += f[1] for f in fmt
    len

  decodeFormat = (fmt, str, offs = 0) ->
    data = []
    for f in fmt
      data.push switch f[0]
        when 'N' then decode str, offs, f[1]
        when 'n' then decodeSigned str, offs, f[1]
        when 'F' then decodeFloat str, offs, f[1], f[2]
        when 'f' then decodeSignedFloat str, offs, f[1], f[2]
      offs += f[1]
    data

  window.Encode64 =
    encode: encode
    decode: decode

    encodeSigned: encodeSigned
    encodeFloat: encodeFloat
    encodeSignedFloat: encodeSignedFloat

    decodeSigned: decodeSigned
    decodeFloat: decodeFloat
    decodeSignedFloat: decodeSignedFloat

    dataSize: dataSize
    decodeFormat: decodeFormat

