
function initGame()
    local PopUp = require("popUp")
    PopUp:disableAll()

    GUI.load.starter.choose.canClick = false
    for i, pok in pairs(GUI.load.starter.pok) do
        pok.button.canClick = false
    end

    Player:reloadPokemon(GUI.load.starter.pokChoice)
    Player.myPokemon:SetStats("isShiny", (math.random(0, 10) == 6) and true or false)

    if Player.myPokemon:GetStats("isShiny") then
        Sound:play("shiny")
    end

    Sound:togglePauseResume(Map.map, "resume")

    GUI:enablePanels()
    GUI.load.loadState = "game"
end

function remuseGame()
    local PopUp = require("popUp")
    PopUp:disableAll()

    for i, button in pairs(GUI.load.buttons) do
        button.canClick = false
    end

    if not Sound:isPlaying(Map.map) then
        Sound:togglePauseResume(Map.map, "resume")
    end

    GUI:enablePanels()
    GUI.load.loadState = "game"
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

function getRandomElm(list)
    local keys = {}
    for key in pairs(list) do
       table.insert(keys, key)
    end
 
    local randomKey = keys[math.random(#keys)]
    return list[randomKey]
end

function capitalize(str)
    return str:gsub("^%l", string.upper)
end

function removeSpaces(str)
    local result = str:gsub("%s+", "")
    return result
end

PokemonTypes = {
    -- Liste des différents types pour les Pokémon

    PLANT = {
        icon = love.graphics.newImage("assets/ui/icon/plant.png"),
    },
    FIRE = {
        icon = love.graphics.newImage("assets/ui/icon/fire.png"),
    },
    WATER = {
        icon = love.graphics.newImage("assets/ui/icon/water.png"),
    },
    GROUND = {
        icon = love.graphics.newImage("assets/ui/icon/ground.png"),
    },
    ElECTRIC = {
        icon = love.graphics.newImage("assets/ui/icon/electric.png"),
    },
    NORMAL = {
        icon = love.graphics.newImage("assets/ui/icon/normal.png"),
    },
    PSY = {
        icon = love.graphics.newImage("assets/ui/icon/psy.png"),
    },
}

ItemTypes = {
    RESSOURCE = {
        nbButton = 3,
        extraButtons = {},
        stack = 64
    },
    CONSUMABLE = {
        extraButtons = {8},
        stack = 32
    },
    EQUIPMENT = "equipment",
    TOOL = {
        nbButton = 4,
        extraButtons = {5},
        stack = 1
    },
    PLOTTABLE = {
        extraButtons = {6},
        stack = 32
    },
    PLANT = {
        extraButtons = {7},
        stack = 16
    }
}

CraftableItems = {
    [1] = {
        item = Items.Log,
        button = nil,
        allowToCraft = true,
        receap = {
            [1] = {
                item = Items.Branch,
                quantity = 4
            }
        }
    },
    [2] = {
        item = Items.Iron,
        button = nil,
        allowToCraft = true,
        receap = {
            [1] = {
                item = Items.Stone,
                quantity = 15
            }
        }
    },
    [3] = {
        item = Items.Workbench,
        button = nil,
        allowToCraft = true,
        receap = {
            [1] = {
                item = Items.Log,
                quantity = 3
            },
            [2] = {
                item = Items.Stone,
                quantity = 1
            }
        }
    },
    [4] = {
        item = Items.CarrotBag,
        button = nil,
        allowToCraft = true,
        receap = {
            [1] = {
                item = Items.FertilizedDirt,
                quantity = 5
            }
        }
    },
    [5] = {
        item = Items.CornBag,
        button = nil,
        allowToCraft = true,
        receap = {
            [1] = {
                item = Items.FertilizedDirt,
                quantity = 5
            }
        }
    },
    [6] = {
        item = Items.StrawberryBag,
        button = nil,
        allowToCraft = true,
        receap = {
            [1] = {
                item = Items.FertilizedDirt,
                quantity = 5
            }
        }
    },
    [7] = {
        item = Items.Axe,
        button = nil,
        allowToCraft = true,
        receap = {
            [1] = {
                item = Items.Branch,
                quantity = 2
            },
            [2] = {
                item = Items.Iron,
                quantity = 3
            }
        }
    },
    [8] = {
        item = Items.Pickaxe,
        button = nil,
        allowToCraft = true,
        receap = {
            [1] = {
                item = Items.Branch,
                quantity = 2
            },
            [2] = {
                item = Items.Iron,
                quantity = 3
            }
        }
    },
    [9] = {
        item = Items.Shovel,
        button = nil,
        allowToCraft = true,
        receap = {
            [1] = {
                item = Items.Branch,
                quantity = 2
            },
            [2] = {
                item = Items.Iron,
                quantity = 1
            }
        }
    },
    [10] = {
        item = Items.Hoe,
        button = nil,
        allowToCraft = true,
        receap = {
            [1] = {
                item = Items.Branch,
                quantity = 2
            },
            [2] = {
                item = Items.Iron,
                quantity = 2
            }
        }
    },
    [11] = {
        item = Items.Bucket,
        button = nil,
        allowToCraft = true,
        receap = {
            [1] = {
                item = Items.Stone,
                quantity = 5
            },
            [2] = {
                item = Items.Iron,
                quantity = 1
            }
        }
    }
}