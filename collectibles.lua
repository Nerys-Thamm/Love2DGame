--// Bachelor of Software Engineering
--// Media Design School
--// Auckland
--// New Zealand
--// 
--// (c) 2021 Media Design School
--//
--// File Name   : 
--// Description : 
--// Author      : Nerys Thamm
--// Mail        : nerys.thamm@mds.ac.nz 

Collectible = {}
Collectible.__index = Collectible

---Builds a Collectible Item
---@param x number @The x position of the Collectible
---@param y number @The y position of the Collectible
---@param w number @The width of the Collectible
---@param h number @The height of the Collectible
---@param image any @The image of the Collectible
---@param name string @The name of the Collectible
---@param value number @The value of the Collectible
---@param world any @The world the Collectible is in
function Collectible.build(x, y, w, h, image, name, value, world)
    local self = setmetatable({}, Collectible)
    --Setting up the Collectible
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.image = image
    self.name = name
    self.value = value

    --Setting up the physics
    self.physics = {}
    self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(false)
    self.physics.shape = love.physics.newRectangleShape(self.image:getWidth() * self.w, self.image:getHeight() * self.h)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setMass(1)

    --Setting up the Sounds
    self.breakSFX = love.audio.newSource("assets/audio/cave_glass.wav", "static")
    self.breakSFX:setVolume(0.03)
    return self
end

--- Draws the Collectible
function Collectible:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.image, self.physics.body:getX(), self.physics.body:getY(), self.physics.body:getAngle(), self.w, self.h, self.image:getWidth()/2, self.image:getHeight()/2)
end

--- Checks collision with the player
---@param player any @The player to check collision with
---@param a any @The first object to check collision with
---@param b any @The second object to check collision with
function Collectible:checkCollision(player, a, b)
    if a == player then
        if b == self.physics.fixture then
            return true
        end
    elseif b == player then
        if a == self.physics.fixture then
            return true
        end
    end
    return false
end

--- Destroy the Physics of the Collectible and play a sound
function Collectible:destroy()
    self.physics.fixture:destroy()
    self.physics.body:destroy()
    self.breakSFX:play()
end

--- Updates the Collectible
---@param dt any @The time since the last update
function Collectible:update(dt)
    self.x = self.physics.body:getX()
    self.y = self.physics.body:getY()
end
    



