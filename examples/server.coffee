net              = require 'net'
SocketPoolServer = require('../lib/index').server


syncFunc = (content) ->
  "#{content} has been processed"

server = new SocketPoolServer(syncFunc)