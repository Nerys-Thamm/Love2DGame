--// Bachelor of Software Engineering
--// Media Design School
--// Auckland
--// New Zealand
--// 
--// (c) 2021 Media Design School
--//
--// File Name   : menu.lua
--// Description : Contains functions for building a menu
--// Author      : Nerys Thamm
--// Mail        : nerys.thamm@mds.ac.nz 

Menu = {}
Menu.__index = Menu

--- Creates a new menu using Factory Pattern
---@param originX number @The x position of the menu
---@param originY number @The y position of the menu
---@param width number @The width of the menu
---@param height number @The height of the menu
---@param title string @The title of the menu
---@param options table @The options table
function Menu.build(originX, originY, width, height, title, options)
    local self = setmetatable({}, Menu)
    self.originX = originX
    self.originY = originY
    self.width = width
    self.height = height
    self.title = title
    self.options = options
    self.selected = 1
    self.visible = true
    self.buttons = {}
    self.buttonHeight = height / #options
    self.buttonWidth = width
    for i, option in ipairs(options) do
        local button = Button.new(originX, originY + (i) * self.buttonHeight, self.buttonWidth, self.buttonHeight, option.name, option.action, option.color, option.selectedColor, option.textColor)
        table.insert(self.buttons, button)
    end
    return self
end

--- Updates the menu
---@param dt any @The delta time
function Menu:update(dt)
    for i, button in ipairs(self.buttons) do
        button:update(dt)
    end
end

--Draws the Menu
function Menu:draw()
    if self.visible then
        love.graphics.setColor(0, 0, 0.0, 0.0)
        love.graphics.rectangle("fill", self.originX, self.originY, self.width, self.height)
        love.graphics.setColor(1, 0.7, 0, 1)
        love.graphics.setFont(love.graphics.newFont("assets/fonts/GothicPixels.ttf", 70))
        love.graphics.print(self.title, self.originX + self.width / 2 - self.title:len() * 21, self.originY)
        for i, button in ipairs(self.buttons) do
            button:draw()
        end
    end
end



Button = {}
Button.__index = Button
--- Creates a new button
---@param originX any @The x position of the button
---@param originY any @The y position of the button
---@param width any @The width of the button
---@param height any @The height of the button
---@param text any @The text of the button
---@param callback any @The callback function the button activates
---@param color any @The color of the button
---@param selectedColor any @The color of the button when selected
---@param textColor any @The color of the text of the button
function Button.new(originX, originY, width, height, text, callback, color, selectedColor, textColor)
    local self = setmetatable({}, Button)
    self.originX = originX
    self.originY = originY
    self.width = width
    self.height = height
    self.text = text
    self.callback = callback
    self.color = color
    self.selectedColor = selectedColor
    self.textColor = textColor
    return self
end

--Draws a button
function Button:draw()
    if self.selected then
        love.graphics.setColor(self.selectedColor)
    else
        love.graphics.setColor(self.color)
    end
    love.graphics.rectangle("fill", self.originX, self.originY, self.width, self.height)
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.rectangle("line", self.originX, self.originY, self.width, self.height)  
    love.graphics.setColor(self.textColor)
    love.graphics.setFont(love.graphics.newFont("assets/fonts/GothicPixels.ttf", 30))
    love.graphics.print(self.text, self.originX + self.width / 2 - self.text:len() * 8, self.originY + self.height / 3)
    love.graphics.setColor(255, 255, 255, 255)
end

--- Updates the button
---@param dt any @The delta time
function Button:update(dt) 
    if self.originX < love.mouse.getX() and self.originX + self.width > love.mouse.getX() and self.originY < love.mouse.getY() and self.originY + self.height > love.mouse.getY() then
        self.selected = true
        if love.mouse.isDown(1) and self.callback then
            self.callback()
        end
    else
        self.selected = false 
    end
end

