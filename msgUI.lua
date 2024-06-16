
local MsgUI = {}
MsgUI.__index = MsgUI
local ActiveMsgUIs = {}

function MsgUI.new(x, y, text, clickable, timer, callback)
    local instance = setmetatable({}, MsgUI)
    instance.text = text
    instance.width = 800 -- Largeur initiale du pop-up
    instance.height = 100 -- Hauteur initiale du pop-up
    instance.clickable = clickable or false -- Paramètre pour rendre le texte cliquable (par défaut, false)
    instance.timer = {current = 0, rate = (timer == nil) and (nil) or (timer)}
    instance.callback = callback or false 

    -- Calcul de la hauteur réelle du pop-up en fonction de la hauteur du texte
    local font = love.graphics.getFont()
    local textWidth, wrappedText = font:getWrap(instance.text, instance.width - 40) -- Marge de chaque côté du texte
    instance.height = font:getHeight() * #wrappedText + 20 -- Marge en haut et en bas du texte

    -- Si le texte est court et occupe une seule ligne, ajuste la largeur du pop-up en fonction de la longueur du texte
    if #wrappedText == 1 then
        instance.width = textWidth + 40 -- Marge de chaque côté du texte
    end

    -- Si x et y ne sont pas fournis, centrer le pop-up en bas au milieu de la fenêtre
    instance.x = x == nil and (love.graphics.getWidth() / 2 - instance.width / 2) or (x)
    instance.y = y == nil and (love.graphics.getHeight() - instance.height - 20) or (y)

    table.insert(ActiveMsgUIs, instance)
    return instance
end

function MsgUI:isTableEmpty()
    return next(ActiveMsgUIs) == nil
end

function MsgUI.removeAll()
    ActiveMsgUIs = {}
end

function MsgUI:update(dt)
    self:checkRemove(dt)
end

function MsgUI:checkRemove(dt)
    if self.timer.rate ~= nil then
        self.timer.current = self.timer.current + dt
        if self.timer.current >= self.timer.rate then
            self:remove()
        end
    end
end

function MsgUI:remove()
    for i, instance in ipairs(ActiveMsgUIs) do
        if instance == self then
            table.remove(ActiveMsgUIs, i)
            break
        end
    end
end

function MsgUI.updateAll(dt)
    for i, instance in ipairs(ActiveMsgUIs) do
        instance:update(dt)
    end
end

function MsgUI:draw()
    -- Dessiner le fond du pop-up
    love.graphics.setColor(0.2, 0.2, 0.2, 0.6) -- Couleur de fond
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Dessiner le texte à l'intérieur du pop-up
    love.graphics.setColor(1, 1, 1) -- Couleur du texte
    local font = love.graphics.getFont()
    local textWidth, wrappedText = font:getWrap(self.text, self.width - 40) -- Soustraire 40 pour laisser une marge de chaque côté du texte
    local textX = self.x + 20 -- Décalage de 20 pixels vers l'intérieur à gauche
    local textY = self.y + (self.height - font:getHeight() * #wrappedText) / 2 -- Centrer verticalement le texte

    if self.clickable then
        -- Dessiner le texte comme un bouton cliquable
        local margin = 5
        local textMargin = 10

        local mx, my = love.mouse.getPosition()
        self.isHovered = mx >= textX - margin and mx <= textX + textWidth + textMargin and my >= textY - margin and my <= textY + font:getHeight() * #wrappedText + margin

        if self.isHovered then
            love.graphics.setColor(0.1, 0.7, 0.2, 0.8)
        end
    end

    for _, line in ipairs(wrappedText) do
        love.graphics.printf(line, textX, textY, self.width - 40, "center")
        textY = textY + font:getHeight()
    end

    love.graphics.setColor(1, 1, 1)
end

function MsgUI.drawAll()
    for i, instance in ipairs(ActiveMsgUIs) do
        instance:draw()
    end
end

function MsgUI.mousepressed(x, y, button, istouch, presses)
    for _, instance in ipairs(ActiveMsgUIs) do
        if instance.clickable and instance.isHovered then
            instance:remove()
            instance.callback()
        end
    end
end

-- function MsgUI.mousepressed(x, y, button, istouch, presses)
--     for _, instance in ipairs(ActiveMsgUIs) do
--         if instance.clickable and instance.isHovered then
--             if instance.text == "Oui" then
--                 instance.removeAll()
--                 instance.callback()
--             elseif instance.text == "Non" then
--                 instance.removeAll()
--                 local newMsgUI = MsgUI.new(nil, nil, "A la revoyure", false, true) -- Crée une nouvelle instance
--                 newMsgUI.activeTimer = true -- Active le timer pour la nouvelle instance
--             end
--         end
--     end
-- end

return MsgUI