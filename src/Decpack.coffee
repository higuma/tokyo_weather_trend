# Decpack JavaScript implementation (decoder only)

# internal: same as jQuery.type
type = (obj) -> Object::toString.call(obj).slice(8, -1).toLowerCase()

# internal: decimal digits to bit width
log = Math.log
ceil = Math.ceil
LOG10_LOG2 = log(10) / log(2)

D2B = (d) -> ceil(LOG10_LOG2 * d)
d2b = (d) -> ceil(LOG10_LOG2 * d) + 1

# internal: parse format string to internal representation
RE_FORMAT = /^(?:([BbDd])(\d+)|([RrFf])(\d+)\.(\d+))(.*)$/
INT_METHODS = ['B', 'b', 'D', 'd']

parseFormat = (format) ->
  parsed = []
  while re = RE_FORMAT.exec(format)
    if INT_METHODS.indexof(re[1]) != -1
      parsed.push [re[1], parseInt(re[2])]
    else
      parsed.push [re[3], parseInt(re[4]), parseInt(re[5])]
    format = re[6]
  parsed

# text (6bit) decoding engine
DECODE_MAP =
  '0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7
  '8': 8, '9': 9, 'A':10, 'B':11, 'C':12, 'D':13, 'E':14, 'F':15
  'G':16, 'H':17, 'I':18, 'J':19, 'K':20, 'L':21, 'M':22, 'N':23
  'O':24, 'P':25, 'Q':26, 'R':27, 'S':28, 'T':29, 'U':30, 'V':31
  'W':32, 'X':33, 'Y':34, 'Z':35, 'a':36, 'b':37, 'c':38, 'd':39
  'e':40, 'f':41, 'g':42, 'h':43, 'i':44, 'j':45, 'k':46, 'l':47
  'm':48, 'n':49, 'o':50, 'p':51, 'q':52, 'r':53, 's':54, 't':55
  'u':56, 'v':57, 'w':58, 'x':59, 'y':60, 'z':61, '-':62, '_':63

class Decoder6
  constructor: (@data) ->       # @data = String
    @bit_off = @byte_off = 0
    @

  isText: -> true
  isBinary: -> false
  supportEof: -> false

  decode: (w) ->
    n = 0
    if @bit_off > 0
      n = DECODE_MAP[@data[@byte_off]] & (1 << 6 - @bit_off) - 1
      if @bit_off + w < 6
        @bit_off += w
        return n >> 6 - @bit_off
      w -= 6 - @bit_off
      @byte_off += 1
    while w >= 6
      n = (n << 6) + DECODE_MAP[@data[@byte_off]]
      w -= 6
      @byte_off += 1
    n = (n << w) + (DECODE_MAP[@data[@byte_off]] >> 6 - w) if w > 0
    @bit_off = w
    n

class Decoder6E extends Decoder6
  constructor: (@data) ->
    super
    throw 'size too short' if @data.length < 4
    @bits_read = 0
    @size = 30
    @size = @decode 30
    @bits_read = 0
    @

  supportEof: -> true

  eof: -> @bits_read >= @size

  decode: (w) ->
    throw 'end of data' if (@bits_read += w) > @size
    super

# binary (8bit) decoding engine
class Decoder8
  constructor: (@data) ->   # @data = Uint8Array(browser) or Buffer(node.js)
    @bit_off = @byte_off = 0
    @

  isText: -> false
  isBinary: -> true
  supportEof: -> false

  decode: if window?
    (w) ->      # browser
      n = 0
      if @bit_off > 0
        n = @data[@byte_off] & (1 << 8 - @bit_off) - 1
        if @bit_off + w < 8
          @bit_off += w
          return n >> 8 - @bit_off
        w -= 8 - @bit_off
        @byte_off += 1
      while w >= 8
        n = (n << 8) + @data[@byte_off]
        w -= 8
        @byte_off += 1
      n = (n << w) + (@data[@byte_off] >> 8 - w) if w > 0
      @bit_off = w
      n
  else
    (w) ->      # node.js
      n = 0
      if @bit_off > 0
        n = @data.readUInt8(@byte_off) & (1 << 8 - @bit_off) - 1
        if @bit_off + w < 8
          @bit_off += w
          return n >> 8 - @bit_off
        w -= 8 - @bit_off
        @byte_off += 1
      while w >= 8
        n = (n << 8) + @data.readUInt8(@byte_off)
        w -= 8
        @byte_off += 1
      n = (n << w) + (@data.readUInt8(@byte_off) >> 8 - w) if w > 0
      @bit_off = w
      n

class Decoder8E extends Decoder8
  constructor: (@data) ->
    super
    throw 'size too short' if @data.length < 4
    @bits_read = 0
    @size = 32
    @size = @decode 32
    @bits_read = 0
    @

  support_eof: -> true

  eof: -> @bits_read >= @size

  decode: (w) ->
    throw 'exceeds end of data' if (@bits_read += w) > @size
    super

# decoder interface
POW_10 = [
  1.0
  0.1
  0.01
  0.001
  0.0001
  0.00001
  0.000001
  0.0000001
  0.00000001
  0.000000001
  0.0000000001
]

class Unpack                    # no nil
  constructor: (input, use_eof) ->
    ctor = if type(input) == 'string'
      if use_eof then Decoder6E else Decoder6
    else
      if use_eof then Decoder8E else Decoder8
    @dec = new ctor input
    @

  isText: -> @dec.isText()
  isBinary: -> @dec.isBinary()
  supportEof: -> @dec.supportEof()
  useNil: -> false

  eof: -> @dec.eof()

  raw: (w) -> @dec.decode(w)
  B: (w) -> @raw(w)
  b: (w) -> @raw(w) - (1 << w - 1)
  R: (w, f) -> @B(w) * POW_10[f]
  r: (w, f) -> @b(w) * POW_10[f]

  D: (w) -> @B D2B(w)
  d: (w) -> @b d2b(w)
  F: (w, f) -> @R D2B(w), f
  f: (w, f) -> @f d2b(w), f

  array: (format) ->
    format = parseFormat(format) if type(format) != 'array'
    data = []
    for f in format
      data.push switch f[0]
        when 'B' then @B f[1]
        when 'b' then @b f[1]
        when 'D' then @D f[1]
        when 'd' then @d f[1]
        when 'R' then @R f[1], f[2]
        when 'r' then @r f[1], f[2]
        when 'D' then @D f[1], f[2]
        when 'd' then @d f[1], f[2]
    data

class UnpackN extends Unpack    # use nil
  constructor: (input, binary, use_eof) -> super

  use_nil: -> true

  B: (w) -> if (n = @raw w) == 0 then null else n - 1
  b: (w) -> if (n = @raw w) == 0 then null else n - (1 << w - 1)
  R: (w, f) -> if (n = @B w)? then n * POW_10[f] else null
  r: (w, f) -> if (n = @b w)? then n * POW_10[f] else null

unpack = (input, option = {}) ->
  new (if option.nil then UnpackN else Unpack) input, option.eof

# browser interface
if window?
  window.Decpack =
    unpack: unpack
    parseFormat: parseFormat

# node.js interface
if exports?
  exports.unpack = unpack
  exports.parseFormat = parseFormat
