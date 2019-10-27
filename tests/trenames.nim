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
    let dir = "tests/runMoveFile"
    createDir(dir)
  teardown:
    removeDir(dir)

  test "same dir":
    let targetDir = dir / "dir1"
    createDir(dir)
    runMoveFile(pcDir, targetDir, targetDir, false, false, false)
    check existsDir(targetDir)

  test "new dir":
    let targetDir = dir / "dir1"
    let newDir = targetDir & "_2"
    createDir(dir)
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
