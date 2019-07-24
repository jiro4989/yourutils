import strutils, strformat
from sequtils import mapIt

proc formatMarkdown*(rows: ref seq[seq[string]]): ref seq[string] =
  new result
  proc mdRow(cols: seq[string]): string = "|" & cols.join("|") & "|"

  # ヘッダ
  result[].add(rows[0].mdRow)
  # ヘッダとボディの区切り線
  result[].add(rows[0].mapIt(":---:").mdRow)
  # ボディ
  for row in rows[1..^1]:
    result[].add(row.mdRow)

proc formatHtml*(rows: ref seq[seq[string]]): ref seq[string] =
  new result
  proc mkTr(cols: seq[string]): string =
    "<tr><td>" & cols.join("</td><td>") & "</td></tr>"

  result[].add("<table>")
  result[].add("<thead>")
  result[].add(rows[0].mkTr)
  result[].add("</thead>")
  result[].add("<tbody>")
  for row in rows[1..^1]:
    result[].add(row.mkTr)
  result[].add("</tbody>")
  result[].add("</table>")

proc formatAsciidoc*(rows: ref seq[seq[string]]): ref seq[string] =
  new result
  proc mkRow(cols: seq[string]): string = "|" & cols.join("|")

  result[].add("""[options="header"]""")
  result[].add("|=================")
  for row in rows[]:
    result[].add(row.mkRow)
  result[].add("|=================")

proc tb(delimiter="\t", format="markdown", files: seq[string]): int =
  ## tb converts to table (markdown or html or asciidoc).
  template formatEcho(rows: ref seq[seq[string]]) =
    let lines =
      case format
      of "markdown", "md": formatMarkdown(rows)
      of "html": formatHtml(rows)
      of "asciidoc", "adoc": formatAsciidoc(rows)
      else:
        stderr.writeLine("Illegal format = " & format)
        nil
    if lines.isNil: return 1
    for line in lines[]:
      echo line
    result = 0

  # ファイルが存在しない場合は標準入力を処理
  if files.len < 1:
    var rows = new seq[seq[string]]
    var line: string
    while stdin.readLine(line):
      rows[].add(line.split(delimiter))
    formatEcho(rows)
    return
  
  # ファイルが存在するときは都度ファイルを開いて処理
  for file in files:
    var rows = new seq[seq[string]]
    var f = open(file)
    var line: string
    while f.readLine(line):
      rows[].add(line.split(delimiter))
    formatEcho(rows)
    f.close

when isMainModule:
  import cligen
  import clitools/appinfo
  clCfg.version = version
  dispatch(tb, help = {"format":"print format of table. (markdown | md | html | asciidoc | adoc)"})