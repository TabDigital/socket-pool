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

  initPool:  ->
    poolSize = @poolSize

    deferred = Q.defer()

    while poolSize--
      @socketPool[poolSize] = net.connect {port: @serverPort}, () ->
        if poolSize == 0
          deferred.resolve()

    return deferred.promise

  initStreams: (callback) ->
    for stream in @socketPool
      stream.tunnels = []

      for i in [0..@streamSize-1]
        stream.tunnels[i] =
          msn:      i
          callback: null

      stream.on 'data', (buf) =>
        @process buf, stream

    callback()

  send: (content, callback) =>
    @pick().tunnel.callback = callback
    encoded = protocol.encode(@pick().tunnel.msn, content)
    @pick().stream.write protocol.toBuffer(encoded)

  pick: ->
    for stream in @socketPool
      tunnel = _.find stream.tunnels, (t) -> !t.callback
      if tunnel
        return {stream, tunnel}

  process: (buf, stream)->
    if @partialBuffer?.length > 0
      combinedBuffer = Buffer.concat [@partialBuffer, buf]
    else
      combinedBuffer = buf

    results = protocol.fromBuffer combinedBuffer
    @partialBuffer = results.buffer

    if results.dataArray.length > 0
      decoded = _.map results.dataArray, (s) -> protocol.decode (s)
      _.each decoded, (d) -> stream.tunnels[d.msn].callback d.content
