
local inventory = {
    toolbelt = {},

    pokBelt = {max = 5, current = 1},

    inventory = {},

    harvestTable = {},

    slotPlant = {
        id = nil,
        quantity = 0,
        icon = nil,
        item = nil
    },

    plottable = {
        canDrawHitbox = false,
        slot = nil,
        msgUI = nil,
        width = 0,
        height = 0
    },

    coin = 0
}

for i = 1, 3 do
    table.insert(inventory.toolbelt, {id = nil, icon = nil, button = nil, item = nil})
end

for i=1, 24 do
    table.insert(inventory.inventory, {id = nil, quantity = 0, icon = nil, item = nil})
end
-- print(#inventory.inventory)

function inventory:addPokemonToBelt(newPok)
    -- Ajoute le pokémon en paramètre dans la ceinture

    pokToAdd = Entities[newPok]
    pokToAdd:SetStats("isShiny", (math.random(0, 2) == 2) and true or false)
    pokToAdd:load()

    if pokToAdd:GetStats("isShiny") then
        Sound:play("shiny")
    end

    inventory.pokBelt[#inventory.pokBelt+1] = pokToAdd
end

function inventory:isToolbeltFull()
    for i=1, #inventory.toolbelt do
        if(inventory.toolbelt[i].id == nil) then
            return i
        end
    end

    return true
end

function inventory:isInventoryFull()
    for i=1, #inventory.inventory do
        if(inventory.inventory[i].id == nil) then
            return false
        end
    end

    return true
end


function inventory:affInventory()
    -- Affichage de l'inventaire dans la console

    for i=1, 24 do
        print("Slot ", i, " : ", inventory.inventory[i].id, inventory.inventory[i].quantity)
    end
end

function inventory:giveToInventory(item, instance, quantity)
    -- Ajoute un x item à l'inventaire (avec icon pour aff dans inventaire)

    local quantity = (quantity ~= nil) and quantity or 1
    local instance = (instance ~= nil) and instance or nil
    local icon = (instance ~= nil) and (instance.img) or nil
    local indMin = nil
    
    for i=1, #inventory.inventory do
        local slot = inventory.inventory[i]

        if(slot.id == item and instance.itemType.stack > slot.quantity) then
            if(quantity == "all") then
                slot.quantity = 0
            else
                if(slot.quantity + quantity) <= instance.itemType.stack then
                    slot.quantity = slot.quantity + quantity
                else
                    quantity = quantity - (instance.itemType.stack - slot.quantity)
                    slot.quantity = instance.itemType.stack
                    inventory:giveToInventory(item, instance, quantity)
                end
            end

            if(slot.quantity <= 0) then
                slot.id = nil
                slot.quantity = 0
                slot.icon = nil
                slot.item = nil
            end

            -- affInventory()
            return
        elseif(slot.id == nil and indMin == nil) then
            indMin = i
        end
    end
    
    if(indMin ~= nil) then
        inventory.inventory[indMin].id = item

        if(inventory.inventory[indMin].quantity + quantity) <= instance.itemType.stack then
            inventory.inventory[indMin].quantity = inventory.inventory[indMin].quantity + quantity
        else
            inventory.inventory[indMin].quantity = instance.itemType.stack
            quantity = quantity - inventory.inventory[indMin].quantity
            inventory:giveToInventory(item, instance, quantity)
        end

        if(icon ~= nil) then
            inventory.inventory[indMin].icon = icon
            inventory.inventory[indMin].item = instance
        end

        if(inventory.inventory[indMin].quantity <= 0) then
            print("negative inventory")
            inventory.inventory[indMin].id = nil
            inventory.inventory[indMin].quantity = 0
            inventory.inventory[indMin].icon = nil
            inventory.inventory[indMin].item = nil
        end

        -- self:affInventory()
    else
        print("INVENTORY FULL !")
    end
end

function inventory:resetSlot(slotIndex)
    inventory.inventory[slotIndex].id = nil
    inventory.inventory[slotIndex].quantity = 0
    inventory.inventory[slotIndex].icon = nil
    inventory.inventory[slotIndex].item = nil
end

function inventory:removeToInventory(list)
    for _, recipeItem in ipairs(list) do
        for i=1, #inventory.inventory do
            if recipeItem.item.name == inventory.inventory[i].id then
                if recipeItem.quantity < inventory.inventory[i].quantity then
                    inventory.inventory[i].quantity = inventory.inventory[i].quantity - recipeItem.quantity
                elseif recipeItem.quantity == inventory.inventory[i].quantity then
                    inventory:resetSlot(i)
                else
                    local listToRemove = {item = recipeItem.item, quantity = recipeItem.quantity - inventory.inventory[i].quantity}
                    inventory:resetSlot(i)
                    inventory:removeToInventory(listToRemove)
                end
            end
        end
    end
end

function inventory:removeFromInventory(slotIndex, quantity)
    local quantityToRemove = (quantity == "all") and (inventory.inventory[slotIndex].quantity) or (quantity)

    inventory.inventory[slotIndex].quantity = inventory.inventory[slotIndex].quantity - quantityToRemove

    if(inventory.inventory[slotIndex].quantity <= 0) then
        inventory:resetSlot(slotIndex)
    end
end

function inventory:dropFromInventory(item, quantity, x, y, width)
    for i=1, #inventory.inventory do
        local slot = inventory.inventory[i]

        if(slot.id == item) then
            local Items = require("items")
            local finalQuantity = quantity == "all" and (slot.quantity) or quantity

            for i=1, finalQuantity do
                local itemClass = Items[removeSpaces(capitalize(item))]
                itemClass.new(x, y + width * 2 + 15)
            end

            if(quantity == "all") then
                slot.quantity = 0
            else
                slot.quantity = slot.quantity - quantity
            end

            if(slot.quantity <= 0) then
                slot.id = nil
                slot.quantity = 0
                slot.icon = nil
                slot.item = nil
            end
        end
    end
end

function inventory:TryToCraftItem(craftableItem, x, y)
    if inventory:haveListItem(craftableItem.receap) and craftableItem.allowToCraft then
        craftableItem.item.new(x, y)
        inventory:removeToInventory(craftableItem.receap)
        Sound:play("craft")
    else
        Sound:play("error")
    end
end

function inventory:haveListItem(list)
    for _, recipeItem in ipairs(list) do
        local found = false
        for _, inventoryItem in ipairs(inventory.inventory) do
            if inventoryItem.id == recipeItem.item.name and inventoryItem.quantity >= recipeItem.quantity then
                found = true
                break
            end
        end
        if not found then
            return false
        end
    end
    return true
end

function inventory:assignedToolToToolbelt(slotIndex)
    local slotOfTool = inventory.inventory[slotIndex]
    local indexOfSlotInToolbelt = inventory:isToolbeltFull()

    if(indexOfSlotInToolbelt ~= true) then
        local tool = slotOfTool.item

        inventory.toolbelt[indexOfSlotInToolbelt].id = slotOfTool.id
        inventory.toolbelt[indexOfSlotInToolbelt].icon = slotOfTool.icon
        inventory.toolbelt[indexOfSlotInToolbelt].item = slotOfTool.item
        inventory.toolbelt[indexOfSlotInToolbelt].button = nil

        slotOfTool.id = nil
        slotOfTool.quantity = 0
        slotOfTool.icon = nil
        slotOfTool.item = nil

        inventory:syncHarvestTable()

        -- for i, item in ipairs(harvestTable) do
        --     print(item)
        -- end

        print(inventory.toolbelt[indexOfSlotInToolbelt].item.durability)
    end
end

function inventory:assignedPlantToBelt(slotOfPlant)
    if(inventory.slotPlant.id ~= nil) then
        inventory:giveToInventory(inventory.slotPlant.id, inventory.slotPlant.item, inventory.slotPlant.quantity)
    end

    inventory.slotPlant.id = inventory.inventory[slotOfPlant].id
    inventory.slotPlant.quantity = inventory.inventory[slotOfPlant].quantity
    inventory.slotPlant.icon = inventory.inventory[slotOfPlant].icon
    inventory.slotPlant.item = inventory.inventory[slotOfPlant].item

    inventory:resetSlot(slotOfPlant)
end

function inventory:placePlottable(slotOfPlottable)
    if(inventory.plottable.canDrawHitbox) then
        inventory.plottable.msgUI:remove()
        inventory.plottable.msgUI = nil
        inventory.plottable.canDrawHitbox = false

        return
    end

    inventory.plottable.canDrawHitbox = true
    inventory.plottable.slot = slotOfPlottable

    local plottable = inventory.inventory[inventory.plottable.slot].item
    inventory.plottable.width = plottable.width * plottable.scale
    inventory.plottable.height = plottable.height * plottable.scale
end

function inventory:placePlottableCallback(slotOfPlottable, quantity, x, y)
    print(inventory.inventory[inventory.plottable.slot].item.name)
    inventory.inventory[inventory.plottable.slot].item.plot.new(x, y + 60) -- * 35) / (self.inventory[self.plottable.slot].item.height * self.inventory[self.plottable.slot].item.scale))
    inventory.plottable.msgUI = nil
    inventory.plottable.canDrawHitbox = false
    inventory:removeFromInventory(slotOfPlottable, quantity)
