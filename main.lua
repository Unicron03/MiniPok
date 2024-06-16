love.graphics.setDefaultFilter("nearest","nearest")

local Button = require("button")
local MsgUI = require("msgUI")
local PopUp = require("popUp")
local SolidElm = require("solidElm")
local Projectile = require("projectile")
local Particles = require("particles")

Player = require("player")
GUI = require("gui")
Sound = require("sound")
Camera = require("camera")
Harvestable = require("harvestable")
Entities = require("entities")
Items = require("items")
Enemy = require("enemy")
Objects = require("objects")
Lume = require("lume")
Map = require("map")
Utils = require("utils")
Inventory = require("inventory")
Quest = require("quest")
Shop = require("shop")

function saveGame()
    -- Sauvegarde le jeu (prototype)

    data = {}
    data.player = {
        x = Player.x,
        y = Player.y,
        canEvolve = Player.canEvolve,
        canSwitch = Player.canSwitch,
        currentPok = Player.currentPok,
        toolbelt = {},
        -- pokBelt = Player.pokBelt,
        -- inventory = Player.inventory
    }
    
    for i, v in ipairs(Player.toolbelt) do
        data.player.toolbelt[i] = {
            id = v.id,
            -- icon = v.icon,
            -- button = v.button,
            -- item = v.item
        }
    end    

    serialized = Lume.serialize(data)
    love.filesystem.write("savedata.txt", serialized)
end  

function love.load()
    -- Chargement des ressources

    math.randomseed(os.time())
    
    Harvestable.loadAssets()
    Sound:loadSong()
    Map:load()
    Player:load()
    GUI:load()
    Quest:load()
    Shop:load()

    if love.filesystem.getInfo("savedata.txt") then
        file = love.filesystem.read("savedata.txt")
        data = Lume.deserialize(file)

        Player.physics.body:setPosition(data.player.x, data.player.y)
    end

    Items.Pickaxe.new(Player.x, Player.y + 50)
end

function love.update(dt)
    -- Mise à jour du jeu

    World:update(dt)
    Player:update(dt)
    Camera:setPosition(Player.x, Player.y)
    Map:update(dt)
    GUI:update(dt)
    Quest:update(dt)
    Shop:update(dt)
    Items.updateAll(dt)
    Harvestable.updateAll(dt)
    Button.updateAll(dt)
    MsgUI.updateAll(dt)
    PopUp.updateAll(dt)
    SolidElm.updateAll(dt)
    Enemy.updateAll(dt)
    Objects.updateAll(dt)
    Projectile.updateAll(dt)
end

function love.draw()
    -- Affichage du jeu

    Map:draw()
    
    Camera:apply()
    Harvestable.drawAll()
    Objects.drawAll()
    Player:draw()
    Map:drawTextLayer()
    Items.drawAll()
    SolidElm.drawAll()
    Enemy.drawAll()
    Projectile.drawAll()

    if Map.map ~= "dungeon" then
        GUI:drawSky()
    end
    Camera:clear()

    MsgUI.drawAll()
    GUI:draw()
    Shop:draw()
    Quest:draw()
    PopUp.drawAll()
end

function beginContact(a, b, collision)
    -- Gère les entrées de collisions

    Player:beginContact(a, b, collision)
    Items.beginContactAll(a, b, collision)
    Harvestable.beginContactAll(a, b, collision)
    SolidElm.beginContact(a, b, collision)
    Enemy.beginContactAll(a, b, collision)
    Objects.beginContactAll(a, b, collision)
    Projectile.beginContact(a, b, collision)
end

function endContact(a, b, collision)
    -- Gère les sorties de collisions

    Harvestable.endContactAll(a, b, collision)
    Objects.endContactAll(a, b, collision)
end

function love.keyreleased(key)
    -- Gère l'action de relachement de touches

    if key == Player.key.affBelt.bind then
        GUI:resetSlot()
    end

    if key == Player.key.affBelt.bind and GUI.load.loadState == "game" then
        local state = GUI.affPanel.pokBelt
        GUI:desactivePanels()
        GUI.affPanel.pokBelt = not state
    end

    if key == Player.key.inventory.bind and GUI.load.loadState == "game" then
        local state = GUI.affPanel.inventory
        GUI:desactivePanels()
        GUI.affPanel.inventory = not state
    end

    if key == Player.key.escape.bind and not Player.battle.inBattle and GUI.load.loadState == "game" then
        if GUI:isPanelActive() then
            GUI:desactivePanels()
        else
            GUI.load.loadState = "buttons"
            Sound:togglePauseResume(Map.map, "pause")
        end
    end

    if key == Player.key.quest.bind and GUI.load.loadState == "game" then
        Quest:changeState()
    end

    if key == "f1" then
        saveGame()
        MsgUI.new(nil, nil, "Game saved", false, 2)
    end
 end

function love.mousepressed(x, y, button, istouch, presses)
    -- Gère les clics souris

    Button:mousepressed(x, y, button)
    MsgUI.mousepressed(x, y, button, istouch, presses)
end

function checkIsCollide(x, y, width, height)
    -- Gère la collision avec des objets physique (prototype)

    for _, harvestables in ipairs(Harvestable.returnTable()) do
        if(x>=harvestables.x-harvestables.width*0.5 and x<=harvestables.x+harvestables.width*0.5 and y>=harvestables.y-harvestables.height*0.5 and y<=harvestables.y+harvestables.height*0.5) or
            (x+width>=harvestables.x-harvestables.width*0.5 and x+width<=harvestables.x+harvestables.width*0.5 and y>=harvestables.y-harvestables.height*0.5 and y<=harvestables.y+harvestables.height*0.5) or
            (x>=harvestables.x-harvestables.width*0.5 and x<=harvestables.x+harvestables.width*0.5 and y+height>=harvestables.y-harvestables.height*0.5 and y+height<=harvestables.y+harvestables.height*0.5) or
            (x+width>=harvestables.x-harvestables.width*0.5 and x+width<=harvestables.x+harvestables.width*0.5 and y+height>=harvestables.y-harvestables.height*0.5 and y+height<=harvestables.y+harvestables.height*0.5) then
                return true
        end
    end

    return false
end