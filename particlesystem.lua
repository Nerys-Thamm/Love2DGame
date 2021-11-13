--// Bachelor of Software Engineering
--// Media Design School
--// Auckland
--// New Zealand
--// 
--// (c) 2021 Media Design School
--//
--// File Name   : particlesystem.lua
--// Description : Contains functions related to particlesystems  
--// Author      : Nerys Thamm
--// Mail        : nerys.thamm@mds.ac.nz 

ParticleSystem = {}
ParticleSystem.__index = ParticleSystem

function ParticleSystem.new(x, y, options)
  local self = setmetatable({}, ParticleSystem)
  
  self.x = x
  self.y = y
  self.image = options.image
  
  self.ps = love.graphics.newParticleSystem(self.image, options.maxParticles or 200)
  self.ps:setParticleLifetime(options.lifetime or 1)
  self.ps:setEmissionRate(options.emissionRate or 1)
  self.ps:setEmissionArea("uniform", options.emissionArea.x or 1, options.emissionArea.y or 1)
  self.ps:setSizeVariation(options.sizeVariation or 1)
  self.ps:setSizes(options.sizeOverLifetime.start or 1, options.sizeOverLifetime.finish or 1)
  self.ps:setLinearAcceleration(options.linearAcceleration.xMin or 0, options.linearAcceleration.yMin or 0, 
                                options.linearAcceleration.xMax or 0, options.linearAcceleration.yMax or 0)
  self.ps:setColors(options.startColor or {1, 1, 1, 1}, options.endColor or {1, 1, 1, 1})


  
  return self
end

function ParticleSystem:update(dt)
  self.ps:update(dt)
end

function ParticleSystem:move(x, y)
  self.x = x
  self.y = y
end

function ParticleSystem:moveTo(x, y)
  self.ps:moveTo(x, y)
end

function ParticleSystem:play()
  self.ps:play()
end

function ParticleSystem:stop()
  self.ps:stop()
end

function ParticleSystem:draw()
  love.graphics.draw(self.ps, self.x, self.y, 0, 1, 1)
end





  
  

