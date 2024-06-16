local Mmime = {name = "MMime"}

local stats = {
    isShiny = false
}

function Mmime:new()
    local newMmime = {}
    setmetatable(newMmime, self)
    self.__index = self
    return newMmime
end

function Mmime:load(state)
    self.evolution = "nil"
    self.pv = 80
    self.maxSpeed = 185
    self.type = PokemonTypes.PSY
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/mmime/icon.png")

    self.attack = {
        [1] = {
            name = "Yoga",
            damage = 10
        },
        [2] = {
            name = "Choc mental",
            damage = 30
        },
        [3] = {
            name = "Gifle Rusé",
            damage = 70
        }
    }
end

function Mmime:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 1, current = 1, img = {}, rate = 0.2}
    for i=1,animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/mmime/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/mmime/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/mmime/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/mmime/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/mmime/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Mmime:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Mmime:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Mmime