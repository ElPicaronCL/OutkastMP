-- Scripted by G&T Mapping & Loki

-------------
--   API   --
-------------

local apiKey = "AIzaSyB8rvi8vEoqILowjiq_D3QkaQzL6q9xqBA" -- In case of problems, create your own YouTube API key (https://console.developers.google.com/apis)

function fetchVideoData(id, callback)
    if not hasObjectPermissionTo(getThisResource(), "function.fetchRemote", false) then
        return callback(nil, "This resource does not have permission to access fetchRemote!")
    end

    apiUrl = 'https://www.googleapis.com/youtube/v3/videos?id=' .. id .. '&key=' .. apiKey .. '&fields=items(snippet(title,liveBroadcastContent),contentDetails(duration,'..(useEmbeds and 'regionRestriction' or '')..'),status(embeddable))&part=snippet,contentDetails,status'

    fetchRemote(apiUrl, 2, function(responseData, err)
        if err ~= 0 then
            return callback(nil, "Failed to fetch data from API. Error code: " .. err)
        end

        local data = fromJSON(responseData)
        if not data then
            return callback(nil, "Error parsing API response.")
        end

        local videoData = data and data.items and data.items[1]
        if not videoData then
            return callback(nil, "No video info found in API response.")
        end

        local title = videoData.snippet.title
        local liveBroadcastContent = videoData.snippet.liveBroadcastContent
        local embeddable = videoData.status.embeddable
        local regionRestriction = videoData.contentDetails.regionRestriction
        local length = parseVideoDuration(videoData.contentDetails.duration)

        if liveBroadcastContent and liveBroadcastContent ~= "none" then
            return callback(nil, "Live broadcasts are not allowed.")
        end
        if not embeddable or (useEmbeds and regionRestriction) then
            return callback(nil, "Video cannot be embedded due to restrictions.")
        end

        callback({title = title, length = length, embeddable = embeddable}, nil)
    end, '', true)
end

function parseVideoDuration(duration)
    local hr = tonumber(duration:match('PT(%d+)H')) or 0
    local min = tonumber(duration:match('%dH(%d+)M')) or tonumber(duration:match('PT(%d+)M')) or 0
    local sec = tonumber(duration:match('%dM(%d+)S')) or tonumber(duration:match('%dH(%d+)S')) or tonumber(duration:match('PT(%d+)S')) or 0
    return hr * 3600 + min * 60 + sec
end