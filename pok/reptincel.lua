local Reptincel = {name = "Reptincel"}

local stats = {
    isShiny = false
}

function Reptincel:new()
    local newReptincel = {}
    setmetatable(newReptincel, self)
    self.__index = self
    return newReptincel
end

function Reptincel:load(state)
    self.evolution = "Dracaufeu"
    self.pv = 160
    self.maxSpeed = 145
    self.type = PokemonTypes.FIRE
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/reptincel/icon.png")

    self.attack = {
        [1] = {
            name = "Tranche",
            damage = 30
        },
        [2] = {
            name = "Crocs Feu",
            damage = 50
        },
        [3] = {
            name = "Lance-Flammes",
            damage = 70
        }
    }
end

function Reptincel:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 1, current = 1, img = {}, rate = 0.2}
    for i=1,animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/reptincel/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/reptincel/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/reptincel/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/reptincel/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/reptincel/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Reptincel:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Reptincel:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Reptincel