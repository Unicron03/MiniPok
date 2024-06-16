local Map = {}

local STI = require("sti")
local SolidElm = require("solidElm")

function Map:load()
   self.map = "pok"
   self.x, self.y = 0, 0
   self.textLayer = {}
   self.actualSalle = nil
   self.beginSalle = false

   self.switch = {
      canSwitch = false,
      map = nil,
   }

   World = love.physics.newWorld(0,0)
   World:setCallbacks(beginContact, endContact)

   self:init()
end

function Map:init()
   self.level = STI("map/"..self.map..".lua", {"box2d"})

   self.level:box2d_init(World)
   self.solidLayer = self.level.layers.solid
   self.groundLayer = self.level.layers.ground
   self.entityLayer = self.level.layers.entity
   self.textLayer = self.level.layers.text

   self.solidLayer.visible = false
   self.entityLayer.visible = false
   MapWidth = self.groundLayer.width * self.groundLayer.properties.tileDimensity
   MapHeight = self.groundLayer.height * self.groundLayer.properties.tileDimensity

   self:spawnEntities()
   self:spawnText()
   self:linkedChests()

   if self.map == "dungeon" then
      Player:newFight()
   end
end

function Map:resetAttributes()
   self.x, self.y = 0, 0
   self.textLayer = {}
   self.actualSalle = nil
   self.beginSalle = false
end

function Map:clean()
   self.level:box2d_removeLayer("solid")

   Harvestable.removeAll()
   SolidElm.removeAll()
   Objects.removeAll()
   Enemy.removeAll()

   local Projectile = require("projectile")
   Projectile.removeAll()
end

function Map:switchMap(map)
   self:clean()
   self.map = map
   self:resetAttributes()
   self:init()

   Sound:stopAll()
   Sound:play(self.map)

   Player.form = (self.map == "human") and ("player") or ("myPokemon")
   Player.physics.body:setPosition(self.x, self.y)
end

function Map:prepareSwitchMap(map)
   self.switch.map = map
   self.switch.canSwitch = true
end

function Map:returnSpawnCoords()
   return self.x, self.y
end

function Map:update(dt)
   self.level:update(dt)
   self:EntitiesDie()

   if self.switch.canSwitch then
      self:switchMap(self.switch.map)
      self.switch.canSwitch = false
   end
end

function Map:draw()
   self.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
end

function Map:drawTextLayer()
   if self.textLayer then
       local currentFont = love.graphics.getFont()

       for _, textObj in ipairs(self.textLayer) do
           love.graphics.setFont(textObj.font)
           love.graphics.print(textObj.text, textObj.x, textObj.y)
       end

       love.graphics.setFont(currentFont)
   end
end

function Map:findEntityWithId(id, table)
   for _, entite in ipairs(table) do
      if entite.id == id then
         return entite
      end
   end

   return nil
end

function Map:spawnEntitiesOfSalle(salle)
   self.actualSalle = salle
   self.beginSalle = true

   for i,v in ipairs(self.entityLayer.objects) do
      if v.properties.salle == salle then
         if v.type == "mage" then
            Enemy.Mage.new(v.x, v.y, v.id)
         elseif v.type == "skull" then
            Enemy.Skull.new(v.x, v.y, v.id)
         end
      end
   end
end

function Map:EntitiesDie()
   if self.beginSalle and #Enemy.returnTable() == 0 then
      for i,v in ipairs(self.entityLayer.objects) do
         if v.properties.salle == self.actualSalle then
            local entity = self:findEntityWithId(v.id, Objects.returnTable())
            
            if entity then
               entity:remove()
            end
         end
      end

      self.beginSalle = false
   end
end

function Map:spawnEntities()
   for i, v in ipairs(self.entityLayer.objects) do
      if v.type == "tree" then
         Harvestable.Tree.new(v.x, v.y)
      elseif v.type == "rock" then
         Harvestable.Rock.new(v.x, v.y)
      elseif v.type == "bush" then
         Harvestable.Bush.new(v.x, v.y)
      elseif v.type == "water" then
         Harvestable.Water.new(v.x, v.y, v.width, v.height)
      elseif v.type == "dirt" then
         Harvestable.Dirt.new(v.x, v.y, v.width, v.height)
      elseif v.type == "workbench" then
         Objects.Workbench.new(v.x, v.y)
      elseif v.type == "peaks" then
         Objects.Peaks.new(v.x, v.y, v.width, v.height, v.id, v.properties.orientation, v.properties.salle, function(salle) self:spawnEntitiesOfSalle(salle) end)
      elseif v.type == "door" then
         Objects.Door.new(v.x, v.y, v.properties.img, v.id, v.properties.salle)
      elseif v.type == "trader" then
         Objects.Trader.new(v.x, v.y, v.width, v.height)
      elseif v.type == "pokBush" then
         Objects.PokBush.new(v.x, v.y, v.width, v.height, getRandomElm(Entities))
      elseif v.type == "chest" then
         local linkedChestId = v.properties.obj ~= nil and (v.properties.obj.id) or (nil)
         Objects.Chest.new(v.x, v.y, v.id, linkedChestId, v.properties.type)
      elseif v.type == "enter" then
         self.x, self.y = v.x, v.y
      elseif v.type == "exit" then
         local callback = (v.name == "ExitDungeon") and (
            function()
               Player:endFight()
               Inventory.coin = Inventory.coin + math.random(5, 20 + Player.bonus.coinInDungeon)
            end) or (false)

         Objects.Portal.new(v.x, v.y, v.width, v.height, v.properties.goto, callback)
      end
   end
end

function Map:spawnText()
   if self.textLayer then
      for i, v in ipairs(self.textLayer.objects) do
         table.insert(self.textLayer, {text = v.text, x = v.x, y = v.y, font = love.graphics.newFont(v.pixelsize)})
      end
   end
end

function Map:linkedChests()
   for _, entity in pairs(Objects.Chest.returnTable()) do
      if entity.linkedChestId ~= nil then
         local linkedChest = self:findEntityWithId(entity.linkedChestId, Objects.Chest.returnTable())

         if linkedChest then
            entity.linkedChest = linkedChest
         else
            print("Aucune entité trouvée avec l'ID lié :", entity.linkedObjId)
         end
      end
   end
end

return Map