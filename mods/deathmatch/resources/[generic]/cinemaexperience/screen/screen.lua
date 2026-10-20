local txd = engineLoadTXD("screen/screen.txd")
local loaded = 0

local models = {
	{filename = "screen", id = "3944"},
	{filename = "screen_curved", id = "3942"},
}

for i=1,#models do
	local v = models[i]
	engineImportTXD(txd,v.id)
	
	local dff = engineLoadDFF("screen/models/"..v.filename..".dff")
	local dff_success = engineReplaceModel(dff,v.id)
	
	local col = engineLoadCOL("screen/models/"..v.filename..".col")
	local col_success = engineReplaceCOL(col,v.id)
	
	if dff_success and col_success then
		loaded = loaded + 1
	end
end