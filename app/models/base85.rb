# Based on base85.c file from git source code
# https://github.com/git/git/blob/53f9a3e157dbbc901a02ac2c73346d375e24978c/base85.c
class Base85
  DE85 = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
          nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 62, nil, 63, 64, 65, 66, nil, 67, 68, 69, 70, nil, 71, nil, nil,
          0, 1, 2, 3, 4, 5, 6, 7, 8, 9, nil, 72, 73, 74, 75, 76, 77, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
          24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, nil, nil, nil, 78, 79, 80, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45,
          46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 81, 82, 83, 84].freeze

  # data should be a string or an array of bytes, i.e. ints.
  # We spect the first letter to denote the decoded size, like git spec does.
  def self.decode(data)
    data = data.bytes if data.is_a?(String)
    it = data.each
    len = it.peek
    #      A..Z
    len = (56..90).include?(len) ? len - 'A'.ord + 1 : len - 'a'.ord + 26 + 1
    it.next

    output = []

    while len.positive?
      acc = 0
      cnt = 4

      cnt.times do
        ch = it.peek
        it.next
        de = DE85[ch]
        raise "invalid base85 alphabet #{ch}" if de.nil?

        acc = acc * 85 + de
      end

      ch = it.peek
      it.next
      de = DE85[ch]
      raise "invalid base85 alphabet #{ch}" if de.nil?
      raise 'invalid base85 sequence' if 0xffffffff / 85 < acc || 0xffffffff - de < (acc *= 85)

      acc += de
      cnt = len < 4 ? len : 4
      len -= cnt
      cnt.times do
        acc = (acc << 8) | (acc >> 24)
        output << (acc & 0xff)
      end
    end
    output
  end
end
