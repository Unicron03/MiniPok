
local MsgUI = require("msgUI")
local Particles = require("particles")

local Player = {}
local iconStone = love.graphics.newImage("assets/items/ressources/stone.png")

function Player:load()
    local Map = require("map")
    self.x, self.y = Map:returnSpawnCoords()
    self.width = 20
    self.height = 60
    self.r = 0
    self.rVelocity = 3
    self.xVel = 0
    self.yVel = 0
    self.acceleration = 750
    self.bonusSpeed = 0
    self.friction = 3500
    self.scaleBase = 2
    self.state = "idle"
    self.canSwitch = false
    self.timerProjectile = {current = 0, rate = 0.5, canThrow = true}

    self.bonus = {
        bonusSpeed = 0,
        coinInDungeon = 0,
    }

    self.battle = {
        inBattle = false,
        life = {current = 100, total = 100},
        enemy = nil
    }

    self.fight = {
        inFight = false,
        life = {current = 20, total = 20},
    }

    self.key = {
        top = {bind = "z", description = "Move up"},
        left = {bind = "q", description = "Move left"},
        bottom = {bind = "s", description = "Move down"},
        right = {bind = "d", description = "Move right"},
        affBelt = {bind = "b", description = "Displays PokBelt"},
        switchBelt = {bind = "i", description = "Switch pok in PokBelt"},
        inventory = {bind = "a", description = "Display inventory"},
        quest = {bind = "p", description = "Display quest"},
        escape = {bind = "escape", description = "Returns to menu"},
        
    }
    self.keyState = {
        evolution = false,
        switchBelt = false
    }

    self.color = {
        shiny = {
            r = 255,
            g = 215,
            b = 0
        },
        base = {
            r = 255,
            g = 255,
            b = 255,
            speed = 3
        }
    }

    self.fade = {
        img = love.graphics.newImage("assets/fadeout.png"),
        width = love.graphics.newImage("assets/fadeout.png"):getWidth(),
        height = love.graphics.newImage("assets/fadeout.png"):getHeight(),
        scale = 4
    }

    self.stats = {
        health = {
            current = 100,
            max = 100,
            decreaseFactor = 0,
            creaseFactor = 0
        },
        hunger = {
            current = 100,
            max = 100,
            decreaseFactor = 0.2
        },
        thirst = {
            current = 100,
            max = 100,
            decreaseFactor = 0.5
        }
    }

    self.quest = {
        evolution = 30,
        dungeon = 0,
        kill = 0
    }

    self.currentPok = "Ratata"
    self.myPokemon = Entities[self.currentPok]
    self.myPokemon:load()
    Inventory.pokBelt[1] = self.myPokemon

    self.state = "idle"
    self.player = {animation = self:loadAssets(), maxSpeed = 160}

    self.form = "myPokemon"

    self.particles = Particles:new(self.x, self.y)

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.shape = love.physics.newRectangleShape(self.myPokemon.animation.width * self.scaleBase, self.myPokemon.animation.height * self.scaleBase)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    
    self.physics.fixture:setUserData("player")
    self.physics.body:setFixedRotation(true)
    self.physics.body:setGravityScale(0)
end

function Player:loadAssets()
    local animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 4, current = 1, img = {}, rate = 0.2}
    for i = 1, animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/player/idle/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i = 1, animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/player/left/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i = 1, animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/player/right/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i = 1, animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/player/top/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i = 1, animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/player/bottom/"..i..".png")        
    end

    animation.draw = animation.idle.img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Player:newBattle(enemy)
    local Entities = require("entities")

    GUI.fightButton.escape.button.canClick = true
    GUI:disablePanels()
    self.battle.inBattle = true
    self.battle.life.current = self.battle.life.total
    self.battle.enemy = Entities[enemy]
    self.battle.enemy:load()
end

function Player:escapeBattle()
    local GUI = require("gui")
    GUI.fightButton.escape.button.canClick = false
    GUI:enablePanels()
    self.battle.inBattle = false
    GUI:clearPopupOfFightPanel()
end

