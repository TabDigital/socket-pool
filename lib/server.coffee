net = require 'net'


module.exports = class SocketPoolServer

  constructor: () ->
    net.createServer (c)->
      c.on 'data', (msg) ->
        @process msg, c

  process: (msg, c) ->
    # decode msg to pieces of data
    # loop { c.write data }
