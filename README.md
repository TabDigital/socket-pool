socket-pool
===========


Maintain a sockets connection pool for communication between two servers, but acts like normal single socket calls. Each socket connection does multiplexing.

##Usage(WIP)

### on client side
```coffee
# configure pool size, stream size, host ..etc
client = new SocketPoolClient(options) 

client.send 'some data', (data) -> 'callback to process data'
```

### on server side
```coffee
func = (data) -> 'function to process received data'
server = new SocketPoolServer(func)
server.listen 8888
```
