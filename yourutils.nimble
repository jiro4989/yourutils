# Package

version       = "3.1.0"
author        = "jiro4989"
description   = "yourutils is simple cli commands."
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
bin           = @["flat", "rep", "align", "ucut",
                  "codepoint", "tb", "subnet", "aggr",
                  "renames", "tiff", "jsonfmt", "zshprompt",
                  "mcp", "msel", "marc"]


# Dependencies

requires "nim >= 1.0.0"
requires "eastasianwidth >= 1.1.0"
requires "alignment >= 1.1.0"
requires "cligen >= 0.9.32"
requires "uuids >= 0.1.10"

when not defined(windows):
  requires "nicy#head"

import strformat

task ci, "Run CI":
  exec "nim -v"
  exec "nimble -v"
  exec "nimble install -Y"
  exec "nimble test -Y"
  exec "nimble build -d:release -Y"
  for b in bin:
    exec &"./bin/{b} -h"
    # exec &"./bin/{b} -v"