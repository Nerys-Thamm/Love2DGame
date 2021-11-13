--// Bachelor of Software Engineering
--// Media Design School
--// Auckland
--// New Zealand
--// 
--// (c) 2021 Media Design School
--//
--// File Name   : player.lua
--// Description : Contains functions for the player
--// Author      : Nerys Thamm
--// Mail        : nerys.thamm@mds.ac.nz 
require("particlesystem")
Player = {}
Player.__index = Player

-- Creates a new player
function Player:load(world, playerImg)
  --Set the players location
  self.x = 300
  self.y = 100

  --Determines direction of player sprite
  self.flipscale = 1

  --Determines physics rect size
  self.width = 24
  self.height = 24

  --Player velocity (Done manually because Platformers need to feel snappy)
  self.xVel = 0
  self.yVel = 0

  --Max speed of the player
  self.maxSpeed = 120

  --Acceleration value of the player
  self.accel = 3000

  --Amount to accelerate when jumping
  self.jumpAccel = -50

  --Friction value of the player
  self.friction = 2500

  --Gravity Acceleration
  self.gravity = 1500

  --Determines if the player is on the ground
  self.grounded = false
  self.currentGroundCollisions = {}
  self.groundCollisionNumber = 0

  --Checks to make sure jump input only happens once
  self.jumpedLastFrame = false

  --Initialise the Physics of the player
  self.physics = {}
  self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic")
  self.physics.body:setFixedRotation(true)
  self.physics.body:setMass(60)
  self.physics.shape = love.physics.newRectangleShape(self.width - 12, self.height)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)

  --Set the player to be not dead
  self.dead = false

  --Initialise player animations
  self.img = playerImg
  local grid = anim8.newGrid(48,48, self.img:getWidth(), self.img:getHeight())
  self.walkAnim = anim8.newAnimation(grid(1, '5-12'), 0.12)
  self.idleAnim = anim8.newAnimation(grid(1,'1-4'), 0.12)
  self.jumpAnim = anim8.newAnimation(grid(1,'13-16'), 0.22, 'pauseAtEnd')
  self.currAnim = self.idleAnim
  
  --Initialise player audio
  self.jumpSFX = love.audio.newSource("assets/audio/JUMP_SOUND.wav", "static")
  self.jumpSFX:setVolume(0.1)
  self.landSFX = love.audio.newSource("assets/audio/JUMP_LAND_SOUND.mp3", "static")
  self.landSFX:setVolume(0.3)
  self.deathSFX = love.audio.newSource("assets/audio/DEATH_SPLASH.mp3", "static")
  self.deathSFX:setVolume(0.3)

  --Initialise player particles
  self.particles = ParticleSystem.new(0, 0,
                    {
                      image = love.graphics.newImage("assets/textures/particles/particles-0-0.png"),
                      lifetime = 2,
                      emissionRate =  40,
                      emissionArea = {
                        x = 3,
                        y = 3,
                      },
                      sizeOverLifetime = {
                        start = 0.7,
                        finish = 0,
                      },
                      sizeVariation = 0.3,
                      linearAcceleration = {xMin = -10, yMin = -10, xMax = 10, yMax = 10},
                      startColor = {1, 1, 1, 0.8},
                      endColor = {1, 1, 1, 0},
                      maxParticles = 500
                    })
end

--Updates the player
function Player:update(dt)
  if self.y > love.graphics.getHeight()/2 and not self.dead then
    Faderect = FadeRect.new(800, 600, {0,0,0}, 0.3, "inOut", 
              function()
                Gamestate = "gameover"
              end)
    self.dead = true
    self.deathSFX:play()
  end
  self:syncPhysics()
  self:move(dt)
  --self:applyGravity(dt)
  self:updateAnimationState()
  self.currAnim:update(dt)
  self.particles:moveTo(self.x, self.y)
  self.particles:update(dt)
end

