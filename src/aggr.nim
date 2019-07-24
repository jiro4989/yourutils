proc aggr(nofilename=false, count=false, min=false, max=false, sum=false,
          avg=false, median=false, percentile=false, header=false,
          indelimiter="\t", outdelimiter="\t", fieldfilepath: seq[string] = @[],
          files: seq[string]): int =
  ## 最小値、最大値

when isMainModule:
  import cligen
  import clitools/appinfo
  clCfg.version = version
  dispatch(aggr)