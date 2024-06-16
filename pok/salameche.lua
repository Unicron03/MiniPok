local Salameche = {name = "Salameche"}

local stats = {
    isShiny = false
}

function Salameche:new()
    local newSalameche = {}
    setmetatable(newSalameche, self)
    self.__index = self
    return newSalameche
end

function Salameche:load(state)
    self.evolution = "nil"
    self.pv = 100
    self.maxSpeed = 175
    self.type = PokemonTypes.FIRE
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/salameche/icon.png")

    self.attack = {
        [1] = {
            name = "Griffes",
            damage = 10
        },
        [2] = {
            name = "Queue de flammes",
            damage = 20
        },
        [3] = {
            name = "Flamèche",
            damage = 30
        }
    }
end

function Salameche:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 1, current = 1, img = {}, rate = 0.2}
    for i=1,animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/salameche/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/salameche/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/salameche/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/salameche/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/salameche/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Salameche:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Salameche:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Salameche