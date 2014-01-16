require 'decpack'

def process(infile, outfile, spec)
  spec = Decpack.parse_format spec
  puts "#{infile} => #{outfile}"
  pack = Decpack.pack eof: true
  open infile do |csv|
    csv.gets    # abandon the first line (header)
    while s = csv.gets
      data = s.split(',')
      first = data.shift
      data = data.map {|x| x.to_f }
      data.unshift first.to_i / 3600
      pack.array spec, data
    end
  end
  open outfile, 'w' do |dat|
    dat.print pack.output
  end
end

process *ARGV

# process 'tokyo_monthly.csv', 'tokyo_monthly.dp6', 'b21 r10.1 r10.1 R13.1'
# process 'tokyo_daily.csv',   'tokyo_daily.dp6',   'b20 r10.1 r10.1 R12.1'
# process 'tokyo_hourly.csv',  'tokyo_hourly.dp6',  'B19 r10.1 R10.1'

__END__

# 補足説明

月間統計(tokyo_monthly.csv)及び一日統計(tokyo_daily.csv)のフォーマットは次の通り(共通)。epoch_timeは1秒単位、その他は小数点1桁。

    epoch_time(sec),min_temperature(℃).max_temperature(℃),precipitation(mm)

一時間統計量(tokyo_hourly.csv)は次の通り。

    epoch_time(sec),temperature(℃),precipitation(mm)

> 先頭行は各項目のタイトルになっている。これは以前d3.csvを使って読み込んでいた頃の名残で現在はもう使っていないので単にスキップする。

これらのデータをDecpackを使って圧縮する。

またepoch_timeは今回扱う最小ステップが1時間であることを利用し、3600で割った値を用いる。全データのDecpackフォーマットは次の通り。

* データ総数: B24
* epoch_time(/3600):
    * 1ヶ月データ: b21 (1970年以前のデータもあるため符号付きが正しい)
    * 1日データ: b20 (同上)
    * 1時間データ: B19 (1990年以降のため)
* temperature: r10.1 (全て共通)
* precipitation:
    * 1ヶ月データ: R13.1
    * 1日データ: R12.1
    * 1時間データ: R10.1

