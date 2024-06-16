local Kangourex = {name = "Kangourex"}

local stats = {
    isShiny = false
}

function Kangourex:new()
    local newKangourex = {}
    setmetatable(newKangourex, self)
    self.__index = self
    return newKangourex
end

function Kangourex:load(state)
    self.evolution = "nil"
    self.pv = 180
    self.maxSpeed = 135
    self.type = PokemonTypes.NORMAL
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/kangourex/icon.png")

    self.attack = {
        [1] = {
            name = "Point comète",
            damage = 20
        },
        [2] = {
            name = "P'tit Coup d'Poing",
            damage = 40
        },
        [3] = {
            name = "Ultimapoing",
            damage = 100
        }
    }
end

function Kangourex:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 1, current = 1, img = {}, rate = 0.2}
    for i=1,animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/kangourex/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/kangourex/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/kangourex/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/kangourex/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/kangourex/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Kangourex:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Kangourex:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Kangourex