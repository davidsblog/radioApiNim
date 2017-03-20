# ht02nim nim c --cpu:mipsel --os:linux -d:uClibc radioApi.nim

import asynchttpserver, asyncdispatch, json, tables
import os, strutils, posix, strtabs
import execpiped, externals

var types  = {
  ".js" : "text/javascript",
  ".css" :"text/css",
  ".ico": "image/ico",
  ".woff" : "application/font-woff",
  ".woff2" : "application/font-woff2",
  ".htm" : "text/html",
  ".html" : "text/html",
  ".gif" : "image/gif",
  ".jpg" : "image/jpg",
  ".jpeg":"image/jpeg",
  ".png" : "image/png",
  ".ico" : "image/x-icon"
}.newTable()

const wgetCmd = @["/usr/bin/wget", "-q", "-O", "-"]
const madplayCmd = @["/usr/bin/madplay", "-q", "-"]
const mixer = @["/usr/bin/amixer", "-q", "sset"]
const success = "OK"

var pids = (0,0)
var volume = 4
var idx= "-1"

proc whenValidRequest(req: Request, action: proc(fields: JsonNode): string) {.async.} =
  var error: string
  var parsedFormFields: JsonNode
  try:
    parsedFormFields = req.body.parseUrlencoded()
  except:
    error = getCurrentExceptionMsg()

  if error != nil:
    await req.respond(Http500, "500 Error: " & error)
    return

  if parsedFormFields.len > 0:
    var resp = action(parsedFormFields)
    if idx == nil or idx.len == 0: idx = "-1"
    var json = %* { "status": resp, "volume": $volume, "idx": idx }
    await req.respond(Http200, $json)
  else:
    await req.respond(Http500, "500 Error: no form values were sent")

proc mixervol() =
  if volume > 20: volume = 20
  elif volume < 0: volume = 0
  if fork() == 0:
    let cmd = mixer & "PCM" & $(volume * 5)
    #let cmd = mixer & "Master" & $(volume * 5)
    doAssert(execv(cmd[0], allocCStringArray(cmd)) != -1)

proc volinc(fields: JsonNode): string =
  var vol = fields.getOrDefault("vol").getStr()
  case vol:
    of "up": volume.inc()
    of "dn": volume.dec()
  mixervol()
  result = success

proc setvol(fields: JsonNode): string =
  volume = fields.getOrDefault("vol").getStr().parseInt()
  mixervol()
  result = success

proc stream(fields: JsonNode): string =
  pids = killpiped(pids)
  var url = fields.getOrDefault("streamurl").getStr().decodeUrl()
  idx = fields.getOrDefault("idx").getStr().strip()

  if url.len > 0 and url != "stop":
    pids = execpiped(wgetCmd & url, madplayCmd)
  result = success

proc get(req: Request) {.async.} =
  let path = if $req.url.path == "/": "index.html" else: $req.url.path
  let (dir, name, ext) = path.splitFile()
  if not types.contains(ext):
    await req.respond(Http403, "403 File extension type not supported")
  elif path.contains("..") or path.contains("~"):
    await req.respond(Http403, "403 Parent paths not supported")
  else:
    let filepath = getCurrentDir() / "public" / path
    if fileExists(filepath):
      let httpHeaders = newHttpHeaders()
      httpHeaders.add("Content-Type", types[ext])
      await req.respond(Http200, readFile(filepath), httpHeaders)
    else:
      await req.respond(Http404, "404 Not Found")

proc post(req: Request) {.async.} =
  case $req.url.path:
    of "/api/incvol": await whenValidRequest(req, volinc)
    of "/api/setvol": await whenValidRequest(req, setvol)
    of "/api/stream": await whenValidRequest(req, stream)
    else: await req.respond(Http404, "404 Not Found")

proc httpCallback(req: Request) {.async.} =
  case req.reqMethod:
    of HttpGet: await req.get()
    of HttpPost: await req.post()
    else: await req.respond(Http501, "501 Not Implemented: " & $req.reqMethod)

asyncCheck newAsyncHttpServer().serve(Port(5000), httpCallback)
mixervol()
runForever()
