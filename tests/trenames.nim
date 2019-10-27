import unittest, os
include renames

test "proc printResult":
  printResult()

suite "template printMsg":
  test "same dir and filter = false":
    printMsg(pcDir, "./a", "./a", false)
  test "same dir and filter = true":
    printMsg(pcDir, "./a", "./a", true)
  test "different file and filter = false":
    printMsg(pcFile, "./a", "./b", false)
  test "different file and filter = true":
    printMsg(pcFile, "./a", "./b", true)

suite "proc runMoveFile":
  setup:
    let dir = "tests/tmp_runMoveFile"
    createDir(dir)
  teardown:
    removeDir(dir)

  test "same dir":
    let targetDir = dir / "dir1"
    createDir(targetDir)
    runMoveFile(pcDir, targetDir, targetDir, false, false, false)
    check existsDir(targetDir)

  test "new dir":
    let targetDir = dir / "dir1"
    let newDir = targetDir & "_2"
    createDir(targetDir)
    runMoveFile(pcDir, targetDir, newDir, false, false, false)
    check not existsDir(targetDir)
    check existsDir(newDir)

  test "same file":
    let targetFile = dir / "file1"
    writeFile(targetFile, "1234")
    runMoveFile(pcFile, targetFile, targetFile, false, false, false)
    check existsFile(targetFile)

  test "new file":
    let targetFile = dir / "file1"
    let newFile = targetFile & "_2"
    writeFile(targetFile, "1234")
    runMoveFile(pcFile, targetFile, newFile, false, false, false)
    check not existsFile(targetFile)
    check existsFile(newFile)

suite "proc rename":
  setup:
    let dir = "tests/tmp_rename"
    createDir(dir)
    let dir2 = "tests/tmp_rename/abcd"
    createDir(dir2)
    let dir3 = "tests/tmp_rename/abcd/xyz"
    createDir(dir3)

    proc getUpperName(path: string): string =
      let (dir, name, ext) = splitFile(path)
      let base = name & ext
      result = dir / toUpperAscii(base)
  teardown:
    removeDir(dir)

  test "rename dirs":
    let targetFile = dir2 / "file1"
    writeFile(targetFile, "1234")
    let targetFile2 = dir2 / "file2"
    writeFile(targetFile2, "1234")
    let targetFile3 = dir3 / "file3"
    writeFile(targetFile3, "1234")

    rename(dir2, getUpperName, false, false, false)

    check not existsFile(targetFile)
    check not existsFile(targetFile2)
    check not existsFile(targetFile3)
    check existsFile(dir2 / "FILE1")
    check existsFile(dir2 / "FILE2")
    check existsFile(dir2 / "XYZ" / "FILE3")
    check existsDir(dir2)
    check existsDir(dir2 / "XYZ")

suite "proc renameDirs":
  setup:
    let dir = "tests/tmp_rename"
    createDir(dir)
    let dir2 = "tests/tmp_rename/abcd"
    createDir(dir2)
    let dir3 = "tests/tmp_rename/abcd/xyz"
    createDir(dir3)

    proc getUpperName(path: string): string =
      let (dir, name, ext) = splitFile(path)
      let base = name & ext
      result = dir / toUpperAscii(base)
  teardown:
    removeDir(dir)

  test "rename dirs":
    let targetFile = dir2 / "file1"
    writeFile(targetFile, "1234")
    let targetFile2 = dir2 / "file2"
    writeFile(targetFile2, "1234")
    let targetFile3 = dir3 / "file3"
    writeFile(targetFile3, "1234")

    renameDirs(@[dir2], getUpperName, false, false, false)

    check not existsFile(targetFile)
    check not existsFile(targetFile2)
    check not existsFile(targetFile3)
    check existsFile(dir / "ABCD" / "FILE1")
    check existsFile(dir / "ABCD" / "FILE2")
    check existsFile(dir / "ABCD" / "XYZ" / "FILE3")
    check not existsDir(dir2)
    check not existsDir(dir3)

suite "cmdDelete":
  setup:
    let dir = "tests/delete"
    createDir(dir)
    let dir2 = dir / "tmp"
    createDir(dir2)
  teardown:
    removeDir(dir)

  test "delete whitespace":
    let f = dir2 / "a b　c\td.txt"
    writeFile(f, "1234")
    check 0 == cmdDelete(false, false, false, whiteSpaces, @[dir2])
    check existsFile(dir2 / "abcd.txt")
    check not existsFile(f)
    check existsDir(dir2)

  test "delete strings":
    let f = dir2 / "a-bXcZd.txt"
    writeFile(f, "1234")
    check 0 == cmdDelete(false, true, false, @["-", "X", "Z"], @[dir2])
    check existsFile(dir2 / "abcd.txt")
    check not existsFile(f)
    check existsDir(dir2)

suite "cmdReplace":
  setup:
    let dir = "tests/replace"
    createDir(dir)
    let dir2 = dir / "tmp"
    createDir(dir2)
  teardown:
    removeDir(dir)

  test "replace whitespace":
    let f = dir2 / "a b　d.txt"
    writeFile(f, "1234")
    check 0 == cmdReplace(false, true, false, whiteSpaces, "_", @[dir2])
    check existsFile(dir2 / "a_b_d.txt")
    check not existsFile(f)
    check existsDir(dir2)

  test "replace any strings":
    let f = dir2 / "abcd----XXXXZZZZ.txt"
    writeFile(f, "1234")
    check 0 == cmdReplace(false, true, false, @["-", "X", "Z"], "_", @[dir2])
    check existsFile(dir2 / "abcd____________.txt")
    check not existsFile(f)
    check existsDir(dir2)

suite "cmdLower":
  setup:
    let dir = "tests/lower"
    createDir(dir)
    let dir2 = dir / "TMP"
    createDir(dir2)
  teardown:
    removeDir(dir)

  test "rename to lower":
    let f = dir2 / "ABCD.txt"
    writeFile(f, "1234")
    check 0 == cmdLower(false, true, false, @[dir2])
    check existsFile(dir / "tmp" / "abcd.txt")
    check not existsFile(f)
    check existsDir(dir / "tmp")

suite "cmdUpper":
  setup:
    let dir = "tests/lower"
    createDir(dir)
    let dir2 = dir / "tmp"
    createDir(dir2)
  teardown:
    removeDir(dir)

  test "rename to upper":
    let f = dir2 / "abcd.txt"
    writeFile(f, "1234")
    check 0 == cmdUpper(false, true, false, @[dir2])
    check existsFile(dir / "TMP" / "ABCD.TXT")
    check not existsFile(f)
    check existsDir(dir / "TMP")
