Collectible = {}
Collectible.__index = Collectible

function Collectible.build(x, y, w, h, image, name, value, world)
    local self = setmetatable({}, Collectible)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.image = image
    self.name = name
    self.value = value

    self.physics = {}
    self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(false)
    self.physics.shape = love.physics.newRectangleShape(self.image:getWidth() * self.w, self.image:getHeight() * self.h)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setMass(10)

    self.breakSFX = love.audio.newSource("assets/audio/cave_glass.wav", "static")
    self.breakSFX:setVolume(0.03)
    return self
end

function Collectible:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.image, self.physics.body:getX(), self.physics.body:getY(), self.physics.body:getAngle(), self.w, self.h, self.image:getWidth()/2, self.image:getHeight()/2)
end

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

function Collectible:destroy()
    self.physics.fixture:destroy()
    self.physics.body:destroy()
    self.breakSFX:play()
end

function Collectible:update(dt)
    self.x = self.physics.body:getX()
    self.y = self.physics.body:getY()
end
    



