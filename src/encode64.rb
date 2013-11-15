# 64bit ASCII numeric encoding
module Encode64
  module_function

  # low level encoding
  CODE_MAP = Array('0'..';') + Array('A'..'Z') + Array('a'..'z')

  def encode(n, w)
    return '_' * w if n == nil
    raise "Cannot encode: (#{n}, #{w})" unless
      n.is_a?(Integer) &&
      w.is_a?(Integer) &&
      w > 0 &&
      n >= 0 &&
      n < 64 ** w
    code = ''
    w.times do
      code << CODE_MAP[n % 64]
      n /= 64
    end
    code.reverse
  end

  # low level decoding
  DECODE_MAP = {}
  CODE_MAP.each_with_index do |c, i|
    DECODE_MAP[c] = i
  end

  def decode(code)
    return nil if code == '_' * code.size
    n = 0
    code.each_char do |c|
      i = DECODE_MAP[c]
      raise "Cannot decode: '#{code}'" unless i
      n = (n << 6) + i
    end
    n
  end

  # encoding/decoding with format
  def encode_signed(n, w)
    encode n ? n + (1 << w * 6 - 1) : nil, w
  end

  def encode_float(f, w, d)
    encode f ? (f * 10 ** d).round : nil, w
  end

  def encode_signed_float(f, w, d)
    encode f ? (f * 10 ** d).round + (1 << w * 6 - 1) : nil, w
  end

  def decode_signed(c)
    (x = decode(c)) ? x - (1 << c.size * 6 - 1) : nil
  end

  def decode_float(c, d)
    (x = decode(c)) ? x.to_f / 10 ** d : nil
  end

  def decode_signed_float(c, d)
    (x = decode_signed(c)) ? x.to_f / 10 ** d : nil
  end

  # pack/unpack with format spec
  RE_FORMAT_SPEC = /^(?:([Nn])(\d+)|([Ff])(\d+)\.(\d+))(.*)$/

  def format(spec)
    format = []
    while spec =~ RE_FORMAT_SPEC
      if $1 == 'N' || $1 == 'n'
        format << [$1, $2.to_i]
      else
        format << [$3, $4.to_i, $5.to_i]
      end
      spec = $6
    end
    format
  end

  def code_size(format)
    format.inject(0) {|sz, fmt| sz + fmt[1] }
  end

  def pack(data, format)
    code = ''
    data.each_with_index do |x, i|
      f, w, d = format[i]
      case f
      when 'N' then code << encode(x, w)
      when 'n' then code << encode_signed(x, w)
      when 'F' then code << encode_float(x, w, d)
      when 'f' then code << encode_signed_float(x, w, d)
      end
    end
    code
  end

  def unpack(code, format)
    data = []
    offset = 0
    format.each do |fmt|
      f, w, d = fmt
      case f
      when 'N' then data << decode(code[offset, w])
      when 'n' then data << decode_signed(code[offset, w])
      when 'F' then data << decode_float(code[offset, w], d)
      when 'f' then data << decode_signed_float(code[offset, w], d)
      end
      offset += w
    end
    data
  end
end

