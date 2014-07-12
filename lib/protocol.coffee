# content type is string
# 2 is for length of data
# data consisted of "msn content"
exports.toBuffer = (data) ->
  buf = new Buffer(data.length + 2)

  buf.writeUInt16LE(data.length, 0)
  buf.write(data,2)

  buf

exports.fromBuffer = (buffer) ->
  dataArray = []

  while(true)
    # partial content's length
    if buffer.length <= 2
      break

    contentLen = buffer.readUInt16LE(0,2)

    # partial content
    if contentLen + 2 > buffer.length
      break

    dataArray.push buffer.toString('utf-8', 2, 2 + contentLen)
    buffer = buffer.slice(2 + contentLen , buffer.length)

    contentLen = buffer.readUInt16LE(0,2)

  # return partial buffer to be concated
  return { dataArray, buffer }

# msn: message sequential number in one stream
exports.encode = (msn, content) ->
  "#{msn} #{content}"

exports.decode = (data) ->
  i = data.indexOf(' ')
  msn = parseInt data[0..i-1]
  content = data.substring(i+1)

  { msn, content }
