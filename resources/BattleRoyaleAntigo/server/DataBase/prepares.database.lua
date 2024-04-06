-----------------------------------------------------------------------------------------------------------------------------------------
-- LOJA - SHOP
-----------------------------------------------------------------------------------------------------------------------------------------
vRP._prepare("vRP/GetClothes","SELECT * FROM clothes")
vRP._prepare("vRP/getWeaponsShop","SELECT * FROM weapons")
-----------------------------------------------------------------------------------------------------------------------------------------
-- JOGADOR - PLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
vRP._prepare("vRP/GetInventory","SELECT * FROM inventory WHERE user_id = @user_id")
vRP._prepare("vRP/GetUserGroups","SELECT * FROM users_groups WHERE user_id = @user_id")
vRP._prepare("vRP/GetUserGroupHas","SELECT * FROM users_groups WHERE `group` = @group AND user_id = @user_id")
vRP._prepare("vRP/GetUserReports","SELECT * FROM users_reports WHERE id = @user_id")
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEAPON - JOGADOR
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare('vRP/updateWeaon','UPDATE inventory SET inventory_status = @inventory_status WHERE inventory_id = @inventory_id AND user_id = @user_id')
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN
-----------------------------------------------------------------------------------------------------------------------------------------
vRP._prepare("vRP/giveItem","INSERT INTO inventory(user_id,inventory_itemName,inventory_itemStatus,inventory_itemType, inventory_generate) VALUES(@user_id,@inventory_itemName,@inventory_itemStatus,@inventory_itemType,@inventory_generate)")
vRP._prepare("vRP/addMatch","INSERT INTO matchs(id,matchWinner) VALUES(@id,@matchWinner)")
vRP._prepare("vRP/addCode","INSERT INTO codiguins(code,used) VALUES(@code,@used)")

vRP._prepare("vRP/AddGroup","INSERT INTO users_groups(user_id,`group`) VALUES(@user_id,@group)")
vRP._prepare("vRP/RemoveGroup","DELETE FROM users_groups WHERE user_id = @user_id AND `group` = @group")

vRP._prepare("vRP/getFriends","SELECT * FROM users_friends WHERE user_id = @user_id")
vRP._prepare("vRP/getInventory","SELECT * FROM inventory WHERE user_id = @user_id")

vRP.prepare('vRP/updateInventory','UPDATE inventory SET inventory_itemStatus = @inventory_itemStatus WHERE inventory_id = @inventory_id AND user_id = @user_id')
vRP.prepare('vRP/updatePoints','UPDATE users SET points = @points WHERE id = @id')
vRP.prepare('vRP/updateKills','UPDATE users SET kills = @kills WHERE id = @id')
vRP.prepare('vRP/updateDeaths','UPDATE users SET deaths = @deaths WHERE id = @id')
vRP.prepare('vRP/updateLoses','UPDATE users SET loses = @loses WHERE id = @id')
vRP.prepare('vRP/updateSkin','UPDATE inventory SET inventory_itemStatus = @inventory_itemStatus WHERE inventory_id = @inventory_id')

vRP.prepare('vRP/updateConfig','UPDATE users SET fpsSettings = @fpsSettings WHERE id = @id')
vRP._prepare("vRP/GetRanking","SELECT * FROM users")

vRP._prepare("vRP/removeCoins","UPDATE users SET duthCoins = duthCoins - @duthCoins WHERE id = @id")
vRP._prepare("vRP/GiveCoins","UPDATE users SET duthCoins = duthCoins + @duthCoins WHERE id = @id")

-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCORD SYNC
-----------------------------------------------------------------------------------------------------------------------------------------
vRP._prepare("vRP/UpdateDiscord","UPDATE users SET discord = @discord WHERE id = @id")
vRP._prepare("vRP/RemoveItem","DELETE FROM inventory WHERE user_id = @user_id AND inventory_itemName = @inventory_itemName")
-----------------------------------------------------------------------------------------------------------------------------------------
-- PASSE DE BATALHA
-----------------------------------------------------------------------------------------------------------------------------------------
vRP._prepare("vRP/updateLevelPasse","UPDATE users SET duthBattleLevel = @duthBattleLevel WHERE id = @id")
vRP._prepare("vRP/updateXpPasse","UPDATE users SET duthBattleXp = @duthBattleXp WHERE id = @id")
vRP._prepare("vRP/updatePasse","UPDATE users SET duthBattlePass = @duthBattlePass WHERE id = @id")
vRP._prepare("vRP/updateDuthPoints","UPDATE users SET duthPoints = @duthPoints WHERE id = @id")
vRP._prepare('vRP/set_whitelisted', "UPDATE users SET whitelisted = @whitelisted WHERE id = @user_id")
-----------------------------------------------------------------------------------------------------------------------------------------
-- TEAMS
-----------------------------------------------------------------------------------------------------------------------------------------
vRP._prepare("vRP/GetTeams","SELECT * FROM teams")
vRP._prepare("vRP/UpdateTeam","UPDATE teams SET roleItems = @roleItems WHERE roleId = @roleId")
vRP._prepare("vRP/AddTeam","INSERT INTO teams(roleId,roleNameTag) VALUES(@roleId,@roleNameTag)")
