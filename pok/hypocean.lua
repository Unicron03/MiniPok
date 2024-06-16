local Hypocean = {name = "Hypocean"}

local stats = {
    isShiny = false
}

function Hypocean:new()
    local newHypocean = {}
    setmetatable(newHypocean, self)
    self.__index = self
    return newHypocean
end

function Hypocean:load(state)
    self.evolution = "nil"
    self.pv = 120
    self.maxSpeed = 165
    self.type = PokemonTypes.WATER
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/hypocean/icon.png")

    self.attack = {
        [1] = {
            name = "Nage Libre",
            damage = 10
        },
        [2] = {
            name = "Pistolet à O",
            damage = 20
        },
        [3] = {
            name = "Bulles d'O",
            damage = 50
        }
    }
end

function Hypocean:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 4, current = 1, img = {}, rate = 0.2}
    for i=1, animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/hypocean/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/hypocean/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/hypocean/left/"..i..".png")        
    end

    animation.bottom = {total = 1, current = 1, img = {}, rate = 0.15}
    for i=1, animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/hypocean/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/hypocean/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Hypocean:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Hypocean:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Hypocean