local DebugStartRound = {}

function DebugStartRound:processOnServer()
	LS13.RoundManager.addClient(self.invoker)
	LS13.RoundManager.startRound()
	return true
end

return DebugStartRound
