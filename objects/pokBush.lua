
local PokBush = {}
PokBush.__index = PokBush
local ActivePokBushs = {}

local MsgUI = require("msgUI")

function PokBush.removeAll()
    for i,v in ipairs(ActivePokBushs) do
        v.physics.body:destroy()
    end

    ActivePokBushs = {}
end

function PokBush:returnTable()
    return ActivePokBushs 
end

function PokBush:remove()
    for i, instance in ipairs(ActivePokBushs) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActivePokBushs, i)
        end
    end
end

function PokBush.new(x, y, width, height, pok)
    instance = setmetatable({}, PokBush)
    instance.x = x
    instance.y = y
    instance.pok = pok

    instance.msgUI = nil

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x + width * 0.5, instance.y + height * 0.5, "static")
    instance.physics.shape = love.physics.newRectangleShape(width, height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

    instance.physics.fixture:setSensor(true)

    table.insert(ActivePokBushs, instance)

    return instance
end

function PokBush.returnTable()
    return ActivePokBushs
end

function PokBush:update(dt)
end

function PokBush:draw()
    -- self:drawHitbox()
end

function PokBush:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function PokBush.updateAll(dt)
    for i,instance in ipairs(ActivePokBushs) do
        instance:update(dt)
    end
end

function PokBush.drawAll()
    for i,instance in ipairs(ActivePokBushs) do
        instance:draw()
    end
end

function PokBush.beginContact(a, b, collision)
    for i,instance in ipairs(ActivePokBushs) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                local additionnalText = (Inventory.pokBelt.current == Inventory.pokBelt.max) and (" (You dont have place in your PokBelt)") or ("")
                instance.msgUI = MsgUI.new(nil, nil, "Take the fight"..additionnalText, true, nil,
                    function()
                        local Entities = require("entities")
                        Player:newBattle(instance.pok.name)
                        instance:remove()
                    end)
            end
        end
    end
end

function PokBush.endContact(a, b, collision)
    for i, instance in ipairs(ActivePokBushs) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if instance.msgUI ~= nil then
                instance.msgUI:remove()
            end

            instance.msgUI = nil
        end
    end
end

return PokBush