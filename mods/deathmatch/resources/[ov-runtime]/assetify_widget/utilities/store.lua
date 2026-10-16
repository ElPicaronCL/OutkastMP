local store = assetify.class:create("store", false, "ov_widget")

function store.public.valid(id)
    return (store.private[id] and store.private[id].private and store.private[id].private.ctx and true) or false
end

function store.public.fetch(id, type)
    store.private[id] = store.private[id] or {}
    if type then
        store.private[id][type] = store.private[id][type] or {}
        if (type == "private") and not store.private[id][type].ready then
            store.private[id][type].ready = 1
            store.private[id][type].state = {count = 0, mode = {}}
            store.private[id][type].transition = {}
        end
        return store.private[id][type]
    end
    return store.private[id]
end

function store.public.flush(id)
    store.private[id] = nil
    return true
end

function store.public.match(value, match)
    if not value or not match or (type(value) ~= type(match)) then return false end
    if type(value) == "table" then
        for i = 1, #match, 1 do
            local j = match[i]
            if type(j) == "table" then
                return store.public.match(value[i], j)
            elseif value[i] ~= j then
                return false
            end
        end
        return true
    end
    return value == match
end

function store.public.state(mode, state)
    if not mode then return false end
    return mode[state]
end

function store.public.value(id, property)
    if not store.public.valid(id) then return false end
    local public = store.public.fetch(id, "public")
    local private = store.public.fetch(id, "private")
    if store.public.valid(private.parent) then return store.public.value(private.parent, property) end
    return (
        (private.ctx.transition and private.ctx.transition[property] and private.transition[property] and private.transition[property].value) or
        ov_widget.property.value(property, public[property]) or
        ov_widget.property.value(property, private.ctx[property], true)
    )
end

function store.public.update(id)
    if not store.public.valid(id) then return false end
    local public = store.public.fetch(id, "public")
    local private = store.public.fetch(id, "private")
    if not store.public.valid(private.parent) then
        private.state.count = 0
        for i, j in pairs(private.state.mode) do
            private.state.count = private.state.count + 1
        end
        local updated = private.state.precount ~= private.state.count
        if updated then
            for i, j in pairs(public) do
                public[i] = private.ctx[i]
            end
        end
        private.state.precount = private.state.count
    end
    return updated
end

function store.public.animate(id, fetch)
    if not store.public.valid(id) then return false end
    local public = store.public.fetch(id, "public")
    local private = store.public.fetch(id, "private")
    if fetch then return private.animated or false end
    private.animated = private.ready ~= -1
    private.ready = -1
    if not store.public.valid(private.parent) and private.ctx.transition then
        for i, j in pairs(private.ctx.transition) do
            local next_syntax = ov_widget.property.syntax(i)
            if next_syntax then
                private.transition[i] = private.transition[i] or {}
                local next_value = ov_widget.property.value(i, public[i]) or ov_widget.property.value(i, private.ctx[i], true)
                if not store.public.match(private.transition[i].next, next_value) then
                    private.transition[i].tick = ov_widget.tick
                    private.transition[i].current = private.transition[i].value or store.public.value(id, i)
                    private.transition[i].current = ((next_syntax.type == "table") and table.clone(private.transition[i].current)) or private.transition[i].current
                    private.transition[i].next = next_value
                end
                private.transition[i].progress = (ov_widget.tick - private.transition[i].tick)/j.duration
                if private.transition[i].progress <= 1 then
                    private.animated = true
                    if next_syntax.type == "table" then
                        private.transition[i].value = private.transition[i].value or {}
                        private.transition[i].value[1], private.transition[i].value[2], private.transition[i].value[3] = interpolateBetween(private.transition[i].current[1], private.transition[i].current[2], private.transition[i].current[3], private.transition[i].next[1], private.transition[i].next[2], private.transition[i].next[3], private.transition[i].progress, j.easing)
                    else
                        private.transition[i].value = interpolateBetween(private.transition[i].current, 0, 0, next_value, 0, 0, private.transition[i].progress, j.easing)
                    end
                end
            end
        end
        if private.state.mode["hover"] and private.ctx.on_hover then private.ctx.on_hover(public) end
    end
    return private.animated
end