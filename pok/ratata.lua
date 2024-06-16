local Ratata = {name = "Ratata"}

local stats = {
    isShiny = false
}

function Ratata:new()
    local newRatata = {}
    setmetatable(newRatata, self)
    self.__index = self
    return newRatata
end

function Ratata:load(state)
    self.evolution = "Ratatac"
    self.pv = 60
    self.maxSpeed = 195
    self.type = PokemonTypes.NORMAL
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/ratata/icon.png")

    self.attack = {
        [1] = {
            name = "Griffe",
            damage = 10
        },
        [2] = {
            name = "Morsure",
            damage = 20
        },
        [3] = {
            name = "Coup Rapide",
            damage = 30
        }
    }
end

function Ratata:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 1, current = 1, img = {}, rate = 0.2}
    for i=1,animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/ratata/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/ratata/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/ratata/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/ratata/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/ratata/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Ratata:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Ratata:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Ratata