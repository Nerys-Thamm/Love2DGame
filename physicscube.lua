--// Bachelor of Software Engineering
--// Media Design School
--// Auckland
--// New Zealand
--// 
--// (c) 2021 Media Design School
--//
--// File Name   : physicscube.lua
--// Description : Physics Enabled Puzzle Cube
--// Author      : Nerys Thamm
--// Mail        : nerys.thamm@mds.ac.nz 

PhysicsCube = {}
PhysicsCube.__index = PhysicsCube

--- Creates a new PhysicsCube
---@param x any @ The x position of the PhysicsCube
---@param y any @ The y position of the PhysicsCube
---@param w any @ The width of the PhysicsCube
---@param h any @ The height of the PhysicsCube
---@param image any @ The image of the PhysicsCube
---@param world any @ The Box2D world
function PhysicsCube.new(x, y, w, h, image, world)
    local self = setmetatable({}, PhysicsCube)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.image = image

    --Setup Physics
    self.physics = {}
    self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.image:getWidth() * self.w, self.image:getHeight() * self.h)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setMass(4)
    return self
end

--- Draws the physics cube
function PhysicsCube:draw()
    love.graphics.draw(self.image, self.physics.body:getX(), self.physics.body:getY(), self.physics.body:getAngle(), self.w, self.h, self.image:getWidth()/2, self.image:getHeight()/2)
end