--Updates the animation state of the player
function Player:updateAnimationState()
  if self.xVel > 0 then
    self.flipscale = 1
  elseif self.xVel < 0 then
    self.flipscale = -1
  end
  
  local vx, vy = self.physics.body:getLinearVelocity()

  if self.grounded then
    if self.xVel ~= 0 then
      self.currAnim = self.walkAnim
    else
      self.currAnim = self.idleAnim
    end
  else
    if vy ~= 0 then
      self.currAnim = self.jumpAnim
    end
  end
end

--Applies gravity to the player
function Player:applyGravity(dt)
  if self.grounded then return end
  if self.yVel < (self.maxSpeed + 20) then
      if  self.yVel + self.gravity * dt < (self.maxSpeed + 20) then
        self.yVel = self.yVel + self.gravity * dt
      else
        self.yVel = (self.maxSpeed + 20)
      end
  end
end

--Handles input and movement
function Player:move(dt)
  local inAirMult = 1
  if not self.grounded then
    inAirMult = 0.5
  end
  if love.keyboard.isDown("d", "right") then
    if self.xVel < self.maxSpeed then
      if self.xVel + self.accel * dt < self.maxSpeed then
        self.xVel = self.xVel + self.accel * inAirMult * dt
      else
        self.xVel = self.maxSpeed
      end
    end
  elseif love.keyboard.isDown("a", "left") then
    if self.xVel > -self.maxSpeed then
      if  self.xVel - self.accel * dt > -self.maxSpeed then
        self.xVel = self.xVel - self.accel * inAirMult * dt
      else
        self.xVel = -self.maxSpeed
      end
    end
  else
    self:applyFriction(dt)
  end
  
  if love.keyboard.isDown("space") then
    if not self.jumpedLastFrame and self.grounded then
      self.jumpedLastFrame = true
      self.physics.body:applyLinearImpulse(0, self.jumpAccel)
      
      self.jumpAnim:gotoFrame(1)
      self.jumpAnim:resume()
      self.jumpSFX:play()
    end
  else
    self.jumpedLastFrame = false
  end
  
end

--Applies friction to the player
function Player:applyFriction(dt)
  if self.xVel > 0 then
    if self.xVel - self.friction * dt > 0 then
      self.xVel = self.xVel - self.friction * dt
    else
      self.xVel = 0
    end
  elseif self.xVel < 0 then
    if self.xVel + self.friction * dt < 0 then
      self.xVel = self.xVel + self.friction * dt
    else
      self.xVel = 0
    end
  end
end
  
--Collision callback for checking if the player is on the ground
function Player:beginContact(a, b, collision)
  if self.grounded then return end
  local nx, ny = collision:getNormal()
  if a == self.physics.fixture then
    if ny > 0 then
      self:land(collision)
    end
  elseif b == self.physics.fixture then
    if ny < 0 then
      self:land(collision)
    end
  end
  
end

--Called when the player becomes grounded
function Player:land(collision)
  self.yVel = 0
  self.jumpSFX:stop()
  self.landSFX:play()
  self.grounded = true
  self.groundCollisionNumber = self.groundCollisionNumber + 1
  table.insert(self.currentGroundCollisions, collision)
end

--Callback for when the player is no longer grounded
function Player:endContact(a, b, collision)
  if a == self.physics.fixture or b == self.physics.fixture then
    for i = 1, #self.currentGroundCollisions do
      if self.currentGroundCollisions[i] == collision then
        table.remove(self.currentGroundCollisions, i)
        if #self.currentGroundCollisions == 0 then
          self.grounded = false
        end
        return
      end
    end
  end
end

--Synchronises the player position with the physics body
function Player:syncPhysics()
  self.x = self.physics.body:getX()
  self.y = self.physics.body:getY()
  local x, y = self.physics.body:getLinearVelocity()
  self.physics.body:setLinearVelocity(self.xVel, y)
  end


--Draws the player
function Player:draw()
  self.particles:draw()
  self.currAnim:draw(self.img, self.x - ((self.width / 2) * self.flipscale), self.y - self.height / 2, 0, self.flipscale / 2, 1 / 2)
  --love.graphics.print(#self.currentGroundCollisions, 10, 10)
  
  
end

function Player:getFixture()
  return self.physics.fixture
end
