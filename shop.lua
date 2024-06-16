
local Shop = {}

local Button = require("button")

function Shop:load()
    self.img = love.graphics.newImage("assets/ui/quest/panel.png")
    self.scale = 1
    self.width = self.img:getWidth() * self.scale
    self.height = self.img:getHeight() * self.scale

    self.affPanel = false
    self.enablePanel = true

    self.x = love.graphics.getWidth() * 0.5
    self.y = love.graphics.getHeight() * 0.53
    
    self.offsetX = 75
    self.offsetY = 65

    self.coin = {
        img = love.graphics.newImage("assets/ui/icon/coin.png"),
        width = love.graphics.newImage("assets/ui/icon/coin.png"):getWidth(),
        height = love.graphics.newImage("assets/ui/icon/coin.png"):getHeight()
    }

    self.button = {
        unclic = love.graphics.newImage("assets/ui/button/button_up.png"),
        clic = love.graphics.newImage("assets/ui/button/button_down.png"),
        scale = 1.5,
        width = nil,
        height = nil
    }
    self.button.width = self.button.unclic:getWidth() * self.button.scale
    self.button.height = self.button.unclic:getHeight() * self.button.scale

    self.max = {
        img = love.graphics.newImage("assets/ui/icon/max.png"),
        width = love.graphics.newImage("assets/ui/icon/max.png"):getWidth(),
        height = love.graphics.newImage("assets/ui/icon/max.png"):getHeight(),
    }

    self.sellLst = {"speed", "inventoryCapacity", "coinInDungeon"}

    self.trade = {
        speed = {
            img = love.graphics.newImage("assets/ui/icon/upgrade_speed.png"),
            description = "Increase the speed of your pok",
            cost = 15,
            stock = 4,
        },
        inventoryCapacity = {
            img = love.graphics.newImage("assets/ui/icon/upgrade_inventory.png"),
            description = "Increase the capacity of your pokBelt",
            cost = 10,
            stock = 3,
        },
        coinInDungeon = {
            img = love.graphics.newImage("assets/ui/icon/upgrade/coinInDungeon.png"),
            description = "Gives a bonus of coins in dungeons",
            cost = 5,
            stock = 5,
        }
    }

    self:initButtons()
end

function Shop:initButtons()
    self.buttons = {}
    self.tratedButtons = {}
    
    self.timer = {current = 0, rate = 0.15}

    for i=1, #self.sellLst do
        local x = self.x - self.width * 0.4
        local y = (self.y - self.height / 2) + i * self.offsetY + (i-1) * self.button.height * 0.5

        local newButton = Button.new(x, y, self.button.width, self.button.height, 1, self.button.unclic,
            function(button) self:shopCallback(button, self.sellLst[i]) end, nil, self.trade[self.sellLst[i]].description, false
        )

        table.insert(self.buttons, newButton)
    end
end

function Shop:playerSetBonus(bonus)
    if bonus == "speed" then
        Player.bonus.bonusSpeed = Player.bonus.bonusSpeed + 15
    elseif bonus == "inventoryCapacity" then
        Inventory.pokBelt.max = Inventory.pokBelt.max + 1
    elseif bonus == "coinInDungeon" then
        Player.bonus.coinInDungeon = Player.bonus.coinInDungeon + 2
    end

    self.trade[bonus].stock = self.trade[bonus].stock - 1
    Inventory.coin = Inventory.coin - self.trade[bonus].cost
    Sound:play("purchase")
end

function Shop:canPurchaseUpgrade(trade)
    return Inventory.coin - trade.cost >= 0 and trade.stock > 0
end

function Shop:shopCallback(button, bonus)
    if self:canPurchaseUpgrade(self.trade[bonus]) then
        self:updDisplayButton(button)
        self:playerSetBonus(bonus)
    else
        Sound:play("error")
    end
end

function Shop:updDisplayButton(button)
    button.img = self.button.clic

    table.insert(self.tratedButtons, button)
end

function Shop:update(dt)
    self:resetStateButton(dt)
end

function Shop:resetStateButton(dt)
    for i, button in ipairs(self.tratedButtons) do
        self.timer.current = self.timer.current + dt
        if self.timer.current > self.timer.rate then
            button.img = self.button.unclic
            table.remove(self.tratedButtons, i)
            self.timer.current = 0
        end
    end
end

function Shop:desactiveButtons()
    for i, button in ipairs(self.buttons) do
        button.canClick = false
    end
end

function Shop:changeState()
    if self.enablePanel then
        local PopUp = require("popUp")
        PopUp:disableAll()

        local state = self.affPanel
        GUI:desactivePanels()
        self.affPanel = not state

        for i, button in ipairs(self.buttons) do
            button.canClick = not state
        end
    end
end

function Shop:draw()
    if self.affPanel then
        love.graphics.draw(self.img, self.x, self.y, 0, self.scale + 0.2, self.scale, self.width / 2, self.height / 2)

        for i=1, #self.buttons do
            local x = self.x - self.width * 0.4 + self.button.width + 20
            local y = (self.y - self.height / 2) + i * self.offsetY + (i) * self.button.height * 0.5 - self.coin.height * 0.5

            local text = self.trade[self.sellLst[i]].cost
            love.graphics.print("x "..text, x, y)

            love.graphics.draw(self.coin.img, x + 55, y)
        end

        self:drawTitle()
        self:drawButtons()
        self:drawIcons()

        love.graphics.print("Player money : "..Inventory.coin, self.x - self.width * 0.45, self.y + self.height * 0.33)
        love.graphics.draw(self.coin.img, self.x - self.width * 0.45 + GUI.font:getWidth("Player money : "..Inventory.coin) + 5, self.y + self.height * 0.33)
    end
end

function Shop:drawTitle()
    love.graphics.setFont(GUI.fontGlossy)
    local text = "Shop"
    local x = love.graphics:getWidth() * 0.5 - GUI.fontGlossy:getWidth(text) * 0.5
    local y = self.y - self.height * 0.5 - GUI.fontGlossy:getHeight(text) * 0.5
    love.graphics.setColor(239/255,217/255,225/255,1)
    love.graphics.print(text, x + 5, y + 5)
    love.graphics.setColor(234/255,132/255,85/255,1)
    love.graphics.print(text, x, y)
    love.graphics.setFont(GUI.font)
    love.graphics.setColor(1, 1, 1)
end

function Shop:drawButtons()
    for i, button in ipairs(self.buttons) do
        button:draw()
    end
end

function Shop:drawIcons()
    for i=1, #self.buttons do
        local img = nil

        if self.trade[self.sellLst[i]].stock > 0 then
            img = self.trade[self.sellLst[i]].img
        else
            img = self.max.img
        end

        local scaleX, scaleY = (self.button.width - 20) / img:getWidth(), (self.button.height - 20) / img:getHeight()
        local x = self.x - self.width * 0.4 + self.button.width * 0.5 - (img:getWidth() * scaleX) * 0.5
        local y = (self.y - self.height / 2) + i * self.offsetY + (i) * self.button.height * 0.5 - (img:getHeight() * scaleY) * 0.5 - 4

        love.graphics.draw(img, x, y, 0, scaleX, scaleY)
    end
end

return Shop