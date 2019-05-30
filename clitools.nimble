# Package

version       = "1.0.0"
author        = "jiro4989"
description   = "clitools is cli commands."
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
bin           = @["flat", "repeat", "align"]


# Dependencies

requires "nim >= 0.19.4"
requires "eastasianwidth >= 1.1.0"
requires "alignment >= 1.0.0"

import strformat

task ci, "Run CI":
  exec "nim -v"
  exec "nimble -v"
  exec "nimble install -Y"
  exec "nimble test -Y"
  exec "nimble build -d:release -Y"
  for b in bin:
    exec &"./bin/{b} -h"
    exec &"./bin/{b} -v"
