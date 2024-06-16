local Caninos = {name = "Caninos"}

local stats = {
    isShiny = false
}

function Caninos:new()
    local newCaninos = {}
    setmetatable(newCaninos, self)
    self.__index = self
    return newCaninos
end

function Caninos:load(state)
    self.evolution = "nil"
    self.pv = 120
    self.maxSpeed = 165
    self.type = PokemonTypes.FIRE
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/caninos/icon.png")

    self.attack = {
        [1] = {
            name = "Flamboiement",
            damage = 10
        },
        [2] = {
            name = "Morsure",
            damage = 30
        },
        [3] = {
            name = "Bélier",
            damage = 50
        }
    }
end

function Caninos:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 1, current = 1, img = {}, rate = 0.2}
    for i=1, animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/caninos/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/caninos/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/caninos/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/caninos/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1, animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/caninos/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Caninos:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Caninos:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Caninos