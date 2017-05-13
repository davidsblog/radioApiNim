# Executes two programs where the standard output from the first
# is piped to the second program (only works on POSIX systems)

import strutils, osproc, streams, posix

# operator to turn a string sequence into a c string array
proc `->` (stringSequence: seq[string]): cstringArray =
  result = allocCStringArray(stringSequence)

# operator to throw an exception if -1 is returned
proc `!` (returnValue: int) =
  doAssert(returnValue != -1)

proc checkExists*(pid: int): bool =
  return kill(pid, 0) != -1

# call from the parent to prevent zombie processes
proc reapZombies*() =
  signal(SIGCHLD, SIG_IGN)

# stop the two programs
proc killpiped*(pids: (int, int)): (int, int) =
  if pids[1] > 0:
    !kill(pids[1], SIGKILL)
    result[1] = 0
  if pids[0] > 0:
    !kill(pids[0], SIGKILL)
    result[0] = 0

# execute two programs sending the output of one to input of the other
proc execpiped*(cmdFrom: seq[string], cmdTo: seq[string]): (int, int) =
  var pipefd: array[2, cint]
  !pipe(pipefd)

  var frompid = fork()
  if frompid == 0:
    !close(pipefd[0])   # close reading end in child process
    !dup2(pipefd[1], 1) # send stdout
    !close(pipefd[1])   # no longer needed
    !execv(cmdfrom[0], -> cmdFrom)
    exitnow(1)

  !close(pipefd[1])    # close write end in parent

  var topid = fork()
  if topid == 0:
    # see: http://stackoverflow.com/questions/9487695/redirecting-input-from-file-to-exec
    # this command reads stdin from the stdout of the last command
    !dup2(pipefd[0], 0)  # get stdin
    !close(pipefd[0])    # no longer needed
    !execv(cmdto[0], -> cmdTo)
    exitnow(1)

  !close(pipefd[0])      # close read end in parent
  result = (frompid, topid)

when isMainModule:
  # non-exported tests
  block:
    const echo = @["/bin/echo", "---\nThe execpiped() procedure seems to work!\n---"]
    const cat = @["/bin/cat", "-b"]
    var pids = execpiped(echo, cat)
    #doAssert(pids[0] > 0 and pids[1] > 0)
    echo "Output from PID *", pids[0], "* piped to PID *", pids[1], "*."
