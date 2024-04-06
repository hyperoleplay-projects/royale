-----------------------------------------------------------------------------------------------------------------------------------------
-- BASE
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare('vRP/create_user', 'INSERT INTO users(whitelisted) VALUES(false)')
vRP.prepare('accounts/getInfos', 'INSERT INTO users(whitelisted) VALUES(false)')

vRP.prepare('vRP/add_identifier', 'INSERT INTO users_identifiers(identifier,user_id) VALUES(@identifier,@user_id)')
vRP.prepare('vRP/userid_byidentifier', 'SELECT user_id FROM users_identifiers WHERE identifier = @identifier')
vRP.prepare('vRP/set_userdata', 'REPLACE INTO users_data(user_id,dkey,dvalue) VALUES(@user_id,@key,@value)')
vRP.prepare('vRP/get_userdata', 'SELECT dvalue FROM users_data WHERE user_id = @user_id AND dkey = @key')
-----------------------------------------------------------------------------------------------------------------------------------------
-- IDENTITY
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare('vRP/updateIdentity','UPDATE users SET username = @username WHERE id = @id')
vRP.prepare('vRP/requestUser','SELECT * FROM users WHERE id = @id')

vRP.prepare('vRP/requestCodes','SELECT * FROM codiguins')
vRP.prepare('vRP/updateCode','UPDATE codiguins SET used = @used WHERE code = @code')
vRP.prepare('vRP/updateWhitelist','UPDATE users SET whitelisted = @whitelisted WHERE id = @id')
vRP.prepare('vRP/addBot','INSERT INTO user_listset_codiguins(id,discord) VALUES(@id,@discord)')
