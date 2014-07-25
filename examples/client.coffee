net              = require 'net'
http             = require 'http'
SocketPoolClient = require('../lib/index').client

s = null
count = 0
client = new SocketPoolClient()

client.init ->

  s = http.createServer (req, resp) ->

    client.send 'test', (data) ->
      console.log count++
      resp.end()

  s.listen 8888