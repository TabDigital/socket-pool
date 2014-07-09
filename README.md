socket-pool
===========


Maintain a sockets connection pool for communication between two servers, but acts like normal single socket calls.

##Usage(WIP)

### on client side
```coffee
client = new SocketPoolClient()

client.send 'some data', (data) -> 'callback to process data'
```

### on server side
```coffee
func = (data) -> 'function to process received data'
server = new SocketPoolServer(func)
server.listen 8888
```

