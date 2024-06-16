local Abra = {name = "Abra"}

local stats = {
    isShiny = false
}

function Abra:new()
    local newAbra = {}
    setmetatable(newAbra, self)
    self.__index = self
    return newAbra
end

function Abra:load(state)
    self.evolution = "Kadabra"
    self.pv = 60 -- pv réel * 2
    self.maxSpeed = 185 -- 115 + 100 - pv
    self.type = PokemonTypes.PSY
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/abra/icon.png")

    self.attack = {
        [1] = {
            name = "Griffe",
            damage = 10
        },
        [2] = {
            name = "Piqûre Psy",
            damage = 20
        },
        [3] = {
            name = "Choc mental",
            damage = 35
        }
    }
end

function Abra:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 1, current = 1, img = {}, rate = 0.2}
    for i=1, animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/abra/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/abra/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/abra/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/abra/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/abra/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Abra:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Abra:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Abra