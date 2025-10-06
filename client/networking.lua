local networking = {}

local enet = require("enet")

local host
local serverPeer

function networking.start(ip)
	if serverPeer then
		LS13.Logging.LogError("Already connected")
		return
	end

	LS13.Logging.LogInfo("Running lua-enet %s", enet.linked_version())

	if not host then
		host = enet.host_create()
	end

	serverPeer = host:connect(ip, 1)

	if not serverPeer then
		LS13.Logging.LogError("Failed to connect to %s", ip)
		return
	end

	LS13.Logging.LogError("Connected to %s", serverPeer)
end

function networking.process()
	if not serverPeer then
		return
	end

	local event = host:service()
	while event do
		if event.type == "receive" then
			LS13.Logging.LogDebug("Got message %s by %s", event.data, event.peer)
		elseif event.type == "connect" then
			LS13.Logging.LogDebug("connected to %s", event.peer)
			event.peer:send("ping")
		elseif event.type == "disconnect" then
			LS13.Logging.LogDebug("disconnected from %s", event.peer)
		end
		event = host:service()
	end
end

function networking.shutdown()
	serverPeer:disconnect_now() -- this might be a bad idea

	host:destroy()
end

return networking
