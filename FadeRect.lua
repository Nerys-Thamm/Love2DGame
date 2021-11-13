--// Bachelor of Software Engineering
--// Media Design School
--// Auckland
--// New Zealand
--// 
--// (c) 2021 Media Design School
--//
--// File Name   : FadeRect.lua
--// Description : FadeRect for fading transitions
--// Author      : Nerys Thamm
--// Mail        : nerys.thamm@mds.ac.nz 

FadeRect = {}
FadeRect.__index = FadeRect

-- This function constructs a FadeRect with a specified color, fade mode [in, out, inout], duration, and callback.
function FadeRect.new(screenWidth, screenHeight, color, duration, fadeMode, onFadeCompleteCallback)
    local self = setmetatable({}, FadeRect)
    self.screenWidth = screenWidth
    self.screenHeight = screenHeight
    self.color = color
    self.duration = duration
    self.isFadingIn = false
    self.inOut = false

    -- Set the fade mode
    if fadeMode == "in" then
        self.isFadingIn = true
    elseif fadeMode == "out" then
        self.isFadingIn = false
    elseif fadeMode == "inOut" then
        self.isFadingIn = false
        self.inOut = true
    end
    if self.isFadingIn then
        self.alpha = 1
    else
        self.alpha = 0
    end

    -- Set the callback
    self.onFadeCompleteCallback = onFadeCompleteCallback
    self.isFading = true
    self.fadeTimer = 0
    self.isComplete = false
    self.completeOnce = false
    return self
end

-- Update function for the fade rect
function FadeRect:update(dt)
    if self.isComplete then return end -- If the fade is complete, don't update it
    if self.isFading then -- If the fade is in progress, update it
        self.fadeTimer = self.fadeTimer + dt 
        if self.fadeTimer >= self.duration then -- If the fade is complete, set the alpha to 0 or 1
            self.fadeTimer = self.duration
            self.isFading = false -- Stop the fade
            
            if self.onFadeCompleteCallback and not self.completeOnce then -- If there is a callback, call it
                self.onFadeCompleteCallback()
            end
            if self.inOut then -- If the fademode is inout, reverse the fade
                if not self.completeOnce then -- If the fade is completing for the first time, reverse it
                    self.isFadingIn = not self.isFadingIn
                    self.fadeTimer = 0
                    self.isFading = true
                    self.completeOnce = true
                end
            end
        end
        if self.isFadingIn then
            self.alpha = 1 - ((self.fadeTimer / self.duration)) -- Calculate the alpha based on the fade timer
        else
            self.alpha = (self.fadeTimer / self.duration) -- Calculate the alpha based on the fade timer
        end
    end
end

-- Draw the fade rect
function FadeRect:draw()
    love.graphics.setColor(0, 0, 0, self.alpha)
    love.graphics.rectangle("fill", 0, 0, self.screenWidth, self.screenHeight)
end