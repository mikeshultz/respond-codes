import re, times, strutils, strformat, typetraits
import asynchttpserver, asyncdispatch, asyncnet

const INDEX_BODY = """################################################################################
################################ respond.codes #################################
################################################################################

This service responds with requested HTTP status codes.  If you want an HTTP
418, send a request to /418.  For example:

    curl -I http://respond.codes/418
"""

proc nowHeader: string =
  # Date: <day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT
  return now().utc.format("ddd, dd MM yyyy hh:mm:ss") & " UTC"

proc logRequest(req: Request, httpCode: string, httpMethod: string = "GET", size: string, stamp: string = nowHeader()) =
  let (ip, port) = req.client.getPeerAddr()
  echo fmt"{ip} - - [{stamp}] ""{httpMethod} {req.url.path} HTTP/1.1"" {httpCode} {size}"

proc send404(req: Request, headers: HttpHeaders) {.async.} =
  await req.respond(HttpCode(404), "Not Found", headers)

proc main(server: AsyncHttpServer) {.async.} =

  proc handler(req: Request) {.async, gcsafe.} =
    var now = nowHeader()
    let headers = {
      "Date": now,
      "Content-type": "text/plain; charset=utf-8"
    }
    var statusCode = "404"

    if req.url.path.high <= 1:
      await req.respond(Http200, INDEX_BODY, headers.newHttpHeaders())

    else:
      var final = req.url.path.high

      # Chop off the end slash
      if req.url.path[final..final] == "/":
        final = req.url.path.high - 1

      statusCode = req.url.path[1..final]
      echo "statusCode:" & statusCode
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
