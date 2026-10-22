OV_WG_LIVE = OV_WG_LIVE or {}
OV_WG_LIVE.tv = {}

-- IPTV/EPG metadata only (no streams)
function OV_WG_LIVE.tv.getEPG(callback)
    -- Use cached/local data for now, no keys
    if callback then callback({}, nil) end
end
