should             = require 'should'
Q                  = require 'q'
net                = require 'net'
EventEmitter       = require('events').EventEmitter
sinon              = require 'sinon'
SocketPoolClient   = require '../lib/client'
protocol           = require '../lib/protocol'

describe 'client', ->

  beforeEach ->
    stream = new EventEmitter()
    sinon.stub(stream, 'on')
    stream.write = sinon.stub()
    sinon.stub(net, 'connect').yields null
    net.connect.returns stream

  afterEach ->
    net.connect.restore()

  it 'initiates a default stream pool', (done) ->
    client = new SocketPoolClient()

    client.init () ->
      client.socketPool.length.should.eql 20
      client.socketPool[0].tunnels.length.should.eql 256
      done()

  it 'picks an available stream tunnel pair', ->
    client = new SocketPoolClient(1, 2)
    func = -> return 'a simple call'

    client.init () ->
      client.socketPool[0].tunnels[0].callback = func
      client.pick().should.eql
        stream: client.socketPool[0]
        tunnel: client.socketPool[0].tunnels[1]

  it 'calls right callbacks after server respondss', ->
    # response buffer from server
    buf1 = protocol.toBuffer '0 content for first request'
    buf2 = protocol.toBuffer '1 content for second request'

    buffer = Buffer.concat [buf1, buf2]

    callback1 = sinon.stub()
    callback2 = sinon.stub()

    client = new SocketPoolClient(1, 2)

    client.init () ->
      client.socketPool[0].tunnels[0].callback = callback1
      client.socketPool[0].tunnels[1].callback = callback2

      client.process buffer, client.socketPool[0]

      sinon.assert.calledWith callback1, 'content for first request'
      sinon.assert.calledWith callback2, 'content for second request'

  it 'sends encoded content with callback', ->
    client = new SocketPoolClient()
    callback = ->

    client.init () ->
      pickedStream = client.socketPool[0]
      pickedTunnel = pickedStream.tunnels[0]

      sinon.stub(client, 'pick').returns
        stream: pickedStream
        tunnel: pickedTunnel

      client.send 'first request', callback

      pickedTunnel.callback.should.eql callback







