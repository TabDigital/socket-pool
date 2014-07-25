net      = require 'net'
_        = require 'lodash'
protocol = require './protocol'

module.exports = class SocketPoolServer

  constructor: () ->
    @partialBuffer = null

    net.createServer (stream)->
      stream.on 'data', (buf) ->
        @process buf, stream, func

  process: (buf, stream, func) ->
    # fromBuffer to get pieces of data
    # results = func data
    # loop { stream.write toBuf(encode results  }
    #
    if @partialBuffer?.length > 0
      combinedBuffer = Buffer.concat [@partialBuffer, buf]
    else
      combinedBuffer = buf

    results = protocol.fromBuffer combinedBuffer
    @partialBuffer = results.buffer

    if results.dataArray.length > 0
      decoded = _.map results.dataArray, (s) -> protocol.decode (s)
      _.each decoded, (d) -> 
        responseData = func(d.content)
        stream.write protocol.toBuffer(protocol.encode d.msn, responseData)
