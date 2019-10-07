import unicode, strutils

const
  version = """codepoint version 1.0.0
Copyright (c) 2019 jiro4989
Released under the MIT License.
https://github.com/jiro4989/clitools"""

iterator genCpRow(line: string, delimiter: string): string =
  for ch in line.toRunes:
    let
      codePoint = ch.ord
      hex = codePoint.toHex
      shortHex = hex.strip(trailing = false, chars = {'0'})
    yield [$ch, $codePoint, "\\U" & shortHex].join(delimiter)

proc codepoint(delimiter = " ", files: seq[string]): int =
  echo ["char", "code_point", "code_point(hex)"].join(delimiter)

  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  if files.len < 1:
    for line in stdin.lines:
      for row in line.genCpRow(delimiter):
        echo row
    return

  # 引数があればファイルの中身を読み取って処理する
  for file in files:
    for line in file.lines:
      for row in line.genCpRow(delimiter):
        echo row

when isMainModule:
  import cligen
  clCfg.version = version
  dispatch(codepoint)
