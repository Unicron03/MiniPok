local Herbizarre = {name = "Herbizarre"}

local stats = {
    isShiny = false
}

function Herbizarre:new()
    local newHerbizarre = {}
    setmetatable(newHerbizarre, self)
    self.__index = self
    return newHerbizarre
end

function Herbizarre:load(state)
    self.evolution = "Florizarre"
    self.pv = 120
    self.maxSpeed = 165
    self.type = PokemonTypes.PLANT
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/herbizarre/icon.png")

    self.attack = {
        [1] = {
            name = "Poudre Toxik",
            damage = 20
        },
        [2] = {
            name = "Tranch'Herbe",
            damage = 30
        },
        [3] = {
            name = "Fouet Lianes",
            damage = 50
        }
    }
end

function Herbizarre:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 4, current = 1, img = {}, rate = 0.2}
    for i=1,animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/herbizarre/idle/"..i..".png")
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/herbizarre/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/herbizarre/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/herbizarre/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/herbizarre/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Herbizarre:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Herbizarre:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Herbizarre