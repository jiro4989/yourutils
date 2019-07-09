import clitools/io

import strutils

proc joinLines*(lines: openArray[string], columnCount: int, delimiter: string): seq[string] =
  ## 行のデータをcolumnCountずつ１行にまとめる
  ## columnCountが初期値(-1)の場合は1行にまとめる
  var s: seq[string]
  for i, v in lines:
    s.add v
    if 0 < columnCount and (i+1) mod columnCount == 0:
      result.add s.join(delimiter)
      s = @[]
  result.add s.join(delimiter)

proc flat(columnCount=0, delimiter=" ", files: seq[string]): int =
 # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  if files.len < 1:
    for line in stdin.readLines.joinLines(columnCount, delimiter):
      echo line
    return

  # 引数があればファイルとして処理
  for arg in files:
    var f = open(arg)
    for line in f.readLines.joinLines(columnCount, delimiter):
      echo line
    f.close

when isMainModule:
  import cligen
  dispatch(flat, short = {"columnCount":'n'})