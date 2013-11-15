require './encode64'

def process(infile, outfile, spec)
  puts "#{infile} => #{outfile}"
  format = Encode64::format spec
  open infile do |csv|
    csv.gets    # abandon the first line (hedder)
    open outfile, 'w' do |txt|
      while s = csv.gets
        data = s.split(',')
        first = data.shift
        data = data.map {|x| x.to_f }
        data.unshift first.to_i / 3600
        txt.write Encode64::pack(data, format)
      end
    end
  end
end

process *ARGV

__END__
process 'tokyo_monthly.csv', 'tokyo_monthly.txt', 'n4f2.1f2.1F3.1'
process 'tokyo_daily.csv',   'tokyo_daily.txt',   'n4f2.1f2.1F2.1'
process 'tokyo_hourly.csv',  'tokyo_hourly.txt',  'n4f2.1F2.1'

