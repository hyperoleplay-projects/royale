local function route(command, child)
    return table.concat({
        '/commands/temporary?prefix='..command,
        child,
        ''
    }, '%20')
end

if type(ENV.vip_command) == 'string' then
    RegisterCommand(ENV.vip_command, function(source)
        local player_id = Proxy.getId(source)

        if not player_id then
            return
        end

        local namespace = { 'group', 'house', 'vehicle' }
        local requests = Citizen.Await(promise.all({
            Hydrus('async:GET', route('ungroup', player_id)),
            Hydrus('async:GET', route('delhouse', player_id)),
            Hydrus('async:GET', route('delvehicle', player_id)),
        }))

        for key, request in ipairs(requests) do
            if request[1] == 200 then
                for it in each(request[2]) do
                    local date = os.date('%d/%m/%Y %H:%M:%S', it.execute_at_unix)
                    emitNet('chat:addMessage', source, {
                        template = string.format([[<div style="%s">%s</div>]], 
                            table.concat(ENV.vip_styles or ENV.chat_styles or {}, ';'), _('vip.template.'..namespace[key])
                        ),
                        args = { it.command:split(' ')[3], date }
                    })
                end
            end
        end
    end)
end