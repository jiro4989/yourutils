import unittest
import rep
import strutils

doAssert "a".repeat(3) == "aaa"
doAssert "あ".repeat(3) == "あああ"

suite "repeatString":
  test "Delimiter is empty":
    check "A".repeatString([3], "") == @["AAA"]
    check "あ".repeatString([3], "") == @["あああ"]
  test "Delimiter is commma":
    check "A".repeatString([3], ",") == @["A,A,A"]
    check "あ".repeatString([3], ",") == @["あ,あ,あ"]
  test "Repeat counts is 2":
    check "B".repeatString([2, 3], ",") == @["B,B", "B,B,B"]
  test "Repeat counts is empty":
    var empty: seq[string]
    check "あ".repeatString([], "") == empty
  test "Repeat counts is 0":
    var empty: seq[string]
    check "あ".repeatString([0], "") == empty
    check "あ".repeatString([0, 3], ",") == @["あ,あ,あ"]
