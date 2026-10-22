OV_WG_LIVE = OV_WG_LIVE or {}
OV_WG_LIVE.tv = {}

-- IPTV/EPG metadata only. No streams are fetched and no keys are required.
local epg = {}

function OV_WG_LIVE.tv.getEPG(callback)
    if callback then
        callback(epg, nil)
    end
end

function OV_WG_LIVE.tv.setEPG(channels)
    if type(channels) ~= "table" then
        return false
    end
    epg = channels
    return true
end
