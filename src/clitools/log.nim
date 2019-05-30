import logging

proc setDebugLogger*(useDebug: bool) =
  if useDebug:
    ## デバッグログを標準出力にだすか否か
    var logger = newConsoleLogger(lvlAll, verboseFmtStr)
    addHandler logger