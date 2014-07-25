should             = require 'should'
Q                  = require 'q'
net                = require 'net'
EventEmitter       = require('events').EventEmitter
sinon              = require 'sinon'
SocketPoolServer   = require '../lib/server'
protocol           = require '../lib/protocol'

describe 'server', ->

  stream = null
  syncFunc = null

  beforeEach ->
    syncFunc = sinon.stub()

    stream = new EventEmitter()
    sinon.stub(stream, 'on')
    stream.write = sinon.stub()
    sinon.stub(net, 'connect').yields null
    net.connect.returns stream

  afterEach ->
    net.connect.restore()
  
  it 'sends back encoded reponse on the request stream', ->

    socketPoolServer = new SocketPoolServer()
    syncFunc.returns 'request processed'

    buf = protocol.toBuffer '0 content for first request'
    socketPoolServer.process buf, stream, syncFunc

    sinon.stub(protocol, 'toBuffer').returns 'response buffer'
    sinon.assert.calledWith syncFunc, 'content for first request'
    protocol.toBuffer.calledWith protocol.toBuffer, '0 request processed'
    stream.write.calledWith stream.write, 'response buffer'

    protocol.toBuffer.restore()

