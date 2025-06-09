require 'inline'                # gem install RubyInline
require 'cbor-pure'             # gem install cbor-diag

class String
  def hexi
    bytes.map{|x| "%02x" % x}.join
  end
end

class MyTest
  inline do |builder|
    builder.c File.read("half-encode.c")
  end
end
t = MyTest.new

(0..0xFFFF).each do |n|
  cbf = [0xF9, n].pack("Cn")
  f = CBOR.decode(cbf)
  b64 = [f].pack("G").unpack("Q>").first
  enc = t.try_float16_encode(b64)
  if enc != n
    puts "mismatch %x %s %g %x %x" % [n, cbf.hexi, f, b64, enc]
  end
  b64x = b64
  10.times do
    b64x ^= 1 << rand(64)
    encx = t.try_float16_encode(b64x)
    if encx != -1
      cbx = [0xF9, encx].pack("Cn")
      fx = CBOR.decode(cbx)
      b64y = [fx].pack("G").unpack("Q>").first
      if b64x != b64y
        puts "hit #{"x=%x %x y=%x %x n=%g" %
                    [b64x, encx, b64y, b64x ^ b64y, Math.log2(b64x ^ b64y)]}"
      end
    end
  end
end
