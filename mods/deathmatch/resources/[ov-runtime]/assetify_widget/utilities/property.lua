local property = assetify.class:create("property", false, "ov_widget")
property.private = {
    ["text"] = {type = "string", default = ""},
    ["x"] = {type = "number", default = 0},
    ["y"] = {type = "number", default = 0},
    ["width"] = {type = "number", default = 0},
    ["height"] = {type = "number", default = 0},
    ["radius"] = {type = "number", default = 0},
    ["progress"] = {type = "number", default = 0},
    ["text_align_x"] = {type = "string", default = "center"},
    ["text_align_y"] = {type = "string", default = "center"},
    ["color"] = {type = "table", length = 3, default = {255, 255, 255}},
    ["font_family"] = {type = "userdata", default = "default-bold"}, --TODO: ADD STRING AND USERDATA SUPPORT BOTH
    ["font_scale"] = {type = "number", default = 1},
    ["background_color"] = {type = "table", length = 3, default = {255, 255, 255}},
    ["foreground_color"] = {type = "table", length = 3, default = {255, 255, 255}},
    ["border_radius"] = {type = "number", default = 0},
    ["border_width"] = {type = "number", default = 0},
    ["border_dash"] = {type = "number", default = 0},
    ["border_color"] = {type = "table", length = 3, default = {255, 255, 255}}
}

function property.public.syntax(name)
    return (name and property.private[name]) or false
end

function property.public.valid(name, value)
    local syntax = property.public.syntax(name)
    if not syntax or not value or (syntax.type ~= type(value)) then return false end
    if (syntax.type == "table") and (syntax.length ~= #value) then return false end
    return true
end

function property.public.value(name, value, default)
    local syntax = property.public.syntax(name)
    if not syntax then return false end
    return (property.public.valid(name, value) and value) or (default and syntax.default) or false
end