--[[
    Item idea by /u/robtheimpure: https://www.reddit.com/5mledp
--]]

-- total number of rooms required to clear to trigger the completion reward
local NUM_ROOMS_TO_CLEAR = 10
-- maximum number of reward pickup types to spawn
-- (randomly chosen from 0 -> the defined number below for each type)
local MAX_REWARD = {
    [PickupVariant.PICKUP_HEART]        = 3,
    [PickupVariant.PICKUP_COIN]         = 3,
    [PickupVariant.PICKUP_KEY]          = 3,
    [PickupVariant.PICKUP_BOMB]         = 2,
    [PickupVariant.PICKUP_BOMBCHEST]    = 2,
    [PickupVariant.PICKUP_SPIKEDCHEST]  = 1,
    [PickupVariant.PICKUP_ETERNALCHEST] = 1,
    [PickupVariant.PICKUP_LOCKEDCHEST]  = 2,
    [PickupVariant.PICKUP_GRAB_BAG]     = 4,
    [PickupVariant.PICKUP_PILL]         = 3,
    [PickupVariant.PICKUP_LIL_BATTERY]  = 2,
    [PickupVariant.PICKUP_TAROTCARD]    = 3,
    [PickupVariant.PICKUP_TRINKET]      = 3,
    [PickupVariant.PICKUP_REDCHEST]     = 3,
}


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
-- CODE BELOW THIS LINE
-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------

local mod = RegisterMod("PanicButton", 1)
local Game = Game
if type(Game) == "function" then
    Game = Game()
end

local function Log(caller, fmt, ...)
    fmt = ("[%s:%s] %s"):format(mod.Name, caller, fmt)
    Isaac.DebugString(fmt:format(...))
end

-- ---------------------------------------------------------------------
-- HELPER METHODS

local hooked = false
function mod:HookTickEvents()
    -- :AddCallback wrapper for on_tick events
    -- Note: once these callbacks are added, there is no API call to remove
    if not hooked then
        Log("HookTickEvents", "hooking events")
        self:AddCallback(ModCallbacks.MC_POST_UPDATE, self.OnUpdate)
        self:AddCallback(ModCallbacks.MC_POST_RENDER, self.OnRender)
        hooked = true
    end
end

