----------------------------------------------------------------
--[[ Resource: Cinemify Library
     Script: utilities: camera.lua
     Author: vStudio
     Developer: -
     DOC: 13/10/2019
     Desc: Camera Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    setmetatable = setmetatable
}


-----------------------
--[[ Class: Camera ]]--
-----------------------

camera = {}
camera.__index = camera

function camera:create(...)
    local cCamera = imports.setmetatable({}, {__index = self})
    if not cCamera:load(...) then
        cCamera = nil
        return false
    end
    return cCamera
end

function camera:destroy(...)
    if not self or (self == camera) then return false end
    return self:unload(...)
end

function camera:load()
    if not self or (self == camera) then return false end
    self.element = element
    self.parent = parent
    imports.setElementCollisionsEnabled(element, false)
    return true
end

function camera:unload()
    if not self or (self == camera) then return false end
    if self.cStreamer then
        self.cStreamer:destroy()
    end
    camera.cache.element[(self.element)] = nil
    camera.buffer.element[(self.element)] = nil
    self = nil
    return true
end

function camera:refresh(cameraData)
    if not self or (self == camera) then return false end
    local parentType = imports.getElementType(self.parent)
    parentType = (parentType == "player" and "ped") or parentType
    if not parentType or not camera.ids[parentType] then return false end
    cameraData.id = imports.tonumber(cameraData.id)
    if not cameraData.id or not camera.ids[parentType][(cameraData.id)] or not cameraData.position or not cameraData.rotation then return false end
    cameraData.position.x, cameraData.position.y, cameraData.position.z = imports.tonumber(cameraData.position.x) or 0, imports.tonumber(cameraData.position.y) or 0, imports.tonumber(cameraData.position.z) or 0
    cameraData.rotation.x, cameraData.rotation.y, cameraData.rotation.z = imports.tonumber(cameraData.position.x) or 0, imports.tonumber(cameraData.position.y) or 0, imports.tonumber(cameraData.position.z) or 0
    cameraData.rotationMatrix = imports.matrix.fromRotation(cameraData.rotation.x, cameraData.rotation.y, cameraData.rotation.z)
    self.cameraData = cameraData
    return true
end

function camera:update()
    if not self or (self == camera) then return false end
    camera.cache.element[(self.parent)] = camera.cache.element[(self.parent)] or {}
    camera.cache.element[(self.parent)][(self.cameraData.id)] = ((camera.cache.element[(self.parent)].streamTick == camera.cache.streamTick) and camera.cache.element[(self.parent)][(self.cameraData.id)]) or imports.getElementcameraMatrix(self.parent, self.cameraData.id)
    camera.cache.element[(self.parent)].streamTick = camera.cache.streamTick
    imports.setElementMatrix(self.element, imports.matrix.transform(camera.cache.element[(self.parent)][(self.cameraData.id)], self.cameraData.rotationMatrix, self.cameraData.position.x, self.cameraData.position.y, self.cameraData.position.z))
end
