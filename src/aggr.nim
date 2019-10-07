import strutils
from sequtils import map
from algorithm import sort

const
  version = """aggr version 1.0.0
Copyright (c) 2019 jiro4989
Released under the MIT License.
https://github.com/jiro4989/clitools"""

proc percentile(datas: openArray[int], percent: int): int =
  ## datas はソート済みでなければならない。
  var pos = int((datas.len + 1) * percent / 100)
  if pos < 0:
    pos = 0
  elif datas.len <= pos:
    pos = datas.len - 1
  result = datas[pos]

proc aggr(nofilename=false, count=false, min=false, max=false, sum=false,
          avg=false, median=false, percentile=false, header=false,
          delimiter="\t", outDelimiter="\t", fields = "0",
          files: seq[string]): int =
  ## ファイル名、フィールド番号、件数、最小値、最大値、合計、平均値、中央値、95パーセンタイル値
  echo ["file_name", "field", "count", "min", "max", "total", "avg", "median", "95percentile"].join(outDelimiter)
  let fieldNums = fields.split(",").map(parseInt)

  template procFile(f: var File, num: int) =
    var datas: seq[int]
    var total: int
    try:
      for line in f.lines:
        try:
          let data = line.split(delimiter)[num].parseInt
          datas.add(data)
          total += data
        except:
          continue
    finally:
      if f != stdin:
        close(f)
    let avg = total / datas.len
    sort(datas)
    let median = datas.percentile(50)
    let perc95 = datas.percentile(95)
    echo ["stdin", $num, $datas.len, $datas.min, $datas.max, $total, $avg, $median, $perc95].join(outDelimiter)

  # ファイルが存在しないときは標準入力を処理
  if files.len < 1:
    for num in fieldNums:
      procFile(stdin, num)
    return

  # ファイルが存在する時はファイルを開く
  for num in fieldNums:
    for file in files:
      var f = open(file)
      procFile(f, num)

when isMainModule:
  import cligen
  clCfg.version = version
  dispatch(aggr, short = {"outDelimiter":'D'})
