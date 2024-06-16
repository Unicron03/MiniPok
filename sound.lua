local Sound = {active = {}, source = {}, music = true, effect = true}

function Sound:init(id, source, soundType, audioType)
    assert(self.source[id] == nil, "Sound with that ID already exists!")
    self.source[id] = {source = love.audio.newSource(source, soundType), type = audioType}
end

function Sound:loadSong()
    self:init("shiny", "assets/sfx/shine.ogg", "stream", "effect")
    self.source["shiny"].source:setVolume(1)
    self:init("evolve", "assets/sfx/evolve.ogg", "stream", "effect")
    self.source["evolve"].source:setVolume(1)
    self:init("tree_hit", "assets/sfx/tree_hit.ogg", "stream", "effect")
    self.source["tree_hit"].source:setVolume(0.5)
    self:init("hit", "assets/sfx/hit.ogg", "stream", "effect")
    self.source["hit"].source:setVolume(0.4)
    self:init("quest", "assets/sfx/quest.ogg", "stream", "effect")
    self.source["quest"].source:setVolume(0.4)
    self:init("purchase", "assets/sfx/purchase.ogg", "stream", "effect")
    self.source["purchase"].source:setVolume(0.4)
    self:init("craft", "assets/sfx/craft.wav", "stream", "effect")
    self.source["craft"].source:setVolume(0.4)
    self:init("error", "assets/sfx/click_error.wav", "stream", "effect")
    self.source["error"].source:setVolume(2)
    self:init("launch", "assets/sfx/launch.wav", "stream", "effect")
    self.source["launch"].source:setVolume(0.4)
    self:init("click", "assets/sfx/click.ogg", "stream", "effect")
    self.source["click"].source:setVolume(0.4)

    self:init("pok", "assets/sfx/music/plain.wav", "stream", "music")
    self.source["pok"].source:setVolume(0.4)
    self:init("dungeon", "assets/sfx/music/dungeon.wav", "stream", "music")
    self.source["dungeon"].source:setVolume(0.4)
    self:init("human", "assets/sfx/music/forest.wav", "stream", "music")
    self.source["human"].source:setVolume(0.4)

    local count = 0
    for _, _ in pairs(self.source) do
        count = count + 1
    end
end

function Sound:stopAll()
    for _, entry in pairs(self.source) do
        entry.source:stop()
    end

    for channel, clones in pairs(self.active) do
        for _, clone in ipairs(clones) do
            clone:stop()
        end

        self.active[channel] = {}
    end
end

function Sound:switchMusic()
    if self.music then
        self:stopAll()
        GUI.load.buttons.music.img = GUI.icon.button.music_off
        self.music = false
    else
        self:play(Map.map)
        GUI.load.buttons.music.img = GUI.icon.button.music_on
        self.music = true
    end
end

function Sound:switchEffect()
    if self.effect then
        GUI.load.buttons.effect.img = GUI.icon.button.effect_off
        self.effect = false
    else
        GUI.load.buttons.effect.img = GUI.icon.button.effect_on
        self.effect = true
    end
end

function Sound:update(dt)
end

function Sound:play(id, channel)
    local channel = channel or "default"
    local entry = self.source[id]

    if entry then
        if (entry.type == "music" and not self.music) or (entry.type == "effect" and not self.effect) then
            return
        end

        local clone = entry.source:clone()
        clone:play()

        if not self.active[channel] then
            self.active[channel] = {}
        end

        table.insert(self.active[channel], clone)
    else
        error("Sound ID not found: " .. tostring(id))
    end
end

function Sound:isPlaying(id)
    local entry = self.source[id]
    if not entry then
        return false
    end

    if entry.source:isPlaying() then
        return true
    end

    for channel, clones in pairs(self.active) do
        for _, clone in ipairs(clones) do
            if clone:isPlaying() then
                return true
            end
        end
    end

    return false
end

function Sound:togglePauseResume(id, mode)
    local entry = self.source[id]
    if not entry then
        error("Sound ID not found: " .. tostring(id))
    end

    if mode == "pause" then
        entry.source:pause()
        for channel, clones in pairs(self.active) do
            for _, clone in ipairs(clones) do
                if clone:isPlaying() then
                    clone:pause()
                end
            end
        end
    elseif mode == "resume" then
        if (entry.type == "music" and not self.music) or (entry.type == "effect" and not self.effect) then
            return
        end
        
        entry.source:play()
    else
        error("Invalid mode: " .. tostring(mode))
    end
end

return Sound