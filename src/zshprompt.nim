import nicy
import strformat, times
from strutils import parseInt

const
  ok = "(*'-'%)! "
  ng = "(;^q^%)? "
  nl = "\n"

let
  # current time
  t = now().format("HH:mm:ss")
  hour = t[0..1].parseInt()
  currentTime =
    if 6 <= hour and hour < 12: color(t, "green")
    elif 12 <= hour and hour < 18: color(t, "yellow")
    else: color(t, "blue")

  # user@host
  userName = color(user(), "cyan")
  hostName = color("%M", "green")

  # current working directory
  cwd = color(&"{tilde(getCwd())}", "magenta")

  # git branch
  gitBranch = color(gitBranch(), "yellow")
  dirty = color("×", "red")
  clean = color("•", "green")
  git = gitBranch & gitStatus(dirty, clean)

  # prompt
  state = returnCondition(ok = color(ok, "green"), ng = color(ng, "blue"))
  prompt = state & color("› ", "magenta")

echo &"{virtualenv()}{currentTime} {userName}@{hostName} {cwd}{git}{nl}{prompt}"