function mod:LoadRemaining()
    -- Loads the required rooms remaining before triggering the reward
    local parsed = {}
    if self:HasData() then
        local data = self:LoadData()
        -- parse the saved string
        for datum in data:gmatch("[^:]+") do
            parsed[#parsed+1] = datum
        end
    end
    Log("LoadRemaining", ("%s; "):rep(#parsed), table.unpack(parsed))
    return table.unpack(parsed)
end

function mod:SaveRemaining()
    -- Saves the mod's state in case the game is closed
    if self._rooms_remaining then
        -- save the number of rooms remaining
        local room = Game:GetRoom()
        data = ("%d:%d"):format(self._rooms_remaining, room:GetSpawnSeed())
        -- also save which rooms have been cleared
        if self._cleared_rooms then
            local cleared = {}
            for room_id, _ in pairs(self._cleared_rooms) do
                cleared[#cleared+1] = room_id
            end

            if #cleared > 0 then
                local fmt = ("%d,"):rep(#cleared)
                fmt = fmt:sub(0, -2) -- strip the trailing ","
                -- add the cleared rooms to the saved data
                data = ("%s:%s"):format(data, fmt:format(table.unpack(cleared)))
            end
        end

        Log("SaveRemaining", "data: %s", data)
        self:SaveData(data)
    end
end

function mod:RemoveRemaining()
    -- Removes the mod's saved data
    Log("RemoveRemaining", "removing data")
    self._rooms_remaining = nil
    self._room_seed = nil
    self._num_room_enemies = nil
    self:RemoveData()
end

function mod:TryCacheClearedRoom()
    -- Caches rooms that have been cleared
    -- Returns true if the room was just cleared
    local result = false
    local room = Game:GetRoom()
    local room_seed = room:GetSpawnSeed()
    self._cleared_rooms = self._cleared_rooms or {}
    -- TODO: rooms with enemy waves (greed, bossrush, bosstrap, mobtrap)
    --  -> bossrush, *trap rooms == AmbushActive => 1st wave
    if room:IsClear() and not self._cleared_rooms[room_seed] then
        self._cleared_rooms[room_seed] = true
        if self._num_room_enemies > 0 then
            -- don't let empty rooms (eg. shops) affect the remaining count
            result = true
        end
    end

    return result
end

function mod:SpeedUp()
    -- Emulates the SPEED! challenge for the current room
    local room = Game:GetRoom()
    --[[
        From docs:

        Broken Watch Room State -
            0 = no watch effect,
            1 = speed down,
            2 = speed up.
    --]]
    room:SetBrokenWatchState(2)

    -- TODO: speed up music
    -- XXX: I don't think it's possible to alter the music through code
    --  at the moment
end

function mod:ResetSpeed()
    local room = Game:GetRoom()
    room:SetBrokenWatchState(0)
end

local variant_to_subtype = {
    -- maps PickupVariant to *SubType enum tables
    [PickupVariant.PICKUP_HEART]        = HeartSubType,
    [PickupVariant.PICKUP_COIN]         = CoinSubType,
    [PickupVariant.PICKUP_KEY]          = KeySubType,
    [PickupVariant.PICKUP_BOMB]         = BombSubType,
    -- [PickupVariant.PICKUP_BOMBCHEST]    = ,
    -- [PickupVariant.PICKUP_SPIKEDCHEST]  = ,
    -- [PickupVariant.PICKUP_ETERNALCHEST] = ,
    -- [PickupVariant.PICKUP_LOCKEDCHEST]  = ,
    -- [PickupVariant.PICKUP_GRAB_BAG]     = ,
    [PickupVariant.PICKUP_PILL]         = PillColor,
    -- [PickupVariant.PICKUP_LIL_BATTERY]  = ,
    [PickupVariant.PICKUP_TAROTCARD]    = Card,
    [PickupVariant.PICKUP_TRINKET]      = TrinketType,
    -- [PickupVariant.PICKUP_REDCHEST]     = ,
}

function mod:SpawnReward()
    -- Spawns the completion rewards
    local player = Isaac.GetPlayer(0)
    local vec = Vector(0, 0)
    local function PlaySound(sfx)
        Log("PlaySound", "Playing sound: %d", sfx)

        local ent = Isaac.Spawn(
            EntityType.ENTITY_NULL,
            0, 0,
            vec, vec,
            player
        )
        ent:ToNPC():PlaySound(sfx, 1.0, 0, false, 1.0)
        ent:Remove()
    end

    local function SpawnItem(variant, subtype)
        Isaac.Spawn(
            EntityType.ENTITY_PICKUP, variant, subtype,
            Isaac.GetFreeNearPosition(player.Position, 80.0), Vector(0, 0),
            player
        )
    end

    -- play a sound
    PlaySound(SoundEffect.SOUND_SUPERHOLY)

    -- spawn pickups
    -- XXX: this does not respect the run's seed
    --  ie, the rewards spawned in two runs with the same seed will be different
    --  (I don't think the API allows for this functionality yet)
    for pickup_type, max in pairs(MAX_REWARD) do
        local num_to_spawn = math.random(0, max)
        local max_subtype = 0
        local SubType = variant_to_subtype[pickup_type]
        if SubType then
            -- XXX: in order to randomly spawn a pickup subtype we need to count
            --  the total number for each subtype enum because they are not
            --  uniformly defined
            -- XXX: this does not respect achievements (ie, may spawn locked
            --  items/pickups)
            -- TODO: weights (all subtypes have an equal chance to spawn)
            for k, v in pairs(SubType) do
                if (
                    -- prune NUM_* enums from the count
                    type(k) == "string" and k:sub(0, 4) ~= "NUM_"
                    -- prune negative and zero subtypes
                    and type(v) == "number" and v > 0
                ) then
                    max_subtype = max_subtype + 1
                end
            end
        end

        for i = 1, num_to_spawn do
            local subtype = 0
            -- roll what kind of pickup this is
            if max_subtype > 0 then
                subtype = math.random(max_subtype)
            end

            Log("SpawnReward", "(%d/%d) spawning type=%d, subtype=%d",
                i, num_to_spawn, pickup_type, subtype
            )
            SpawnItem(pickup_type, subtype)
        end
    end

    -- spawn item pedestal(s)
    local num_collectibles = 1
    if Game:GetLevel():GetAbsoluteStage() >= LevelStage.STAGE4_1 then
        num_collectibles = 2
    end

    for i = 1, num_collectibles do
        local collectible_id = nil
        while not (
            collectible_id and not player:HasCollectible(collectible_id)
        ) do
            -- XXX: will spawn any item so long as the player does not have it
            --  (notably does not take seed into consideration nor does it
            --   respect locked items)
            collectible_id = math.random(CollectibleType.NUM_COLLECTIBLES)
        end
        Log("SpawnReward", "spawning collectible=%d", collectible_id)
        SpawnItem(PickupVariant.PICKUP_COLLECTIBLE, collectible_id)
    end
end

-- ---------------------------------------------------------------------
-- ON INIT

function mod:OnInit(player)
    -- TODO: determine if this breaks in co-op (2nd player init)
    local remaining, room_seed, cleared_rooms = self:LoadRemaining()
    if remaining then
        Log("OnInit", "remaining: %s", remaining)
        -- XXX: need to hook tick events to check if this is a new run
        --  (there doesn't appear to be a way to check in PLAYER_INIT because
        --   the level isn't fully initialized at this point and there is no
        --   apparent way to retreive the in-game run's seed which would be
        --   an easy way to compare)
        -- TODO: figure out a better way to determine if a new run has been
        --  started
        self:HookTickEvents()
        -- clear the cached required room value in case the player restarted
        self._rooms_remaining = nil

        -- create a callback that can be called from the POST_UPDATE handler
        self._check_is_new_run = function()
            local room = Game:GetRoom()
            room_seed = tonumber(room_seed)
            if room:GetSpawnSeed() ~= room_seed then
                Log("Initialize", "new game detected")
                self:RemoveRemaining()
            else
                Log("Initialize", "re-initializing previous state...")
                -- player exited & continued game
                -- re-initialize the saved values
                self._rooms_remaining = tonumber(remaining)
                if self._rooms_remaining then
                    self:HookTickEvents()
                end
                self._room_seed = room_seed
                self._num_room_enemies = room:GetAliveEnemiesCount()
                self:SpeedUp()

                local cleared = {}
                for room_id in cleared_rooms:gmatch("[^,]+") do
                    cleared[#cleared+1] = tonumber(room_id)
                end
                self._cleared_rooms = cleared

                local output = ("%d,"):rep(#cleared)
                output = output:sub(0, -2)
                Log("Initialize", "cleared rooms: %s",
                    output:format(table.unpack(cleared))
                )
            end
        end
    end
end

-- ---------------------------------------------------------------------
-- ON USE

function mod:OnPanicButtonUse(collectible_id, rng)
    Log("OnPanicButtonUse", "%d used", collectible_id)
    -- play the raise-over-head animation
    local player = Isaac.GetPlayer(0)
    player:AnimateCollectible(collectible_id, "UseItem", "PlayerPickup")
    -- remove the Panic Button
    player:RemoveCollectible(collectible_id)

    -- cache the required number of rooms to spawn the reward
    self._rooms_remaining = NUM_ROOMS_TO_CLEAR
    -- cache the room seed so we can detect when the player changes rooms
    local room = Game:GetRoom()
    self._room_seed = room:GetSpawnSeed()
    -- cache the number of enemies currently alive in the room
    self._num_room_enemies = room:GetAliveEnemiesCount()
    -- immediately cache this room in case it as already cleared before use
    self:TryCacheClearedRoom()
    self:SaveRemaining()
    self:SpeedUp()
    self:HookTickEvents()

    --[[
        TODO? increase player speed?
    -- trigger an EVALUATE_CACHE event
    -- player:EvaluateItems()
    --]]

    -- debugging
    -- self:SpawnReward()
end

-- ---------------------------------------------------------------------
-- ON EVALUATE CACHE (apply stat change)

local speed_up_applied = false
function mod:OnEvalCache(player, cache_flag)
    Log("OnEvalCache", "%d", cache_flag)
    if cache_flag == CacheFlag.CACHE_SPEED then
        if not speed_up_applied and self._rooms_remaining then
            Log("OnEvalCache", "speeding up player")
            player.MoveSpeed = player.MoveSpeed * 1.0
            speed_up_applied = true
        elseif speed_up_applied and not self._rooms_remaining then
            Log("OnEvalCache", "resetting player speed")
            player.MoveSpeed = player.MoveSpeed - 1.0
            speed_up_applied = false
        end
    end
end

-- ---------------------------------------------------------------------
-- ON TICK

function mod:OnUpdate()
    if self._rooms_remaining then
        local do_save = false
        local room = Game:GetRoom()
        local room_seed = room:GetSpawnSeed()

        if room_seed ~= self._room_seed then
            -- room changed
            Log("OnUpdate", "room changed")
            self._room_seed = room_seed
            self._num_room_enemies = room:GetAliveEnemiesCount()
            self:SpeedUp()
            -- flag that we need to save
            do_save = true
        end

        -- keep track of which rooms have been cleared
        -- to prevent counting the player backtracking as another cleared room
        if self:TryCacheClearedRoom() then
            Log("OnUpdate", "room cleared!")
            self._rooms_remaining = self._rooms_remaining - 1

            if self._rooms_remaining <= 0 then
                if self._rooms_remaining < 0 then
                    -- the number of rooms remaining became negative
                    -- (this shouldn't happen)
                    Log("OnUpdate", "***** remaining (%d) < 0 !!",
                        self._rooms_remaining
                    )
                end

                self:ResetSpeed()
                self:RemoveRemaining()
                self:SpawnReward()

                --[[
                -- TODO? increase player speed?
                -- trigger an EVALUATE_CACHE event
                local player = Isaac.GetPlayer(0)
                player:RemoveCollectible(CollectibleType.COLLECTIBLE_NULL)
                player:EvaluateItems()
                --]]
            else
                do_save = true
            end
        end

        if do_save then
            self:SaveRemaining()
        end
    elseif self._check_is_new_run then
        -- poll whether the level is initialized
        local level = Game:GetLevel()
        if level and level:GetStartingRoomIndex() >= 0 then
            -- level initialized => continue initialization
            self._check_is_new_run()
            self._check_is_new_run = nil
        end
    end
end

function mod:OnRender()
    local level = Game:GetLevel()
    local room = Game:GetRoom()
    Isaac.RenderText(
        ("BrokenWatchState: %s (%d)"):format(
            tostring(room:GetBrokenWatchState()), room:GetSpawnSeed()
        ),
        85, 50,
        0.0, 1.0, 0.0, 1.0
    )
    Isaac.RenderText(
        ("level.EnterDoor: %d, start idx: %d"):format(
            level.EnterDoor, level:GetStartingRoomIndex()
        ),
        85, 67,
        0.0, 1.0, 0.0, 1.0
    )
    Isaac.RenderText(
        ("IsAmbushActive? %s"):format(tostring(room:IsAmbushActive())),
        85, 85,
        0.0, 1.0, 0.0, 1.0
    )

    -- TODO: disable if in cutscene
    if self._rooms_remaining then
        -- draw the number of remaining rooms needed to spawn the reward
        local player = Isaac.GetPlayer(0)
        local room = Game:GetRoom()
        local pos = room:WorldToScreenPosition(player.Position, true)

        local rooms_remaining = self._rooms_remaining
        local text = ("%d!"):format(rooms_remaining)
        Isaac.RenderText(
            text,
            -- center the text over the player's head
            pos.X - (0.5 * text:len() * 5.5),
            pos.Y - (39 * player.SpriteScale.Y),
            1.0, -- red
            rooms_remaining / NUM_ROOMS_TO_CLEAR, -- green
            rooms_remaining / NUM_ROOMS_TO_CLEAR, -- blue
            -- XXX: do these values range from [0, 1]? setting alpha=1.0
            --  isn't fully opaque (but 2 seems to be)
            2 -- alpha
        )
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.OnInit)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.OnPanicButtonUse)
-- XXX: should the player's speed be increased?
-- mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.OnEvalCache)

