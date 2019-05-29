import unittest
import flat

suite "joinLines":
  test "Default value":
    check @["1", "2", "3"].joinLines(Options(columnCount: 0, delimiter: "")) == @["123"]
  test "Column count = 2":
    check @["1", "2", "3"].joinLines(Options(columnCount: 2, delimiter: "")) == @["12", "3"]
  test "Column countが処理対象のテキストの数より多い":
    check @["1", "2", "3"].joinLines(Options(columnCount: 10, delimiter: "")) == @["123"]
  test "Delimiter = ,":
    check @["1", "2", "3"].joinLines(Options(columnCount: 0, delimiter: ",")) == @["1,2,3"]
  test "Delimiter = , column count = 2":
    check @["1", "2", "3"].joinLines(Options(columnCount: 2, delimiter: ",")) == @["1,2", "3"]