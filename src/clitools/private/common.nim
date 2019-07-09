template setOptions*(body: untyped) =
  if opt.help:
    quit 0
  
  if opt.version:
    echo version
    quit 0

  body

  useDebug = opt.debug
  setDebugLogger useDebug
  debug "options = ", opts[]