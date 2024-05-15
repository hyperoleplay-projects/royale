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
vRP._prepare("vRP/getPlayers","SELECT * FROM users")

vRP.prepare('vRP/updateInventory','UPDATE inventory SET inventory_itemStatus = @inventory_itemStatus WHERE inventory_id = @inventory_id AND user_id = @user_id')
vRP.prepare('vRP/updateSkin','UPDATE inventory SET inventory_itemStatus = @inventory_itemStatus WHERE inventory_id = @inventory_id')
vRP._prepare("vRP/removeCoins","UPDATE users SET duthCoins = duthCoins - @duthCoins WHERE id = @id")
vRP._prepare("vRP/removePoints","UPDATE users SET duthPoints = duthPoints - @duthPoints WHERE id = @id")
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
-- GUILDS
-----------------------------------------------------------------------------------------------------------------------------------------
vRP._prepare("vRP/AddGuild","INSERT INTO guilds (tag, name, image_url) VALUES (@tag, @name, @imageURL);")
vRP._prepare("vRP/UpdateGuildTag","UPDATE guilds SET `tag` = @newTag WHERE tag = @oldTag;")
vRP._prepare("vRP/UpdateGuildName","UPDATE guilds SET `name` = @name WHERE tag = @tag;")
vRP._prepare("vRP/UpdateGuildImage","UPDATE guilds SET `image_url` = @imageURL WHERE tag = @tag;")
vRP._prepare("vRP/RemoveGuild","DELETE FROM guilds WHERE tag = @tag;")
vRP._prepare("vRP/GetGuilds","SELECT tag, name, image_url as imageURL FROM guilds;")
vRP._prepare("vRP/AddGuildMember","INSERT INTO guild_members (guild_tag, user_id, role) VALUES (@tag, @userId, @role);")
vRP._prepare("vRP/UpdateGuildMember","UPDATE guild_members SET `role` = @role WHERE `user_id` = @userId AND `guild_tag` = @tag;")
vRP._prepare("vRP/GetGuildMembers","SELECT user_id as userId, role FROM guild_members WHERE `guild_tag` = @tag;")
vRP._prepare("vRP/RemoveGuildMember","DELETE FROM guild_members WHERE `user_id` = @userId AND `guild_tag` = @tag;")