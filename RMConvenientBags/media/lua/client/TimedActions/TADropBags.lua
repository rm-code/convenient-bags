---
-- This feature is inspired by the Turn Tail mod originally developed by The_Real_Al.
--
require('TimedActions/ISBaseTimedAction');

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TIME_BACKPACK = 100;
local TIME_DEFAULT  =  50;

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

TADropBags = ISBaseTimedAction:derive('TADropBags');

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Calculates the time it takes to perform the timed action.
-- @param item - The item to drop.
-- @param player - The player who performs the TA.
--
local function calculateTime(item, player)
    if item == player:getClothingItem_Back() then
        return TIME_BACKPACK;
    end
    return TIME_DEFAULT;
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- The condition which tells the timed action if it is still valid.
--
function TADropBags:isValid()
    return self.character:getInventory():contains(self.item)
end

---
-- Stops the Timed Action.
--
function TADropBags:stop()
    ISBaseTimedAction.stop(self);
    self.item:setJobDelta(0.0);
end

---
-- Starts the Timed Action.
--
function TADropBags:start()
    self.item:setJobType("Dumping");
    self.item:setJobDelta(0.0);
end

---
-- Is called when the time has passed.
--
function TADropBags:perform()
    local item = self.item;
    local player = self.character;

    item:getContainer():setDrawDirty(true);
    item:setJobDelta(0.0);

    if item == player:getPrimaryHandItem() then
        player:setPrimaryHandItem(nil);
    elseif item == player:getSecondaryHandItem() then
        player:setSecondaryHandItem(nil);
    elseif item == player:getClothingItem_Back() then
        player:setClothingItem_Back(nil);
    end

    -- Drop the item to the floor and remove it from the inventory.
    player:getCurrentSquare():AddWorldInventoryItem(item, 0.0, 0.0, 0.0);
    player:getInventory():Remove(item);

    -- Make sure we refresh the inventory.
    local pdata = getPlayerData(player:getPlayerNum());
    if pdata then
        pdata.playerInventory:refreshBackpacks();
        pdata.lootInventory:refreshBackpacks();
    end

    ISBaseTimedAction.perform(self);
end

---
-- Constructor
-- @param character - The character who performs the action.
-- @param item - The container / bag top drop.
--
function TADropBags:new(character, item)
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.character = character;
    o.item = item;
    o.maxTime = calculateTime(item, character);
    o.stopOnWalk = false;
    o.stopOnRun = false;
    return o;
end
