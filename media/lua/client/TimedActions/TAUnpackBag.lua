require('TimedActions/ISBaseTimedAction');

-- ------------------------------------------------
-- Global Variables
-- ------------------------------------------------

TAUnpackBag = ISBaseTimedAction:derive('TAUnpackBag');

-- ------------------------------------------------
-- Functions
-- ------------------------------------------------

---
-- The condition which tells the timed action if it
-- is still valid.
--
function TAUnpackBag:isValid()
    return true;
end

---
-- Stops the Timed Action.
--
function TAUnpackBag:stop()
    ISBaseTimedAction.stop(self);
end

---
-- Starts the Timed Action.
--
function TAUnpackBag:start()
end

---
-- Is called when the time has passed.
--
function TAUnpackBag:perform()
    local player = self.character;
    local bag = self.bag;
    local inventory = bag:getInventory(); -- Get the bag's inventory.
    local container = bag:getContainer(); -- Get the container in which the bag itself is contained.

    -- Remove all items from the baggage container.
    inventory:removeAllItems();

    -- Now we move all the items from the bag to the container.
    container:setDrawDirty(true);

    for _, item in ipairs(self.itemsInBag) do
        if item then
            -- If the floor is selected add the items to the ground.
            if container:getType() == 'floor' then
                bag:getWorldItem():getSquare():AddWorldInventoryItem(item, 0.0, 0.0, 0.0);
            else
                container:AddItem(item);
            end
        end
    end

    -- Make sure we refresh the inventory so the items show up.
    local pdata = getPlayerData(player:getPlayerNum());
    if pdata then
        pdata.playerInventory:refreshBackpacks();
        pdata.lootInventory:refreshBackpacks();
    end

    -- Remove Timed Action from stack.
    ISBaseTimedAction.perform(self);
end

---
-- Constructor
-- @param character - The character who performs the action.
-- @param iTable - The table containing all items in the bag.
-- @param bag - The container / bag itself.
-- @param time - The time to complete the action.
--
function TAUnpackBag:new(character, iTable, bag, time)
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.character = character;
    o.bag = bag;
    o.itemsInBag = iTable;
    o.stopOnWalk = false;
    o.stopOnRun = false;
    o.maxTime = time;
    return o;
end
