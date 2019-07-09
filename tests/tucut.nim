import unittest
import ucut

suite "cut":
  test "1 field":
    check "1,2,3".cut(",", ",", @[1]) == "1"
    check "あ,い,う".cut(",", ",", @[2]) == "い"
  test "2 field":
    check "1,2,3".cut(",", " ", @[1, 3]) == "1 3"
    check "あんいんう".cut("ん", "ン", @[2, 3]) == "いンう"