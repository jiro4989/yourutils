import strutils, sequtils

proc cut*(line: string, delimiter: string, outputDelimiter: string, fields: seq[int]): string =
  let fs = line.split(delimiter)
  var outf: seq[string]
  for i in fields:
    let n = i - 1
    if n < 0 or fs.len <= n: continue
    outf.add fs[n]
  result = outf.join(outputDelimiter)

proc ucut(delimiter = " ", outputDelimiter = " ", fields = "1", files: seq[string]): int =
  let fs = fields.split(",").mapIt(it.parseInt)

  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  if files.len < 1:
    for line in stdin.lines:
      echo line.cut(delimiter, outputDelimiter, fs)

  # 引数があればファイルの中身を読み取って処理する
  for arg in files:
    for line in arg.lines:
      echo line.cut(delimiter, outputDelimiter, fs)

when isMainModule:
  import cligen
  import clitools/appinfo
  clCfg.version = version
  dispatch(ucut, short = {"outputDelimiter": 'D'})
