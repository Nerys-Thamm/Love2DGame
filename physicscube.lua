PhysicsCube = {}
PhysicsCube.__index = PhysicsCube

function PhysicsCube.new(x, y, w, h, image, world)
    local self = setmetatable({}, PhysicsCube)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.image = image

    self.physics = {}
    self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.image:getWidth() * self.w, self.image:getHeight() * self.h)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setMass(10)
    return self
end

function PhysicsCube:draw()
    love.graphics.draw(self.image, self.physics.body:getX(), self.physics.body:getY(), self.physics.body:getAngle(), self.w, self.h, self.image:getWidth()/2, self.image:getHeight()/2)
end