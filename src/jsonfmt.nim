import os, json

const
  usage = """jsonfmt formats json string from stdin.

Usage:
    {json stream} | jsonfmt

Options:
    -h, --help    Print this help.
"""

let args = commandlineParams()
if "-h" in args or "--help" in args:
  echo usage
  quit 0

echo readAll(stdin).parseJson().pretty()
