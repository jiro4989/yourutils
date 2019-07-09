import argparse

import clitools/[io, log, option]
import clitools/private/common

import parseopt, logging, unicode
from strutils import parseInt, join, repeat
from strformat import `&`
from sequtils import mapIt
from os import commandLineParams

type
  Options* = ref object of RootOptions
    delimiter*: string
    useStdin*: bool

const
  appName = "repeat"

var
  version: string
  useDebug: bool

include clitools/private/version

proc repeatString*(word: string, repeatCounts: openArray[int], opts: Options): seq[string] =
  debug &"{appName}: word = {word}, repeatCounts = {repeatCounts}, opts = {opts[]}"
  if repeatCounts.len < 1: return
  for cnt in repeatCounts:
    if cnt < 1: continue
    var s: seq[string]
    for i in 1..cnt:
      s.add word
      s.add opts.delimiter
    s = s[0..^2]
    result.add s.join

proc main*(params: seq[string]): seq[string] =
  var p = newParser(appName):
    flag("-v", "--version", help="Print version")
    flag("-X", "--debug", help="Debug")
    option("-d", "--delimiter", help="Delimiter", default = "")
    flag("-i", "--stdin", help="Debug")
    arg("args", nargs = -1)

  let opt = p.parse(params)
  setOptions:
    let opts = Options(
      delimiter: opt.delimiter,
      useStdin: opt.stdin,
      args: opt.args)

  doAssert 0 < opts.args.len, &"{appName}: must count of arguments is over 0"

  var
    repeatCounts: seq[int]
    word: string
  if opts.useStdin:
    repeatCounts.add opts.args.mapIt(it.parseInt)
    word = stdin.readLines.join
  else:
    repeatCounts = opts.args[0..^2].mapIt(it.parseInt)
    word = opts.args[opts.args.len-1]

  result = word.repeatString(repeatCounts, opts)

when isMainModule:
  try:
    for line in main(commandLineParams()):
      echo line
  except:
    stderr.writeLine(getCurrentExceptionMsg())
    quit 1
