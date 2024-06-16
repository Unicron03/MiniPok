local Leveinard = {name = "Leveinard"}

local stats = {
    isShiny = false
}

function Leveinard:new()
    local newLeveinard = {}
    setmetatable(newLeveinard, self)
    self.__index = self
    return newLeveinard
end

function Leveinard:load(state)
    self.evolution = "nil"
    self.pv = 240
    self.maxSpeed = 115
    self.type = PokemonTypes.NORMAL
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/leveinard/icon.png")

    self.attack = {
        [1] = {
            name = "Empilage",
            damage = 10
        },
        [2] = {
            name = "Damoclès",
            damage = 80
        },
        [3] = {
            name = "Gifle Cordiale",
            damage = 100
        }
    }
end

function Leveinard:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 4, current = 1, img = {}, rate = 0.2}
    for i=1,animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/leveinard/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/leveinard/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/leveinard/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/leveinard/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/leveinard/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Leveinard:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Leveinard:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Leveinard