loadstring(exports.assetify_library:import("*"))()
assetify.namespace:create("ov_widget")
ov_widget.resource = getResourceName(getThisResource())
ov_widget.resolution = {guiGetScreenSize()}

addEventHandler("onClientPreRender", root, function()
    ov_widget.tick = getTickCount()
end)

function svgGetDocumentNodes(root, result)
    result = result or {}
    local children = xmlNodeGetChildren(root)
    for i = 1, #children, 1 do
        local j = children[i]
        local name = xmlNodeGetName(j)
        result[name] = result[name] or {}
        table.insert(result[name], j)
        svgGetDocumentNodes(j, result)
    end
    return result
end

local color_cache = {}
function RGBToHex(r, g, b, a) return string.format((a and "#%.2X%.2X%.2X%.2X") or "#%.2X%.2X%.2X", r, g, b, a) end
function RGBToColor(color)
    local ref = (color[1] or 255)..(color[2] or 255)..(color[3] or 255)..(color[4] or 255)
    color_cache[ref] = color_cache[ref] or tocolor(color[1], color[2], color[3], color[4])
    return color_cache[ref]
end