local Florizarre = {name = "Florizarre"}

local stats = {
    isShiny = false
}

function Florizarre:new()
    local newFlorizarre = {}
    setmetatable(newFlorizarre, self)
    self.__index = self
    return newFlorizarre
end

function Florizarre:load(state)
    self.evolution = "nil"
    self.pv = 200
    self.maxSpeed = 115
    self.type = PokemonTypes.PLANT
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/florizarre/icon.png")

    self.attack = {
        [1] = {
            name = "Plaquage",
            damage = 40
        },
        [2] = {
            name = "Lance-Soleil",
            damage = 60
        },
        [3] = {
            name = "Marteau Végétal",
            damage = 90
        }
    }
end

function Florizarre:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 4, current = 1, img = {}, rate = 0.2}
    for i=1,animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/florizarre/idle/"..i..".png")        
    end

    animation.right = {total = 2, current = 1, img = {}, rate = 0.15}
    for i=1,animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/florizarre/right/"..i..".png")        
    end

    animation.left = {total = 2, current = 1, img = {}, rate = 0.15}
    for i=1,animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/florizarre/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/florizarre/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/florizarre/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Florizarre:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end
   
function Florizarre:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Florizarre