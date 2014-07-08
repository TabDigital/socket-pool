Q        = require 'q'
_        = require 'lodash'
net      = require 'net'
protocol = require './protocol'

module.exports = class SocketPoolClient

  POOL_SIZE = 100
  STREAM_SIZE = 256
  SERVER_PORT = 8889

  constructor: (poolSize, streamSize, serverPort)->
    @poolSize   = poolSize   || POOL_SIZE
    @streamSize = streamSize || STREAM_SIZE
    @serverPort = serverPort || SERVER_PORT
    @socketPool = []
    @partialBuffer = null

    @init()

  init: ->
    @initPool().then initStreams

  initPool:  ->
    poolSize = @poolSize

    deferred = Q.defer()

    while poolSize--
      stream = net.connect {port: @serverPort}, () ->
        @socketPool.push stream
        if poolSize == 0
          deferred.resolve()

    return deferred.promise

  initStreams: () =>
    for stream in @socketPool
      stream.tunnels = []

      for i in [0..STREAM_SIZE-1]
        stream.tunnels[i] =
          msn:      i
          callback: null

      stream.on 'data', (buf) =>
        @process buf, stream

  send: (content, callback) ->
    @pick.tunnel.callback = callback
    encoded = protocol.encode(@pick.tunnel.msn, content)
    @pick.stream.write protocol.toBuffer(encoded)

  pick: ->
    for stream in @socketPool
      tunnel = _.find stream.tunnels, (t) -> !t.callback
      if tunnel
        return {stream, tunnel}

  process: (buf, stream)->
    if @partialBuffer
      combinedBuffer = Buffer.concat [@partialBuffer, buf]
    else
      combinedBuffer = buf

    results = protocol.fromBuffer combinedBuffer
    @partialBuffer = results.buffer

    if results.dataArray.length > 0
      decoded = _.map results.dataArray, (s) -> protocol.decode (s)
      _.each decoded, (d) -> stream.tunnels[d.msn].callback d.content
