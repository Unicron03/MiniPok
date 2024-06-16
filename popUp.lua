
local PopUp = {}
PopUp.__index = PopUp
local ActivePopUps = {}

function PopUp.new(text)
    local instance = setmetatable({}, PopUp)
    instance.text = text
    instance.width = 500 -- Largeur initiale du pop-up
    instance.height = 100 -- Hauteur initiale du pop-up

    instance.canAff = false

    -- Calculer la hauteur réelle du pop-up en fonction de la hauteur du texte
    local font = love.graphics.getFont()
    local textWidth, wrappedText = font:getWrap(instance.text, instance.width - 40) -- Soustraire 40 pour laisser une marge de chaque côté du texte
    instance.height = font:getHeight() * #wrappedText + 20 -- Ajouter 20 pour laisser une marge en haut et en bas du texte

    -- Si le texte est court et occupe une seule ligne, ajuster la largeur du pop-up en fonction de la longueur du texte
    if #wrappedText == 1 then
        instance.width = textWidth + 40 -- Ajouter 40 pour laisser une marge de chaque côté du texte
    end

    instance.x, instance.y = instance:calcPos()

    table.insert(ActivePopUps, instance)
    return instance
end

function PopUp:isTableEmpty()
    return next(ActivePopUps) == nil
end

function PopUp:disableAll()
    for i, instance in ipairs(ActivePopUps) do
        instance.canAff = false
    end
end

function PopUp.removeAll()
    ActivePopUps = {}
end

function PopUp:calcPos()
    return love.mouse.getPosition()
end

function PopUp:update(dt)
    self.x, self.y = self:calcPos()
end

function PopUp:remove()
    for i, instance in ipairs(ActivePopUps) do
        if instance == self then
            table.remove(ActivePopUps, i)
            break
        end
    end
end

function PopUp.updateAll(dt)
    for i, instance in ipairs(ActivePopUps) do
        instance:update(dt)
    end
end

function PopUp:draw()
    if self.canAff then
        -- Dessiner le texte à l'intérieur du pop-up
        love.graphics.setColor(1, 1, 1) -- Couleur du texte
        local font = love.graphics.getFont()
        local textWidth, wrappedText = font:getWrap(self.text, self.width - 40) -- Soustraire 40 pour laisser une marge de chaque côté du texte
        local textX = self.x + 20 -- Décalage de 20 pixels vers l'intérieur à gauche
        local textY = self.y + (self.height - font:getHeight() * #wrappedText) / 2 -- Centrer verticalement le texte

        for _, line in ipairs(wrappedText) do
            love.graphics.printf(line, textX, textY, self.width - 40, "left")
            textY = textY + font:getHeight()
        end
    end
end

function PopUp.drawAll()
    for i, instance in ipairs(ActivePopUps) do
        instance:draw()
    end
end

return PopUp