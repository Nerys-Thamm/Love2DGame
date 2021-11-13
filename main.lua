--// Bachelor of Software Engineering
--// Media Design School
--// Auckland
--// New Zealand
--// 
--// (c) 2021 Media Design School
--//
--// File Name   : main.lua
--// Description : This file contains the main code for the game.
--// Author      : Nerys Thamm
--// Mail        : nerys.thamm@mds.ac.nz 
local sti = require("sti")
local love = _G.love
local Camera = require "Camera"
local map, world, tx, ty, points, playerImg
require("player")
require("utils")
--require("particlesystem")
require("level")
require("menu")
require("FadeRect")
anim8 = require("anim8")
local myCamera = Camera()
local bgm
local testparticle
local mainMenu, gameOverMenu
local currentLevel
Gamestate = "mainmenu"
Faderect = nil
RenderTexture = nil
WaterShader = love.graphics.newShader[[
  extern number time;
  
  vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    
    float PI = 6.28318530718; //2*PI because thats a circle
    float Directions = 32.0; //Number of directions to sample
    float Quality = 10.0; // Times to sample
    float Size = 0.1; // Radius of circle to sample from surrounding pixels
    vec2 Radius = vec2(Size, Size);
    float d = 0.1;
    vec3 col;

    for(float i=0.0; i<PI; i+=PI/Directions)
    {
        for(float j=1.0/Quality; j<=1.0; j+=1.0/Quality)
        {
			
            col += Texel( texture, (texture_coords + vec2(0.0, cos((screen_coords.y/2.0) + time) * 0.08) + (vec2(cos(i),sin(i))*(Radius* d)*j))).rgb;
            
        }
    }

    col /= Quality * Directions - 15.0;

    vec4 pixel = vec4(col * (1.0+(cos((screen_coords.y/2.0) + time))/6), 0.7);
    
    return pixel;
  }
]]


local levels = {"Level1.lua"}
local levelindex = 1


--Loads the game
function love.load()
    love.graphics.setFont(love.graphics.newFont("assets/fonts/GothicPixels.ttf", 20))
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)
    RenderTexture = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight()-100)
    --Create the Main Menu
    mainMenu = Menu.build(200, 100, 400, 200, "Cavern", {
        {
            name = "Play",
            action = function() --Callback to fade into the first level
              Faderect = FadeRect.new(800, 600, {0,0,0}, 1, "inOut", 
              function()
                currentLevel = Level.load("Level1.lua")
                Gamestate = "playing"
              end)
            end,
            color = {0.85, 0.55, 0.0},
            selectedColor = {0.76, 0.46, 0.0},
            textColor = {0, 0, 0}
        },
        {
            name = "Quit",
            action = function() --Callback to quit the game
                love.event.quit()
            end,
            color = {0.85, 0.55, 0.0},
            selectedColor = {0.76, 0.46, 0.0},
            textColor = {0, 0, 0}
        }
    })

    --Create the Game Over Menu
    gameOverMenu = Menu.build(200, 100, 400, 200, "Game Over", {
        {
            name = "Retry",
            action = function() --Callback to fade into the level being retried
              Faderect = FadeRect.new(800, 600, {0,0,0}, 1, "inOut", 
              function()
                currentLevel = Level.load(levels[levelindex])
                Gamestate = "playing"
              end)
            end,
            color = {0.7, 0.7, 0.7},
            selectedColor = {0.3, 0.3, 0.3},
            textColor = {0, 0, 0}
        },
        {
            name = "Quit",
            action = function() --Callback to quit the game
                love.event.quit()
            end,
            color = {0.7, 0.7, 0.7},
            selectedColor = {0.3, 0.3, 0.3},
            textColor = {0, 0, 0}
        }
    })
  
  if arg[#arg] == "-debug" then require("mobdebug").start() end
end

--Love2D callback to update the game
function love.update(dt)
  if Gamestate ~= "playing" and currentLevel ~= nil then --If the game is not playing then clean up any level data
    currentLevel.bgm:stop()
    currentLevel = nil 
  end
  if currentLevel ~= nil then --If there is a level then update it
    currentLevel:update(dt)
  elseif Gamestate == "mainmenu" then --Otherwise, update the main menu if in the mainmenu state
    mainMenu:update(dt)
  elseif  Gamestate == "gameover" then --Otherwise, update the game over menu if in the gameover state
    gameOverMenu:update(dt)
  end

  if Faderect ~= nil then --If there is a fade rect then update it
    Faderect:update(dt)
  end
    
    
end

--Love2D callback to draw
function love.draw()
  if currentLevel ~= nil then --If there is a level then draw it
    currentLevel:draw()
  elseif Gamestate == "mainmenu" then --Otherwise, draw the main menu if in the mainmenu state
    mainMenu:draw()
  elseif  Gamestate == "gameover" then --Otherwise, draw the game over menu if in the gameover state
    gameOverMenu:draw()
  end
  if Faderect ~= nil then
    Faderect:draw()
  end
end

function beginContact(a, b, collision) --Callback for when two objects collide
  --Player:beginContact(a, b, collision)
  if currentLevel ~= nil then
    currentLevel:beginContact(a, b, collision)
  end
  
end


function endContact(a, b, collision) --Callback for when two objects stop colliding
  --Player:endContact(a, b, collision)
  if currentLevel ~= nil then
    currentLevel:endContact(a, b, collision)
  end
  
end
