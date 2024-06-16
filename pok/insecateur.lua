local Insecateur = {name = "Insecateur"}

local stats = {
    isShiny = false
}

function Insecateur:new()
    local newInsecateur = {}
    setmetatable(newInsecateur, self)
    self.__index = self
    return newInsecateur
end

function Insecateur:load(state)
    self.evolution = "nil"
    self.pv = 140
    self.maxSpeed = 155
    self.type = PokemonTypes.PLANT
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/insecateur/icon.png")

    self.attack = {
        [1] = {
            name = "Hâte",
            damage = 10
        },
        [2] = {
            name = "Tranche",
            damage = 30
        },
        [3] = {
            name = "Lame Tranchante",
            damage = 60
        }
    }
end

function Insecateur:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 1, current = 1, img = {}, rate = 0.2}
    for i=1, animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/insecateur/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/insecateur/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/insecateur/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/insecateur/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/insecateur/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Insecateur:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Insecateur:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Insecateur