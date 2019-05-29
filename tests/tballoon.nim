import unittest
import balloon

suite "formatBalloon":
  test "Normal":
    check @["HELLO"].formatBalloon(Options()) == @[
      ".---------.",
      "|         |",
      "|  HELLO  |",
      "|         |",
      "`---------'",
      ]
  test "ひらがな":
    check @["こんにちは", "HELLO"].formatBalloon(Options()) == @[
      ".--------------.",
      "|              |",
      "|  こんにちは  |",
      "|    HELLO     |",
      "|              |",
      "`--------------'",
      ]
  when false:
    test "Top":
      check @["こんにちは", "HELLO"].formatBalloon(Options(top: true)) == @[
        "     |\\         ",
        ".----' `-------.",
        "|              |",
        "|  こんにちは  |",
        "|    HELLO     |",
        "|              |",
        "`--------------'",
        ]
    test "Right":
      check @["こんにちは", "HELLO"].formatBalloon(Options(right: true)) == @[
        ".--------------. ",
        "|              | ",
        "|  こんにちは  | ",
        "|    HELLO      >",
        "|              | ",
        "`--------------' ",
        ]
    test "Bottom":
      check @["こんにちは", "HELLO"].formatBalloon(Options(bottom: true)) == @[
        ".--------------.",
        "|              |",
        "|  こんにちは  |",
        "|    HELLO     |",
        "|              |",
        "`----. .-------'",
        "     |/         ",
        ]
    test "Left":
      check @["こんにちは", "HELLO"].formatBalloon(Options(left: true)) == @[
        " .--------------.",
        " |              |",
        " |  こんにちは  |",
        "<     HELLO     |",
        " |              |",
        " `--------------'",
        ]
    test "Left, position = -1":
      check @["こんにちは", "HELLO"].formatBalloon(Options(left: true, position: -1)) == @[
        " .--------------.",
        " |              |",
        "<   こんにちは  |",
        " |    HELLO     |",
        " |              |",
        " `--------------'",
        ]
    test "Left, position = 1":
      check @["こんにちは", "HELLO"].formatBalloon(Options(left: true, position: 1)) == @[
        " .--------------.",
        " |              |",
        " |  こんにちは  |",
        " |    HELLO     |",
        "<               |",
        " `--------------'",
        ]