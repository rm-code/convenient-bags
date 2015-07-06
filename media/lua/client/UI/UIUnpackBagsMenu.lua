require('Mods/UnpackBags/TimedActions/TAUnpackBag');
require('TimedActions/ISTimedActionQueue');

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MENU_ENTRY_TEXT_ONE = getText('UI_menu_entry_one');
local MENU_ENTRY_TEXT_MUL = getText('UI_menu_entry_multi');
local MODAL_WARNING_TEXT  = getText('UI_warning_modal');

-- The factors for calculating the timed action durations for both
-- the normal and the partial unpacking.
local DURATION_DEFAULT_FACTOR = 2.5;
local DURATION_PARTIAL_FACTOR = 3.5;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Shows a modal window that informs the player about something and only has
-- an okay button to be closed.
--
-- @param txt - The text to display on the modal.
-- @param centered - If set to true the modal will be centered (optional).
-- @param w - The width of the window (optional).
-- @param h - The height of the window (optional).
-- @param x - The x position of the modal (optional).
-- @param y - The y position of the modal (optional).
--
local function showOkModal(txt, centered, w, h, x, y)
    local x, y = x or 0, y or 0;
    local w, h = w or 230, h or 120;
    local core = getCore();

    -- center the modal if necessary
    if centered then
        x = core:getScreenWidth() * 0.5 - w * 0.5;
        y = core:getScreenHeight() * 0.5 - h * 0.5;
    end

    local modal = ISModalDialog:new(x, y, w, h, txt);
    modal.backgroundColor = { r = 1.0, g = 0.0, b = 0.0, a = 0.5 };
    modal:initialise();
    modal:addToUIManager();
end

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
-- @param itemsInContainer - The items contained in the bag.
-- @param bag - The bag to unpack.
--
local function onUnpackBag(items, player, itemsInContainer, bag)
    local container = bag:getContainer();

    -- Display a warning and abort the unpacking if the next item in the bag doesn't fit into the container.
    if container:getMaxWeight() < itemsInContainer[1]:getActualWeight() + container:getCapacityWeight() then
        showOkModal(MODAL_WARNING_TEXT, true);
        return;
    end

    -- Partially unpacking a bag will have a longer timed action to represent how the player is emptying the bag
    -- more carefully. The duration of the TimedAction also depends on the amount of items in the bag.
    local duration;
    if container:getMaxWeight() < (bag:getInventory():getCapacityWeight() + container:getCapacityWeight()) then
        duration = #itemsInContainer * DURATION_PARTIAL_FACTOR;
    else
        duration = #itemsInContainer * DURATION_DEFAULT_FACTOR;
    end
    ISTimedActionQueue.add(TAUnpackBag:new(player, itemsInContainer, bag, duration));
end

---
-- Creates the actual menu entry
-- @param item - The bag item.
-- @param itemTable - A table containing the clicked items / stack.
-- @param player - The player who clicked the menu.
-- @param context - The context menu to add a new option to.
--
local function createMenuEntry(item, itemTable, player, context)
    if instanceof(item, 'InventoryItem') and instanceof(item, 'InventoryContainer') then
        local itemsInContainer = convertArrayList(item:getInventory():getItems());
        if #itemsInContainer == 1 then
            context:addOption(MENU_ENTRY_TEXT_ONE, itemTable, onUnpackBag, player, itemsInContainer, item);
        elseif #itemsInContainer > 1 then
            context:addOption(string.format(MENU_ENTRY_TEXT_MUL, #itemsInContainer), itemTable, onUnpackBag, player, itemsInContainer, item);
        end
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

-- ------------------------------------------------
-- Game Hooks
-- ------------------------------------------------

Events.OnPreFillInventoryObjectContextMenu.Add(createInventoryMenu);
