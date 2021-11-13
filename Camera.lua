--// Bachelor of Software Engineering
--// Media Design School
--// Auckland
--// New Zealand
--// 
--// (c) 2021 Media Design School
--//
--// File Name   : Camera.lua
--// Description : Camera implementation
--// Author      : Nerys Thamm
--// Mail        : nerys.thamm@mds.ac.nz 

local Camera = {}
Camera.__index = Camera

--Constructor
local function construct()
    local self = setmetatable({x = 0, y = 0, scaleX = 0.5, scaleY = 0.5, rotation = 0, layers={}}, Camera)
    return self
end

setmetatable(Camera, {__call = construct})

--Applies Camera's transformation to the Love2D graphics system
function Camera:set()
    love.graphics.push()
    love.graphics.rotate(-self.rotation)
    love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
    love.graphics.translate(-self.x, -self.y)
end

--Resets the transformation applied by Camera
function Camera:unset()
    love.graphics.pop()
end

--Draws the camera's view
function Camera:draw(mode)
    local bx, by = self.x, self.y
    for _, v in ipairs(self.layers) do
        if (mode == "noFG" and not v.foreground) or (mode == "FGonly" and v.foreground) or mode == nil then
        --Apply parallax scaling
        self.x = bx * v.scale
        self.y = by * v.scale
        --Apply camera transformation
        self:set()
        love.graphics.setColor(1,1,1,1)
        --Draw the layer
        v.draw()
        --Reset the transformation
        self:unset()
        end
    end
    self.x, self.y = bx, by
end

--Translates the camera
function Camera:setPosition(x, y) --x and y are the coordinates of the camera
    self.x = x or self.x
    self.y = y or self.y
end

--Creates a new layer
function Camera:newLayer(order, scale, func, fg) -- order: the order of the layer, scale: the parallax scalar, func: the function to draw the layer
    local newLayer = {draw = func, scale = scale, order = order, foreground = fg or false}
    table.insert(self.layers, newLayer)
    table.sort(self.layers, function(a, b) return a.order < b.order end) --Sort the layers by order
    return newLayer
end




return Camera