function Player:sendAttackInBattle(damage, target, bonus)
    local damageCalc = (damage/30)*22
    local rd = math.random(100)

    if rd <= damageCalc then
        damage = 0
    end

    if target == "player" then
        self.battle.life.current = self.battle.life.current - (damage * 0.5) * math.random(1+bonus)
        
        if self.battle.life.current <= 0 then
            self:escapeBattle()
            MsgUI.new(nil, nil, "You loose the fight !", false, 3)
        end
    else
        self.battle.enemy.pv = self.battle.enemy.pv - damage

        if self.battle.enemy.pv <= 0 then
            self.quest.kill = self.quest.kill + 1
            self:escapeBattle()
            MsgUI.new(nil, nil, "You win the fight !", false, 3)
            if #Inventory.pokBelt < Inventory.pokBelt.max then Inventory:addPokemonToBelt(self.battle.enemy.name) end
        end

        if rd <= damageCalc then
            bonus = 0.2
        end

        local newDamage = self.battle.enemy.attack[math.random(#self.battle.enemy.attack)].damage
        self:sendAttackInBattle(newDamage, "player", bonus)
    end
end

function Player:newFight()
    self.fight.inFight = true
    self.fight.life.current = self.fight.life.total
end

function Player:takeDamageInFight(damage)
    self.fight.life.current = self.fight.life.current - damage

    if self.fight.life.current <= 0 then
        self:endFight()
        MsgUI.new(nil, nil, "You died in the dungeon !", false, 3)
    else
        self:tintRed()
    end
end

function Player:endFight()
    self.fight.inFight = false
    Map:prepareSwitchMap("pok")
end

function Player:tintRed()
    self.color.base.g = 0
    self.color.base.b = 0
end

function Player:reloadPokemon(currentPok)
    -- Gère le rechargement d'un Pokémon via son nom
    -- /!\ IL DOIT ETRE PRESENT DANS ENTITIES

    self.currentPok = currentPok
    self.myPokemon = Entities[self.currentPok]
    self.myPokemon:load(self.state)
    self:syncHitBox()
    Inventory.pokBelt[1] = self.myPokemon
end

function Player:throwProjectile(x, y)
    if Map.map == "dungeon" and self.timerProjectile.canThrow then
        local Projectile = require("projectile")
        
        local worldX = (x / Camera.scale) + Camera.x
        local worldY = (y / Camera.scale) + Camera.y
        
        Projectile.new(self.x, self.y, worldX, worldY, 4, "Player")
        self.timerProjectile.canThrow = false
    end
end

function Player:consumeItem(slotOfConsumable)
    if Inventory.inventory[slotOfConsumable].item.name == "Orb" then
        if self.myPokemon.evolution ~= "nil" then
            GUI:desactivePanels()
            self:evolveCurrentPok()
            Inventory:removeFromInventory(slotOfConsumable, 1)
        else
            MsgUI.new(nil, nil, "You're pok don't have an evolution !", false, 3)
        end
    else
        local givable = Inventory:returnConsumeValue(slotOfConsumable)

        self.stats[givable.type].current = math.min(self.stats[givable.type].current + givable.value, 100)
        Inventory:removeFromInventory(slotOfConsumable, 1)
    end
end

function Player:update(dt)
    self:syncPhysics()
    self:animate(dt)
    self:handleInput(dt)
    self:applyFriction(dt)
    self:switchBelt()
    if Map.map ~= "dungeon" and GUI.load.loadState == "game" then self:decreaseStats(dt) end
    self:creaseStats(dt)
    self:unTint(dt)
    self:rechargeProjectile(dt)

    if(self.myPokemon:GetStats("isShiny")) then
        Particles:update(dt, self.particles)
        Particles:setPosition(self.particles, self.x, self.y)
    end
end

function Player:rechargeProjectile(dt)
    if not self.timerProjectile.canThrow then
        self.timerProjectile.current = self.timerProjectile.current + dt

        if self.timerProjectile.current > self.timerProjectile.rate then
            self.timerProjectile.current = 0
            self.timerProjectile.canThrow = true
        end
    end
end

function Player:unTint(dt)
    self.color.base.r = math.min(self.color.base.r + self.color.base.speed * dt, 1)
    self.color.base.g = math.min(self.color.base.g + self.color.base.speed * dt, 1)
    self.color.base.b = math.min(self.color.base.b + self.color.base.speed * dt, 1)
end

function Player:decreaseStats(dt)
    local stats = self.stats
    
    if stats.hunger.current <= 0 then
        stats.hunger.current = 0
    else
        stats.hunger.current = stats.hunger.current - dt * stats.hunger.decreaseFactor
    end

    if stats.thirst.current <= 0 then
        stats.thirst.current = 0
    else
        stats.thirst.current = stats.thirst.current - dt * stats.thirst.decreaseFactor
    end

    if stats.hunger.current == 0 and stats.thirst.current == 0 then
        stats.health.decreaseFactor = 2
    elseif stats.hunger.current == 0 or stats.thirst.current == 0 then
        stats.health.decreaseFactor = 1
    else
        stats.health.decreaseFactor = 0
    end

    if stats.health.decreaseFactor ~= 0 then
        stats.health.current = stats.health.current - dt * stats.health.decreaseFactor
        if stats.health.current < 0 then
            stats.health.current = 0
        end
    end
end

function Player:creaseStats(dt)
    local stats = self.stats

    if stats.hunger.current > 80 and stats.thirst.current > 80 then
        stats.health.creaseFactor = 2
    elseif stats.hunger.current > 80 or stats.thirst.current > 80 then
        stats.health.creaseFactor = 1
    else
        stats.health.creaseFactor = 0
    end

    if stats.health.creaseFactor ~= 0 then
        stats.health.current = stats.health.current + dt * stats.health.creaseFactor
        if stats.health.current > 100 then
            stats.health.current = 100
        end
    end
end

function Player:switchBelt()
    -- Passe au pokémon suivant dans la ceinture

    self.keyState.switchBelt = love.keyboard.isDown(self.key.switchBelt.bind)

    if self:isSwitchBeltKeyPressed() and self.keyState.switchBelt and self.canSwitch and #Inventory.pokBelt > 1 then
        Inventory.pokBelt.current = Inventory.pokBelt.current + 1
        if Inventory.pokBelt.current > #Inventory.pokBelt then
            Inventory.pokBelt.current = 1
        end

        self.myPokemon = Inventory.pokBelt[Inventory.pokBelt.current]
        self.myPokemon:load(self.state)
        self:syncHitBox()
        self.canSwitch = false
    elseif not self.keyState.switchBelt and not self.canSwitch then
        self.canSwitch = true
    end
end

function Player:evolveCurrentPok()
    Sound:play("evolve")
    local isShiny = self.myPokemon:GetStats("isShiny")
    self:reloadPokemon(self.myPokemon.evolution)
    self.myPokemon:SetStats("isShiny", isShiny)
    self.quest.evolution = self.quest.evolution + 1
end

function Player:animate(dt)
    -- Gère l'animation du Pokemon

    self[self.form].animation.timer = self[self.form].animation.timer + dt
    if self[self.form].animation.timer > self[self.form].animation.rate then
        self[self.form].animation.timer = 0
        self:setNewFrame()
    end
end

function Player:setNewFrame()
    -- Gère l'animation du Pokemon (parti visuel)

    local anim = self[self.form].animation[self.state]

    if anim.current < anim.total then
        anim.current = anim.current + 1 
    else
        anim.current = 1
    end

    self[self.form].animation.draw = anim.img[anim.current]
end

function Player:isTopKeyPressed()
    -- Renvoie état touche top
    return love.keyboard.isDown(self.key.top.bind)
end

function Player:isLeftKeyPressed()
    -- Renvoie état touche left
    return love.keyboard.isDown(self.key.left.bind)
end

function Player:isBottomKeyPressed()
    -- Renvoie état touche bottom
    return love.keyboard.isDown(self.key.bottom.bind)
end

function Player:isRightKeyPressed()
    -- Renvoie état touche right
    return love.keyboard.isDown(self.key.right.bind)
end

function Player:isAffBeltKeyPressed()
    -- Renvoie état touche affBelt
    return love.keyboard.isDown(self.key.affBelt.bind)
end

function Player:isSwitchBeltKeyPressed()
    -- Renvoie état touche switchBelt
    return love.keyboard.isDown(self.key.switchBelt.bind)
end

function Player:changeState(state)
    -- Gère le changement d'état du Pokémon

    if self.state ~= state then
        self.state = state
        self[self.form].animation.rate = self[self.form].animation[state].rate
    end
end

function Player:handleInput(dt)
    -- Gère les déplacement du Pokémon

    if GUI.load.loadState == "game" then
        if self:isTopKeyPressed() then
            self:changeState("top")
            self.yVel = math.max(self.yVel - self.acceleration * dt, -self[self.form].maxSpeed - self.bonus.bonusSpeed)
            self.xVel = 0
        elseif self:isLeftKeyPressed() then
            self:changeState("left")
            self.xVel = math.max(self.xVel - self.acceleration * dt, -self[self.form].maxSpeed - self.bonus.bonusSpeed)
            self.yVel = 0
        elseif self:isBottomKeyPressed() then
            self:changeState("bottom")
            self.yVel = math.min(self.yVel + self.acceleration * dt, self[self.form].maxSpeed + self.bonus.bonusSpeed)
            self.xVel = 0
        elseif self:isRightKeyPressed() then
            self:changeState("right")
            self.xVel = math.min(self.xVel + self.acceleration * dt, self[self.form].maxSpeed + self.bonus.bonusSpeed)
            self.yVel = 0
        else
            self:changeState("idle")
        end
    end
end

function Player:applyFriction(dt)
    -- Gère l'arrêt/friction du Pokémon

    if not (self:isTopKeyPressed() or self:isLeftKeyPressed() or self:isBottomKeyPressed() or self:isRightKeyPressed()) then
        if self.xVel > 0 then
            self.xVel = math.max(self.xVel - self.friction * dt, 0)
        elseif self.xVel < 0 then
            self.xVel = math.max(self.xVel + self.friction * dt, 0)
        elseif self.yVel > 0 then
            self.yVel = math.max(self.yVel - self.friction * dt, 0)
        elseif self.yVel < 0 then
            self.yVel = math.max(self.yVel + self.friction * dt, 0)
        end
    end
end

function Player:syncPhysics()
    -- Gère les déplacement (partie physique)
    
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:syncHitBox()
    -- Actualise la hitbox du Pokémon

    self.physics.fixture:destroy()  -- Détruisez l'ancienne fixture

    local playerWidth, playerHeight = self[self.form].animation.draw:getWidth() * self.scaleBase, self[self.form].animation.draw:getHeight() * self.scaleBase

    self.physics.shape = love.physics.newRectangleShape(playerWidth, playerHeight)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function Player:draw()
    -- Affiche le Pokémon, son possible effet shiny et sa hitbox

    love.graphics.setColor(self.color.base.r, self.color.base.g, self.color.base.b)
    if self.myPokemon:GetStats("isShiny") and self.form == "myPokemon" then
        love.graphics.setColor(self.color.shiny.r, self.color.shiny.g, self.color.shiny.b)
        self:drawParticles()
    end

    love.graphics.draw(self[self.form].animation.draw, self.x, self.y, self.r, self.scaleBase, self.scaleBase, self[self.form].animation.width/2, self[self.form].animation.height/2)
    love.graphics.setColor(1, 1, 1)

    -- self:drawHitBox()
    -- if Map.map == "dungeon" then self:drawFade() end
    self:drawPlottableHitbox()
end

function Player:drawFade()
    love.graphics.draw(self.fade.img, self.x - (self.fade.width * self.fade.scale) * 0.5, self.y - (self.fade.height * self.fade.scale) * 0.5, 0, self.fade.scale, self.fade.scale)
end

function Player:drawParticles()
    Particles:draw(self.particles)
end

function Player:drawHitBox()
    -- Affiche la hitbox du Pokémon

    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Player:drawPlottableHitbox()
    if(Inventory.plottable.canDrawHitbox) then
        local inventory = Inventory.inventory
        local plottable = Inventory.plottable

        love.graphics.setColor(0, 0, 0.5)
        love.graphics.rectangle("line", self.x - (inventory[plottable.slot].item.width * inventory[plottable.slot].item.scale) * 0.5, self.y + 42, plottable.width, plottable.height)
        love.graphics.setColor(0.5, 0.5, 1)
        love.graphics.rectangle("fill", self.x - (inventory[plottable.slot].item.width * inventory[plottable.slot].item.scale) * 0.5, self.y + 42, plottable.width, plottable.height)
        love.graphics.setColor(1, 1, 1)

        if(not checkIsCollide(self.x - inventory[plottable.slot].item.width * 1.25, self.y + inventory[plottable.slot].item.height * 3, plottable.width, plottable.height)) then
            if(not plottable.msgUI) then
                local text = "Place "..inventory[plottable.slot].id
                local x = love.graphics:getWidth() * 0.5 - love.graphics.getFont():getWidth(text) * 0.5

                plottable.msgUI = MsgUI.new(x, 25, text, true, nil, function() Inventory:placePlottableCallback(plottable.slot, 1, self.x, self.y) end)
            elseif(plottable.msgUI.text ~= "Place "..inventory[plottable.slot].id) then
                plottable.msgUI:remove()
                plottable.msgUI = nil
            end
        else
            if(not plottable.msgUI) then
                local text = "You cant place "..inventory[plottable.slot].id.." here"
                local x = love.graphics:getWidth() * 0.5 - love.graphics.getFont():getWidth(text) * 0.5

                plottable.msgUI = MsgUI.new(x, 25, text, false, nil)
            elseif(plottable.msgUI.text ~= "You cant place "..inventory[plottable.slot].id.." here") then
                plottable.msgUI:remove()
                plottable.msgUI = nil
            end
        end
    end
end

function Player:beginContact(a, b, collision)
    -- Gère les collisions du Pokémon

    if self.grounded == true then return end
    local nx, ny = collision:getNormal()
    if a == self.physics.fixture then
        if ny < 0 then
            self.yVel = 0
        end
    elseif b == self.physics.fixture then
        if ny > 0 then
            self.yVel = 0
        end
    end
end

return Player