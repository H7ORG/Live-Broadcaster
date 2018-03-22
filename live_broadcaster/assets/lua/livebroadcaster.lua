
cameleonCenterClient = nil
streams = {}
localClients = {}
localClientCount = 0
masterClient = nil

function onStart( path )
  
  print("Server application '"..path.."' started")
  for k in pairs(mona.configs) do NOTE(k..": "..tostring(mona.configs[k])) end
  ccAppStart( name )
  
end

function onStop(path)
  
  NOTE("Server application '"..path.."' stopping...")
  
  closeAllLocalClients()
  --closeAllPublications()
  
  ccAppStop( name )
  NOTE("Server application '"..path.."' stopped")
  
end

function closeAllPublications()
  
  for p in pairs( publications ) do
    publications[p].close()
  end
  
end

function closeAllLocalClients()
  
  NOTE("Closing all clients...")
  for p in pairs(localClients) do 
    
    NOTE("Client."..p..": "..tostring( localClients[p] ))
    closeLocalClient( localClients[p] )
    --ccClientDisconnect( name, localClients[p] )
    --ccCloseClient( localClients[p].id )
    
  end
  
end

function closeLocalClient( client )
  
  clientId = client.id
  NOTE("closeLocalClient.Closing "..tostring( client )..", id:"..client.id)
  onDisconnection( client )
  client.writer:close()
  --ccCloseClient( clientId )
  
end

function onConnection( client, properties )
  
  --client.address.host.value
  NOTE("Client.id: "..client.id)
  clientAddress = tostring(client.address)
  clientIP = client.address.host.value
  NOTE("Client.address: "..clientAddress)
  NOTE("clientIP: "..clientIP)
  NOTE("Client.ping: "..client.ping)
  NOTE("Client.protocol: "..client.protocol)
  if ( client.query ~= nil ) then NOTE("Client.query: "..client.query) end
  --NOTE("Client.properties.swfUrl"..client.properties.swfUrl)
  
  for p in pairs(client) do NOTE("Client."..p..": "..tostring(client[p])) end
  for p in pairs(client.parameters) do NOTE("Client.parameters."..p..": "..tostring(client.parameters[p])) end
  for p in pairs(client.properties) do NOTE("Client.properties."..p..": "..tostring(client.properties[p])) end
  
  if ( properties ~= nil ) then
    
    for p in pairs(properties) do NOTE(p..": "..tostring(properties[p])) end
    
    properties.id = client.id
    
    if ( properties.type == "CameleonCenter" ) then
      
      return addCameleonCenterClient( client, properties )
      
    elseif ( properties.type == "LiveBroadcaster" ) then
      
      return addLiveBroadcasterClient( client, properties )
      
    else 
      
      error( "Connection not allowed, unknown client type" )
      
    end
  
  else
    -- Possibly FFMPEG connection?
    if ( clientIP == "127.0.0.1" ) then
      addFFMPEGClient( client, properties )
      -- DO NOT return anything to FFMPEG, otherwise it fails
    else 
      --error( "Connection not allowed, no properties set" )
      -- Possibly mobile client?
      addMobileClient( client, properties )
    end
  end
  
  --return { mona=mona.configs }

end

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=0
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function addCameleonCenterClient( client, properties )
  client.properties = properties
  cameleonCenterClient = client
  NOTE( "CameleonCenter client added: "..client.id )
  return { mona=mona.configs }
end

function addLiveBroadcasterClient( client, properties )
  client.properties = properties
  
  masterClient = client
  
  function client:getStreams()
    --for name, publication in pairs(mona.publications) do INFO( name, " : ", publication.properties ) end
    NOTE( "Publications length: ", #mona.publications )
    INFO(mona:toJSON(mona.publications))
    for p in pairs(streams) do NOTE( "Stream:", p ) end
    return { streams=streams }
  end
  
  NOTE( "LiveBroadcaster client added: "..client.id )
  if ( cameleonCenterClient ~= nil ) then
    cameleonCenterClient.writer:writeInvocation( "clientAdded", properties )
    cameleonCenterClient.writer:flush()
  end
  
  localClients[ client.id ] = client
  localClientCount = localClientCount + 1
  ccClientConnect( name, client )
  
  return { mona=mona.configs }
end

function onDisconnection( client )
  
  --localClients[ client.id ].writer:close()
  if ( client ~= nil ) then 
    
    for p in pairs(client) do NOTE("onDisconnection.Client."..p..": "..tostring(client[p])) end
    ccClientDisconnect( name, client )
  
    if ( localClients[ client.id ] ~= nil ) then
      localClients[ client.id ] = nil
      localClientCount = localClientCount - 1
    end
    
    if ( client == masterClient ) then
      
      closeAllLocalClients()
      
    end

    NOTE( ":::::"..localClientCount )
    --client.writer:close()
    
  end

  if ( localClientCount <= 0 ) then
    localClientCount = 0
    --stop()
  end
  
end

function addFFMPEGClient( client, properties )
  client.properties = properties
  
  function client:releaseStream(publication)
    --dummy function for FFMPEG
  end
  
  function client:FCPublish(publication)
  end

  function client:FCUnpublish(publication)
  end
  
  function client:onPublish(publication)
    for p in pairs(publication) do NOTE( "Publication:", p ) end
    streams[publication.name] = publication
    ccStreamPublish( name, publication )
  end
  
  function client:onUnpublish(publication)
    streams[publication.name] = nil
    ccStreamUnpublish( name, publication )
  end
  
  NOTE( "FFMPEG client added: "..client.id )
  if ( cameleonCenterClient ~= nil ) then
    cameleonCenterClient.writer:writeInvocation( "clientAdded", properties )
    cameleonCenterClient.writer:flush()
  end
  
  localClients[ client.id ] = client
  localClientCount = localClientCount + 1
  ccClientConnect( name, client )
  
  return true
end

function addMobileClient( client, properties )
  client.properties = properties
  
  function client:releaseStream(publication)
    --dummy function for FFMPEG
  end
  
  function client:FCPublish(publication)
  end

  function client:FCUnpublish(publication)
  end
  
  function client:onPublish(publication)
    for p in pairs(publication) do NOTE( "Publication:", p ) end
    streams[publication.name] = publication
    ccStreamPublish( name, publication )
  end
  
  function client:onUnpublish(publication)
    streams[publication.name] = nil
    ccStreamUnpublish( name, publication )
  end
  
  NOTE( "Mobile client added: "..client.id )
  if ( cameleonCenterClient ~= nil ) then
    cameleonCenterClient.writer:writeInvocation( "clientAdded", properties )
    cameleonCenterClient.writer:flush()
  end
  
  localClients[ client.id ] = client
  localClientCount = localClientCount + 1
  ccClientConnect( name, client )
  
  return true
end
