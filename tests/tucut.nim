import unittest
import ucut

suite "cut":
  test "1 field":
    check "1,2,3".cut(Options(delimiter: ",", outputDelimiter: ",", fields: @[1])) == "1"
    check "あ,い,う".cut(Options(delimiter: ",", outputDelimiter: ",", fields: @[2])) == "い"
  test "2 field":
    check "1,2,3".cut(Options(delimiter: ",", outputDelimiter: " ", fields: @[1, 3])) == "1 3"
    check "あんいんう".cut(Options(delimiter: "ん", outputDelimiter: "ン", fields: @[2, 3])) == "いンう"