
local GUI = {}

local Button = require("button")
local PopUp = require("popUp")

function GUI:load()
    self.panel = love.graphics.newImage("assets/ui/inventory/panel.png")
    self.slot = love.graphics.newImage("assets/ui/inventory/slot.png")
    self.fightPanel = love.graphics.newImage("assets/ui/fightPanel.png")
    self.fightSlot = {
        img = love.graphics.newImage("assets/ui/fightSlot.png"),
        width = love.graphics.newImage("assets/ui/fightSlot.png"):getWidth(),
        height = love.graphics.newImage("assets/ui/fightSlot.png"):getHeight()
    }
    self.icon = {
        bag = love.graphics.newImage("assets/ui/inventory/bag.png"),
        heart = love.graphics.newImage("assets/ui/icon/heart.png"),
        button = {
            start = love.graphics.newImage("assets/ui/button/start.png"),
            info = love.graphics.newImage("assets/ui/button/info.png"),
            webproject = love.graphics.newImage("assets/ui/button/webproject.png"),
            back = love.graphics.newImage("assets/ui/button/back.png"),
            exit = love.graphics.newImage("assets/ui/button/exit.png"),
            music_on = love.graphics.newImage("assets/ui/button/music_on.png"),
            music_off = love.graphics.newImage("assets/ui/button/music_off.png"),
            effect_on = love.graphics.newImage("assets/ui/button/effect_on.png"),
            effect_off = love.graphics.newImage("assets/ui/button/effect_off.png"),
            normal = love.graphics.newImage("assets/ui/button/normal.png"),
            locked = love.graphics.newImage("assets/ui/button/locked.png"),
        }
    }

    self.panelGlossy = {
        img = love.graphics.newImage("assets/ui/quest/panel.png"),
        width = love.graphics.newImage("assets/ui/quest/panel.png"):getWidth(),
        height = love.graphics.newImage("assets/ui/quest/panel.png"):getHeight(),
        x = love.graphics.getWidth() * 0.5,
        y = love.graphics.getHeight() * 0.53
    }

    self.sky = {img = love.graphics.newImage("assets/tiles/sky.png")}
    for i=1, math.floor(MapWidth/self.sky.img:getWidth())+2 do
        table.insert(self.sky, {x = self.sky.img:getWidth()*(0.5*(i-1)), y = -self.sky.img:getHeight()*(i-1)})
    end

    self.inventory = {
        slot = {}
    }

    self.tooltip = {
        active = false,
        x = 0,
        y = 0,
        index = 0
    }

    self.tooltipButton = {
        [1] = {
            text = "Drop 1 item",
            callback = function()
                Inventory:dropFromInventory(Inventory.inventory[self.tooltip.index].id, 1, Player.x, Player.y, Player.width)
                self:resetTooltip()
            end,
            button = nil
        },
        [2] = {
            text = "Drop all items",
            callback = function()
                Inventory:dropFromInventory(Inventory.inventory[self.tooltip.index].id, "all", Player.x, Player.y, Player.width)
                self:resetTooltip()
            end,
            button = nil
        },
        [3] = {
            text = "Destroy 1 item",
            callback = function()
                Inventory:removeFromInventory(self.tooltip.index, 1)
                self:resetTooltip()
            end,
            button = nil
        },
        [4] = {
            text = "Destroy all items",
            callback = function()
                Inventory:removeFromInventory(self.tooltip.index, "all")
                self:resetTooltip()
            end,
            button = nil
        },
        [5] = {
            text = "Equip",
            callback = function()
                Inventory:assignedToolToToolbelt(self.tooltip.index)
                self:resetTooltip()
            end,
            button = nil
        },
        [6] = {
            text = "Place",
            callback = function()
                Inventory:placePlottable(self.tooltip.index)
                self:resetTooltip()
                self:desactivePanels()
            end,
            button = nil
        },
        [7] = {
            text = "Equip",
            callback = function()
                Inventory:assignedPlantToBelt(self.tooltip.index)
                self:resetTooltip()
            end,
            button = nil
        },
        [8] = {
            text = "Consume",
            callback = function()
                Player:consumeItem(self.tooltip.index)
                self:resetTooltip()
            end,
            button = nil
        }
    }

    self.fightButton = {
        [1] = {
            button = nil,
        },
        [2] = {
            button = nil,
        },
        [3] = {
            button = nil,
        },
        escape = {
            button = Button.new(love.graphics.getWidth() * 0.5 - self.fightSlot.width * 0.25,
                235, self.fightSlot.width * 0.5, self.fightSlot.height,
                1, nil, function() Player:escapeBattle() end, "Escape the fight", "You will loose the fight !", false
            )
        }
    }

    self.affPanel = {
        inventory = false,
        pokBelt = false,
        craft = false,
    }

    self.enablePanel = {
        inventory = true,
        pokBelt = true,
        craft = true,
    }

    Sound:play("launch")
    self.load = {
        hasLoaded = false,
        loadState = "charge",
        background = love.graphics.newImage("assets/background.jpeg"),
        backgroundInfo = love.graphics.newImage("assets/ui/background/info.png"),
        bar = love.graphics.newImage("assets/barScreen.png"),
        changeX = 20,
        purcent = 10,
        quad = love.graphics.newQuad(0, 0, 20, 20, love.graphics.newImage("assets/barScreen.png"):getWidth(), love.graphics.newImage("assets/barScreen.png"):getHeight()),
        x = love.graphics.getHeight()*0.5 - (love.graphics.newImage("assets/barScreen.png"):getWidth())*0.5,
        y = love.graphics.getHeight() - 115,
        buttons = {
            start = Button.new(love.graphics.getWidth()*0.5 - (self.icon.button.start:getWidth()*0.65)*1.7, love.graphics.getHeight() - 115,
                    self.icon.button.start:getWidth()*0.65, self.icon.button.start:getHeight()*0.65, 0.65,
                    self.icon.button.start, function()
                        if self.load.hasLoaded then
                            remuseGame()
                        else
                            self.load.loadState = "starter"
                        end
                        Sound:play("click") 
                    end, nil, "Start the game", false
                ),
            info = Button.new(love.graphics.getWidth()*0.5 - (self.icon.button.start:getWidth()*0.65)*0.7, love.graphics.getHeight() - 115,
                    self.icon.button.info:getWidth()*0.65, self.icon.button.info:getHeight()*0.65, 0.65,
                    self.icon.button.info, function() self.load.loadState = "info" Sound:play("click") end, nil, "Open input panel", false
                ),
            webproject = Button.new(love.graphics.getWidth()*0.5 + (self.icon.button.start:getWidth()*0.65)*0.3, love.graphics.getHeight() - 115,
                    self.icon.button.webproject:getWidth()*0.65, self.icon.button.webproject:getHeight()*0.65, 0.65,
                    self.icon.button.webproject, function() love.system.openURL("https://github.com/Unicron03/RushOfLands") Sound:play("click") end, nil, "Open the website project", false
                ),
            exit = Button.new(love.graphics.getWidth()*0.5 + (self.icon.button.exit:getWidth()*0.65)*1.3, love.graphics.getHeight() - 115,
                    self.icon.button.exit:getWidth()*0.65, self.icon.button.exit:getHeight()*0.65, 0.65,
                    self.icon.button.exit, function() love.event.quit(0) Sound:play("click") end, nil, "Close the game", false
                ),
            music = Button.new(25, 25,
                    self.icon.button.music_on:getWidth()*0.65, self.icon.button.music_on:getHeight()*0.65, 0.65,
                    self.icon.button.music_on, function() Sound:switchMusic() Sound:play("click") end, nil, "Turn on/off the musics", false
                ),
            effect = Button.new(25, self.icon.button.effect_on:getHeight()*0.65,
                    self.icon.button.effect_on:getWidth()*0.65, self.icon.button.effect_on:getHeight()*0.65, 0.65,
                    self.icon.button.effect_on, function() Sound:switchEffect() Sound:play("click") end, nil, "Turn on/off the effects", false
                )
        },
        buttonsInfo = {
            back = Button.new(love.graphics.getWidth()*0.5 - (self.icon.button.start:getWidth()*0.65)*0.25, love.graphics.getHeight() - 115,
                    self.icon.button.back:getWidth()*0.65, self.icon.button.back:getHeight()*0.65, 0.65,
                    self.icon.button.back, function() self.load.loadState = "buttons" Sound:play("click") end, nil, "Return to menu", false
                )
        },
        starter = {
            pokChoice = nil,
            choose = Button.new(love.graphics.getWidth()*0.5 - (self.icon.button.start:getWidth()*0.65)*0.65, love.graphics.getHeight() - 200,
                    self.icon.button.locked:getWidth()*0.65, self.icon.button.locked:getHeight()*0.65, 0.65,
                    self.icon.button.locked, function()
                        if self.load.starter.pokChoice ~= nil then
                            initGame(self.load.starter.pokChoice) 
                            self.load.hasLoaded = true
                            Sound:play("click")
                        end
                        end, "Locked", "Select a pok to play", false
                ),
            pok = {
                [1] = {
                    button = Button.new(love.graphics.getWidth()*0.5 - (self.slot:getWidth()*0.65), love.graphics.getHeight() - 400,
                        self.slot:getWidth()*0.65, self.slot:getHeight()*0.65, 0.65,
                        self.slot, function() self.load.starter.pokChoice = "Bulbizarre" Sound:play("click") end, nil, "Choose Bulbizarre", false
                    ),
                    icon = love.graphics.newImage("assets/pok/bulbizarre/icon.png"),
                    name = "Bulbizarre",
                },
                [2] = {
                    button = Button.new(love.graphics.getWidth()*0.5 - (self.slot:getWidth()*0.65)*0.25, love.graphics.getHeight() - 400,
                        self.slot:getWidth()*0.65, self.slot:getHeight()*0.65, 0.65,
                        self.slot, function() self.load.starter.pokChoice = "Carapuce" Sound:play("click") end, nil, "Choose Carapuce", false
                    ),
                    icon = love.graphics.newImage("assets/pok/carapuce/icon.png"),
                    name = "Carapuce",
                },
                [3] = {
                    button = Button.new(love.graphics.getWidth()*0.5 + (self.slot:getWidth()*0.65)*0.5, love.graphics.getHeight() - 400,
                        self.slot:getWidth()*0.65, self.slot:getHeight()*0.65, 0.65,
                        self.slot, function() self.load.starter.pokChoice = "Salameche" Sound:play("click") end, nil, "Choose Salameche", false
                    ),
                    icon = love.graphics.newImage("assets/pok/salameche/icon.png"),
                    name = "Salameche",
                }
            }
        }
    }

    self.drawCraftPanel = false

    self.font = love.graphics.newFont("assets/bit.ttf", 36)
    self.fontGlossy = love.graphics.newFont("assets/glossyShine.ttf", 96)
    love.graphics.setFont(self.font)
