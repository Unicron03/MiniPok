local Carapuce = {name = "Carapuce"}

local stats = {
    isShiny = false
}

function Carapuce:new()
    local newCarapuce = {}
    setmetatable(newCarapuce, self)
    self.__index = self
    return newCarapuce
end

function Carapuce:load(state)
    self.evolution = "Carabaffe"
    self.pv = 80
    self.maxSpeed = 185
    self.type = PokemonTypes.WATER
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/carapuce/icon.png")

    self.attack = {
        [1] = {
            name = "Ecume",
            damage = 10
        },
        [2] = {
            name = "Pistolet à O",
            damage = 30
        },
        [3] = {
            name = "Hydroqueue",
            damage = 60
        }
    }
end

function Carapuce:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 1, current = 1, img = {}, rate = 0.2}
    for i=1, animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/carapuce/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/carapuce/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/carapuce/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/carapuce/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/carapuce/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Carapuce:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Carapuce:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Carapuce