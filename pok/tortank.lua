local Tortank = {name = "Tortank"}

local stats = {
    isShiny = false
}

function Tortank:new()
    local newTortank = {}
    setmetatable(newTortank, self)
    self.__index = self
    return newTortank
end

function Tortank:load(state)
    self.evolution = "nil"
    self.pv = 200
    self.maxSpeed = 115
    self.type = PokemonTypes.WATER
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/tortank/icon.png")

    self.attack = {
        [1] = {
            name = "Hydrocanon",
            damage = 40
        },
        [2] = {
            name = "Bombre Eclaboussante",
            damage = 70
        },
        [3] = {
            name = "Hydro-Charge",
            damage = 120
        }
    }
end

function Tortank:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 1, current = 1, img = {}, rate = 0.2}
    for i=1,animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/tortank/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/tortank/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/tortank/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/tortank/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/tortank/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Tortank:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Tortank:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Tortank