end

function GUI:resetSlot()
    -- Supprime les slots de l'inventaire (modif)

    for i, slot in ipairs(self.inventory.slot) do
        slot:remove()
    end

    self.inventory.slot = {}
end

function GUI:resetTooltip()
    -- Supprime les boutons du tooltip (modif)

    self.tooltip.active = false

    for i=1, #self.tooltipButton do
        if(self.tooltipButton[i].button ~= nil) then
            self.tooltipButton[i].button:remove()
        end

        self.tooltipButton[i].button = nil
    end
end

function GUI:enablePanels()
    Shop.enablePanel = true
    Quest.enablePanel = true
    
    for key, _ in pairs(self.enablePanel) do
        self.enablePanel[key] = true
    end
end

function GUI:disablePanels()
    PopUp:disableAll()
    self:desactivePanels()
    Shop.enablePanel = false
    Shop:desactiveButtons()
    Quest.enablePanel = false
    Quest:desactiveButtons()

    for key, _ in pairs(self.enablePanel) do
        self.enablePanel[key] = false
    end

    for i=1, #CraftableItems do
        if CraftableItems[i].button ~= nil then
            CraftableItems[i].button.canClick = false
        end
    end
end

function GUI:desactivePanels()
    PopUp:disableAll()
    Shop.affPanel = false
    Shop:desactiveButtons()
    Quest.affPanel = false
    Quest:desactiveButtons()
    
    for key, _ in pairs(self.affPanel) do
        self.affPanel[key] = false
    end

    for i=1, #CraftableItems do
        if CraftableItems[i].button ~= nil then
            CraftableItems[i].button.canClick = false
        end
    end
