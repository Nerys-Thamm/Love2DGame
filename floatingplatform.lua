FloatingPlatform = {}
FloatingPlatform.__index = FloatingPlatform

function FloatingPlatform.new(x, y, w, h, image, world)
    local self = setmetatable({}, FloatingPlatform)
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
    self.physics.body:setMass(1)
    

    self.jointPhysics = {}
    self.jointPhysics.body = love.physics.newBody(world, self.x, self.y - 5, "static")
    self.jointPhysics.joint = love.physics.newDistanceJoint(self.jointPhysics.body, self.physics.body, self.x, self.y - 5, self.x, self.y, false)
    self.jointPhysics.joint:setDampingRatio(0.3)
    self.jointPhysics.joint:setFrequency(1)
    
    return self
end

function FloatingPlatform:draw()
    love.graphics.draw(self.image, self.physics.body:getX(), self.physics.body:getY(), self.physics.body:getAngle(), self.w, self.h, self.image:getWidth()/2, self.image:getHeight()/2)
end