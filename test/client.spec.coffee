should             = require 'should'
Q                  = require 'q'
net                = require 'net'
EventEmitter       = require('events').EventEmitter
sinon              = require 'sinon'
SocketPoolClient   = require '../lib/client'

describe 'client', ->

  beforeEach ->
    stream = new EventEmitter()
    sinon.stub(stream, 'on')
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