end

function GUI:isPanelActive()
    if Shop.affPanel or Quest.affPanel then
        return true
    end

    for key, _ in pairs(self.affPanel) do
        if self.affPanel[key] then
            return true
        end
    end

    return false
end

function GUI:setTooltipCoords(x, y)
    self.tooltip.x = x
    self.tooltip.y = y
end

function GUI:update(dt)
    if self.load.loadState == "charge" then self:updateLoad(dt) end
    self:updateSkyCoords(dt)
end

function GUI:updateLoad(dt)
    self:disablePanels()
    self.load.changeX = self.load.changeX + 60 * dt
    self.load.purcent = math.floor(self.load.changeX + 1) / 2
    self.load.quad = love.graphics.newQuad(0, 0, self.load.changeX, 20, self.load.bar:getWidth(), self.load.bar:getHeight())

    if self.load.purcent >= 100 then
        self.load.loadState = "buttons"
    end
end

function GUI:updateSkyCoords(dt)
    local FLOATING_SPEED = 10

    for i, sky in ipairs(self.sky) do
        sky.x = sky.x + -FLOATING_SPEED * dt
        sky.y = sky.y + FLOATING_SPEED * dt

        if sky.y >= self.sky.img:getHeight() then
            sky.x = self.sky.img:getWidth() * 0.5
            sky.y = -self.sky.img:getHeight()
        end
    end
end

function GUI:clearPopup()
    for i=1, #CraftableItems do
        if CraftableItems[i].button ~= nil then
            CraftableItems[i].button.popUp.canAff = false
        end
    end
end

