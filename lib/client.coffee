Q        = require 'q'
_        = require 'lodash'
net      = require 'net'
protocol = require './protocol'

module.exports = class SocketPoolClient

  POOL_SIZE = 20
  STREAM_SIZE = 256
  SERVER_PORT = 8889

  constructor: (poolSize, streamSize, serverPort)->
    @poolSize   = poolSize   || POOL_SIZE
    @streamSize = streamSize || STREAM_SIZE
    @serverPort = serverPort || SERVER_PORT
    @socketPool = []
    @partialBuffer = null

  init: (callback)=>
    @initPool().then () =>
      @initStreams(callback)
  
  initPool:  =>
    connects = _.map [0..@poolSize - 1], @connect

    Q.all connects

  connect: (i) =>
    deferred = Q.defer()

    @socketPool[i] = net.connect {port: @serverPort}, () ->
      deferred.resolve() 

    return deferred.promise

  initStreams: (callback) =>
    for stream in @socketPool
      stream.tunnels = []

      for i in [0..@streamSize-1]
        stream.tunnels[i] =
          msn:      i
          callback: null

      that = this

      stream.on 'data', (buf) ->

        if that.partialBuffer?.length > 0
          combinedBuffer = Buffer.concat [that.partialBuffer, buf]
        else
          combinedBuffer = buf

        results = protocol.fromBuffer combinedBuffer
        that.partialBuffer = results.buffer

        if results.dataArray.length > 0
          decoded = _.map results.dataArray, (s) -> protocol.decode (s)

          # bind to stream
          me = this

          _.each decoded, (d) -> 
            me.tunnels[d.msn].callback(d.content)
            me.tunnels[d.msn].callback = null

    callback()

  send: (content, callback) ->
    picked = @pick()
    picked.tunnel.callback = callback
    encoded = protocol.encode(picked.tunnel.msn, content)
    picked.stream.write protocol.toBuffer(encoded)

  pick: ->
    for stream in @socketPool
      tunnel = _.find stream.tunnels, (t) -> !t.callback

      if tunnel
        return {stream, tunnel}

