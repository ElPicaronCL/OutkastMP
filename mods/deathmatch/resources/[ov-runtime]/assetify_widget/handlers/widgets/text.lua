local text = assetify.class:create("text", false, "ov_widget")

function text.public.draw(ctx, parent)
    local id = ov_widget.resource..":text:"..ctx.id
    local public = ov_widget.store.fetch(id, "public")
    local private = ov_widget.store.fetch(id, "private")
    private.ctx = ctx
    private.parent = parent
    if not private.parent then
        private.state.mode["hover"] = (assetify.interface.isCursorAtPosition(ov_widget.store.value(id, "x"), ov_widget.store.value(id, "y"), ov_widget.store.value(id, "width"), ov_widget.store.value(id, "height")) and true) or nil
    end
    ov_widget.store.update(id)
    if ov_widget.store.animate(id) or ov_widget.store.animate(private.parent, true) then end
    dxDrawText(ctx.text, ov_widget.store.value(id, "x"), ov_widget.store.value(id, "y"), ov_widget.store.value(id, "x") + ov_widget.store.value(id, "width"), ov_widget.store.value(id, "y") + ov_widget.store.value(id, "height"), RGBToColor(ov_widget.store.value(id, "color")), ov_widget.store.value(id, "font_scale"), ov_widget.store.value(id, "font_family"), ov_widget.store.value(id, "text_align_x"), ov_widget.store.value(id, "text_align_y"))
end