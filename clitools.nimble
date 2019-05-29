# Package

version       = "1.0.0"
author        = "jiro4989"
description   = "clitools is cli commands."
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
bin           = @["flat"]


# Dependencies

requires "nim >= 0.19.4"
requires "eastasianwidth >= 1.1.0"

import strformat

task docs, "Generate documents":
  exec "nimble doc src/rect.nim -o:docs/rect.html"
  for m in ["classifiedstring", "crop", "paste", "util"]:
    exec &"nimble doc src/rect/{m}.nim -o:docs/{m}.html"

task ci, "Run CI":
  exec "nim -v"
  exec "nimble -v"
  exec "nimble install -Y"
  exec "nimble test -Y"
  exec "nimble docs -Y"
  exec "nimble build -d:release -Y"
  exec "./bin/rect -h"
  exec "./bin/rect -v"
