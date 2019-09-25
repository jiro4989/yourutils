import unittest
import flat

suite "joinLines":
  test "Default value":
    check @["1", "2", "3"].joinLines(0, "") == @["123"]
  test "Column count = 2":
    check @["1", "2", "3"].joinLines(2, "") == @["12", "3"]
  test "Column countが処理対象のテキストの数より多い":
    check @["1", "2", "3"].joinLines(10, "") == @["123"]
  test "Delimiter = ,":
    check @["1", "2", "3"].joinLines(0, ",") == @["1,2,3"]
  test "Delimiter = , column count = 2":
    check @["1", "2", "3"].joinLines(2, ",") == @["1,2", "3"]
