proc readLines*(f: File): seq[string] =
    var line: string
    while f.readLine line:
      result.add line
  