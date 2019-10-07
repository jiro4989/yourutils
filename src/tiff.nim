import strutils

const
  version = """tiff version 1.0.0
Copyright (c) 2019 jiro4989
Released under the MIT License.
https://github.com/jiro4989/clitools"""
  second = 1
  minute = 60 * second
  hour = 60 * minute

proc timeToSeconds(t: string): int =
  ## HH:MMを秒数として返す。
  let t2 = t.split(":")
  if t2.len < 2:
    return -1
  let h = t2[0].parseInt
  let m = t2[1].parseInt
  result = h * hour + m * minute

proc tiff(unit = true, hours = false, minutes = false, tods: seq[string]): int =
  ## 時刻と時刻の差分を計算する。(HH:MM - HH:MM)
  if tods.len < 2:
    stderr.writeLine("引数は最低2つ必要です")
    return 1

  let st = timeToSeconds(tods[0])
  let et = timeToSeconds(tods[1])
  let diff = st - et
  if diff < 0:
    stderr.writeLine("不正な計算結果:" & $diff)
    return 1

  if hours:
    var t = $int(diff / hour)
    if unit:
      t.add(" hours")
    echo t
    return

  if minutes:
    var t = $int(diff / minute)
    if unit:
      t.add(" minutes")
    echo t
    return

  var t = $diff
  if unit:
    t.add(" seconds")
  echo t

when isMainModule:
  import cligen
  clCfg.version = version
  dispatch(tiff,
           short = {"hours":'H', "minutes":'M'},
           help = {"unit":"prints time unit"})