function GUI:clearPopupOfFightPanel()
    -- Désactive l'affichage des popUp pour le menu de combat

    for i=1,#self.fightButton do
        self.fightButton[i].button.popUp.canAff = false
    end

    self.fightButton.escape.button.popUp.canAff = false
end

function GUI:draw()
    if self.affPanel.pokBelt and self.enablePanel.pokBelt then self:pokBelt() end
    if self.affPanel.inventory and self.enablePanel.inventory then
        self:Inventory()
    else
        self:resetSlot()
        self:resetTooltip()
    end

    self:drawTooltipPanel()
    self:drawTooltipButtons()

    if Map.map ~= "dungeon" and GUI.load.loadState == "game" then self:drawToolbelt() end

    if self.affPanel.craft and self.enablePanel.craft then self:drawCraft() end
    if Player.battle.inBattle then self:drawBattle() end
    if Player.fight.inFight then self:drawFight() end

    if Map.map ~= "dungeon" then self:drawStats() end
    if self.load.loadState ~= "game" then self:drawLoad() end
    -- self:drawSky()
end

function GUI:drawKeyBindings()
    local padding = 20
    local startX = 80
    local startY = 240
    local lineHeight = self.font:getHeight() * 1.5
    local maxPerLine = 2

    local currentX = startX
    local currentY = startY
    local count = 0

    for key, data in pairs(Player.key) do
        local text = "["..data.bind.."] : "..data.description
        love.graphics.print(text, currentX, currentY)

        count = count + 1
        if count % maxPerLine == 0 then
            currentX = startX
            currentY = currentY + lineHeight
        else
            currentX = currentX + (love.graphics.getWidth() - padding * 2) / maxPerLine
        end
    end
end

function GUI:drawLoad()
    if self.load.loadState == "info" then
        love.graphics.draw(self.load.backgroundInfo, 0, 0, 0, love.graphics.getWidth() / self.load.backgroundInfo:getWidth(), love.graphics.getHeight() / self.load.backgroundInfo:getHeight())
        
        love.graphics.setFont(self.fontGlossy)
        local text = "Key Board"
        local x = love.graphics:getWidth() * 0.5 - self.fontGlossy:getWidth(text) * 0.5
        local y = 100
        love.graphics.setColor(239/255,217/255,225/255,1)
        love.graphics.print(text, x + 5, y + 5)
        love.graphics.setColor(234/255,132/255,85/255,1)
        love.graphics.print(text, x, y)
        love.graphics.setFont(self.font)
        love.graphics.setColor(1, 1, 1)
    elseif self.load.loadState ~= "game" and self.load.loadState ~= "starter" then
        love.graphics.draw(self.load.background, 0, 0, 0, love.graphics.getWidth() / self.load.background:getWidth(), love.graphics.getHeight() / self.load.background:getHeight())
    
        love.graphics.setFont(self.fontGlossy)
        local text = "MiniPok"
        local x = love.graphics:getWidth() * 0.65
        local y = 100
        love.graphics.setColor(239/255,217/255,225/255,1)
        love.graphics.print(text, x + 5, y + 5)
        love.graphics.setColor(234/255,132/255,85/255,1)
        love.graphics.print(text, x, y)
        love.graphics.setFont(self.font)
        love.graphics.setColor(1, 1, 1)
    end

    if self.load.loadState == "charge" then
        love.graphics.draw(self.load.bar, self.load.quad, self.load.x, self.load.y, 0, 3, 3)
        love.graphics.print(self.load.purcent.." %", self.load.x + 15, self.load.y + 12)
    elseif self.load.loadState == "buttons" or self.load.loadState == "pause" then
        PopUp:disableAll()
        self.load.buttonsInfo.back.canClick = false
        for i, button in pairs(self.load.buttons) do
            button.canClick = true
            button:draw()
        end
    elseif self.load.loadState == "info" then
        PopUp:disableAll()
        for i, button in pairs(self.load.buttons) do
            button.canClick = false
        end
        self.load.buttonsInfo.back.canClick = true
        self.load.buttonsInfo.back:draw()
        self:drawKeyBindings()
    elseif self.load.loadState == "starter" then
        PopUp:disableAll()
        for i, button in pairs(self.load.buttons) do
            button.canClick = false
        end

        local panel = self.panelGlossy
        love.graphics.draw(panel.img, panel.x, panel.y, 0, 1.2, 1, panel.width / 2, panel.height / 2)

        love.graphics.setFont(self.fontGlossy)
        local text = "Starter"
        local x = love.graphics:getWidth() * 0.5 - self.fontGlossy:getWidth(text) * 0.5
        local y = panel.y - panel.height * 0.5 - self.fontGlossy:getHeight(text) * 0.5
        love.graphics.setColor(239/255,217/255,225/255,1)
        love.graphics.print(text, x + 5, y + 5)
        love.graphics.setColor(234/255,132/255,85/255,1)
        love.graphics.print(text, x, y)
        love.graphics.setFont(self.font)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Choose your starter and press the\nbutton to play !", x - 110, y + 130)

        self.load.starter.choose.canClick = true
        self.load.starter.choose:draw()

        for i, pok in pairs(self.load.starter.pok) do
            pok.button.canClick = true
            pok.button:draw()

            local slotWidth = self.icon.button.start:getWidth()*0.65
            local scale = math.min(slotWidth * 0.7 / pok.icon:getWidth(), slotWidth * 0.7 / pok.icon:getHeight())
            local offsetX = (slotWidth - pok.icon:getWidth() * scale) / 2
            local x = 370 + 125 * (i-1)
            love.graphics.draw(pok.icon, x + offsetX, 335, 0, scale, scale)

            if self.load.starter.pokChoice == pok.name then
                love.graphics.setColor(1, 1, 0)
                love.graphics.rectangle("line", x - 1, 317, slotWidth, slotWidth, 2, 2)
                love.graphics.setColor(1, 1, 1)

                self.load.starter.choose.img = self.icon.button.normal
                self.load.starter.choose.text = "GO !"
                self.load.starter.choose.popUp:remove()
            end
        end
    end
