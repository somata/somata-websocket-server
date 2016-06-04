ws = require 'ws'
somata = require 'somata'
{log} = somata

setup_ws = ({port}) ->
    server = new ws.Server {port}
    client = new somata.Client

    server.on 'connection', (socket) ->
        log.i "[ws.on connection] New connection"
        subscriptions = {}
        socket.id = somata.helpers.randomString()

        socket.on 'message', (data) ->
            message = JSON.parse data
            switch message.kind

                when 'remote'
                    {service, method, args, id} = message
                    console.log "[ws.on remote] <#{ socket.id }> #{ service } : #{ method }"
                    client.remote service, method, args..., (err, response) ->
                        socket.send JSON.stringify {kind: 'response', response, id}

                when 'subscribe'
                    # Forward subscriptions by emitting events back over socket
                    {service, type} = message
                    console.log "[ws.on subscribe] <#{ socket.id }> #{ service } : #{ type }"
                    handler = client.on service, type, (event) ->
                        socket.send JSON.stringify {kind: 'event', service, type, event}
                    subscriptions[service] ||= {}
                    subscriptions[service][type] ||= []
                    subscriptions[service][type].push handler

                when 'unsubscribe'
                    {service, type} = message
                    console.log '[ws.on unsubscribe]', service, type
                    subscriptions[service][type].map (sub_id) ->
                        client.unsubscribe sub_id
                    delete subscriptions[service][type]

        # Unsubscribe from all of a socket's subscriptions
        socket.on 'close', ->
            console.log "[ws.on disconnect] <#{ socket.id }>"
            for service, types of subscriptions
                for type, subs of types
                    subs.map (sub_id) ->
                        client.unsubscribe sub_id

    console.log "Listening on :#{port}"

if require.main == module
    setup_ws {port: 5555}
else
    module.exports = setup_ws

