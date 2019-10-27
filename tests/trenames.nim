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

