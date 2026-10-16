local box = assetify.class:create("box", false, "ov_widget")
box.private.svg = [[
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
    </svg>
]]

function box.public.draw(ctx, parent)
    local id = ov_widget.resource..":box:"..ctx.id
    local public = ov_widget.store.fetch(id, "public")
    local private = ov_widget.store.fetch(id, "private")
    private.ctx = ctx
    private.parent = parent
    if not private.parent then
        private.state.mode["hover"] = (assetify.interface.isCursorAtPosition(ov_widget.store.value(id, "x"), ov_widget.store.value(id, "y"), ov_widget.store.value(id, "width"), ov_widget.store.value(id, "height")) and true) or nil
    end
    ov_widget.store.update(id)
    if ov_widget.store.animate(id) or ov_widget.store.animate(private.parent, true) then
        private.svg = private.svg or svgCreate(ov_widget.resolution[1], ov_widget.resolution[2], box.private.svg)
        if not private.document then
            private.document = private.document or {}
            private.document.root = svgGetDocumentXML(private.svg)
            private.document.node = svgGetDocumentNodes(private.document.root)
        end
        xmlNodeSetAttribute(private.document.node.rect[1], "x", ov_widget.store.value(id, "x").."px")
        xmlNodeSetAttribute(private.document.node.rect[1], "y", ov_widget.store.value(id, "y").."px")
        xmlNodeSetAttribute(private.document.node.rect[1], "width", ov_widget.store.value(id, "width").."px")
        xmlNodeSetAttribute(private.document.node.rect[1], "height", ov_widget.store.value(id, "height").."px")
        xmlNodeSetAttribute(private.document.node.rect[1], "fill", stringn.format("#%.2X%.2X%.2X", table.unpack(ov_widget.store.value(id, "background_color"))))
        xmlNodeSetAttribute(private.document.node.rect[1], "stroke", stringn.format("#%.2X%.2X%.2X", table.unpack(ov_widget.store.value(id, "border_color"))))
        xmlNodeSetAttribute(private.document.node.rect[1], "stroke-width", ov_widget.store.value(id, "border_width").."px")
        xmlNodeSetAttribute(private.document.node.rect[1], "stroke-dasharray", ov_widget.store.value(id, "border_dash").."px")
        xmlNodeSetAttribute(private.document.node.rect[1], "rx", ov_widget.store.value(id, "border_radius").."px")
        xmlNodeSetAttribute(private.document.node.rect[1], "ry", ov_widget.store.value(id, "border_radius").."px")
        svgSetDocumentXML(private.svg, private.document.root)
    end
    dxDrawImage(0, 0, ov_widget.resolution[1], ov_widget.resolution[2], private.svg)
end