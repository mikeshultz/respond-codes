import re, times, strutils, strformat, typetraits
import asynchttpserver, asyncdispatch, asyncnet

proc nowHeader: string =
  # Date: <day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT
  return now().utc.format("ddd, dd MM yyyy hh:mm:ss") & " UTC"

proc logRequest(req: Request, httpCode: string, httpMethod: string = "GET", size: string, stamp: string = nowHeader()) =
  let (ip, port) = req.client.getPeerAddr()
  echo fmt"{ip} - - [{stamp}] ""{httpMethod} {req.url.path} HTTP/1.1"" {httpCode} {size}"

proc send404(req: Request, headers: HttpHeaders) {.async.} =
  await req.respond(HttpCode(404), "Not Found", headers)

proc main(server: AsyncHttpServer) {.async.} =

  proc handler(req: Request) {.async.} =
    var now = nowHeader()
    let headers = {
      "Date": now,
      "Content-type": "text/plain; charset=utf-8"
    }
    var statusCode = "404"

    if req.url.path.high <= 1:
      await send404(req, headers.newHttpHeaders())

    else:
      statusCode = req.url.path[1..req.url.path.high]

      if match(statusCode, re"^[0-9]+$", start=0):
        var intCode = parseint(statusCode)
        await req.respond(HttpCode(intCode), "", headers.newHttpHeaders())
      else:
        await send404(req, headers.newHttpHeaders())

    logRequest(req, statusCode, "GET", "0", now)

    # Close the connection
    req.client.close()

  waitFor server.serve(Port(5555), handler)

when isMainModule:
  var server = newAsyncHttpServer()
  asyncCheck main(server)
  runForever()
