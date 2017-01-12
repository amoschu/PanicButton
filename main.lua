--[[
    Item idea by /u/robtheimpure: https://www.reddit.com/5mledp
--]]

-- total number of rooms required to clear to trigger the completion reward
local NUM_ROOMS_TO_CLEAR = 10

-- reward range (inclusive)
local MIN_REWARDS = 5
local MAX_REWARDS = 6

-- pickup subtype weights
-- higher numbers have a higher chance to spawn
-- negative numbers and zero mean that the pickup type cannot spawn
local HEART_WEIGHTS = {
    [HeartSubType.HEART_FULL]       = 5,
    [HeartSubType.HEART_HALF]       = 3,
    [HeartSubType.HEART_DOUBLEPACK] = 2,
    [HeartSubType.HEART_SOUL]       = 1,
    [HeartSubType.HEART_ETERNAL]    = 0.5,
    [HeartSubType.HEART_BLACK]      = 0.5,
    [HeartSubType.HEART_GOLDEN]     = 1,
    [HeartSubType.HEART_HALF_SOUL]  = 2,
    [HeartSubType.HEART_SCARED]     = 2,
    [HeartSubType.HEART_BLENDED]    = 1,
}

local COIN_WEIGHTS = {
    [CoinSubType.COIN_PENNY]        = 5,
    [CoinSubType.COIN_NICKEL]       = 2,
    [CoinSubType.COIN_DIME]         = 1,
    [CoinSubType.COIN_DOUBLEPACK]   = 3,
    [CoinSubType.COIN_LUCKYPENNY]   = 1,
    [CoinSubType.COIN_STICKYNICKEL] = 1,
}

local KEY_WEIGHTS = {
    [KeySubType.KEY_NORMAL]     = 10,
    [KeySubType.KEY_DOUBLEPACK] = 2,
    [KeySubType.KEY_GOLDEN]     = 1,
    [KeySubType.KEY_CHARGED]    = 0.5,
}

local BOMB_WEIGHTS = {
    [BombSubType.BOMB_NORMAL]     = 5,
    [BombSubType.BOMB_DOUBLEPACK] = 2,
    [BombSubType.BOMB_TROLL]      = 2,
    [BombSubType.BOMB_GOLDEN]     = 1,
    [BombSubType.BOMB_SUPERTROLL] = 1,
}

local CHEST_WEIGHTS = {
    [PickupVariant.PICKUP_CHEST]        = 10,
    [PickupVariant.PICKUP_BOMBCHEST]    = 2,
    [PickupVariant.PICKUP_SPIKEDCHEST]  = 2,
    [PickupVariant.PICKUP_ETERNALCHEST] = 0.1,
    [PickupVariant.PICKUP_LOCKEDCHEST]  = 2,
    [PickupVariant.PICKUP_REDCHEST]     = 1,
}

local PILL_WEIGHTS = {
	[PillColor.PILL_BLUE_BLUE]        = 1,
	[PillColor.PILL_WHITE_BLUE]       = 1,
	[PillColor.PILL_ORANGE_ORANGE]    = 1,
	[PillColor.PILL_WHITE_WHITE]      = 1,
	[PillColor.PILL_REDDOTS_RED]      = 1,
	[PillColor.PILL_PINK_RED]         = 1,
	[PillColor.PILL_BLUE_CADETBLUE]   = 1,
	[PillColor.PILL_YELLOW_ORANGE]    = 1,
	[PillColor.PILL_ORANGEDOTS_WHITE] = 1,
	[PillColor.PILL_WHITE_AZURE]      = 1,
	[PillColor.PILL_BLACK_YELLOW]     = 1,
	[PillColor.PILL_WHITE_BLACK]      = 1,
	[PillColor.PILL_WHITE_YELLOW]     = 1,
}

