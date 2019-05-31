import unittest
import ucut

suite "cut":
  test "1 field":
    check ["1,2,3", "a,b,c"].cut(Options(delimiter: ",", outputDelimiter: ",", fields: @[1])) == @["1", "a"]
    check ["1,2,3", "a,b,c"].cut(Options(delimiter: ",", outputDelimiter: ",", fields: @[2])) == @["2", "b"]
  test "2 field":
    check ["1,2,3", "a,b,c"].cut(Options(delimiter: ",", outputDelimiter: " ", fields: @[1, 3])) == @["1 3", "a c"]
    check ["1,2,3", "a,b,c"].cut(Options(delimiter: ",", outputDelimiter: ",", fields: @[1, 3])) == @["1,3", "a,c"]