# content type is string
# 2 is for length of data
# data consisted of "msn content"
exports.toBuffer = (data) ->
  buf = new Buffer(data.length + 2)
  hexLen = data.length.toString(16)

  buf.writeUInt16LE("0x#{hexLen}", 0)
  buf.write(data,2)

  buf

exports.fromBuffer = (buffer) ->
  dataArray = []
  readable = true

  while(readable)
    contentLen = buffer.readUInt16LE(0,2)

    if contentLen + 2 <= buffer.length
      dataArray.push buffer.toString('utf-8', 2, 2 + contentLen)
      buffer = buffer.slice(0,2 + contentLen)
    else
      readable = false

  # return partial buffer to be concatted
  return { dataArrary, buffer }

exports.encode = (msn, content) ->
  "#{msn} #{content}"

exports.decode = (data) ->
  i = data.indexOf(' ')
  msn = data[0..i-1]
  content = data.substring(i+1)

  { msn, content }