local CARD_WEIGHTS = {
	[Card.CARD_FOOL]              = 5,
	[Card.CARD_MAGICIAN]          = 5,
	[Card.CARD_HIGH_PRIESTESS]    = 5,
	[Card.CARD_EMPRESS]           = 5,
	[Card.CARD_EMPEROR]           = 5,
	[Card.CARD_HIEROPHANT]        = 5,
	[Card.CARD_LOVERS]            = 5,
	[Card.CARD_CHARIOT]           = 5,
	[Card.CARD_JUSTICE]           = 5,
	[Card.CARD_HERMIT]            = 5,
	[Card.CARD_WHEEL_OF_FORTUNE]  = 5,
	[Card.CARD_STRENGTH]          = 5,
	[Card.CARD_HANGED_MAN]        = 5,
	[Card.CARD_DEATH]             = 5,
	[Card.CARD_TEMPERANCE]        = 5,
	[Card.CARD_DEVIL]             = 5,
	[Card.CARD_TOWER]             = 5,
	[Card.CARD_STARS]             = 5,
	[Card.CARD_MOON]              = 5,
	[Card.CARD_SUN]               = 5,
	[Card.CARD_JUDGEMENT]         = 5,
	[Card.CARD_WORLD]             = 5,
	[Card.CARD_CLUBS_2]           = 2,
	[Card.CARD_DIAMONDS_2]        = 2,
	[Card.CARD_SPADES_2]          = 2,
	[Card.CARD_HEARTS_2]          = 2,
	[Card.CARD_ACE_OF_CLUBS]      = 2,
	[Card.CARD_ACE_OF_DIAMONDS]   = 2,
	[Card.CARD_ACE_OF_SPADES]     = 2,
	[Card.CARD_ACE_OF_HEARTS]     = 2,
	[Card.CARD_JOKER]             = 2,
	[Card.RUNE_HAGALAZ]           = 1,
	[Card.RUNE_JERA]              = 1,
	[Card.RUNE_EHWAZ]             = 1,
	[Card.RUNE_DAGAZ]             = 1,
	[Card.RUNE_ANSUZ]             = 1,
	[Card.RUNE_PERTHRO]           = 1,
	[Card.RUNE_BERKANO]           = 1,
	[Card.RUNE_ALGIZ]             = 1,
	[Card.RUNE_BLANK]             = 1,
	[Card.RUNE_BLACK]             = 1,
	[Card.CARD_CHAOS]             = 1,
	[Card.CARD_CREDIT]            = 1,
	[Card.CARD_RULES]             = 1,
	[Card.CARD_HUMANITY]          = 1,
	[Card.CARD_SUICIDE_KING]      = 1,
	[Card.CARD_GET_OUT_OF_JAIL]   = 1,
	[Card.CARD_QUESTIONMARK]      = 1,
	[Card.CARD_DICE_SHARD]        = 1,
	[Card.CARD_EMERGENCY_CONTACT] = 1,
	[Card.CARD_HOLY]              = 1,
}

-- weights for each type of pickup
local PICKUP_WEIGHTS = {
    [PickupVariant.PICKUP_HEART] = {
        weight = 10,
        subtype_weights = HEART_WEIGHTS,
    },
    [PickupVariant.PICKUP_COIN] = {
        weight = 5,
        subtype_weights = COIN_WEIGHTS,
    },
    [PickupVariant.PICKUP_KEY] = {
        weight = 5,
        subtype_weights = KEY_WEIGHTS,
    },
    [PickupVariant.PICKUP_BOMB] = {
        weight = 5,
        subtype_weights = BOMB_WEIGHTS,
    },
    [PickupVariant.PICKUP_CHEST] = {
        weight = 1,
        subtype_weights = CHEST_WEIGHTS,
    },
    [PickupVariant.PICKUP_GRAB_BAG] = {
        weight = 2,
    },
    [PickupVariant.PICKUP_PILL] = {
        weight = 3,
        subtype_weights = PILL_WEIGHTS,
    },
    [PickupVariant.PICKUP_LIL_BATTERY] = {
        weight = 2,
    },
    [PickupVariant.PICKUP_TAROTCARD] = {
        weight = 3,
        subtype_weights = CARD_WEIGHTS,
    },
    [PickupVariant.PICKUP_TRINKET] = {
        weight = 1,
    },
}


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
-- CODE BELOW THIS LINE
-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------

-- turn on/off some debug functionality
local _DEBUG = false

