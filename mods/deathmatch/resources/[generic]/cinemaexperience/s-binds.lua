-- Scripted by G&T Mapping & Loki

local PanelKey = "F2"

function bindKeys()
    for _,player in pairs(getElementsByType("player")) do
        bindKey(player,PanelKey,"up",togglePanel)
    end
    addEventHandler("onPlayerJoin",root,function()
        bindKey(source,PanelKey,"up",togglePanel)
    end)
end
addEventHandler("onResourceStart",resourceRoot,bindKeys)