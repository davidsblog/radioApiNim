##
## Some things that I've copied from libraries, rather than bring in the
## whole library.  Just to try and make the executable smaller
##
import json, strutils

#### cgi
#### FROM: https://github.com/nim-lang/Nim/blob/master/lib/pure/cgi.nim#L55
####
proc handleHexChar(c: char, x: var int) {.inline.} =
  case c
  of '0'..'9': x = (x shl 4) or (ord(c) - ord('0'))
  of 'a'..'f': x = (x shl 4) or (ord(c) - ord('a') + 10)
  of 'A'..'F': x = (x shl 4) or (ord(c) - ord('A') + 10)
  else: assert(false)

proc decodeUrl*(s: string): string =
  ## Decodes a value from its HTTP representation: This means that a ``'+'``
  ## is converted to a space, ``'%xx'`` (where ``xx`` denotes a hexadecimal
  ## value) is converted to the character with ordinal number ``xx``, and
  ## and every other character is carried over.
  result = newString(s.len)
  var i = 0
  var j = 0
  while i < s.len:
    case s[i]
    of '%':
      var x = 0
      handleHexChar(s[i+1], x)
      handleHexChar(s[i+2], x)
      inc(i, 2)
      result[j] = chr(x)
    of '+': result[j] = ' '
    else: result[j] = s[i]
    inc(i)
    inc(j)
  setLen(result, j)
####
#### END FROM: https://github.com/nim-lang/Nim/blob/master/lib/pure/cgi.nim#L55


#### httpform
#### FROM: https://github.com/tulayang/httpform/blob/master/httpform.nim#L22
####
proc parseUrlencoded*(body: string): JsonNode {.inline.} =
  var
    a: seq[string]
    i, h: int
  result = newJObject()
  for s in body.split('&'):
    if s.len() == 0 or s == "=":
      result[""] = newJString("")
    else:
      i = s.find('=')
      h = s.high()
      if i == -1:
        result[s] = newJString("")
      elif i == 0:
        result[""] = newJString(s[i+1..h])
      elif i == h:
        result[s[0..h-1]] = newJString("")
      else:
        result[s[0..i-1]] = newJString(s[i+1..h])
####
#### END FROM: https://github.com/tulayang/httpform/blob/master/httpform.nim#L22
