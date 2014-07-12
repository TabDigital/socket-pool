should   = require 'should'
protocol = require '../lib/protocol'


createBuffer = (s) ->
  buf = new Buffer(s.length + 2)
  buf.writeUInt16LE s.length, 0
  buf.write(s, 2)

  buf

describe 'protocol', ->

  it '#toBuffer convert string into length tagged buffer', ->
    s = '3 request content' # msn + content
    buf = protocol.toBuffer(s)

    buf.readUInt16LE(0,2).should.eql s.length
    buf.toString('utf-8', 2, 2 + s.length).should.eql '3 request content'

  describe '#fromBuffer', ->

    it 'returns content in buffer into an array', ->
      buf1 = createBuffer '0 first request'
      buf2 = createBuffer '1 second request'

      buf = Buffer.concat [buf1, buf2]

      results = protocol.fromBuffer buf
      results.dataArray.should.eql ['0 first request', '1 second request']

    describe 'partial buffer', ->

      it 'returns content and partial buffer in the result', ->
        buf1 = createBuffer '0 first request'
        buf2 = createBuffer '1 second request'

        s3 = '2 third request'
        partialS3 = '2 th'
        buf3 = new Buffer(partialS3.length + 2)
        buf3.writeUInt16LE s3.length, 0
        buf3.write partialS3, 2

        buf = Buffer.concat [buf1, buf2, buf3]

        results = protocol.fromBuffer buf
        results.dataArray.should.eql ['0 first request', '1 second request']
        results.buffer.should.eql buf3

      it 'returns correct result even if content length is in two seperate buffers', ->
        buf1 = createBuffer '0 first request'

        s2 = '1 second request'
        buf2 = new Buffer(2)
        buf2.writeUInt16LE s2.length, 0

        # only get the first half
        buf2 = buf2.slice 0, 1

        buf = Buffer.concat [buf1, buf2]

        results = protocol.fromBuffer buf
        results.dataArray.should.eql ['0 first request']
        results.buffer.should.eql buf2


  it '#encode encodes sent content with message sequential number(msn)', ->
    content = 'a request data'
    msn = 31

    protocol.encode(msn, content).should.eql '31 a request data'

  it '#decode decodes received data into msn and content', ->
    data = '31 a request data'

    protocol.decode(data).should.eql
      msn: 31
      content: 'a request data'



