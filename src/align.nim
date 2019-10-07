import alignment

import clitools/io

import sequtils
from strutils import join

const
  version = """align version 1.0.0
Copyright (c) 2019 jiro4989
Released under the MIT License.
https://github.com/jiro4989/clitools"""

proc left(length = 0, pad = " ", writeFile = false, files: seq[string]): int =
  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  if files.len < 1:
    let lines = stdin.readLines
    for line in lines.alignLeft(pad = pad).mapIt(it & pad.repeat(length).join):
      echo line
    return

  # 引数があればファイルの中身を読み取って処理する
  for file in files:
    var f = open(file)
    let lines = f.readLines
    f.close

    var outf = if writeFile: open(file, fmWrite)
      else: stdout
    for line in lines.alignLeft(pad = pad).mapIt(it & pad.repeat(length).join):
      outf.writeLine(line)
    if outf != stdout: outf.close

proc center(length = 0, pad = " ", writeFile = false, files: seq[string]): int =
  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  if files.len < 1:
    let lines = stdin.readLines
    for line in lines.alignCenter(pad = pad).mapIt(it & pad.repeat(length).join):
      echo line
    return

  # 引数があればファイルの中身を読み取って処理する
  for file in files:
    var f = open(file)
    let lines = f.readLines
    f.close

    var outf = if writeFile: open(file, fmWrite)
      else: stdout
    for line in lines.alignCenter(pad = pad).mapIt(it & pad.repeat(length).join):
      outf.writeLine(line)
    if outf != stdout: outf.close

proc right(length = 0, pad = " ", writeFile = false, files: seq[string]): int =
  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  if files.len < 1:
    let lines = stdin.readLines
    for line in lines.alignRight(pad = pad).mapIt(it & pad.repeat(length).join):
      echo line
    return

  # 引数があればファイルの中身を読み取って処理する
  for file in files:
    var f = open(file)
    let lines = f.readLines
    f.close

    var outf = if writeFile: open(file, fmWrite)
      else: stdout
    for line in lines.alignRight(pad = pad).mapIt(it & pad.repeat(length).join):
      outf.writeLine(line)
    if outf != stdout: outf.close

when isMainModule:
  import cligen
  clCfg.version = version
  dispatchMulti([left, short = {"length": 'n'}],
                [center, short = {"length": 'n'}],
                [right, short = {"length": 'n'}])
