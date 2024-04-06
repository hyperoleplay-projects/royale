local function handle_command(id, raw)
    local ok, retval = pcall(function()
        local args = raw:split(' ')

        assert(#args > 0, {'Empty command'})

        -- Automatically parse every argument to number if possible
        for index, raw in ipairs(args) do
            args[index] = tonumber(raw) or raw
        end

        local fname = table.remove(args, 1)
        local func = Commands[fname]
        assert(is_callable(func), {'Commands["'..fname..'"] is not a function'})

        return func(table.unpack(args))
    end)

    if not ok and type(retval) == 'table' then
        retval = retval[1]
    end

    if type(retval) ~= 'string' then
        retval = ok and 'OK' or 'ERROR'
    else
        retval = retval:sub(0,255)
    end

    local body = {
        status = ok and 'done' or 'failed',
        message = retval,
    }

    local tries = 0
    while true do
        local status, body, err = Hydrus('PATCH', 'commands/'..id, body)
        if status == 0 then
            if tries == 0 then
                print('Failed to connect to the api endpoint, the script will try again')
            end
            tries+= 1
            Wait(1e3)
        elseif status ~= 200 and status ~= 404 then
            printf('Failed to UPDATE the command {ID=%d, STATUS=%d} the script will try again in 10 seconds', id, status)
            if status >= 500 then
                logger('Status %d -> %s', status, err)
            end
            Wait(10e3)
        else
            return body or { status = 'missing', message = 'Model not found (ignored)' }
        end
    end
end

-----------------------------------------------------
Queue = {}
Queue.pending = {}
Queue.workers = {}

function Queue:push(command)
    table.insert(self.pending, command)
end

function Queue:exists(key, val)
    for job in each(self.pending) do
        if job[key] == val then
            return job
        end
    end
    for worker in each(self.workers) do
        if worker.job and worker.job[key] == val then
            return worker.job
        end
    end
end

function Queue:next()
    return table.remove(self.pending, 1)
end

function Queue:work()
    local worker = { started_at = GetGameTimer() }
    table.insert(self.workers, worker)

    CreateThread(function()
        while true do
            local job = self:next()
            if not job then
                Wait(100)
            elseif self.is_replaced then
                break
            else
                job.created_at = GetGameTimer()
                worker.job = job

                local ok, ret = pcall(handle_command, job.id, job.command)
                if not ok then
                    print('Critical error: '..ret)
                else
                    logger('Command %d [%s] -> %s', job.id, ret.status, ret.message)
                end

                worker.job = nil
            end
        end
    end)
end

CreateThread(function()
    while true do
        for id, worker in ipairs(Queue.workers) do
            local job = worker.job
            if job then
                local elapsed = GetGameTimer() - job.created_at
                if elapsed >= 5000 and not worker.is_stuck then
                    printf('[%dms] Worker %d got stuck running "%s" (ID=%d)', elapsed, id, job.command, job.id)
                    worker.is_stuck = true
                elseif elapsed >= 60000 and not worker.is_replaced then
                    printf('A new worker has been created, since the Worker %d got stuck for %d ms', id, elapsed)
                    worker.is_replaced = true
                    Queue:work()
                end
            end
        end
        Wait(1000)
    end
end)

local workers_count = ENV.workers or 1

for i = 1, workers_count do
    Queue:work()
end