end

function GUI:drawStats()
    local stats = Player.stats

    love.graphics.rectangle("line", 10, 10, 200, 20)
    local progress = stats.hunger.current / stats.hunger.max
    love.graphics.setColor(1 - progress, progress, 0)
    love.graphics.rectangle("fill", 11, 11, 198 * progress, 18)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Hunger", 220, 3)

    love.graphics.rectangle("line", 10, 50, 200, 20)
    local progress = stats.thirst.current / stats.thirst.max
    love.graphics.setColor(1 - progress, progress, 0)
    love.graphics.rectangle("fill", 11, 51, 198 * progress, 18)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Thirst", 220, 43)

    love.graphics.rectangle("line", 10, 90, 200, 20)
    local progress = stats.health.current / stats.health.max
    love.graphics.setColor(1 - progress, progress, 0)
    love.graphics.rectangle("fill", 11, 91, 198 * progress, 18)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Health", 220, 83)
end

function GUI:drawBattle()
    local x = love.graphics.getWidth() * 0.5 - self.fightPanel:getWidth() * 0.5
    local y = love.graphics.getHeight() * 0.5 - self.fightPanel:getHeight() * 0.5

    love.graphics.draw(self.fightPanel, x, y)

    local slotWidth = 98
    local scale = math.min(slotWidth / Player.myPokemon.icon:getWidth(), slotWidth / Player.myPokemon.icon:getHeight())
    local offsetX = (slotWidth - Player.myPokemon.icon:getWidth() * scale) / 2 + 52
    local offsetY = (slotWidth - Player.myPokemon.icon:getHeight() * scale) / 2 + 52
    love.graphics.draw(Player.myPokemon.icon, x + offsetX, y + offsetY, 0, scale, scale)

    local scale = math.min(slotWidth / Player.battle.enemy.icon:getWidth(), slotWidth / Player.battle.enemy.icon:getHeight())
    local offsetX = (slotWidth - Player.battle.enemy.icon:getWidth() * scale) / 2 + 398
    local offsetY = (slotWidth - Player.battle.enemy.icon:getHeight() * scale) / 2 + 52
    love.graphics.draw(Player.battle.enemy.icon, x + offsetX, y + offsetY, 0, scale, scale)

    love.graphics.draw(Player.myPokemon.type.icon, x + 47, y + 168, 0, 1.5, 1.5)
    love.graphics.draw(Player.battle.enemy.type.icon, x + 393, y + 168, 0, 1.5, 1.5)

    love.graphics.print(Player.battle.life.current, x + 76, y + 163)
    love.graphics.print(Player.battle.enemy.pv, x + 422, y + 163)

    love.graphics.draw(self.icon.heart, x + 123, y + 168, 0, 1.9, 1.9)
    love.graphics.draw(self.icon.heart, x + 469, y + 168, 0, 1.9, 1.9)

    love.graphics.draw(self.fightSlot.img, love.graphics.getWidth() * 0.5 - self.fightSlot.width * 0.25, 240, 0, 0.5, 1)

    for i=1,#self.fightButton do
        local yOffset = 320 + (self.fightSlot.height * 0.65 + 70) * (i-1)

        if self.fightButton[i].button == nil then
            self.fightButton[i].button = Button.new(love.graphics.getWidth() * 0.5 - self.fightSlot.width * 0.5,
                y + yOffset, self.fightSlot.width, self.fightSlot.height,
                1, nil, function() Player:sendAttackInBattle(Player.myPokemon.attack[i].damage, "enemy", 0) end, nil, "Send an attack", true)
        else
            love.graphics.draw(self.fightSlot.img, love.graphics.getWidth() * 0.5 - self.fightSlot.width * 0.5, y + yOffset)

            local attack = Player.myPokemon.attack[i].name.." | "..Player.myPokemon.attack[i].damage
            love.graphics.print(attack, x + 75, y + yOffset + 13)
            love.graphics.draw(self.icon.heart, x + 82 + self.font:getWidth(attack), y + yOffset + 18, 0, 1.9, 1.9)
            self.fightButton[i].button:draw()
        end
    end

    self.fightButton.escape.button:draw()
