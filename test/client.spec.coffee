should             = require 'should'
Q                  = require 'q'
net                = require 'net'
EventEmitter       = require('events').EventEmitter
sinon              = require 'sinon'
SocketPoolClient   = require '../lib/client'

describe 'client', ->

  beforeEach ->
    sinon.stub(net, 'connect').yields null

  afterEach ->
    net.connect.restore()

  it 'initiates a default stream pool', (done) ->
    stream = new EventEmitter()
    sinon.stub(stream, 'on')
    net.connect.returns stream
    client = new SocketPoolClient()

    client.init () ->
      client.socketPool.length.should.eql 20
      client.socketPool[0].tunnels.length.should.eql 256
      done()
