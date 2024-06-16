local Carabaffe = {name = "Carabaffe"}

local stats = {
    isShiny = false
}

function Carabaffe:new()
    local newCarabaffe = {}
    setmetatable(newCarabaffe, self)
    self.__index = self
    return newCarabaffe
end

function Carabaffe:load(state)
    self.evolution = "Tortank"
    self.pv = 140
    self.maxSpeed = 155
    self.type = PokemonTypes.WATER
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/carabaffe/icon.png")

    self.attack = {
        [1] = {
            name = "Charge",
            damage = 30
        },
        [2] = {
            name = "Coquill-attaque",
            damage = 50
        },
        [3] = {
            name = "Cascade",
            damage = 60
        }
    }
end

function Carabaffe:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 1, current = 1, img = {}, rate = 0.2}
    for i=1, animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/carabaffe/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/carabaffe/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/carabaffe/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/carabaffe/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/carabaffe/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Carabaffe:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Carabaffe:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Carabaffe