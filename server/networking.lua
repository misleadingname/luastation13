local networking = {}

local enet = require("enet")

local host

function networking.start(port, maxPeers)
	if host then
		LS13.Logging.LogError("Host already created")
		return
	end

	LS13.Logging.LogInfo("Running lua-enet %s", enet.linked_version())

	host = enet.host_create("localhost:" .. port, maxPeers, 1)

	LS13.Logging.LogInfo("Host created on port %s", port)
end

function networking.process()
	local event = host:service()
	while event do
		if event.type == "receive" then
			LS13.Logging.LogDebug("Got message %s by %s", event.data, event.peer)
			event.peer:send("pong")
		elseif event.type == "connect" then
			LS13.Logging.LogDebug("%s connected", event.peer)
		elseif event.type == "disconnect" then
			LS13.Logging.LogDebug("%s disconnected", event.peer)
		end
		event = host:service()
	end
end

function networking.shutdown()
	host:destroy()
end

return networking