end

function GUI:drawFight()
    local scale = 3
    local x = love.graphics.getWidth() - 10 - self.icon.heart:getWidth() * scale
    love.graphics.draw(self.icon.heart, x, 10, 0, scale, scale)
    love.graphics.print(Player.fight.life.current, x - self.font:getWidth(Player.fight.life.current) - 10, 15)
end

function GUI:drawCraft()
    local nbInLine = 5
    local scale = 0.4
    local slotWidth = self.slot:getWidth() * scale
    local slotHeight = self.slot:getHeight() * scale
    local spacing = 0.15 * slotWidth
    local panel = self.panelGlossy

    love.graphics.draw(panel.img, panel.x, panel.y, 0, 1.2, 1, panel.width / 2, panel.height / 2)

    for i=1, #CraftableItems do
        local x = panel.x - panel.width * 0.5 + ((i - 1) % nbInLine) * (slotWidth + spacing)
        local y = panel.y - panel.height * 0.41 + math.floor((i - 1) / nbInLine) * (slotHeight + spacing)
        local textPopup = CraftableItems[i].item.name

        for j=1, #CraftableItems[i].receap do
            textPopup = textPopup..("\n - "..CraftableItems[i].receap[j].item.name.." x "..CraftableItems[i].receap[j].quantity)
        end        

        if(CraftableItems[i].button == nil) then
            CraftableItems[i].button = Button.new(x, y, slotWidth, slotHeight, 1, love.graphics.newImage("assets/ui/inventory/slot.png"),
            function() Inventory:TryToCraftItem(CraftableItems[i], Player.x, Player.y) end, nil, textPopup, true)
        end

        if(CraftableItems[i].allowToCraft) then
            if Inventory:haveListItem(CraftableItems[i].receap) then
                love.graphics.setColor(0, 1, 0, 0.6)
            else
                love.graphics.setColor(1, 0, 0, 0.6)
            end
        else
            love.graphics.setColor(1, 0, 0, 0.6)
        end
        CraftableItems[i].button.canClick = true
        CraftableItems[i].button:draw()
        love.graphics.setColor(1, 1, 1)

        local scaleX = (slotWidth * 0.8) / CraftableItems[i].item.img:getWidth()
        local scaleY = (slotWidth * 0.8) / CraftableItems[i].item.img:getHeight()
        local scale = math.min(scaleX, scaleY)
        local offsetX = (slotWidth - CraftableItems[i].item.img:getWidth() * scale) / 2
        local offsetY = (slotHeight - CraftableItems[i].item.img:getHeight() * scale) / 2
        love.graphics.draw(CraftableItems[i].item.img, x + offsetX, y + offsetY, 0, scale, scale)
    end

    love.graphics.setFont(self.fontGlossy)
    local text = "Craft"
    local x = love.graphics:getWidth() * 0.5 - self.fontGlossy:getWidth(text) * 0.5
    local y = panel.y - panel.height * 0.5 - self.fontGlossy:getHeight(text) * 0.5
    love.graphics.setColor(239/255,217/255,225/255,1)
    love.graphics.print(text, x + 5, y + 5)
    love.graphics.setColor(234/255,132/255,85/255,1)
    love.graphics.print(text, x, y)
    love.graphics.setFont(self.font)
    love.graphics.setColor(1, 1, 1)
end

function GUI:drawSky()
    love.graphics.setColor(0, 0, 0, 0.3)
    for i, sky in ipairs(self.sky) do
        love.graphics.draw(self.sky.img, sky.x, sky.y)
    end
    love.graphics.setColor(1, 1, 1)
end

