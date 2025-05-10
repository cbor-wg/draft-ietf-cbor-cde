require 'csv'
require 'cbor-pure'
require 'treetop'
require 'cbor-diag-parser'
require 'cbor-diagnostic'
require 'cbor-pretty'
require 'cbor-deterministic'

class String
  def hexi
    bytes.map{|x| "%02x" % x}.join
  end
  def hexs
    bytes.map{|x| "%02x" % x}.join(" ")
  end
  def xeh
    gsub(/\s/, "").chars.each_slice(2).map{ |x| Integer(x.join, 16).chr("BINARY") }.join
  end
end

$parser = CBOR_DIAGParser.new

def edn_decode(i)
  if result = $parser.parse(i)
    result.to_rb
  else
    warn "*** can't parse #{i}"
    warn "*** #{parser.failure_reason}"
    exit 1
  end
end

def isnan(n)
  Float === n && n.nan?
end

csv = CSV.read("example-table-input.csv")

typs = {"int" => "Integer Value Examples",
 "flt" => "Floating Point Value Examples",
 "bad" => "Failing Examples"}

tables = Hash[typs.keys.map {
                [_1, "| EDN | CBOR (hex) | Comment |\n"]
              }]

csv.each do |row|
  typ, dn, hex, comment = row
  hex = hex.downcase
  # p row
  bin = hex.xeh
  # p bin
  data = CBOR.decode(bin) rescue :undefined
  data.cbor_stream!(false) rescue nil
  det =  data.cbor_prepare_deterministic.to_cbor
  if (det != bin) != (typ == "bad")
    warn ["*** DET, #{det}, #{bin}"].inspect
  end
  # p data
  ednout = edn_decode(dn)
  # p ednout
  if ednout != data
    unless :undefined == data || isnan(ednout) && isnan(data)
      warn ["*** EDNOUT", ednout, data].inspect
    end
  end
  tables[typ] << "| #{dn == "" ? "(Not CBOR)" : dn} | #{hex} | #{comment} |\n"
end

typs.keys.each do |typ|
  puts "## #{typs[typ]}"
  puts
  puts '<?v3xml2rfc table_borders="light" ?>'
  puts
  puts tables[typ]
  puts %{{: #tab-example-#{typ} title="#{typs[typ]}"}}
  puts
end

