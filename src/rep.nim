import sequtils, strutils

proc repeatString*(word: string, repeatCounts: openArray[int], delimiter: string): seq[string] =
  if repeatCounts.len < 1: return
  for cnt in repeatCounts:
    if cnt < 1: continue
    var s: seq[string]
    for i in 1..cnt:
      s.add word
      s.add delimiter
    s = s[0..^2]
    result.add s.join

proc rep(delimiter="", useStdin=false, args: seq[string]): int =
  # 標準入力受付フラグがある問は標準入力を処理
  # その時は全ての引数を繰り返し回数として扱う
  if useStdin:
    let repCnts = args.mapIt(it.parseInt)
    for word in stdin.lines:
      for line in word.repeatString(repCnts, delimiter):
        echo line
    return
    
  # 標準入力受付フラグの指定がない場合は、引数のうち最後の文字を繰り返す文字、
  # それ以外を繰り返し回数として扱う
  let repCnts = args[0..^2].mapIt(it.parseInt)
  let word = args[args.len-1]
  for line in word.repeatString(repCnts, delimiter):
    echo line

when isMainModule:
  import cligen
  dispatch(rep, short = {"useStdin": 'i'})