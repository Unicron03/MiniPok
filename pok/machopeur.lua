local Machopeur = {name = "Machopeur"}

local stats = {
    isShiny = false
}

function Machopeur:new()
    local newMachopeur = {}
    setmetatable(newMachopeur, self)
    self.__index = self
    return newMachopeur
end

function Machopeur:load(state)
    self.evolution = "mackogneur"
    self.pv = 160
    self.maxSpeed = 145
    self.type = PokemonTypes.GROUND
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/machopeur/icon.png")

    self.attack = {
        [1] = {
            name = "Balayage",
            damage = 20
        },
        [2] = {
            name = "Poing-Karaté",
            damage = 40
        },
        [3] = {
            name = "Frappe Atlas",
            damage = 60
        }
    }
end

function Machopeur:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 1, current = 1, img = {}, rate = 0.2}
    for i=1,animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/machopeur/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/machopeur/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/machopeur/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/machopeur/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/machopeur/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Machopeur:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Machopeur:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Machopeur