function GUI:drawToolbelt()
    local scale = 0.3
    local slotWidth = self.slot:getWidth() * scale
    local slotHeight = self.slot:getHeight() * scale

    love.graphics.draw(self.panel, 10, love.graphics:getHeight() * 0.25, 0, 0.34, 360 / self.panel:getHeight())

    for i=1, #Inventory.toolbelt do
        local y = love.graphics:getHeight() * 0.25 + 17 + (6 + self.slot:getHeight() * scale) * (i-1)

        love.graphics.draw(self.slot, 15, y, 0, scale, scale)

        if(Inventory.toolbelt[i].button == nil) then
            local nameItem = (Inventory.toolbelt[i].item ~= nil) and (Inventory.toolbelt[i].item.name) or (nil)

            Inventory.toolbelt[i].button = Button.new(15, y, self.slot:getWidth() * scale, self.slot:getHeight() * scale, 1,
                nil, function() Inventory:desequipTool(Inventory.toolbelt[i]) end, nil, nameItem, true)
        else
            Inventory.toolbelt[i].button:draw()
        end

        if(Inventory.toolbelt[i].id ~= nil) then
            local scale = math.min((slotWidth * 0.8) / Inventory.toolbelt[i].icon:getWidth(), (slotWidth * 0.8) / Inventory.toolbelt[i].icon:getHeight())
            local offsetX = (slotWidth - Inventory.toolbelt[i].icon:getWidth() * scale) / 2
            local offsetY = (slotHeight - Inventory.toolbelt[i].icon:getHeight() * scale) / 2
            love.graphics.draw(Inventory.toolbelt[i].icon, 15 + offsetX, y + offsetY, 0, scale, scale)

            local text = tostring(Inventory.toolbelt[i].item.durability)
            local textWidth = love.graphics.getFont():getWidth(text)
            local textX = 15 + slotWidth * 0.94 - textWidth -- Centre le texte horizontalement
            
            love.graphics.print(Inventory.toolbelt[i].item.durability, textX, y + slotHeight * 0.55)
        end
    end

    local y = love.graphics:getHeight() * 0.25 + 17 + (6 + self.slot:getHeight() * scale) * #Inventory.toolbelt
    local scale = math.min((slotWidth * 0.8) / self.icon.bag:getWidth(), (slotWidth * 0.8) / self.icon.bag:getHeight())
    local offsetX = (slotWidth - self.icon.bag:getWidth() * scale) / 2
    local offsetY = (slotHeight - self.icon.bag:getHeight() * scale) / 2
    love.graphics.draw(self.slot, 15, y, 0, 0.3, 0.3)
    love.graphics.draw(self.icon.bag, 15 + offsetX, y + offsetY, 0, scale, scale)
    
    if(Inventory.slotPlant.id ~= nil) then
        local scale = math.min((slotWidth * 0.8) / Inventory.slotPlant.icon:getWidth(), (slotWidth * 0.8) / Inventory.slotPlant.icon:getHeight())
        local offsetX = (slotWidth - Inventory.slotPlant.icon:getWidth() * scale) / 2
        local offsetY = (slotHeight - Inventory.slotPlant.icon:getHeight() * scale) / 2
        love.graphics.draw(Inventory.slotPlant.icon, 15 + offsetX, y + offsetY, 0, scale, scale)
        love.graphics.print(Inventory.slotPlant.quantity, 15 + 8, y)
    end
end

