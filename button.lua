
local PopUp = require("popUp")

local Button = {}
Button.__index = Button
local ActiveSimpleButtons = {}

function Button.new(x, y, width, height, scale, img, callback, text, popUp, switchClick)
    local instance = setmetatable({}, Button)
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height
    instance.img = img
    instance.scale = scale
    instance.callback = callback
    instance.text = text or nil
    instance.isHovered = false
    instance.popUp = nil
    instance.canClick = switchClick

    if(popUp ~= nil) then
        instance.popUp = PopUp.new(popUp)
    end

    table.insert(ActiveSimpleButtons, instance)
    return instance
end

function Button:returnNbEntities()
    return #ActiveSimpleButtons
end

function Button:remove()
    for i, instance in ipairs(ActiveSimpleButtons) do
        if instance == self then
            if(instance.popUp ~= nil) then
                instance.popUp:remove()
            end

            table.remove(ActiveSimpleButtons, i)
        end
    end
end

function Button.removeAll()
    ActiveSimpleButtons = {}
end

function Button:update(dt)
    local mx, my = love.mouse.getPosition()
    self.isHovered = mx >= self.x and mx <= self.x + self.width * self.scale and my >= self.y and my <= self.y + self.height * self.scale
end

function Button:draw()
    if(self.img ~= nil) then
        love.graphics.draw(self.img, self.x, self.y, 0, self.scale * (self.width / self.img:getWidth()), self.scale * (self.height / self.img:getHeight()))
    end

    self:drawText()
    -- self:drawHitBox()
    
    if self.popUp ~= nil then
        if self.isHovered then
            self.popUp.canAff = true
        else
            self.popUp.canAff = false
        end
    end
end

function Button:drawText()
    if self.text ~= nil then
        local maxWidth = self.width * self.scale * 0.85 -- Utilisez 90% de la largeur du bouton
        local font = love.graphics.newFont("assets/bit.ttf", 36) -- Taille maximale de la police
        local textWidth, textHeight = font:getWidth(self.text), font:getHeight(self.text)

        -- Réduire la taille de la police si le texte dépasse la largeur maximale
        while textWidth > maxWidth do
            local newSize = font:getHeight() - 1
            if newSize < 8 then
                -- Taille minimale de la police pour éviter une boucle infinie
                break
            end
            font = love.graphics.newFont("assets/bit.ttf", newSize)
            textWidth, textHeight = font:getWidth(self.text), font:getHeight(self.text)
        end

        -- Centrer le texte dans le bouton
        local textX = self.x + (self.width * self.scale - textWidth) / 2
        local textY = self.y + (self.height * self.scale - textHeight) / 2

        love.graphics.setFont(font)
        love.graphics.print(self.text, textX, textY)

        love.graphics.setFont(love.graphics.newFont("assets/bit.ttf", 36))
    end
end

function Button:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
end

function Button.drawAll()
    for i, instance in ipairs(ActiveSimpleButtons) do
        instance:draw()
    end
end

function Button.updateAll(dt)
    for i, instance in ipairs(ActiveSimpleButtons) do
        instance:update(dt)
    end
end

function Button.mousepressed(x, y, button, istouch, presses)
    for _, instance in ipairs(ActiveSimpleButtons) do
        if instance.isHovered and instance.canClick then
            instance.callback(instance)
        end
    end
end

return Button