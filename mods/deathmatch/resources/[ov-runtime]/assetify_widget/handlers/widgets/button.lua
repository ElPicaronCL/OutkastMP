local button = assetify.class:create("button", false, "ov_widget")

function button.public.draw(ctx, parent)
    local id = ov_widget.resource..":button:"..ctx.id
    local public = ov_widget.store.fetch(id, "public")
    local private = ov_widget.store.fetch(id, "private")
    private.ctx = ctx
    private.parent = parent
    if not private.parent then
        private.state.mode["hover"] = (assetify.interface.isCursorAtPosition(ov_widget.store.value(id, "x"), ov_widget.store.value(id, "y"), ov_widget.store.value(id, "width"), ov_widget.store.value(id, "height")) and true) or nil
    end
    ov_widget.store.update(id)
    if ov_widget.store.animate(id) or ov_widget.store.animate(private.parent, true) then end
    ov_widget.box.draw(ctx, id)
    if ctx.text then
        ov_widget.text.draw(ctx, id)
    end
end