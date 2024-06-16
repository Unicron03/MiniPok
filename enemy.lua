local Skull = require("mobs/skull")
local Mage = require("mobs/mage")

local enemies = {
    Skull = Skull,
    Mage = Mage
}

function enemies.returnTable()
    -- Renvoi les enemies actifs

    local enemiesTable = {}

    for _, enemy in pairs(enemies) do
        if type(enemy) == "table" and enemy.returnTable then
            for _, instance in ipairs(enemy.returnTable()) do
                table.insert(enemiesTable, instance)
            end
        end
    end

    return enemiesTable
end

function enemies.removeAll()
    -- Supprimer les ennemies actifs

    for _, enemy in pairs(enemies) do
        if type(enemy) == "table" and enemy.removeAll then
            enemy.removeAll()
        end
    end
end

function enemies.loadAssets()
    -- Charge les assets

    for _, enemy in pairs(enemies) do
        if type(enemy) == "table" and enemy.loadAssets then
            enemy.loadAssets()
        end
    end
end

function enemies.updateAll(dt)
    -- Mets à jour les enemies

    for _, enemy in pairs(enemies) do
        if type(enemy) == "table" and enemy.update then
            enemy.updateAll(dt)
        end
    end
end

function enemies.drawAll()
    -- Affiche les ennemies

    for _, enemy in pairs(enemies) do
        if type(enemy) == "table" and enemy.draw then
            enemy.drawAll()
        end
    end
end

function enemies.beginContactAll(a, b, collision)
    -- Gère l'entrée des collisions

    for _, enemy in pairs(enemies) do
        if type(enemy) == "table" and enemy.beginContact then
            enemy.beginContact(a, b, collision)
        end
    end
end

return enemies