end

function inventory:syncHarvestTable()
    inventory.harvestTable = {}

    for i=1, #inventory.toolbelt do
        if(inventory.toolbelt[i].id ~= nil) then
            print("not nil so passing")
            for j=1, #inventory.toolbelt[i].item.harvestTable do
                local canAddCapacity = true

                -- print(toolbelt[i].item.itemType.harvestTable[j])
                for h, capacity in ipairs(inventory.harvestTable) do
                    if capacity == inventory.toolbelt[i].item.harvestTable[j] then
                        canAddCapacity = false
                        break
                    end
                end

                if(canAddCapacity) then
                    table.insert(inventory.harvestTable, inventory.toolbelt[i].item.harvestTable[j])
                end
            end
        end
    end
end

function inventory:enableToHarvest(harvestable)
    for i, capacity in ipairs(inventory.harvestTable) do
        print(capacity, " and ", harvestable)
        if(capacity == harvestable) then
            return true
        end
    end

    return false
end

function inventory:desequipTool(slotOfTool)
    if(slotOfTool.id ~= nil and not inventory:isInventoryFull()) then
        inventory:giveToInventory(slotOfTool.id, slotOfTool.item)

        slotOfTool.id = nil
        slotOfTool.icon = nil
        slotOfTool.item = nil
        slotOfTool.button:remove()
        slotOfTool.button = nil

        inventory:syncHarvestTable()
    end
end

function inventory:descreaseToolDurability(harvestable)
    for i=1, #inventory.toolbelt do
        for _, v in ipairs(inventory.toolbelt[i].item.harvestTable) do
            if v == harvestable then
                local toolDurability = inventory.toolbelt[i].item.durability

                inventory.toolbelt[i].item.durability = inventory.toolbelt[i].item.durability - 1

                if(inventory.toolbelt[i].item.durability <= 0) then
                    inventory.toolbelt[i].item:remove()

                    inventory.toolbelt[i].id = nil
                    inventory.toolbelt[i].icon = nil
                    inventory.toolbelt[i].item = nil

                    inventory:syncHarvestTable()
                end

                return
            end
        end
    end
end

function inventory:returnConsumeValue(slotOfConsumable)
    return inventory.inventory[slotOfConsumable].item.givable
end

return inventory