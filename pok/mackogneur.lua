local Mackogneur = {name = "Mackogneur"}

local stats = {
    isShiny = false
}

function Mackogneur:new()
    local newMackogneur = {}
    setmetatable(newMackogneur, self)
    self.__index = self
    return newMackogneur
end

function Mackogneur:load(state)
    self.evolution = "nil"
    self.pv = 200
    self.maxSpeed = 115
    self.type = PokemonTypes.GROUND
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/mackogneur/icon.png")

    self.attack = {
        [1] = {
            name = "Frappe Atlas",
            damage = 60
        },
        [2] = {
            name = "Lasso Gros Bras",
            damage = 100
        },
        [3] = {
            name = "Close Combat",
            damage = 120
        }
    }
end

function Mackogneur:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 1, current = 1, img = {}, rate = 0.2}
    for i=1,animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/mackogneur/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/mackogneur/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/mackogneur/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/mackogneur/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/mackogneur/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Mackogneur:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Mackogneur:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Mackogneur