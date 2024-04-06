AddStateBagChangeHandler("submix","",function(bagName,_,value)
	local tgtId = tonumber(bagName:gsub('player:',''),10)
	if not tgtId then return end

	if value and not submixIndicies[value] then return end
	if not value and not radioData[tgtId] and not callData[tgtId] then
		MumbleSetSubmixForServerId(tgtId,-1)
		return
	end

	MumbleSetSubmixForServerId(tgtId,submixIndicies[value])
end)