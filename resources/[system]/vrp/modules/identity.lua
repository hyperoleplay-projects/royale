-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local identities = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- getIdentity - Funciton
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getIdentity(user_id)
	if not identities[user_id] then
		local rows = vRP.query("vRP/requestUser",{ id = user_id })
		if #rows > 0 then
			identities[user_id] = rows[1]
		else
			local nsource = vRP.getUserSource(user_id)
			if nsource then
			    DropPlayer(nsource, "Você teve um problema de identidade, se conecte novamente.")
			end
		end
	end
	
	return identities[user_id]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- updateIdentity - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.updateIdentity(user_id)
	local rows = vRP.query("vRP/requestUser",{ id = user_id })
	identities[user_id] = {}

	Wait(900)
	
	identities[user_id] = rows[1]
end
