local progress = assetify.class:create("progress", false, "ov_widget")
progress.private.svg = {}
progress.private.svg.horizontal = [[
    <svg viewBox = "0 0 ]]..ov_widget.resolution[1].." "..ov_widget.resolution[2]..[[">
        <rect
            x="0px"
            y="0px"
            width="0px"
            height="0px"
            fill="#ffffff"
            stroke="#ffffff"
            stroke-width="0px"
            stroke-dasharray="0px"
            rx="0px"
            ry="0px"
        />
        <rect
            x="0px"
            y="0px"
            width="0px"
            height="0px"
            fill="#ffffff"
            stroke="#ffffff"
            stroke-width="0px"
            stroke-dasharray="0px"
            rx="0px"
            ry="0px"
        />
    </svg>
]]
progress.private.svg.vertical = progress.private.svg.horizontal
progress.private.svg.circle = [[
    <svg viewBox = "0 0 ]]..ov_widget.resolution[1].." "..ov_widget.resolution[2]..[[">
        <circle 
            r="0px"
            cx="0px"
            cy="0px"
            fill="none"
            stroke="#ffffff"
            stroke-width="0px"
        />
        <circle
            r="0px"
            cx="0px"
            cy="0px"
            fill="none"
            stroke="#ffffff"
            stroke-width="0px"
            stroke-linecap="round"
            stroke-dasharray="0px"
            stroke-dashoffset="0px"
        />
    </svg>
]]

function progress.public.draw(ctx, parent)
    local id = ov_widget.resource..":progress:"..ctx.id
    local public = ov_widget.store.fetch(id, "public")
    local private = ov_widget.store.fetch(id, "private")
    private.ctx = ctx
    private.parent = parent
    private.type = private.type or (ctx.type and progress.private.svg[ctx.type] and ctx.type) or "horizontal"
    if not private.parent then
        if private.type == "circle" then
            private.state.mode["hover"] = (assetify.interface.isCursorAtPosition(ov_widget.store.value(id, "x"), ov_widget.store.value(id, "y"), ov_widget.store.value(id, "radius")*2, ov_widget.store.value(id, "radius")*2) and true) or nil
        else
            private.state.mode["hover"] = (assetify.interface.isCursorAtPosition(ov_widget.store.value(id, "x"), ov_widget.store.value(id, "y"), ov_widget.store.value(id, "width"), ov_widget.store.value(id, "height")) and true) or nil
        end
    end
    ov_widget.store.update(id)
    if ov_widget.store.animate(id) or ov_widget.store.animate(private.parent, true) then
        private.svg = private.svg or svgCreate(ov_widget.resolution[1], ov_widget.resolution[2], progress.private.svg[private.type])
        if not private.document then
            private.document = private.document or {}
            private.document.root = svgGetDocumentXML(private.svg)
            private.document.node = svgGetDocumentNodes(private.document.root)
        end
        local progress = math.max(0, math.min(1, ov_widget.store.value(id, "progress")))
        local node = ((private.type == "circle") and private.document.node.circle) or private.document.node.rect
        for i = 1, 2, 1 do
            xmlNodeSetAttribute(node[i], "x", ov_widget.store.value(id, "x").."px")
            xmlNodeSetAttribute(node[i], "y", ov_widget.store.value(id, "y").."px")
            xmlNodeSetAttribute(node[i], "width", ov_widget.store.value(id, "width").."px")
            xmlNodeSetAttribute(node[i], "height", ov_widget.store.value(id, "height").."px")
            xmlNodeSetAttribute(node[i], "fill", stringn.format("#%.2X%.2X%.2X", table.unpack(ov_widget.store.value(id, ((i == 1) and "background_color") or "foreground_color"))))
            xmlNodeSetAttribute(node[i], "stroke", stringn.format("#%.2X%.2X%.2X", table.unpack(ov_widget.store.value(id, "border_color"))))
            xmlNodeSetAttribute(node[i], "stroke-width", ov_widget.store.value(id, "border_width").."px")
            xmlNodeSetAttribute(node[i], "stroke-dasharray", ov_widget.store.value(id, "border_dash").."px")
            xmlNodeSetAttribute(node[i], "rx", ov_widget.store.value(id, "border_radius").."px")
            xmlNodeSetAttribute(node[i], "ry", ov_widget.store.value(id, "border_radius").."px")
        end
        if private.type == "horizontal" then
            xmlNodeSetAttribute(node[2], "width", (ov_widget.store.value(id, "width")*progress).."px")
        elseif private.type == "vertical" then
            xmlNodeSetAttribute(node[2], "height", (ov_widget.store.value(id, "height")*progress).."px")
            xmlNodeSetAttribute(node[2], "y", (ov_widget.store.value(id, "y") + (ov_widget.store.value(id, "height")*(1 - progress))).."px")
        elseif private.type == "circle" then
            for i = 1, 2, 1 do
                xmlNodeSetAttribute(node[i], "r", ov_widget.store.value(id, "radius"))
                xmlNodeSetAttribute(node[i], "cx", (ov_widget.store.value(id, "x") + ov_widget.store.value(id, "radius")).."px")
                xmlNodeSetAttribute(node[i], "cy", (ov_widget.store.value(id, "y") + ov_widget.store.value(id, "radius")).."px")
                xmlNodeSetAttribute(node[i], "fill", "none")
                xmlNodeSetAttribute(node[i], "stroke", stringn.format("#%.2X%.2X%.2X", table.unpack(ov_widget.store.value(id, ((i == 1) and "background_color") or "foreground_color"))))
                if i == 2 then
                    local circumference = 2*3.14*ov_widget.store.value(id, "radius")
                    xmlNodeSetAttribute(node[i], "stroke-dasharray", circumference.."px")
                    xmlNodeSetAttribute(node[i], "stroke-dashoffset", (circumference*(1 - progress)).."px")
                end
            end
        end
        svgSetDocumentXML(private.svg, private.document.root)
    end
    dxDrawImage(0, 0, ov_widget.resolution[1], ov_widget.resolution[2], private.svg)
end