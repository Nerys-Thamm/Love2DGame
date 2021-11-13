--// Bachelor of Software Engineering
--// Media Design School
--// Auckland
--// New Zealand
--// 
--// (c) 2021 Media Design School
--//
--// File Name   : level.lua
--// Description : This file contains functions for levels
--// Author      : Nerys Thamm
--// Mail        : nerys.thamm@mds.ac.nz 

local sti = require("sti")
require("collectibles")
require("physicscube")
require("floatingplatform")

local Camera = require "Camera"

Level = {}
Level.__index = Level

-- Loads a level from a file
function Level.load(mapName)
    local self = setmetatable({}, Level)
    self.map = sti("assets/tilemaps/"..mapName, { "box2d" }) -- Load the map

    --Initialise the Box2D world
    love.physics.setMeter(32)
    self.world = love.physics.newWorld(0, 450)
    self.world:setCallbacks(beginContact, endContact)
    self.map:box2d_init(self.world)

    self.camera = Camera() -- Create a camera
    self.score = 0 -- Initialise the score
    local potImg = love.graphics.newImage('assets/textures/pot01.png')
    self.collectibles = {}
    for i, obj in pairs(self.map.layers["Collectibles"].objects) do
        table.insert(self.collectibles, Collectible.build(obj.x, obj.y, 0.5, 0.5, potImg, obj.name, 1, self.world))
    end
    self.physicsobjects = {}
    for i, obj in pairs(self.map.layers["PhysicsObjects"].objects) do
        if obj.name == "FloatingPlatform" then
            table.insert(self.physicsobjects, FloatingPlatform.new(obj.x, obj.y, 0.5, 0.5, love.graphics.newImage('assets/textures/LargePlatform.png'), self.world))
        elseif obj.name == "PhysicsCube" then
            table.insert(self.physicsobjects, PhysicsCube.new(obj.x, obj.y, 0.5, 0.5, love.graphics.newImage('assets/textures/LargeBlock.png'), self.world))
        end
    end
    --Create background layers for parallax scrolling
    self.camera:newLayer(1, 0, function() 
        self.map:drawImageLayer("CaveSky1")
    end)
    self.camera:newLayer(2, 0, function()
        self.map:drawImageLayer("CaveSky2")
    end)
    self.camera:newLayer(3, 0.1, function()
        self.map:drawImageLayer("Waterfalls")
    end)
    self.camera:newLayer(4, 0.2, function()
        self.map:drawImageLayer("Vapour1")
    end)
    self.camera:newLayer(5, 0.2, function()
        self.map:drawImageLayer("Vapour2")
    end)
    self.camera:newLayer(6, 0.2, function()
        self.map:drawImageLayer("Vapour3")
        end)
        self.camera:newLayer(7, 0.8, function()
        self.map:drawImageLayer("CaveBG")
    end)
    self.camera:newLayer(7, 0.8, function()
        self.map:drawImageLayer("CaveBG2")
    end)
    self.camera:newLayer(8, 0.9, function()
        love.graphics.setColor(0.8, 0.8, 1, 1)
        self.map:drawTileLayer("Background")
        end)

    --Create the Walkable Layer
    self.camera:newLayer(9, 1, function()
        love.graphics.setColor(1, 1, 1, 1)
        self.map:drawTileLayer("Walkable")
        for i, obj in pairs(self.collectibles) do
            obj:draw()
        end
        for i, obj in pairs(self.physicsobjects) do
            obj:draw()
        end
    end)

    --Create a layer for the Player
    self.camera:newLayer(10, 1, function()
        Player:draw()
    end)

    --Create the Foreground layer for Parallax scrolling
    self.camera:newLayer(11, 1.1, function()
        love.graphics.setColor(0.3, 0.3, 0.5, 1)
        self.map:drawTileLayer("Foreground")
        end, true)
    
    

    
    --Create the Player
    Player:load(self.world, love.graphics.newImage('assets/textures/animations/player.png'))
    
    --Start the background music
    self.bgm = love.audio.newSource("assets/audio/Shroud.mp3", "static")
    self.bgm:setLooping(true)
    self.bgm:play()
    
    --Return the level
    return self
end

-- Updates the level
function Level:update(dt)
    self.world:update(dt)
    Player:update(dt)
    self.camera:setPosition(Utils:lerp(self.camera.x, Player.x - 200, dt), 0)
    for i, obj in pairs(self.collectibles) do
        obj:update(dt)
    end
end

-- Draws the level
function Level:draw()
    
    

    love.graphics.setCanvas(RenderTexture)
    love.graphics.clear()
    self.camera:draw("noFG")
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    self.camera:draw("noFG")
    love.graphics.setColor(1, 1, 1, 1)
    WaterShader:send("time", love.timer.getTime())
    love.graphics.setShader(WaterShader)
    love.graphics.draw(RenderTexture, 0, love.graphics.getHeight() + 90, 0, 1, -0.4, 0, 0)
    love.graphics.setShader()
    self.camera:draw("FGonly")
    love.graphics.setColor(1, 0.7, 0.0, 1)
    love.graphics.print("Magic Pots; "..self.score, 10, 550)
end

-- Handles the collision between the player and the level
function Level:beginContact(a, b, collision)
    Player:beginContact(a, b, collision)

    for i = 1, #self.collectibles do
        if self.collectibles[i]:checkCollision(Player:getFixture(), a, b) then
            self.score = self.score + 1
            self.collectibles[i]:destroy()
            table.remove(self.collectibles, i)
            break
        end
    end
end

-- Handles the collision between the player and the level
function Level:endContact(a, b, collision)
    Player:endContact(a, b, collision)
end

