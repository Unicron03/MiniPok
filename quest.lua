
local Quest = {}

local Button = require("button")

function Quest:load()
    self.img = love.graphics.newImage("assets/ui/quest/panel.png")
    self.scale = 1
    self.width = self.img:getWidth() * self.scale
    self.height = self.img:getHeight() * self.scale

    self.affPanel = false
    self.enablePanel = true

    self.questBoxX = love.graphics.getWidth() * 0.5
    self.questBoxY = love.graphics.getHeight() * 0.53

    self.offsetX = 135
    self.offsetY = 48

    self:loadStats()

    self.stats = {Player.quest.evolution, Player.quest.dungeon, Player.quest.kill}
    self.statsMax = {self.evolution[self.evolution[4]], self.dungeon[self.dungeon[4]], self.kill[self.kill[4]]}

    self.typeCallback = {"evolution", "dungeon", "kill"}
    self:initButtons()

    self.font = love.graphics.newFont("assets/glossyShine.ttf", 96)
end

function Quest:initButtons()
    self.buttons = {}

    for i=1, #self.typeCallback do
        local x = (self.questBoxX / 0.725 - self.width / 2) + self.offsetX
        local y = ((self.questBoxY - self.height / 2) + (i-1) * GUI.font:getHeight() * 2) + self.offsetY

        local newButton = Button.new(x, y, 120, GUI.font:getHeight() + 10, 1, nil, function() self:statsCallback(self.typeCallback[i]) end,
            self.stats[i].." / "..self.statsMax[i], nil, false
        )

        table.insert(self.buttons, newButton)
    end
end

function Quest:statsCallback(elmCallback)
    if self:isQuestAble(elmCallback) and not self[elmCallback][5] then
        Sound:play("quest")
        self[elmCallback][4] = self[elmCallback][4] + 1

        if self[elmCallback][4] == 4 then
            self[elmCallback][5] = true
            self[elmCallback][4] = 3
        end
    else
        Sound:play("error")
    end

    self:updDisplayQuest()
    self:updActualStatsQuest()
end

function Quest:loadStats()
    -- tier1, tier2, tier3, nvTier, bouton
    self.evolution = {1, 5, 20, 1, false}
    self.dungeon = {3, 10, 30, 1, false}
    self.kill = {5, 15, 50, 1, false}
end

function Quest:update(dt)
end

function Quest:isQuestAble(quest)
    return Player.quest[quest] >= self[quest][self[quest][4]]
end

function Quest:updActualStatsQuest()
    for i, button in ipairs(self.buttons) do
        self.stats[i], self.statsMax[i] = Player.quest[self.typeCallback[i]], self[self.typeCallback[i]][self[self.typeCallback[i]][4]]
        button.text = self[self.typeCallback[i]][5] and ("Finished") or (self.stats[i].." / "..self.statsMax[i])
    end
end

function Quest:updDisplayQuest()
    self.quest = {}

    if self.evolution[5] then
        table.insert(self.quest, "• Evolve pok")
    else
        table.insert(self.quest, "• Evolve "..self.evolution[self.evolution[4]].." pok")
    end
    
    if self.dungeon[5] then
        table.insert(self.quest, "• Beat dungeons")
    else
        table.insert(self.quest, "• Beat "..self.dungeon[self.dungeon[4]].." dungeons")
    end

    if self.kill[5] then
        table.insert(self.quest, "• Kill pok")
    else
        table.insert(self.quest, "• Kill "..self.kill[self.kill[4]].." poks")
    end
end

function Quest:desactiveButtons()
    for i, button in ipairs(self.buttons) do
        button.canClick = false
    end
end

function Quest:changeState()
    if self.enablePanel then
        self.questBoxX = love.graphics.getWidth() * 0.5
        self.questBoxY = love.graphics.getHeight() * 0.53

        self:updDisplayQuest()
        self:updActualStatsQuest()

        local state = self.affPanel
        GUI:desactivePanels()
        self.affPanel = not state

        for i, button in ipairs(self.buttons) do
            button.canClick = not state
        end
    end
end

function Quest:draw()
    if self.affPanel then
        love.graphics.draw(self.img, self.questBoxX, self.questBoxY, 0, self.scale + 0.2, self.scale, self.width / 2, self.height / 2)

        for i=1, #self.stats do
            local x = (self.questBoxX / 1.25 - self.width / 2) + self.offsetX
            local y = ((self.questBoxY - self.height / 2) + (i-1)*GUI.font:getHeight() * 2) + self.offsetY
            love.graphics.print(self.quest[i], x, y)
        end

        love.graphics.setFont(self.font)
        local text = "Quest"
        local x = love.graphics:getWidth() * 0.5 - self.font:getWidth(text) * 0.5
        local y = self.questBoxY - self.height * 0.5 - self.font:getHeight(text) * 0.5
        love.graphics.setColor(239/255,217/255,225/255,1)
        love.graphics.print(text, x + 5, y + 5)
        love.graphics.setColor(234/255,132/255,85/255,1)
        love.graphics.print(text, x, y)
        love.graphics.setFont(GUI.font)

        self:drawButtons()
    end
end

function Quest:drawButtons()
    for i, button in ipairs(self.buttons) do
        if self[self.typeCallback[i]][5] then
            love.graphics.setColor(153/255, 153/255, 151/255, 0.8)
        elseif self:isQuestAble(self.typeCallback[i]) then
            love.graphics.setColor(0, 1, 0, 0.7)
        else
            love.graphics.setColor(1, 0, 0, 0.7)
        end

        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
        love.graphics.setColor(1, 1, 1)

        button:draw()
    end
end

return Quest