require('Mods/UnpackBags/TimedActions/TAUnpackBag');
require('TimedActions/ISTimedActionQueue');
require('TimedActions/ISInventoryTransferAction');
require('luautils');

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MENU_ENTRY_TEXT_ONE = getText('UI_menu_entry_one');
local MENU_ENTRY_TEXT_MUL = getText('UI_menu_entry_multi');
local MENU_ENTRY_PACKING  = getText('UI_menu_entry_packing');
local MODAL_WARNING_TEXT  = getText('UI_warning_modal');

-- The factors for calculating the timed action durations for both
-- the normal and the partial unpacking.
local DURATION_DEFAULT_FACTOR = 2.5;
local DURATION_PARTIAL_FACTOR = 3.5;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Converts a java arrayList to a lua table.
--
-- @param arrayList - The arrayList to convert.
--
local function convertArrayList(arrayList)
    local itemTable = {};

    for i = 1, arrayList:size() do
        itemTable[i] = arrayList:get(i - 1);
    end

    return itemTable;
end

---
-- Creates the timed action which empties the bag.
-- @param items - A table containing the clicked items / stack.
-- @param player - The player who clicked the menu.
-- @param itemsInBag - The items contained in the bag.
-- @param bag - The bag to unpack.
--
local function onUnpackBag(items, player, itemsInBag, bag)
    local container = bag:getContainer();

    -- Display a warning and abort the unpacking if the next item in the bag doesn't fit into the container.
    if container:getMaxWeight() < itemsInBag[1]:getActualWeight() + container:getCapacityWeight() then
        luautils.okModal(MODAL_WARNING_TEXT, true);
        return;
    end

    -- Partially unpacking a bag will have a longer timed action to represent how the player is emptying the bag
    -- more carefully. The duration of the TimedAction also depends on the amount of items in the bag.
    local duration;
    if container:getMaxWeight() < (bag:getInventory():getCapacityWeight() + container:getCapacityWeight()) then
        duration = #itemsInBag * DURATION_PARTIAL_FACTOR;
    else
        duration = #itemsInBag * DURATION_DEFAULT_FACTOR;
    end
    ISTimedActionQueue.add(TAUnpackBag:new(player, itemsInBag, bag, duration));
end

---
-- Creates the timed action which empties the bag.
-- @param items - A table containing the clicked items / stack.
-- @param player - The player who clicked the menu.
-- @param itemsInContainer - The items contained in the bag.
-- @param bag - The bag to unpack.
--
local function onPackBag(items, player, itemsInContainer, bag)
    for i = 1, #itemsInContainer do
        local item = itemsInContainer[i];
        if instanceof(item, 'InventoryItem') and not instanceof(item, 'InventoryContainer') and not player:isEquipped(item) then
            ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, bag:getContainer(), bag:getInventory()));
        end
    end
end

---
-- Creates the actual menu entry
-- @param item - The bag item.
-- @param itemTable - A table containing the clicked items / stack.
-- @param player - The player who clicked the menu.
-- @param context - The context menu to add a new option to.
-- @paran func - The function to execute when the menu is clicked.
--
local function createMenuEntry(item, itemTable, player, context)
    if instanceof(item, 'InventoryItem') and instanceof(item, 'InventoryContainer') then
        local itemsInBag = convertArrayList(item:getInventory():getItems());
        if #itemsInBag == 1 then
            context:addOption(MENU_ENTRY_TEXT_ONE, itemTable, onUnpackBag, player, itemsInBag, item);
        elseif #itemsInBag > 1 then
            context:addOption(string.format(MENU_ENTRY_TEXT_MUL, #itemsInBag), itemTable, onUnpackBag, player, itemsInBag, item);
        end

        local itemsInContainer = convertArrayList(item:getContainer():getItems());
        context:addOption(MENU_ENTRY_PACKING, itemTable, onPackBag, player, itemsInContainer, item);
    end
end

---
-- Creates a context menu entry when the player selects
-- an inventory container (e.g. hiking bag).
-- @param player - The player who clicked the menu.
-- @param context - The context menu to add a new option to.
-- @param itemTable - A table containing the clicked items / stack.
--
local function createInventoryMenu(player, context, itemTable)
    local player = getSpecificPlayer(player);

    -- We iterate through the table of clicked items. We have
    -- to seperate between single items, stacks and expanded
    -- stacks.
    for i1 = 1, #itemTable do
        local item = itemTable[i1];
        if type(item) == 'table' then
            -- We start to iterate at the second index to jump over the dummy
            -- item that is contained in the item-table.
            for i2 = 2, #item.items do
                createMenuEntry(item.items[i2], itemTable, player, context);
            end
        else
            createMenuEntry(item, itemTable, player, context);
        end
    end
end

---
-- Creates a world context menu when the player selects and item on the floor.
-- @param player - The player who opened the menu.
-- @param context - The menu to add a new option to.
-- @param worldobjects - A table containing the world objects on the tile.
--
local function createWorldContextMenu(player, context, worldobjects)
    local player = getSpecificPlayer(player);

    for _, object in ipairs(worldobjects) do
        if instanceof(object, 'IsoWorldInventoryObject') then
            createUnpackingMenuEntry(object:getItem(), worldobjects, player, context, onUnpackBag);
        end
    end
end

-- ------------------------------------------------
-- Game Hooks
-- ------------------------------------------------

Events.OnPreFillInventoryObjectContextMenu.Add(createInventoryMenu);
Events.OnFillWorldObjectContextMenu.Add(createWorldContextMenu);