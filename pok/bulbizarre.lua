local Bulbizarre = {name = "Bulbizarre"}

local stats = {
    isShiny = false
}

function Bulbizarre:new()
    local newBulbizarre = {}
    setmetatable(newBulbizarre, self)
    self.__index = self
    return newBulbizarre
end

function Bulbizarre:load(state)
    self.evolution = "Herbizarre"
    self.pv = 80
    self.maxSpeed = 185
    self.type = PokemonTypes.PLANT
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/bulbizarre/icon.png")

    self.attack = {
        [1] = {
            name = "Charge",
            damage = 10
        },
        [2] = {
            name = "Fouet Lianes",
            damage = 20
        },
        [3] = {
            name = "Tranch'Herbe",
            damage = 30
        }
    }
end

function Bulbizarre:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    local animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 4, current = 1, img = {}, rate = 0.2}
    for i=1, animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/bulbizarre/idle/"..i..".png")        
    end

    animation.right = {total = 3, current = 1, img = {}, rate = 0.15}
    for i=1, animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/bulbizarre/right/"..i..".png")        
    end

    animation.left = {total = 3, current = 1, img = {}, rate = 0.15}
    for i=1, animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/bulbizarre/left/"..i..".png")        
    end

    animation.bottom = {total = 3, current = 1, img = {}, rate = 0.15}
    for i=1, animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/bulbizarre/bottom/"..i..".png")        
    end

    animation.top = {total = 3, current = 1, img = {}, rate = 0.15}
    for i=1, animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/bulbizarre/top/"..i..".png")
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Bulbizarre:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Bulbizarre:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Bulbizarre