OV_WG = OV_WG or {}
OV_WG.http = {}

--
-- Thin, rate-limited wrapper around fetchRemote.
--
-- The options-table form is used deliberately:
--     fetchRemote(url, options, callback)
--     callback(responseData, responseInfo)   -- responseInfo.success/statusCode
--
-- options accepts: method, postData, postIsBinary, headers, formFields,
-- connectionAttempts, connectTimeout, queueName, maxRedirects, username,
-- password. Internal keys (retries, timeout) are stripped before dispatch.
--

local pending = {}
local inFlight = 0
local nextDispatch = 0
local pumpTimer = nil

local function cfg()
    return OV_WG.config.http
end

local function buildOptions(req)
    local opts = req.options or {}
    return {
        queueName = opts.queueName or "worldgen",
        connectionAttempts = opts.connectionAttempts or 2,
        connectTimeout = opts.connectTimeout or cfg().defaultTimeout,
        method = opts.method or "GET",
        maxRedirects = opts.maxRedirects,
        headers = opts.headers,
        postData = opts.postData,
        postIsBinary = opts.postIsBinary,
        formFields = opts.formFields,
    }
end

local function schedulePump(delay)
    if pumpTimer then
        return
    end
    pumpTimer = setTimer(function()
        pumpTimer = nil
        OV_WG.http.pump()
    end, delay, 1)
end

local function dispatch(req)
    inFlight = inFlight + 1
    nextDispatch = getTickCount() + cfg().minInterval

    local finished = false

    local function complete(data, errInfo, statusCode)
        if finished then
            return
        end
        finished = true
        inFlight = inFlight - 1

        if data then
            if req.callback then
                req.callback(data, nil, statusCode)
            end
        elseif req.attempts < req.retries then
            -- Back off and re-queue at the front.
            table.insert(pending, 1, req)
            schedulePump(2000)
        else
            OV_WG.log(("HTTP failed after %d attempt(s) (%s): %s"):format(
                req.attempts, tostring(errInfo), req.url), 2)
            if req.callback then
                req.callback(nil, errInfo or statusCode or "request-failed")
            end
        end

        OV_WG.http.pump()
    end

    local ok, err = pcall(fetchRemote, req.url, buildOptions(req), function(responseData, responseInfo)
        local statusCode = responseInfo and responseInfo.statusCode
        local success = responseInfo and responseInfo.success
        if success and responseData then
            complete(responseData, nil, statusCode)
        else
            complete(nil, statusCode, statusCode)
        end
    end)

    if not ok then
        complete(nil, tostring(err))
    end
end

function OV_WG.http.pump()
    if inFlight >= cfg().maxConcurrent then
        return
    end
    if #pending == 0 then
        return
    end

    local now = getTickCount()
    if now < nextDispatch then
        schedulePump(nextDispatch - now)
        return
    end

    local req = table.remove(pending, 1)
    req.attempts = (req.attempts or 0) + 1
    dispatch(req)
end

function OV_WG.http.fetch(url, callback, options)
    options = options or {}
    pending[#pending + 1] = {
        url = url,
        callback = callback,
        options = options,
        retries = options.retries or cfg().defaultRetries,
        attempts = 0,
    }
    OV_WG.http.pump()
end

-- Raw text response.
function OV_WG.http.get(url, callback, options)
    options = options or {}
    options.method = "GET"
    OV_WG.http.fetch(url, callback, options)
end

function OV_WG.http.getJson(url, callback, options)
    options = options or {}
    options.method = "GET"
    options.headers = options.headers or { Accept = "application/json" }

    OV_WG.http.fetch(url, function(data, err, status)
        if not data then
            callback(nil, err)
            return
        end
        local decoded = fromJSON(data)
        if not decoded then
            callback(nil, "invalid-json")
            return
        end
        callback(decoded, nil, status)
    end, options)
end

function OV_WG.http.postJson(url, payload, callback, options)
    options = options or {}
    options.method = "POST"
    options.postData = toJSON(payload)
    options.headers = options.headers or {}
    options.headers["Content-Type"] = "application/json"

    OV_WG.http.fetch(url, function(data, err, status)
        if not data then
            callback(nil, err)
            return
        end
        local decoded = fromJSON(data)
        if not decoded then
            callback(nil, "invalid-json")
            return
        end
        callback(decoded, nil, status)
    end, options)
end

function OV_WG.http.stats()
    return {
        pending = #pending,
        inFlight = inFlight,
    }
end