function GUI:drawTooltipPanel()
    -- Affiche le panel du tooltip

    if(self.tooltip.active) then
        love.graphics.draw(self.panel, self.tooltip.x, self.tooltip.y, 0, 1, 0.185 * (4 + #Inventory.inventory[self.tooltip.index].item.itemType.extraButtons))
    end
end

function GUI:drawTooltipButtons()
    -- Affiche les boutons du tooltip
 
    if(self.tooltip.active) then
        for i=1, 4 do
            if(self.tooltipButton[i].button == nil) then
                self.tooltipButton[i].button = Button.new(
                    self.tooltip.x + 10, self.tooltip.y + 15 + (self.slot:getHeight() * 0.15 + 4) * (i-1),
                    self.slot:getWidth() - 20, self.slot:getHeight() * 0.15, 1, self.slot,
                    self.tooltipButton[i].callback, self.tooltipButton[i].text, nil, true
                )
            end

            self.tooltipButton[i].button:draw()
        end

        for i, index in ipairs(Inventory.inventory[self.tooltip.index].item.itemType.extraButtons) do
            if(self.tooltipButton[index].button == nil) then
                self.tooltipButton[index].button = Button.new(
                    self.tooltip.x + 10, self.tooltip.y + 15 + (self.slot:getHeight() * 0.15 + 4) * (3+#Inventory.inventory[self.tooltip.index].item.itemType.extraButtons),
                    self.slot:getWidth() - 20, self.slot:getHeight() * 0.15, 1, self.slot,
                    self.tooltipButton[index].callback, self.tooltipButton[index].text, nil, true
                )
            end

            self.tooltipButton[index].button:draw()
        end
    end
end

function GUI:Tooltip(x, y, index)
    -- Gère affichage du tooltip

    if((self.tooltip.x == x and self.tooltip.y == y and self.tooltip.active) or Inventory.inventory[index].id == nil) then
        self.tooltip.active = false
        return
    end

    self:resetTooltip()
    self:setTooltipCoords(x, y)
    self.tooltip.index = index
    self.tooltip.active = true
end

function GUI:Inventory()
    -- Affichage de l'inventaire

    local nbInLine = 6
    local scale = 0.3
    local slotWidth = self.slot:getWidth() * scale
    local slotHeight = self.slot:getHeight() * scale
    local spacing = 0.1 * slotWidth

    local totalWidth = nbInLine * (slotWidth + spacing) + spacing * 3
    local totalHeight = math.ceil(#Inventory.inventory / nbInLine) * (slotHeight + spacing * 1.3)
    local xBase = love.graphics.getWidth() / 2 - totalWidth / 2
    local yBase = love.graphics.getHeight() * 0.15
    
    love.graphics.draw(self.panel, xBase - spacing * 3, yBase - spacing, 0, (totalWidth + 2 * spacing) / self.panel:getWidth(), (totalHeight + 2 * spacing) / self.panel:getHeight())

    -- Dessin des slots de l'inventaire
    for i, item in ipairs(Inventory.inventory) do
        local x = xBase + ((i - 1) % nbInLine) * (slotWidth + spacing)
        local y = yBase + spacing * 1.1 + math.floor((i - 1) / nbInLine) * (slotHeight + spacing)

        -- love.graphics.draw(self.slot, x, y, 0, scale, scale)
        if(self.inventory.slot[i] == nil) then
            local nameItem = (Inventory.inventory[i].item ~= nil) and (Inventory.inventory[i].item.name) or (nil)

            self.inventory.slot[i] = Button.new(x, y, slotWidth, slotHeight, 1, love.graphics.newImage("assets/ui/inventory/slot.png"),
            function() self:Tooltip(x + slotWidth, y + slotHeight, i) end, nil, nameItem, true)
        end
        self.inventory.slot[i]:draw()
        
        if(Inventory.inventory[i].icon ~= nil) then
            local scaleX = (slotWidth * 0.8) / Inventory.inventory[i].icon:getWidth()
            local scaleY = (slotWidth * 0.8) / Inventory.inventory[i].icon:getHeight()
            local scale = math.min(scaleX, scaleY)
            local offsetX = (slotWidth - Inventory.inventory[i].icon:getWidth() * scale) / 2
            local offsetY = (slotHeight - Inventory.inventory[i].icon:getHeight() * scale) / 2

            love.graphics.draw(Inventory.inventory[i].icon, x + offsetX, y + offsetY, 0, scale, scale)

            if(Inventory.inventory[i].quantity > 1) then
                love.graphics.print(Inventory.inventory[i].quantity, x + 8, y)
            end
        end
    end
end

function GUI:pokBelt()
    -- Affichage de la ceinture de pokémon du joueur

    local scale = 0.3
    local slotWidth = self.slot:getWidth() * scale
    local spacing = 0.1 * slotWidth
    local totalWidth = #Inventory.pokBelt * slotWidth + (spacing * (#Inventory.pokBelt - 1))
    local xBase = love.graphics.getWidth() / 2 - totalWidth / 2
    local y = love.graphics.getHeight() - (self.slot:getHeight() * scale) * 1.3
    
    local boundingBoxTopLeftX = xBase - 10
    local boundingBoxTopLeftY = y - 10
    local boundingBoxBottomRightX = xBase + totalWidth + 10
    local boundingBoxBottomRightY = y + self.slot:getHeight() * scale + 10
    
    love.graphics.draw(self.panel, boundingBoxTopLeftX, boundingBoxTopLeftY, 0, (boundingBoxBottomRightX - boundingBoxTopLeftX) / self.panel:getWidth(), (boundingBoxBottomRightY - boundingBoxTopLeftY) / self.panel:getHeight())

    for i = 1, #Inventory.pokBelt do
        local x = xBase + (slotWidth + spacing) * (i - 1)
        
        if i == Inventory.pokBelt.current then
            love.graphics.setColor(1, 1, 0)
            love.graphics.rectangle("line", x - 1, y - 2, self.slot:getWidth() * scale + 3, self.slot:getHeight() * scale + 5, 5, 5)
            love.graphics.setColor(1, 1, 1)
        end

        love.graphics.draw(self.slot, x, y, 0, scale, scale)

        local scale = math.min((slotWidth * 0.8) / Inventory.pokBelt[i].icon:getWidth(), (slotWidth * 0.8) / Inventory.pokBelt[i].icon:getHeight())
        local offsetX = (slotWidth - Inventory.pokBelt[i].icon:getWidth() * scale) / 2
        local offsetY = (slotWidth - Inventory.pokBelt[i].icon:getHeight() * scale) / 2
        love.graphics.draw(Inventory.pokBelt[i].icon, x + offsetX, y + offsetY, 0, scale, scale)
    end
end

return GUI