type
  RootOptions* = ref object of RootObj
    help*, version*: bool
    args*: seq[string]