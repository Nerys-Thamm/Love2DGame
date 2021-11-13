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

--Global variables storing game state data
CurrentLevel = nil
Gamestate = "mainmenu"

--Post processing variables
Faderect = nil
RenderTexture = nil

--Shader for Water Effect
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
			
            col += Texel( texture, (texture_coords + vec2(cos((screen_coords.y/3.0) - time) * 0.01, cos((screen_coords.y/3.0) - time) * 0.04) + (vec2(cos(i),sin(i))*(Radius* d)*j))).rgb;
            
        }
    }

    col /= Quality * Directions - 15.0;

    vec4 pixel = vec4(col * (1.0+(cos((screen_coords.y/3.0) + time))/10), 0.7);
    
    return pixel;
  }
]]

--Shader for Vignette Effect
VignetteShader = love.graphics.newShader[[
  
  
  vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    
    
    float d = length((screen_coords) - vec2(400, 600));
    

    vec4 pixel = vec4(Texel(texture, texture_coords).rgb - pow(d * 0.0008, 3), Texel(texture, texture_coords).a);
    
    return pixel;
  }
]]

--Keeps track of Levels
Levels = {"Level1.lua", "Level2.lua"}
LevelIndex = 1


--Loads the game
function love.load()
    love.graphics.setFont(love.graphics.newFont("assets/fonts/GothicPixels.ttf", 20)) --Set the font
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15) --Set the background color
    RenderTexture = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight()-100) --Create a new canvas for post processing
    --Create the Main Menu using Menu Factory
    mainMenu = Menu.build(200, 100, 400, 200, "Cavern", { 
        {
            name = "Play",
            action = function() --Callback to fade into the first level
              Faderect = FadeRect.new(800, 600, {0,0,0}, 1, "inOut", 
              function()
                CurrentLevel = Level.load(Levels[LevelIndex])
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
                CurrentLevel = Level.load(Levels[LevelIndex]) --Load the level
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
  
  if arg[#arg] == "-debug" then require("mobdebug").start() end --Load the debug library if in debug mode
end

--- Updates the game
---@param dt any The time passed since the last update
function love.update(dt)
  if Gamestate ~= "playing" and CurrentLevel ~= nil then --If the game is not playing then clean up any level data
    CurrentLevel.bgm:stop()
    CurrentLevel = nil 
  end
  if CurrentLevel ~= nil then --If there is a level then update it
    CurrentLevel:update(dt)
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
  if CurrentLevel ~= nil then --If there is a level then draw it
    CurrentLevel:draw()
  elseif Gamestate == "mainmenu" then --Otherwise, draw the main menu if in the mainmenu state
    mainMenu:draw()
  elseif  Gamestate == "gameover" then --Otherwise, draw the game over menu if in the gameover state
    gameOverMenu:draw()
  end
  if Faderect ~= nil then
    Faderect:draw()
  end
end

--- Love2D callback to handle collision
---@param a any @The first object
---@param b any @The second object
---@param collision any @The collision data
function beginContact(a, b, collision) --Callback for when two objects collide
  --Player:beginContact(a, b, collision)
  if CurrentLevel ~= nil then
    CurrentLevel:beginContact(a, b, collision)
  end
  
end

--- Love2D callback to handle collision
---@param a any @The first object
---@param b any @The second object
---@param collision any @The collision data
function endContact(a, b, collision) --Callback for when two objects stop colliding
  --Player:endContact(a, b, collision)
  if CurrentLevel ~= nil then
    CurrentLevel:endContact(a, b, collision)
  end
  
end
