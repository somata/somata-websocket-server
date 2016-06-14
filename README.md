# somata-websocket-server

Bridge between websocket clients and Somata services, using [ws](https://github.com/websockets/ws).

## Installation

```
npm install somata-websocket-server
```

## Usage

```coffee
swss = require 'somata-websocket-server'
swss {port: 5555}
```

From the client, connect with [somata-websocket-client](https://github.com/somata/somata-websocket-client):

```coffee
swsc = require 'somata-websocket-client'
client = swsc 'ws://localhost:5555'
```

## Using with [Polar](https://github.com/spro/polar) or Express

```coffee
http = require 'http'
polar = require 'polar'
swss = require 'somata-websocket-server'

server = http.createServer()
swss {server}

app = polar()
server.on 'request', app

app.get '/', (req, res) ->
    res.render 'app'

server.listen 5999, -> console.log "Listening on :5999"
```
