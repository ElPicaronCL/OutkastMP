OV_WG = OV_WG or {}
OV_WG.http = {}

local queue = {}
local processing = false
local lastRequest = 0
local minInterval = 1000 -- ms between requests

function OV_WG.http.fetch(url, callback, options)
    options = options or {}
    table.insert(queue, {
        url = url,
        callback = callback,
        options = options,
        retries = options.retries or 3,
        attempts = 0
    })
    if not processing then
        OV_WG.http.processQueue()
    end
end

function OV_WG.http.processQueue()
    if #queue == 0 then
        processing = false
        return
    end
    processing = true
    
    local now = getTickCount()
    if now - lastRequest < minInterval then
        setTimer(OV_WG.http.processQueue, minInterval - (now - lastRequest), 1)
        return
    end
    
    local req = table.remove(queue, 1)
    req.attempts = req.attempts + 1
    lastRequest = getTickCount()
    
    fetchRemote(req.url, function(responseData, errno)
        if errno == 0 and responseData then
            if req.callback then
                req.callback(responseData, nil)
            end
        else
            if req.attempts < req.retries then
                table.insert(queue, 1, req)
                setTimer(OV_WG.http.processQueue, 2000, 1)
            else
                if req.callback then
                    req.callback(nil, errno)
                end
                OV_WG.http.processQueue()
            end
            return
        end
        OV_WG.http.processQueue()
    end)
end
