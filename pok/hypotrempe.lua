local Hypotrempe = {name = "Hypotrempe"}

local stats = {
    isShiny = false
}

function Hypotrempe:new()
    local newHypotrempe = {}
    setmetatable(newHypotrempe, self)
    self.__index = self
    return newHypotrempe
end

function Hypotrempe:load(state)
    self.evolution = "Hypocean"
    self.pv = 80
    self.maxSpeed = 185
    self.type = PokemonTypes.WATER
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/hypotrempe/icon.png")

    self.attack = {
        [1] = {
            name = "Brouillard",
            damage = 10
        },
        [2] = {
            name = "Poussée Inverse",
            damage = 20
        },
        [3] = {
            name = "Aileron Aiguisé",
            damage = 40
        }
    }
end

function Hypotrempe:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 4, current = 1, img = {}, rate = 0.2}
    for i=1, animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/hypotrempe/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/hypotrempe/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/hypotrempe/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/hypotrempe/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/hypotrempe/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Hypotrempe:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Hypotrempe:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Hypotrempe