local mod = RegisterMod("PanicButton", 1)
local Game = Game
if type(Game) == "function" then
    Game = Game()
end

local function Log(caller, fmt, ...)
    if _DEBUG then
        fmt = ("[%s:%s] %s"):format(mod.Name, caller, fmt)
        Isaac.DebugString(fmt:format(...))
    end
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
    self._cleared_rooms = nil
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

-- key added to the "constant" weight tables defined at the top of the file
local KEY_PROBABILITIES = "__probabilities"
local function NormalizeWeights(weights)
    if not weights[KEY_PROBABILITIES] then
        Log("NormalizeWeights", "normalizing weights to interval [0, 1]")
        local sum = 0
        for k, data in pairs(weights) do
            if type(data) == "number" then
                sum = sum + data
            elseif type(data) == "table" and data.weight then
                sum = sum + data.weight
            end
        end
        Log("NormalizeWeights", "\tsum: %0.2f", sum)

        local probabilities = {
            types = {},
        }
        local types = probabilities.types
        -- distribute the probabilities into biased ranges
        -- https://stackoverflow.com/a/479299
        for k, data in pairs(weights) do
            local v = nil
            if type(data) == "number" then
                v = data
            elseif type(data) == "table" and data.weight then
                v = data.weight
            else
                Log("NormalizeWeights", "\t%d: invalid weight (%s)",
                    k, tostring(data)
                )
            end

            if v then
                types[#types+1] = k
                probabilities[#probabilities+1] = v / sum
                Log("NormalizeWeights", "\t%d: %0.2f -> %f",
                    k, v, probabilities[#probabilities]
                )
            end
        end

        weights[KEY_PROBABILITIES] = probabilities
    end
end

local function Roll(weights)
    NormalizeWeights(weights)

    local roll = math.random()
    local sum = 0
    Log("Roll", "%f", roll)
    local types = weights[KEY_PROBABILITIES].types
    for i, probability in pairs(weights[KEY_PROBABILITIES]) do
        local type_ = types[i]
        sum = sum + probability
        Log("Roll", "type: %d, sum: %f (prob: %f)", type_, sum, probability)
        if roll < sum then
            Log("Roll", "rolled %d!", type_)
            return type_
        end
    end
    -- I'm 99% sure this can't happen
    -- (math.random() -> [0, 1) whereas sum should always == 1.0 by the final
    --  iteration)
    Log("Roll", "!!!!! failed")
end

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
    -- XXX: does this enforce spawns to respect the run's seed?
    math.randomseed(Game:GetRoom():GetSpawnSeed())
    -- roll to determine the total number of pickups to spawn
    local num_pickups = math.random(MIN_REWARDS, MAX_REWARDS)
    for i = 1, num_pickups do
        pickup_type = Roll(PICKUP_WEIGHTS)
        subtype = 0
        if PICKUP_WEIGHTS[pickup_type].subtype_weights then
            subtype = Roll(PICKUP_WEIGHTS[pickup_type].subtype_weights)
        end
        -- special cases
        if pickup_type == PickupVariant.PICKUP_CHEST then
            -- chest "subtypes" are actually `PickupVariant`s
            pickup_type = subtype
            subtype = 0
        end

        Log("SpawnReward", "(%d/%d) type: %d, subtype: %d",
            i, num_pickups, pickup_type, subtype
        )
        SpawnItem(pickup_type, subtype)
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
                -- XXX: this breaks if the player resets a seeded run from
                --  the starting room
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
            Log("OnUpdate", "room changed (%d -> %d)",
                self._room_seed, room_seed
            )
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
    if _DEBUG then
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
            ("IsAmbushActive? %s"):format(tostring(room:IsAmbushActive())),
            85, 85,
            0.0, 1.0, 0.0, 1.0
        )
    end

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
local collectible_panicbutton = Isaac.GetItemIdByName("Panic Button")
mod:AddCallback(
    ModCallbacks.MC_USE_ITEM, mod.OnPanicButtonUse, collectible_panicbutton
)
-- XXX: should the player's speed be increased?
-- mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.OnEvalCache)

